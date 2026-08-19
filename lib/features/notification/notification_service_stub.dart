import '../../domain/model/coupon.dart';

/// 웹 빌드용. **아무것도 예약하지 않는다.**
///
/// 예전에는 `ExpirySchedule.build()`를 실제로 돌려 0이 아닌 건수를 돌려줬다.
/// 예약은 하나도 안 됐는데 "N건 예약했습니다"라고 말할 수 있는 값이었다.
/// 스텁은 흉내 내지 않고 정직하게 실패한다 — OCR 스텁과 같은 원칙이다.
class NotificationService {
  NotificationService();

  /// 웹에는 알림이 없으므로 탭 경로도 없다.
  static void Function(String route)? onTapRoute;

  bool get isSupported => false;

  Future<String?> initialRoute() async => null;

  Future<bool> requestPermission() async => false;

  Future<void> initialize() async {}

  Future<int> reschedule(List<Coupon> coupons, {DateTime? now}) async => 0;

  Future<void> cancelAll() async {}
}
