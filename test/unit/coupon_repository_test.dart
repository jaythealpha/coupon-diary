import 'package:coupon_diary/data/repository/in_memory_coupon_repository.dart';
import 'package:coupon_diary/domain/model/coupon.dart';
import 'package:coupon_diary/domain/repository/coupon_repository.dart';
import 'package:flutter_test/flutter_test.dart';

Coupon amountCoupon({
  required String id,
  required int faceValue,
  int? balance,
  CouponStatus status = CouponStatus.active,
  DateTime? expiresAt,
}) {
  final now = DateTime(2026, 1, 1);
  return Coupon(
    id: id,
    brand: '스타벅스',
    productName: '금액권',
    kind: CouponKind.amount,
    status: status,
    category: CouponCategory.cafe,
    createdAt: now,
    updatedAt: now,
    faceValue: faceValue,
    balance: balance ?? faceValue,
    expiresAt: expiresAt,
  );
}

Coupon exchangeCoupon({
  required String id,
  String brand = 'CGV',
  CouponStatus status = CouponStatus.active,
  DateTime? expiresAt,
  DateTime? createdAt,
}) {
  final base = createdAt ?? DateTime(2026, 1, 1);
  return Coupon(
    id: id,
    brand: brand,
    productName: '영화관람권',
    kind: CouponKind.exchange,
    status: status,
    category: CouponCategory.culture,
    createdAt: base,
    updatedAt: base,
    expiresAt: expiresAt,
  );
}

