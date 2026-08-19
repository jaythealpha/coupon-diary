import 'dart:typed_data';

import '../../domain/model/coupon.dart';
import '../../domain/repository/coupon_repository.dart';
import 'backup_codec.dart';

/// 복원 결과 요약. 사용자에게 무엇이 들어왔는지 알려준다.
class RestoreSummary {
  const RestoreSummary({required this.imported, required this.skipped});

  /// 새로 들어온 쿠폰 수.
  final int imported;

  /// 이미 있어서 건너뛴 쿠폰 수.
  final int skipped;
}

sealed class RestoreResult {
  const RestoreResult();
}

final class RestoreSucceeded extends RestoreResult {
  const RestoreSucceeded(this.summary);
  final RestoreSummary summary;
}

final class RestoreFailed extends RestoreResult {
  const RestoreFailed(this.message);
  final String message;
}

/// 백업 만들기와 복원.
class BackupService {
  BackupService(this._repository, {BackupCodec? codec})
    : _codec = codec ?? BackupCodec();

  final CouponRepository _repository;
  final BackupCodec _codec;

  /// 모든 상태의 쿠폰을 담는다. 만료·사용 완료도 포함 —
  /// 만료 쿠폰은 환불 근거가 되므로 백업에서 빠지면 안 된다.
  Future<Uint8List> createBackup(String password) async {
    final coupons = <Coupon>[];
    for (final status in CouponStatus.values) {
      final list = await _repository
          .watchCoupons(CouponQuery(statuses: {status}))
          .first;
      coupons.addAll(list);
    }

    final usage = <UsageEntry>[];
    for (final coupon in coupons) {
      usage.addAll(await _repository.watchUsage(coupon.id).first);
    }

    return _codec.encode(
      BackupPayload(coupons: coupons, usage: usage),
      password,
    );
  }

  /// 백업을 현재 데이터에 **병합**한다.
  ///
  /// 덮어쓰기가 아니라 병합인 이유: 복원은 보통 "새 폰에 옮기기"거나
  /// "실수로 지운 것 되살리기"다. 두 경우 모두 현재 데이터를 지우면 사고가 된다.
  /// 같은 id가 이미 있으면 기기의 것을 남기고 백업 쪽을 건너뛴다 —
  /// 기기 쪽이 더 최신 사용 이력을 들고 있을 가능성이 높다.
  Future<RestoreResult> restore(Uint8List bytes, String password) async {
    final decoded = await _codec.decode(bytes, password);
    if (decoded is BackupDecodeFailed) {
      return RestoreFailed(decoded.error.message);
    }
    final payload = (decoded as BackupDecoded).payload;

    var imported = 0;
    var skipped = 0;
    final importedCouponIds = <String>{};

    for (final coupon in payload.coupons) {
      final existing = await _repository.findById(coupon.id);
      if (existing != null) {
        skipped++;
        continue;
      }
      await _repository.save(coupon);
      importedCouponIds.add(coupon.id);
      imported++;
    }

    // 사용 이력은 새로 들어온 쿠폰의 것만 넣는다. 기존 쿠폰에 백업의 옛
    // 이력을 더하면 잔액이 이중 차감된다.
    for (final entry in payload.usage) {
      if (!importedCouponIds.contains(entry.couponId)) continue;
      await _repository.addUsage(entry);
    }

    return RestoreSucceeded(
      RestoreSummary(imported: imported, skipped: skipped),
    );
  }
}
