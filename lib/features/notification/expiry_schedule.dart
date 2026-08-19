import '../../core/format.dart';
import '../../domain/model/coupon.dart';

/// 예약할 알림 한 건.
class ScheduledReminder {
  const ScheduledReminder({
    required this.id,
    required this.couponId,
    required this.fireAt,
    required this.title,
    required this.body,
  });

  final int id;
  final String couponId;
  final DateTime fireAt;
  final String title;
  final String body;
}

/// 알림 규칙.
///
/// 순수 함수로 분리해 실기기 없이 테스트한다. 알림은 이 앱의 핵심 기능이라
/// "언제 몇 개가 잡히는가"를 코드로 확인할 수 있어야 한다.
abstract final class ExpirySchedule {
  /// 만료 며칠 전에 알릴지. D-30은 여유를 두고 계획하라는 뜻, D-1은 마지막 경고.
  static const daysBefore = [30, 7, 3, 1];

  /// 알림이 뜨는 시각. 저녁 7시 — 퇴근길·저녁 약속 직전이라 실제로 쓰러 갈 수 있다.
  static const notifyHour = 19;

  /// 하루에 여러 쿠폰이 겹치면 개별 알림 대신 묶음 하나로 보낸다.
  /// 알림이 쏟아지면 사용자는 알림 자체를 꺼버린다.
  static const bundleThreshold = 2;

  static List<ScheduledReminder> build(
    List<Coupon> coupons, {
    required DateTime now,
  }) {
    // 발송일 → 그 날 알려야 할 (쿠폰, 남은일수) 목록
    final byDate = <DateTime, List<(Coupon, int)>>{};

    for (final coupon in coupons) {
      if (coupon.status != CouponStatus.active) continue;
      final expiry = coupon.expiresAt;
      if (expiry == null) continue;

      for (final offset in daysBefore) {
        final fireDate = DateTime(
          expiry.year,
          expiry.month,
          expiry.day,
        ).subtract(Duration(days: offset));
        final fireAt = DateTime(
          fireDate.year,
          fireDate.month,
          fireDate.day,
          notifyHour,
        );
        // 이미 지난 시점은 예약하지 않는다.
        if (!fireAt.isAfter(now)) continue;
        byDate.putIfAbsent(fireAt, () => []).add((coupon, offset));
      }
    }

    final reminders = <ScheduledReminder>[];
    var idSeed = 0;

    final dates = byDate.keys.toList()..sort();
    for (final date in dates) {
      final items = byDate[date]!;

      if (items.length >= bundleThreshold) {
        final names = items
            .take(3)
            .map((e) => '${e.$1.brand} ${e.$1.productName}')
            .join(', ');
        final extra = items.length > 3 ? ' 외 ${items.length - 3}장' : '';
        reminders.add(
          ScheduledReminder(
            id: idSeed++,
            // 묶음 알림은 특정 쿠폰으로 보낼 수 없으므로 보관함으로 연다.
            couponId: '',
            fireAt: date,
            title: '${items.length}장이 곧 만료돼요',
            body: '$names$extra',
          ),
        );
      } else {
        final (coupon, offset) = items.first;
        reminders.add(
          ScheduledReminder(
            id: idSeed++,
            couponId: coupon.id,
            fireAt: date,
            title: _titleFor(offset),
            body:
                '${coupon.brand} ${coupon.productName} · '
                '${Fmt.date(coupon.expiresAt)}까지',
          ),
        );
      }
    }

    return reminders;
  }

  static String _titleFor(int daysBefore) => switch (daysBefore) {
    1 => '내일이면 사라져요',
    3 => '3일 남았어요',
    7 => '이번 주에 만료돼요',
    _ => '한 달 뒤 만료되는 쿠폰이 있어요',
  };
}