void main() {
  group('금액권 잔액', () {
    test('사용 이력을 더해 잔액을 차감한다', () async {
      final repo = InMemoryCouponRepository(
        seed: [amountCoupon(id: 'a', faceValue: 30000)],
      );

      await repo.addUsage(
        UsageEntry(
          id: 'u1',
          couponId: 'a',
          amount: 6500,
          usedAt: DateTime(2026, 3, 1),
        ),
      );
      await repo.addUsage(
        UsageEntry(
          id: 'u2',
          couponId: 'a',
          amount: 6000,
          usedAt: DateTime(2026, 3, 5),
        ),
      );

      final coupon = await repo.findById('a');
      expect(coupon!.balance, 17500);
      expect(coupon.status, CouponStatus.active);
    });

    test('잔액이 0이 되면 자동으로 사용 완료가 된다', () async {
      final repo = InMemoryCouponRepository(
        seed: [amountCoupon(id: 'a', faceValue: 5000)],
      );

      await repo.addUsage(
        UsageEntry(
          id: 'u1',
          couponId: 'a',
          amount: 5000,
          usedAt: DateTime(2026, 3, 1),
        ),
      );

      final coupon = await repo.findById('a');
      expect(coupon!.balance, 0);
      expect(coupon.status, CouponStatus.used);
    });

    test('사용 이력을 지우면 잔액이 복구된다', () async {
      final repo = InMemoryCouponRepository(
        seed: [amountCoupon(id: 'a', faceValue: 10000)],
      );

      await repo.addUsage(
        UsageEntry(
          id: 'u1',
          couponId: 'a',
          amount: 4000,
          usedAt: DateTime(2026, 3, 1),
        ),
      );
      expect((await repo.findById('a'))!.balance, 6000);

      await repo.deleteUsage('u1');
      expect((await repo.findById('a'))!.balance, 10000);
    });

    test('교환권에는 잔액 계산을 적용하지 않는다', () async {
      final repo = InMemoryCouponRepository(seed: [exchangeCoupon(id: 'a')]);

      await repo.addUsage(
        UsageEntry(
          id: 'u1',
          couponId: 'a',
          amount: 1000,
          usedAt: DateTime(2026, 3, 1),
        ),
      );

      final coupon = await repo.findById('a');
      expect(coupon!.balance, isNull);
      expect(coupon.status, CouponStatus.active);
    });
  });

  group('만료 상태 갱신', () {
    test('지난 쿠폰만 만료로 바꾼다', () async {
      final repo = InMemoryCouponRepository(
        seed: [
          exchangeCoupon(id: 'past', expiresAt: DateTime(2026, 6, 30)),
          exchangeCoupon(id: 'today', expiresAt: DateTime(2026, 7, 1)),
          exchangeCoupon(id: 'future', expiresAt: DateTime(2026, 8, 1)),
          exchangeCoupon(id: 'none', expiresAt: null),
        ],
      );

      final changed = await repo.refreshExpiredStatuses(
        DateTime(2026, 7, 1, 23),
      );

      expect(changed, 1);
      expect((await repo.findById('past'))!.status, CouponStatus.expired);
      // 당일 만료는 아직 쓸 수 있다. 23시에 열어도 만료로 넘기지 않는다.
      expect((await repo.findById('today'))!.status, CouponStatus.active);
      expect((await repo.findById('future'))!.status, CouponStatus.active);
      expect((await repo.findById('none'))!.status, CouponStatus.active);
    });
  });

  group('조회', () {
    test('만료 임박순 정렬에서 만료일 없는 쿠폰은 뒤로 간다', () async {
      final repo = InMemoryCouponRepository(
        seed: [
          exchangeCoupon(id: 'none', expiresAt: null),
          exchangeCoupon(id: 'late', expiresAt: DateTime(2026, 12, 1)),
          exchangeCoupon(id: 'soon', expiresAt: DateTime(2026, 7, 5)),
        ],
      );

      final coupons = await repo
          .watchCoupons(const CouponQuery(sort: CouponSort.expiryAsc))
          .first;

      expect(coupons.map((c) => c.id).toList(), ['soon', 'late', 'none']);
    });

    test('검색어는 브랜드·상품명·메모를 훑는다', () async {
      final repo = InMemoryCouponRepository(
        seed: [
          exchangeCoupon(id: 'a', brand: '스타벅스'),
          exchangeCoupon(id: 'b', brand: 'CGV'),
        ],
      );

      final coupons = await repo
          .watchCoupons(const CouponQuery(keyword: '스타'))
          .first;

      expect(coupons.map((c) => c.id).toList(), ['a']);
    });

    test('상태 필터가 걸린다', () async {
      final repo = InMemoryCouponRepository(
        seed: [
          exchangeCoupon(id: 'a'),
          exchangeCoupon(id: 'b', status: CouponStatus.used),
        ],
      );

      final active = await repo.watchCoupons(const CouponQuery()).first;
      expect(active.map((c) => c.id).toList(), ['a']);

      final used = await repo
          .watchCoupons(const CouponQuery(statuses: {CouponStatus.used}))
          .first;
      expect(used.map((c) => c.id).toList(), ['b']);
    });
  });

  group('만료 계산', () {
    test('시각이 아니라 날짜로 남은 일수를 센다', () {
      final coupon = exchangeCoupon(id: 'a', expiresAt: DateTime(2026, 7, 5));

      // 같은 날 23시 59분에 열어도 "5일에 만료"까지 4일이 남아 있어야 한다.
      expect(coupon.daysLeftFrom(DateTime(2026, 7, 1, 23, 59)), 4);
      expect(coupon.daysLeftFrom(DateTime(2026, 7, 5, 0, 1)), 0);
      expect(coupon.daysLeftFrom(DateTime(2026, 7, 6, 0, 1)), -1);
    });

    test('7일 이내면 임박으로 본다', () {
      final coupon = exchangeCoupon(id: 'a', expiresAt: DateTime(2026, 7, 5));

      expect(coupon.isExpiringSoon(DateTime(2026, 7, 1)), isTrue);
      expect(coupon.isExpiringSoon(DateTime(2026, 6, 1)), isFalse);
      expect(coupon.isExpiringSoon(DateTime(2026, 7, 6)), isFalse);
    });
  });
}
