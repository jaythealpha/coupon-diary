import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../design/theme.dart';
import 'providers.dart';
import '../features/notification/notification_sync.dart';
import '../features/settings/application/settings_controller.dart';
import 'router.dart';

class CouponDiaryApp extends ConsumerStatefulWidget {
  const CouponDiaryApp({super.key});

  @override
  ConsumerState<CouponDiaryApp> createState() => _CouponDiaryAppState();
}

class _CouponDiaryAppState extends ConsumerState<CouponDiaryApp> {
  AppLifecycleListener? _lifecycle;

  @override
  void initState() {
    super.initState();
    // 앱을 다시 앞으로 가져올 때 "오늘"을 다시 계산한다.
    //
    // `nowProvider`를 autoDispose로 바꿔도 이것만으로는 부족했다. 보관함이
    // 계속 watch 하고 있으면 리스너가 끊기지 않아 폐기되지 않는다. 그래서
    // 자정을 넘겨 앱을 켜 둔 채로 두면 "1일 남음"이 다음 날에도 그대로 남았다.
    // 만료 임박이 이 앱의 존재 이유라 하루치 오표시는 치명적이다.
    _lifecycle = AppLifecycleListener(
      onResume: () {
        ref.invalidate(nowProvider);
        ref
            .read(couponRepositoryProvider)
            .refreshExpiredStatuses(DateTime.now());
      },
    );
  }

  @override
  void dispose() {
    _lifecycle?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    // 쿠폰이 바뀔 때마다 만료 알림을 다시 예약한다. 앱이 떠 있는 동안 계속
    // 살아 있어야 하므로 루트에서 구독한다.
    ref.watch(notificationSyncProvider);

    return MaterialApp.router(
      title: '쿠폰다이어리',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode,
      locale: const Locale('ko', 'KR'),
      supportedLocales: const [Locale('ko', 'KR'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
