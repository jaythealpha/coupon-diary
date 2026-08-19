import 'dart:typed_data';

import 'package:coupon_diary/data/repository/in_memory_coupon_repository.dart';
import 'package:coupon_diary/domain/model/coupon.dart';
import 'package:coupon_diary/features/backup/backup_codec.dart';
import 'package:coupon_diary/features/backup/backup_service.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';

Coupon coupon({
  required String id,
  String brand = '스타벅스',
  CouponKind kind = CouponKind.exchange,
  CouponStatus status = CouponStatus.active,
  int? faceValue,
  int? balance,
  String? barcode,
}) {
  final now = DateTime(2026, 7, 1);
  return Coupon(
    id: id,
    brand: brand,
    productName: '테스트 상품',
    kind: kind,
    status: status,
    category: CouponCategory.cafe,
    createdAt: now,
    updatedAt: now,
    barcode: barcode,
    barcodeFormat: BarcodeFormat.code128,
    expiresAt: DateTime(2026, 12, 31),
    faceValue: faceValue,
    balance: balance,
  );
}

/// 테스트에서는 KDF 반복을 줄인다. 210k회는 형식 검증에 필요 없고 느리기만 하다.
BackupCodec fastCodec() =>
    BackupCodec(kdf: Pbkdf2.hmacSha256(iterations: 10, bits: 256));

