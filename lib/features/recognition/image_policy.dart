/// 쿠폰 이미지로 받아들일지 판정한다.
///
/// 검사를 OCR **앞에** 두는 이유: 40MB 파노라마나 깨진 파일을 인식기에 그대로
/// 넣으면 시간과 배터리만 쓰고 실패한다. 헤더만 읽어 미리 걸러낸다.
///
/// 원본은 절대 변형하지 않는다. 이 파일은 판정만 하고, 저장은 호출자가 한다.
library;

import 'dart:typed_data';

import 'image_probe.dart';

enum ImageRejection {
  empty('파일이 비어 있습니다.'),
  unsupportedFormat('지원하지 않는 이미지 형식입니다. JPG, PNG, WebP, HEIC만 등록할 수 있습니다.'),
  tooLarge('이미지 용량이 너무 큽니다.'),
  tooSmall('이미지가 너무 작아 글자를 읽을 수 없습니다.'),
  tooManyPixels('이미지 해상도가 너무 큽니다.');

  const ImageRejection(this.baseMessage);

  /// 사용자에게 보여줄 기본 문구. 정책값이 들어가는 항목은
  /// [CouponImagePolicy.messageFor]에서 수치를 채워 넣는다.
  final String baseMessage;
}

sealed class ImageInspection {
  const ImageInspection();
}

final class ImageAccepted extends ImageInspection {
  const ImageAccepted({
    required this.format,
    required this.byteLength,
    this.width,
    this.height,
  });

  final ImageFormat format;
  final int byteLength;
  final int? width;
  final int? height;
}

final class ImageRejected extends ImageInspection {
  const ImageRejected(this.reason, this.message);

  final ImageRejection reason;

  /// 무엇이 문제고 어떻게 하면 되는지까지 담은 한국어 문구.
  final String message;
}

class CouponImagePolicy {
  const CouponImagePolicy();

  /// 기프티콘 캡처는 보통 1MB 안쪽이다. 20MB면 고화질 원본 사진까지 넉넉히
  /// 받아들이면서 파노라마·연사 원본은 걸러낸다.
  static const int maxBytes = 20 * 1024 * 1024;

  /// 이보다 작으면 바코드 선이 뭉개져 OCR·스캐너 모두 실패한다.
  static const int minSide = 200;

  /// 한 변이 이보다 길면 기프티콘 캡처가 아니라 다른 사진일 가능성이 높고,
  /// ML Kit도 내부적으로 축소하느라 시간만 더 쓴다.
  static const int maxSide = 12000;

  /// 헤더를 읽기에 충분한 길이. 호출자는 파일 앞부분을 이만큼만 읽으면 된다.
  static const int headerBytes = 64 * 1024;

  /// [byteLength]는 파일 전체 크기, [header]는 파일 앞부분 바이트.
  ImageInspection inspect({
    required int byteLength,
    required Uint8List header,
  }) {
    if (byteLength <= 0 || header.isEmpty) {
      return ImageRejected(
        ImageRejection.empty,
        messageFor(ImageRejection.empty),
      );
    }

    // 용량을 형식보다 먼저 본다. 거대한 파일은 헤더를 읽는 것 자체가 낭비다.
    if (byteLength > maxBytes) {
      return ImageRejected(
        ImageRejection.tooLarge,
        messageFor(ImageRejection.tooLarge),
      );
    }

    final probed = ImageProbe.probe(header);
    if (probed == null) {
      return ImageRejected(
        ImageRejection.unsupportedFormat,
        messageFor(ImageRejection.unsupportedFormat),
      );
    }

    // 크기를 못 읽는 경우가 있다(주로 HEIC). 형식이 확실하면 통과시킨다.
    // 여기서 반려하면 아이폰 기본 촬영 사진을 못 쓰게 되어 손해가 더 크다.
    final width = probed.width;
    final height = probed.height;
    if (width != null && height != null) {
      final shortSide = width < height ? width : height;
      final longSide = width > height ? width : height;

      if (shortSide < minSide) {
        return ImageRejected(
          ImageRejection.tooSmall,
          messageFor(ImageRejection.tooSmall),
        );
      }
      if (longSide > maxSide) {
        return ImageRejected(
          ImageRejection.tooManyPixels,
          messageFor(ImageRejection.tooManyPixels),
        );
      }
    }

    return ImageAccepted(
      format: probed.format,
      byteLength: byteLength,
      width: width,
      height: height,
    );
  }

  /// 정책 수치가 들어간 안내 문구를 만든다.
  /// 오류 메시지는 원인과 해결 방법을 함께 담는다 (AGENTS.md 5절).
  String messageFor(ImageRejection reason) => switch (reason) {
    ImageRejection.empty => '파일이 비어 있습니다. 다른 이미지를 선택해주세요.',
    ImageRejection.unsupportedFormat =>
      '${reason.baseMessage} 스크린샷으로 다시 저장한 뒤 등록해보세요.',
    ImageRejection.tooLarge =>
      '이미지 용량이 ${maxBytes ~/ (1024 * 1024)}MB를 넘습니다. '
          '기프티콘 부분만 잘라내거나 화면을 캡처해서 등록해주세요.',
    ImageRejection.tooSmall =>
      '이미지가 너무 작습니다. 가로·세로 모두 ${minSide}px 이상이어야 '
          '바코드와 글자를 읽을 수 있습니다.',
    ImageRejection.tooManyPixels =>
      '이미지 한 변이 ${maxSide}px를 넘습니다. 기프티콘 부분만 잘라내서 등록해주세요.',
  };
}
