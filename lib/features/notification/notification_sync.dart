import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/repository/coupon_repository.dart';
import '../settings/application/settings_controller.dart';
import 'notification_service.dart';

/// 쿠폰이 바뀔 때마다 만료 알림을 다시 예약한다.
///
/// 예전에는 설정 화면에서 스위치를 켜는 순간에만 `reschedule()`을 불렀다.
/// 그래서 **켠 뒤에 등록한 쿠폰은 영원히 알림이 걸리지 않았다.** 첫 실행에서
/// "알림 켜기 → 쿠폰 등록" 순서를 밟으면 예약 건수가 0인 채로 끝났다.
///
/// 저장·삭제·사용·선물 화면마다 재예약 호출을 뿌리는 방법도 있지만, 그러면
/// 새 화면을 만들 때마다 빠뜨릴 자리가 하나씩 늘어난다. 대신 저장소 스트림
/// 하나를 구독해서 **쿠폰 목록이 바뀌면 무조건 다시 예약한다.** 호출자가
/// 기억할 것이 없다.
final notificationSyncProvider = StreamProvider<int>((ref) async* {
  final settings = ref.watch(settingsControllerProvider);
  final repository = ref.watch(couponRepositoryProvider);

  if (!settings.notificationsEnabled) {
    yield 0;
    return;
  }

  final service = NotificationService();
  if (!service.isSupported) {
    yield 0;
    return;
  }
  await service.initialize();

  // 만료일이 있는 활성 쿠폰만 알림 대상이다. 상태나 잔액만 바뀐 경우까지
  // 전량 재예약하면 낭비지만, 예약은 하루 몇 건 수준이라 정확성을 택한다.
  await for (final coupons in repository.watchCoupons(const CouponQuery())) {
    final count = await service.reschedule(coupons);
    ref.read(settingsControllerProvider.notifier).setScheduledCount(count);
    yield count;
  }
});
