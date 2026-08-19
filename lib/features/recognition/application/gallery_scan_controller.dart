import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../gallery/gallery_source.dart';
import '../gallery/gallery_types.dart';
import '../parsing/coupon_parser.dart';

/// 갤러리에서 찾아낸 기프티콘 후보 한 장.
class ScanCandidate {
  const ScanCandidate({
    required this.image,
    required this.parsed,
    this.selected = true,
  });

  final GalleryImage image;
  final ParsedCoupon parsed;
  final bool selected;

  ScanCandidate copyWith({bool? selected}) => ScanCandidate(
    image: image,
    parsed: parsed,
    selected: selected ?? this.selected,
  );
}

sealed class GalleryScanState {
  const GalleryScanState();
}

class GalleryScanIdle extends GalleryScanState {
  const GalleryScanIdle();
}

class GalleryScanUnsupported extends GalleryScanState {
  const GalleryScanUnsupported();
}

class GalleryScanPermissionDenied extends GalleryScanState {
  const GalleryScanPermissionDenied();
}

class GalleryScanRunning extends GalleryScanState {
  const GalleryScanRunning({
    required this.scanned,
    required this.total,
    required this.found,
  });

  final int scanned;
  final int total;
  final int found;

  double get progress => total == 0 ? 0 : scanned / total;
}

class GalleryScanDone extends GalleryScanState {
  const GalleryScanDone({
    required this.candidates,
    required this.scannedCount,
    this.limitedPermission = false,
  });

  final List<ScanCandidate> candidates;
  final int scannedCount;

  /// iOS "선택한 사진만 허용" 상태였는가. 결과가 적을 때 이유를 설명해야 한다.
  final bool limitedPermission;

  int get selectedCount => candidates.where((c) => c.selected).length;
}

class GalleryScanFailed extends GalleryScanState {
  const GalleryScanFailed(this.message);
  final String message;
}

/// 최근 사진을 훑어 기프티콘 후보를 골라낸다.
///
/// 전량 스캔이 아니라 최근 [_scanLimit]장만 본다. 사용자는 보통 최근에 받은
/// 쿠폰을 등록하려 하고, 수천 장에 OCR을 돌리면 배터리와 시간이 감당이 안 된다.
class GalleryScanController extends Notifier<GalleryScanState> {
  static const _scanLimit = 60;

  @override
  GalleryScanState build() => const GalleryScanIdle();

  Future<void> start() async {
    if (!ref.read(scannerSupportedProvider)) {
      state = const GalleryScanUnsupported();
      return;
    }

    final source = GallerySource();
    final permission = await source.ensurePermission();

    switch (permission) {
      case GalleryPermission.unsupported:
        state = const GalleryScanUnsupported();
        return;
      case GalleryPermission.denied:
        state = const GalleryScanPermissionDenied();
        return;
      case GalleryPermission.granted:
      case GalleryPermission.limited:
        break;
    }

    try {
      final images = await source.recentImages(limit: _scanLimit);
      state = GalleryScanRunning(scanned: 0, total: images.length, found: 0);

      final scanner = ref.read(couponScannerProvider);
      final parser = ref.read(couponParserProvider);
      final candidates = <ScanCandidate>[];

      for (var i = 0; i < images.length; i++) {
        final image = images[i];
        try {
          final scan = await scanner.scan(image.path);
          final parsed = parser.parse(scan);
          if (_looksLikeCoupon(parsed)) {
            candidates.add(ScanCandidate(image: image, parsed: parsed));
          }
        } on Exception {
          // 한 장이 실패해도 전체 스캔은 계속한다. 손상된 이미지나 지원하지 않는
          // 포맷이 섞여 있을 수 있다.
        }
        state = GalleryScanRunning(
          scanned: i + 1,
          total: images.length,
          found: candidates.length,
        );
      }

      state = GalleryScanDone(
        candidates: candidates,
        scannedCount: images.length,
        limitedPermission: permission == GalleryPermission.limited,
      );
    } on Exception catch (error) {
      state = GalleryScanFailed(
        '사진을 읽는 중 문제가 생겼습니다. ($error)\n'
        '다시 시도하거나 “사진 한 장 선택”으로 등록해주세요.',
      );
    }
  }

  void toggle(String imageId) {
    final current = state;
    if (current is! GalleryScanDone) return;
    state = GalleryScanDone(
      candidates: [
        for (final candidate in current.candidates)
          candidate.image.id == imageId
              ? candidate.copyWith(selected: !candidate.selected)
              : candidate,
      ],
      scannedCount: current.scannedCount,
      limitedPermission: current.limitedPermission,
    );
  }

  void setAllSelected(bool selected) {
    final current = state;
    if (current is! GalleryScanDone) return;
    state = GalleryScanDone(
      candidates: [
        for (final candidate in current.candidates)
          candidate.copyWith(selected: selected),
      ],
      scannedCount: current.scannedCount,
      limitedPermission: current.limitedPermission,
    );
  }

  /// 기프티콘으로 볼 만한가.
  ///
  /// 기준을 느슨하게 잡으면 셀카까지 목록에 올라오고, 빡빡하게 잡으면 정작
  /// 등록하려던 쿠폰을 놓친다. 바코드가 있으면 거의 확실하고, 없더라도
  /// 브랜드와 유효기간이 함께 잡히면 후보로 올린다.
  bool _looksLikeCoupon(ParsedCoupon parsed) {
    if (parsed.barcode != null && parsed.barcode!.isNotEmpty) return true;
    return parsed.brand != null && parsed.expiresAt != null;
  }
}

final galleryScanControllerProvider =
    NotifierProvider<GalleryScanController, GalleryScanState>(
      GalleryScanController.new,
    );