void main() {
  group('암호화 왕복', () {
    test('encode → decode 왕복이 데이터를 보존한다', () async {
      final codec = fastCodec();
      final payload = BackupPayload(
        coupons: [
          coupon(id: 'a', barcode: '8801234567890'),
          coupon(
            id: 'b',
            kind: CouponKind.amount,
            faceValue: 30000,
            balance: 17500,
            status: CouponStatus.active,
          ),
        ],
        usage: [
          UsageEntry(
            id: 'u1',
            couponId: 'b',
            amount: 12500,
            usedAt: DateTime(2026, 7, 15),
            place: '강남점',
          ),
        ],
      );

      final bytes = await codec.encode(payload, '올바른 암호');
      final decoded = await codec.decode(bytes, '올바른 암호');

      expect(decoded, isA<BackupDecoded>());
      final restored = (decoded as BackupDecoded).payload;
      expect(restored.coupons.length, 2);
      expect(restored.coupons[0].barcode, '8801234567890');
      expect(restored.coupons[1].faceValue, 30000);
      expect(restored.coupons[1].balance, 17500);
      expect(restored.usage.single.amount, 12500);
      expect(restored.usage.single.place, '강남점');
    });

    test('틀린 암호는 복호화되지 않는다', () async {
      final codec = fastCodec();
      final bytes = await codec.encode(
        BackupPayload(
          coupons: [coupon(id: 'a', barcode: '12345678')],
          usage: const [],
        ),
        '진짜 암호',
      );

      final decoded = await codec.decode(bytes, '틀린 암호');

      expect(decoded, isA<BackupDecodeFailed>());
      expect(
        (decoded as BackupDecodeFailed).error,
        BackupDecodeError.wrongPasswordOrCorrupted,
      );
    });

    test('바코드가 평문으로 노출되지 않는다', () async {
      // 이 테스트가 실패하면 백업 파일이 사실상 평문이라는 뜻이다. 절대 스킵 금지.
      final codec = fastCodec();
      const barcode = '8809998877665';
      final bytes = await codec.encode(
        BackupPayload(
          coupons: [coupon(id: 'a', barcode: barcode)],
          usage: const [],
        ),
        '암호',
      );

      final asLatin = String.fromCharCodes(bytes);
      expect(asLatin.contains(barcode), isFalse);
      // JSON 구조 자체도 보이면 안 된다.
      expect(asLatin.contains('"barcode"'), isFalse);
      expect(asLatin.contains('스타벅스'), isFalse);
    });

    test('한 바이트만 손상돼도 복호화가 거부된다', () async {
      final codec = fastCodec();
      final bytes = await codec.encode(
        BackupPayload(
          coupons: [coupon(id: 'a')],
          usage: const [],
        ),
        '암호',
      );

      final tampered = Uint8List.fromList(bytes);
      tampered[tampered.length ~/ 2] ^= 0xFF;

      final decoded = await codec.decode(tampered, '암호');
      expect(
        (decoded as BackupDecodeFailed).error,
        BackupDecodeError.wrongPasswordOrCorrupted,
      );
    });

    test('백업 파일이 아닌 바이트는 형식 오류로 알린다', () async {
      final codec = fastCodec();
      final decoded = await codec.decode(
        Uint8List.fromList(List.filled(100, 0x41)),
        '암호',
      );
      expect(
        (decoded as BackupDecodeFailed).error,
        BackupDecodeError.notABackup,
      );
    });

    test('미래 버전 백업은 업데이트 안내를 낸다', () async {
      final codec = fastCodec();
      final bytes = await codec.encode(
        BackupPayload(coupons: const [], usage: const []),
        '암호',
      );
      final future = Uint8List.fromList(bytes);
      future[7] = '9'.codeUnitAt(0); // CPDBAK01 → CPDBAK09

      final decoded = await codec.decode(future, '암호');
      expect(
        (decoded as BackupDecodeFailed).error,
        BackupDecodeError.newerVersion,
      );
    });

    test('같은 내용을 두 번 백업해도 파일이 다르다 (salt·nonce 난수)', () async {
      final codec = fastCodec();
      final payload = BackupPayload(
        coupons: [coupon(id: 'a')],
        usage: const [],
      );

      final first = await codec.encode(payload, '암호');
      final second = await codec.encode(payload, '암호');

      expect(first, isNot(equals(second)));
    });
  });

  group('복원 병합', () {
    test('새 쿠폰은 들어오고 기존 쿠폰은 건너뛴다', () async {
      final source = InMemoryCouponRepository(
        seed: [
          coupon(id: 'a'),
          coupon(id: 'b'),
        ],
      );
      addTearDown(source.dispose);
      final backupBytes = await BackupService(
        source,
        codec: fastCodec(),
      ).createBackup('암호');

      final target = InMemoryCouponRepository(seed: [coupon(id: 'a')]);
      addTearDown(target.dispose);
      final result = await BackupService(
        target,
        codec: fastCodec(),
      ).restore(backupBytes, '암호');

      final summary = (result as RestoreSucceeded).summary;
      expect(summary.imported, 1);
      expect(summary.skipped, 1);
      expect(await target.findById('b'), isNotNull);
    });

    test('금액권 사용 이력까지 복원되고 잔액이 다시 계산된다', () async {
      final source = InMemoryCouponRepository(
        seed: [
          coupon(
            id: 'm',
            kind: CouponKind.amount,
            faceValue: 30000,
            balance: 30000,
          ),
        ],
      );
      addTearDown(source.dispose);
      await source.addUsage(
        UsageEntry(
          id: 'u1',
          couponId: 'm',
          amount: 12000,
          usedAt: DateTime(2026, 7, 10),
        ),
      );
      final bytes = await BackupService(
        source,
        codec: fastCodec(),
      ).createBackup('암호');

      final target = InMemoryCouponRepository();
      addTearDown(target.dispose);
      await BackupService(target, codec: fastCodec()).restore(bytes, '암호');

      final restored = await target.findById('m');
      expect(restored!.balance, 18000);
      final usage = await target.watchUsage('m').first;
      expect(usage.single.amount, 12000);
    });

    test('기존 쿠폰의 사용 이력은 다시 넣지 않는다 (이중 차감 방지)', () async {
      final source = InMemoryCouponRepository(
        seed: [
          coupon(
            id: 'm',
            kind: CouponKind.amount,
            faceValue: 10000,
            balance: 10000,
          ),
        ],
      );
      addTearDown(source.dispose);
      await source.addUsage(
        UsageEntry(
          id: 'u1',
          couponId: 'm',
          amount: 4000,
          usedAt: DateTime(2026, 7, 10),
        ),
      );
      final bytes = await BackupService(
        source,
        codec: fastCodec(),
      ).createBackup('암호');

      // 대상 기기에 같은 쿠폰과 같은 이력이 이미 있다.
      final target = InMemoryCouponRepository(
        seed: [
          coupon(
            id: 'm',
            kind: CouponKind.amount,
            faceValue: 10000,
            balance: 10000,
          ),
        ],
      );
      addTearDown(target.dispose);
      await target.addUsage(
        UsageEntry(
          id: 'u1',
          couponId: 'm',
          amount: 4000,
          usedAt: DateTime(2026, 7, 10),
        ),
      );

      await BackupService(target, codec: fastCodec()).restore(bytes, '암호');

      // 이력이 u1 하나뿐이어야 한다. 복원이 이력을 복제하면 잔액이 2000이 된다.
      final usage = await target.watchUsage('m').first;
      expect(usage.length, 1);
      expect((await target.findById('m'))!.balance, 6000);
    });

    test('만료·사용 완료 쿠폰도 백업에 포함된다', () async {
      final source = InMemoryCouponRepository(
        seed: [
          coupon(id: 'active'),
          coupon(id: 'used', status: CouponStatus.used),
          coupon(id: 'expired', status: CouponStatus.expired),
          coupon(id: 'gifted', status: CouponStatus.gifted),
        ],
      );
      addTearDown(source.dispose);
      final bytes = await BackupService(
        source,
        codec: fastCodec(),
      ).createBackup('암호');

      final target = InMemoryCouponRepository();
      addTearDown(target.dispose);
      final result = await BackupService(
        target,
        codec: fastCodec(),
      ).restore(bytes, '암호');

      expect((result as RestoreSucceeded).summary.imported, 4);
      expect((await target.findById('expired'))!.status, CouponStatus.expired);
    });

    test('틀린 암호로 복원하면 아무것도 바뀌지 않는다', () async {
      final source = InMemoryCouponRepository(seed: [coupon(id: 'a')]);
      addTearDown(source.dispose);
      final bytes = await BackupService(
        source,
        codec: fastCodec(),
      ).createBackup('진짜');

      final target = InMemoryCouponRepository();
      addTearDown(target.dispose);
      final result = await BackupService(
        target,
        codec: fastCodec(),
      ).restore(bytes, '가짜');

      expect(result, isA<RestoreFailed>());
      expect(await target.findById('a'), isNull);
    });
  });
}
