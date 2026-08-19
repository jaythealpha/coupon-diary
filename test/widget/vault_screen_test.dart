import 'package:coupon_diary/app/providers.dart';
import 'package:coupon_diary/data/demo_data.dart';
import 'package:coupon_diary/data/repository/in_memory_coupon_repository.dart';
import 'package:coupon_diary/design/theme.dart';
import 'package:coupon_diary/domain/model/coupon.dart';
import 'package:coupon_diary/features/vault/presentation/vault_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

Widget wrap(Widget child, InMemoryCouponRepository repository) {
  return ProviderScope(
    overrides: [couponRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(
      theme: AppTheme.light(),
      locale: const Locale('ko', 'KR'),
      supportedLocales: const [Locale('ko', 'KR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: child,
    ),
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ko_KR');
  });

  testWidgets('쿠폰이 없으면 사용 방법을 안내한다', (tester) async {
    final repository = InMemoryCouponRepository();
    addTearDown(repository.dispose);

    await tester.pumpWidget(wrap(const VaultScreen(), repository));
    await tester.pumpAndSettle();

    // 기본 상태가 빈 보관함이므로, 이 화면이 첫 실행 안내를 겸한다.
    // 세 걸음과 등록 경로가 모두 보여야 한다.
    expect(find.text('기프티콘, 여기 모아두세요'), findsOneWidget);
    expect(find.textContaining('갤러리에서 기프티콘을 찾아 등록'), findsOneWidget);
    expect(find.textContaining('계산대에서 바코드를 크게'), findsOneWidget);
    expect(find.textContaining('만료 전에 미리 알림'), findsOneWidget);
    expect(find.text('첫 쿠폰 등록하기'), findsOneWidget);
    expect(find.text('사용 방법 자세히 보기'), findsOneWidget);
  });

  testWidgets('등록된 쿠폰을 목록에 그린다', (tester) async {
    final now = DateTime.now();
    final repository = InMemoryCouponRepository(
      seed: demoCoupons(now),
      usageSeed: demoUsage(now),
    );
    addTearDown(repository.dispose);

    await tester.pumpWidget(wrap(const VaultScreen(), repository));
    await tester.pumpAndSettle();

    expect(find.text('아이스 카페 아메리카노 T'), findsOneWidget);
    // 사용 완료·만료·선물함 쿠폰은 기본 탭(사용 가능)에 나오지 않는다.
    expect(find.text('싱글레귤러 아이스크림'), findsNothing);
  });

  testWidgets('검색어로 목록을 좁힌다', (tester) async {
    final now = DateTime.now();
    final repository = InMemoryCouponRepository(seed: demoCoupons(now));
    addTearDown(repository.dispose);

    await tester.pumpWidget(wrap(const VaultScreen(), repository));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'BBQ');
    await tester.pumpAndSettle();

    expect(find.text('황금올리브 치킨 + 콜라 1.25L'), findsOneWidget);
    expect(find.text('아이스 카페 아메리카노 T'), findsNothing);
  });

  testWidgets('결과가 없으면 필터 초기화를 제안한다', (tester) async {
    final now = DateTime.now();
    final repository = InMemoryCouponRepository(seed: demoCoupons(now));
    addTearDown(repository.dispose);

    await tester.pumpWidget(wrap(const VaultScreen(), repository));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '존재하지않는브랜드');
    await tester.pumpAndSettle();

    expect(find.text('조건에 맞는 쿠폰이 없습니다'), findsOneWidget);
    expect(find.text('필터 초기화'), findsOneWidget);
  });

  testWidgets('만료 임박 배너가 뜬다', (tester) async {
    final now = DateTime.now();
    final repository = InMemoryCouponRepository(seed: demoCoupons(now));
    addTearDown(repository.dispose);

    await tester.pumpWidget(wrap(const VaultScreen(), repository));
    await tester.pumpAndSettle();

    // 배너는 특정 쿠폰을 되풀이하지 않고 장수만 알린다.
    // (목록 첫 줄이 이미 그 쿠폰이라 반복이었다.)
    expect(find.textContaining('이번 주에 만료돼요'), findsOneWidget);
  });

  testWidgets('사용·만료 탭으로 전환하면 해당 쿠폰만 보인다', (tester) async {
    final now = DateTime.now();
    final repository = InMemoryCouponRepository(seed: demoCoupons(now));
    addTearDown(repository.dispose);

    await tester.pumpWidget(wrap(const VaultScreen(), repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('사용·만료'));
    await tester.pumpAndSettle();

    expect(find.text('싱글레귤러 아이스크림'), findsOneWidget);
    expect(find.text('아이스 카페 아메리카노 T'), findsNothing);
  });

  testWidgets('작은 화면에서 가로 오버플로가 없다', (tester) async {
    // 최소 지원 폭. 카드 안의 긴 상품명이 밀려 나가는지 확인한다.
    tester.view.physicalSize = const Size(375 * 3, 812 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final now = DateTime.now();
    final repository = InMemoryCouponRepository(seed: demoCoupons(now));
    addTearDown(repository.dispose);

    await tester.pumpWidget(wrap(const VaultScreen(), repository));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('쿠폰 카드에 스크린리더용 설명이 붙는다', (tester) async {
    final now = DateTime.now();
    // 만료 임박 배너가 뜨지 않도록 넉넉한 만료일을 준다. 배너에도 브랜드명이
    // 들어가서 카드와 구분되지 않기 때문.
    final repository = InMemoryCouponRepository(
      seed: [
        Coupon(
          id: 'a',
          brand: '스타벅스',
          productName: '아이스 카페 아메리카노 T',
          kind: CouponKind.exchange,
          status: CouponStatus.active,
          category: CouponCategory.cafe,
          createdAt: now,
          updatedAt: now,
          expiresAt: now.add(const Duration(days: 60)),
        ),
      ],
    );
    addTearDown(repository.dispose);

    await tester.pumpWidget(wrap(const VaultScreen(), repository));
    await tester.pumpAndSettle();

    final handle = tester.ensureSemantics();
    await tester.pumpAndSettle();

    final semantics = tester.getSemantics(
      find.bySemanticsLabel(RegExp('스타벅스')).first,
    );
    expect(semantics.label, contains('스타벅스'));
    expect(semantics.label, contains('사용 가능'));

    // 테스트 종료 검증보다 먼저 정리되어야 하므로 addTearDown을 쓰지 않는다.
    handle.dispose();
  });

  testWidgets('앱을 열면 지난 쿠폰이 만료로 정리된다', (tester) async {
    final past = DateTime.now().subtract(const Duration(days: 3));
    final repository = InMemoryCouponRepository(
      seed: [
        Coupon(
          id: 'stale',
          brand: '스타벅스',
          productName: '아메리카노',
          kind: CouponKind.exchange,
          status: CouponStatus.active,
          category: CouponCategory.cafe,
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
          expiresAt: past,
        ),
      ],
    );
    addTearDown(repository.dispose);

    await tester.pumpWidget(wrap(const VaultScreen(), repository));
    await tester.pumpAndSettle();

    final coupon = await repository.findById('stale');
    expect(coupon!.status, CouponStatus.expired);
  });
}
