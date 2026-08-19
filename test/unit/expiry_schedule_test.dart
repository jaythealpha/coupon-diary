import 'package:coupon_diary/domain/model/coupon.dart';
import 'package:coupon_diary/features/notification/expiry_schedule.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

Coupon couponWith({
  required String id,
  required DateTime? expiresAt,
  CouponStatus status = CouponStatus.active,
  String brand = '스타벅스',
}) {
  final now = DateTime(2026, 1, 1);
  return Coupon(
    id: id,
    brand: brand,
    productName: '아메리카노',
    kind: CouponKind.exchange,
    status: status,
    category: CouponCategory.cafe,
    createdAt: now,
    updatedAt: now,
    expiresAt: expiresAt,
  );
}

void main() {
  // 알림 본문에 한국어 날짜 포맷이 들어간다.
  setUpAll(() async => initializeDateFormatting('ko_KR'));

  final now = DateTime(2026, 7, 1, 9);

  test('만료 30·7·3·1일 전에 예약한다', () {
    final reminders = ExpirySchedule.build([
      couponWith(id: 'a', expiresAt: DateTime(2026, 12, 25)),
    ], now: now);

    expect(reminders.length, 4);
    expect(reminders.map((r) => r.fireAt).toList(), [
      DateTime(2026, 11, 25, ExpirySchedule.notifyHour),
      DateTime(2026, 12, 18, ExpirySchedule.notifyHour),
      DateTime(2026, 12, 22, ExpirySchedule.notifyHour),
      DateTime(2026, 12, 24, ExpirySchedule.notifyHour),
    ]);
  });

  test('이미 지난 시점은 예약하지 않는다', () {
    final reminders = ExpirySchedule.build([
      couponWith(id: 'a', expiresAt: DateTime(2026, 7, 3)),
    ], now: now);

    // D-30(6/3), D-7(6/26), D-3(6/30)은 모두 과거. D-1(7/2 19시)만 남는다.
    expect(reminders.length, 1);
    expect(reminders.single.fireAt, DateTime(2026, 7, 2, 19));
    expect(reminders.single.couponId, 'a');
  });

  test('만료일이 없는 쿠폰은 알림을 걸지 않는다', () {
    final reminders = ExpirySchedule.build([
      couponWith(id: 'a', expiresAt: null),
    ], now: now);

    expect(reminders, isEmpty);
  });

  test('사용 완료·만료된 쿠폰은 제외한다', () {
    final reminders = ExpirySchedule.build([
      couponWith(
        id: 'a',
        expiresAt: DateTime(2026, 12, 25),
        status: CouponStatus.used,
      ),
      couponWith(
        id: 'b',
        expiresAt: DateTime(2026, 12, 25),
        status: CouponStatus.gifted,
      ),
    ], now: now);

    expect(reminders, isEmpty);
  });

  test('같은 날 두 장 이상이면 묶음 알림 하나로 만든다', () {
    final reminders = ExpirySchedule.build([
      couponWith(id: 'a', expiresAt: DateTime(2026, 12, 25), brand: '스타벅스'),
      couponWith(id: 'b', expiresAt: DateTime(2026, 12, 25), brand: 'CGV'),
    ], now: now);

    // 두 쿠폰의 만료일이 같으므로 4개 시점 전부가 묶음이 된다.
    expect(reminders.length, 4);
    for (final reminder in reminders) {
      expect(reminder.title, '2장이 곧 만료돼요');
      // 묶음은 특정 쿠폰으로 열 수 없다.
      expect(reminder.couponId, isEmpty);
    }
  });

  test('알림 ID는 서로 겹치지 않는다', () {
    final reminders = ExpirySchedule.build([
      couponWith(id: 'a', expiresAt: DateTime(2026, 12, 25)),
      couponWith(id: 'b', expiresAt: DateTime(2026, 11, 11)),
      couponWith(id: 'c', expiresAt: DateTime(2027, 1, 5)),
    ], now: now);

    final ids = reminders.map((r) => r.id).toSet();
    expect(ids.length, reminders.length);
  });
}
