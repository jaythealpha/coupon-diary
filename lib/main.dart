import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'app/router.dart';
import 'features/notification/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 한국어 날짜 포맷("3월 15일")을 쓰려면 로케일 데이터를 먼저 올려야 한다.
  await initializeDateFormatting('ko_KR');

  // 저장소는 앱이 그려지기 전에 준비한다. 화면마다 로딩 상태를 한 겹 더
  // 다루지 않기 위한 선택 (lib/app/providers.dart 참고).
  final repository = await initCouponRepository();

  // 알림을 탭하면 해당 쿠폰으로 바로 연다. 앱이 떠 있을 때는 콜백으로,
  // 죽어 있다가 알림으로 켜진 경우는 시작 경로로 들어온다.
  NotificationService.onTapRoute = appRouter.go;
  final launchRoute = await NotificationService().initialRoute();
  if (launchRoute != null) appRouter.go(launchRoute);

  runApp(
    ProviderScope(
      overrides: [couponRepositoryProvider.overrideWithValue(repository)],
      child: const CouponDiaryApp(),
    ),
  );
}
