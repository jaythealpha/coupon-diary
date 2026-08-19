import 'dart:io' show Platform;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/model/coupon.dart';
import 'expiry_schedule.dart';

/// 만료 알림을 OS에 예약한다.
///
/// 예약은 **전체 재작성** 방식이다. 쿠폰이 하나 바뀔 때마다 차이를 계산해
/// 개별 알림을 손보면 상태가 어긋나기 쉬운데, 예약 건수가 수십 개 수준이라
/// 전부 지우고 다시 거는 편이 단순하고 안전하다.
class NotificationService {
  NotificationService();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// 알림을 탭했을 때 열 경로. `initialize()` 전에 지정해야 한다.
  ///
  /// 예전에는 payload에 `/coupon/<id>`를 심어두기만 하고 아무도 읽지 않았다.
  /// 라우터 주석은 이걸 "핵심 동선"이라 불렀는데 실제로는 알림을 눌러도
  /// 보관함만 열렸다.
  static void Function(String route)? onTapRoute;

  bool get isSupported => true;

  static const _channelId = 'coupon_expiry';

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    final timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName.identifier));

    await _plugin.initialize(
      onDidReceiveNotificationResponse: (response) {
        final route = response.payload;
        if (route != null && route.isNotEmpty) onTapRoute?.call(route);
      },
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          // 권한은 사용자가 알림 기능을 켤 때 따로 요청한다. 앱 첫 실행에
          // 권한 팝업부터 띄우면 대부분 거절한다.
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _initialized = true;
  }

  /// 알림을 눌러 앱이 **처음 켜진** 경우의 경로. 없으면 null.
  ///
  /// 앱이 죽어 있을 때 탭하면 `onDidReceiveNotificationResponse`가 오지 않는다.
  /// 시작 시 한 번 따로 물어봐야 한다.
  Future<String?> initialRoute() async {
    await initialize();
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp != true) return null;
    final route = details?.notificationResponse?.payload;
    return (route == null || route.isEmpty) ? null : route;
  }

  Future<bool> requestPermission() async {
    await initialize();

    if (Platform.isIOS) {
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    }

    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final granted = await android?.requestNotificationsPermission();
      return granted ?? false;
    }

    return false;
  }

  Future<int> reschedule(List<Coupon> coupons, {DateTime? now}) async {
    await initialize();
    await cancelAll();

    final reminders = ExpirySchedule.build(coupons, now: now ?? DateTime.now());

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        '쿠폰 만료 알림',
        channelDescription: '등록한 쿠폰의 유효기간이 다가올 때 알려드립니다.',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    for (final reminder in reminders) {
      await _plugin.zonedSchedule(
        id: reminder.id,
        title: reminder.title,
        body: reminder.body,
        scheduledDate: tz.TZDateTime.from(reminder.fireAt, tz.local),
        notificationDetails: details,
        // 정확한 알람 권한(Android 12+)이 없어도 동작하도록 inexact를 쓴다.
        // 만료 알림은 몇 분 늦어도 무방하고, 권한 요청을 하나 줄일 수 있다.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        // 알림을 탭하면 해당 쿠폰으로 바로 연다. 묶음 알림은 보관함으로.
        payload: reminder.couponId.isEmpty
            ? '/'
            : '/coupon/${reminder.couponId}',
      );
    }

    return reminders.length;
  }

  Future<void> cancelAll() async {
    await initialize();
    await _plugin.cancelAll();
  }
}
