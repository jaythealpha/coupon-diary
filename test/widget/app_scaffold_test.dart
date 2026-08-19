import 'package:coupon_diary/design/theme.dart';
import 'package:coupon_diary/design/tokens.dart';
import 'package:coupon_diary/design/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 하단 액션 바가 본문을 삼키지 않는지 지킨다.
///
/// 실제로 한 번 터진 버그다. 본문 폭을 제한하는 Align에 heightFactor가 없어
/// 세로로도 최대치까지 부풀었고, 느슨한 제약을 받는 bottomNavigationBar 자리에
/// 놓이자 화면 전체(0~812)를 차지해 본문 높이가 0이 됐다. 화면에는 버튼만
/// 덩그러니 남았는데 예외는 하나도 나지 않아 눈으로 보기 전엔 알 수 없었다.
void main() {
  Widget harness({Widget? bottomBar}) => MaterialApp(
    theme: AppTheme.light(),
    home: PlainScaffold(
      title: '스타벅스',
      bottomBar: bottomBar,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          for (var i = 0; i < 12; i++)
            SizedBox(height: 60, child: Text('row $i')),
        ],
      ),
    ),
  );

  testWidgets('하단 바가 있어도 본문이 화면 대부분을 차지한다', (tester) async {
    tester.view.physicalSize = const Size(375 * 2, 812 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      harness(
        bottomBar: BottomActionBar(
          child: FilledButton(onPressed: () {}, child: const Text('사용하기')),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    final bar = tester.getRect(find.byType(BottomActionBar));
    final list = tester.getRect(find.byType(ListView).first);

    expect(bar.height, lessThan(160), reason: '하단 바는 콘텐츠 높이만큼만 차지해야 한다');
    expect(bar.bottom, 812, reason: '하단 바는 화면 맨 아래에 붙어야 한다');
    expect(list.height, greaterThan(600), reason: '본문이 짓눌리면 안 된다');
    expect(find.text('row 0'), findsOneWidget);
    expect(find.text('사용하기'), findsOneWidget);
  });

  testWidgets('하단 바가 없으면 본문이 앱 바 아래 전부를 쓴다', (tester) async {
    tester.view.physicalSize = const Size(375 * 2, 812 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(harness());
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      tester.getRect(find.byType(ListView).first).height,
      greaterThan(700),
    );
  });

  // T-061 검증 흔적이 375pt 하나뿐이었다. 전역 규칙은 375/768/1440을 요구한다.
  for (final (label, width) in [
    ('mobile', 375.0),
    ('tablet', 768.0),
    ('desktop', 1440.0),
  ]) {
    testWidgets('$label($width) 폭에서 가로 오버플로가 없다', (tester) async {
      tester.view.physicalSize = Size(width * 2, 900 * 2);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        harness(
          bottomBar: BottomActionBar(
            child: FilledButton(onPressed: () {}, child: const Text('사용하기')),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // 오버플로가 나면 Flutter가 예외를 올린다.
      expect(tester.takeException(), isNull);

      // 본문은 넓은 화면에서도 읽기 좋은 폭으로 묶여야 한다.
      final list = tester.getRect(find.byType(ListView).first);
      expect(list.width, lessThanOrEqualTo(width));
      expect(
        list.width,
        lessThanOrEqualTo(Layout.maxContentWidth),
        reason: '넓은 화면에서 본문이 끝까지 늘어나면 한 줄이 너무 길어진다',
      );
    });
  }
}
