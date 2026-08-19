import 'package:coupon_diary/app/providers.dart';
import 'package:coupon_diary/data/repository/in_memory_coupon_repository.dart';
import 'package:coupon_diary/design/theme.dart';
import 'package:coupon_diary/domain/model/coupon.dart';
import 'package:coupon_diary/domain/repository/coupon_repository.dart';
import 'package:coupon_diary/features/usage/presentation/use_coupon_screen.dart';
import 'package:coupon_diary/features/vault/presentation/coupon_detail_screen.dart';
import 'package:coupon_diary/features/vault/presentation/coupon_form_screen.dart';
import 'package:coupon_diary/features/vault/presentation/vault_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

/// 실제 화면을 실제 라우터에 태워 "등록 → 저장 → 목록 → 사용 → 잔액 차감"을
/// 사람이 누르는 것과 같은 경로로 확인한다.
///
/// 앱의 전역 `appRouter`를 쓰지 않고 테스트마다 라우터를 새로 만든다.
/// 전역 인스턴스를 공유하면 앞 테스트의 화면 스택이 남아 다음 테스트가 멈춘다.
void main() {
  setUpAll(() async => initializeDateFormatting('ko_KR'));

  /// 고정 프레임만큼 진행시킨다.
  ///
  /// `pumpAndSettle`을 쓰지 않는 이유: 화면에 진행 표시줄 같은 무한 애니메이션이
  /// 하나라도 있으면 영원히 끝나지 않는다. 프레임 수를 정해두면 테스트가
  /// 멈추지 않으면서도 상태 전이가 모두 반영된다.
  Future<void> settle(WidgetTester tester, [int frames = 25]) async {
    for (var i = 0; i < frames; i++) {
      await tester.pump(const Duration(milliseconds: 40));
    }
  }

  /// 앱과 같은 이름의 라우트를 갖는 테스트용 라우터.
  GoRouter buildRouter(String initial) => GoRouter(
    initialLocation: initial,
    routes: [
      GoRoute(
        path: '/',
        name: 'vault',
        builder: (_, _) => const VaultScreen(),
        routes: [
          GoRoute(
            path: 'add',
            name: 'add',
            builder: (_, _) => const Scaffold(body: Text('ADD')),
            routes: [
              GoRoute(
                path: 'manual',
                name: 'addManual',
                builder: (_, _) => const CouponFormScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'settings',
            name: 'settings',
            builder: (_, _) => const Scaffold(body: Text('SETTINGS')),
          ),
          GoRoute(
            path: 'coupon/:id',
            name: 'couponDetail',
            builder: (_, state) =>
                CouponDetailScreen(couponId: state.pathParameters['id']!),
            routes: [
              GoRoute(
                path: 'use',
                name: 'useCoupon',
                builder: (_, state) =>
                    UseCouponScreen(couponId: state.pathParameters['id']!),
              ),
              GoRoute(
                path: 'edit',
                name: 'editCoupon',
                builder: (_, state) =>
                    CouponFormScreen(couponId: state.pathParameters['id']!),
              ),
              GoRoute(
                path: 'gift',
                name: 'giftCoupon',
                builder: (_, _) => const Scaffold(body: Text('GIFT')),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  /// 항상 보관함에서 시작한다. 앱을 여는 실제 경로이고, 폼으로 딥링크하면
  /// 보관함이 빈 상태로 먼저 만들어져 실제와 다른 상황이 된다.
  Future<(InMemoryCouponRepository, GoRouter)> pumpApp(
    WidgetTester tester, {
    List<Coupon> seed = const [],
  }) async {
    final repository = InMemoryCouponRepository(seed: seed);
    addTearDown(repository.dispose);
    final router = buildRouter('/');
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [couponRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp.router(
          routerConfig: router,
          // 로딩 스켈레톤은 무한 반복이라 pumpAndSettle이 끝나지 않는다.
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
          theme: AppTheme.light(),
          locale: const Locale('ko', 'KR'),
          supportedLocales: const [Locale('ko', 'KR')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      ),
    );
    await settle(tester);
    return (repository, router);
  }

  /// 사용자가 하듯 보관함에서 등록 폼으로 이동한다.
  Future<void> gotoForm(WidgetTester tester, GoRouter router) async {
    router.go('/add/manual');
    await settle(tester);
  }

  /// 폼은 ListView라 화면 밖 입력란이 아직 만들어지지 않는다.
  /// 실제 사용자처럼 스크롤해서 필드를 화면에 올린 뒤 입력한다.
  Future<void> enterField(WidgetTester tester, String key, String text) async {
    final finder = find.byKey(Key(key));
    await tester.scrollUntilVisible(
      finder,
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(finder, text);
    await settle(tester);
  }

  /// 폼을 채우고 등록한다. 등록 후에는 상세 화면으로 넘어간다.
  Future<void> fillAndSubmit(
    WidgetTester tester, {
    required String brand,
    required String product,
    String? barcode,
    String? faceValue,
  }) async {
    await enterField(tester, 'field_brand', brand);
    await enterField(tester, 'field_product', product);

    if (faceValue != null) {
      await tester.tap(find.text('금액권'));
      await settle(tester);
      await enterField(tester, 'field_face_value', faceValue);
    }
    if (barcode != null) {
      await enterField(tester, 'field_barcode', barcode);
    }

    await tester.tap(find.text('등록하기'));
    await settle(tester);
  }

  testWidgets('교환권을 등록하면 저장되고 보관함에 나타난다', (tester) async {
    final (repository, router) = await pumpApp(tester);
    await gotoForm(tester, router);

    await fillAndSubmit(
      tester,
      brand: '메가커피',
      product: '아이스 아메리카노',
      barcode: '9911223344556',
    );

    // 저장소에 실제로 들어갔는가.
    final saved = await repository.watchCoupons(const CouponQuery()).first;
    expect(saved.length, 1);
    expect(saved.single.brand, '메가커피');
    expect(saved.single.productName, '아이스 아메리카노');
    expect(saved.single.barcode, '9911223344556');
    expect(saved.single.status, CouponStatus.active);

    // 등록 후 상세 화면으로 이동했는가.
    // 상세 화면의 제목은 이제 브랜드다. 브랜드는 패스 카드에도 나오므로
    // 이 화면에만 있는 '쿠폰 정보' 머리글로 확인한다.
    expect(find.text('쿠폰 정보'), findsOneWidget);

    // 보관함 목록에 반영되는가.
    router.go('/');
    await settle(tester);
    expect(find.text('아이스 아메리카노'), findsOneWidget);
    expect(find.text('아직 등록한 쿠폰이 없어요'), findsNothing);
  });

  testWidgets('필수 항목이 비면 저장되지 않는다', (tester) async {
    final (repository, router) = await pumpApp(tester);
    await gotoForm(tester, router);

    await tester.tap(find.text('등록하기'));
    await settle(tester);

    expect(find.textContaining('브랜드를 입력해주세요'), findsOneWidget);
    expect(await repository.watchCoupons(const CouponQuery()).first, isEmpty);
  });

  testWidgets('금액권을 부분 사용하면 잔액이 차감된다', (tester) async {
    final (repository, router) = await pumpApp(tester);
    await gotoForm(tester, router);

    await fillAndSubmit(
      tester,
      brand: '스타벅스',
      product: '금액권 3만원',
      faceValue: '30000',
    );

    var coupon =
        (await repository.watchCoupons(const CouponQuery()).first).single;
    expect(coupon.kind, CouponKind.amount);
    expect(coupon.faceValue, 30000);
    expect(coupon.balance, 30000);

    // 상세 → 사용 화면.
    await tester.tap(find.text('사용하기'));
    await settle(tester);

    // 나가면서 얼마 썼는지 묻는다.
    await tester.tap(find.text('사용 완료'));
    await settle(tester);
    expect(find.text('얼마 사용하셨어요?'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '6500');
    await tester.tap(find.text('사용 금액 기록'));
    await settle(tester);

    coupon = (await repository.watchCoupons(const CouponQuery()).first).single;
    expect(coupon.balance, 23500);
    expect(coupon.status, CouponStatus.active);

    final usage = await repository.watchUsage(coupon.id).first;
    expect(usage.single.amount, 6500);
  });

  testWidgets('잔액보다 큰 금액은 기록되지 않는다', (tester) async {
    final (repository, router) = await pumpApp(tester);
    await gotoForm(tester, router);

    await fillAndSubmit(
      tester,
      brand: 'GS25',
      product: '상품권 5천원',
      faceValue: '5000',
    );
    await tester.tap(find.text('사용하기'));
    await settle(tester);
    await tester.tap(find.text('사용 완료'));
    await settle(tester);

    await tester.enterText(find.byType(TextField).first, '9000');
    await tester.tap(find.text('사용 금액 기록'));
    await settle(tester);

    expect(find.textContaining('잔액'), findsWidgets);
    final coupon =
        (await repository.watchCoupons(const CouponQuery()).first).single;
    expect(coupon.balance, 5000, reason: '거부됐으므로 잔액이 그대로여야 한다');
  });

  testWidgets('교환권을 사용 완료하면 상태가 바뀌고 목록에서 내려간다', (tester) async {
    final (repository, router) = await pumpApp(tester);
    await gotoForm(tester, router);

    await fillAndSubmit(tester, brand: 'BBQ', product: '황금올리브');

    await tester.tap(find.text('사용하기'));
    await settle(tester);
    await tester.tap(find.text('사용 완료'));
    await settle(tester);

    expect(find.text('쿠폰을 사용하셨나요?'), findsOneWidget);
    await tester.tap(find.text('네, 사용했어요'));
    await settle(tester);

    final used = await repository
        .watchCoupons(const CouponQuery(statuses: {CouponStatus.used}))
        .first;
    expect(used.single.status, CouponStatus.used);

    router.go('/');
    await settle(tester);
    expect(find.text('황금올리브'), findsNothing);
  });

  testWidgets('"아직 안 썼어요"를 고르면 상태가 그대로다', (tester) async {
    final (repository, router) = await pumpApp(tester);
    await gotoForm(tester, router);

    await fillAndSubmit(tester, brand: 'CGV', product: '영화관람권');
    await tester.tap(find.text('사용하기'));
    await settle(tester);
    await tester.tap(find.text('사용 완료'));
    await settle(tester);
    await tester.tap(find.text('아직 안 썼어요'));
    await settle(tester);

    final coupon =
        (await repository.watchCoupons(const CouponQuery()).first).single;
    expect(coupon.status, CouponStatus.active);
  });

  testWidgets('바코드를 입력했으면 사용 화면에 번호가 보인다', (tester) async {
    final (_, router) = await pumpApp(tester);
    await gotoForm(tester, router);

    await fillAndSubmit(
      tester,
      brand: 'GS25',
      product: '모바일 상품권',
      barcode: '8801234567890',
    );
    await tester.tap(find.text('사용하기'));
    await settle(tester);

    // 4자리씩 끊어 보여준다.
    expect(find.text('8801 2345 6789 0'), findsOneWidget);
    expect(find.text('번호 복사'), findsOneWidget);
    expect(find.text('바코드가 등록되어 있지 않습니다'), findsNothing);
  });

  testWidgets('바코드가 없으면 안내 문구가 대신 나온다', (tester) async {
    final (_, router) = await pumpApp(tester);
    await gotoForm(tester, router);

    await fillAndSubmit(tester, brand: '투썸플레이스', product: '케이크');
    await tester.tap(find.text('사용하기'));
    await settle(tester);

    expect(find.text('바코드가 등록되어 있지 않습니다'), findsOneWidget);
  });

  testWidgets('등록한 쿠폰을 검색으로 찾을 수 있다', (tester) async {
    final now = DateTime.now();
    Coupon make(String id, String brand, String product) => Coupon(
      id: id,
      brand: brand,
      productName: product,
      kind: CouponKind.exchange,
      status: CouponStatus.active,
      category: CouponCategory.etc,
      createdAt: now,
      updatedAt: now,
      expiresAt: now.add(const Duration(days: 60)),
    );

    await pumpApp(
      tester,
      seed: [make('a', '스타벅스', '아메리카노'), make('b', 'BBQ', '황금올리브')],
    );

    expect(find.text('아메리카노'), findsOneWidget);
    expect(find.text('황금올리브'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'BBQ');
    await settle(tester);

    expect(find.text('황금올리브'), findsOneWidget);
    expect(find.text('아메리카노'), findsNothing);
  });

  testWidgets('쿠폰을 삭제하면 목록에서 사라진다', (tester) async {
    final (repository, router) = await pumpApp(tester);
    await gotoForm(tester, router);

    await fillAndSubmit(tester, brand: '이디야커피', product: '아메리카노 2잔');
    expect(
      await repository.findById(
        (await repository.watchCoupons(const CouponQuery()).first).single.id,
      ),
      isNotNull,
    );

    // 상세 화면의 더보기 → 삭제 → 확인.
    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await settle(tester);
    await tester.tap(find.text('삭제').last);
    await settle(tester);

    expect(find.text('쿠폰을 삭제할까요?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, '삭제'));
    await settle(tester);

    expect(await repository.watchCoupons(const CouponQuery()).first, isEmpty);
  });

  testWidgets('금액권 상세에 로딩 표시가 남지 않는다', (tester) async {
    // 잔액·사용내역이 계속 로딩 중으로 보이면 사용자는 앱이 멈춘 줄 안다.
    final now = DateTime.now();
    final (_, router) = await pumpApp(
      tester,
      seed: [
        Coupon(
          id: 'm',
          brand: '스타벅스',
          productName: '금액권 3만원',
          kind: CouponKind.amount,
          status: CouponStatus.active,
          category: CouponCategory.cafe,
          createdAt: now,
          updatedAt: now,
          faceValue: 30000,
          balance: 30000,
        ),
      ],
    );

    router.go('/coupon/m');
    await settle(tester, 40);

    // 상세는 스크롤 화면이라 잔액 섹션이 처음엔 화면 밖에 있다.
    await tester.scrollUntilVisible(
      find.text('사용 내역'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await settle(tester);

    expect(find.text('남은 금액'), findsOneWidget);
    expect(find.text('사용 내역'), findsOneWidget);
    expect(find.textContaining('아직 사용 내역이 없습니다'), findsOneWidget);

    // 잔액 막대(결정형) 하나만 있어야 하고, 값이 null(무한 회전)이면 안 된다.
    final bars = tester
        .widgetList<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        )
        .toList();
    expect(bars.length, 1, reason: '로딩 막대가 남아 있으면 안 된다');
    expect(bars.single.value, isNotNull, reason: '무한 애니메이션이 남아 있다');
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
