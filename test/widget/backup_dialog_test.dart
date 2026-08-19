import 'package:coupon_diary/features/backup/presentation/backup_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 백업 암호 다이얼로그의 검증 규칙.
///
/// 이 다이얼로그가 백업 보안의 첫 관문이다. 8자 미만 암호나 확인 불일치가
/// 통과되면 사용자가 복원 불가능한 백업을 만들게 된다.
void main() {
  Future<String?> openDialog(
    WidgetTester tester, {
    required bool requireConfirmation,
  }) async {
    String? returned;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () async {
                  returned = await showBackupPasswordDialog(
                    context,
                    title: '백업 암호 만들기',
                    description: '테스트',
                    confirmLabel: '백업 만들기',
                    requireConfirmation: requireConfirmation,
                  );
                },
                child: const Text('열기'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('열기'));
    await tester.pumpAndSettle();
    return returned;
  }

  testWidgets('8자 미만 암호는 거부된다', (tester) async {
    await openDialog(tester, requireConfirmation: true);

    await tester.enterText(find.byType(TextField).first, 'short');
    await tester.tap(find.text('백업 만들기'));
    await tester.pumpAndSettle();

    expect(find.text('암호는 8자 이상이어야 합니다.'), findsOneWidget);
    // 다이얼로그가 닫히지 않았다.
    expect(find.text('백업 암호 만들기'), findsOneWidget);
  });

  testWidgets('확인 암호가 다르면 거부된다', (tester) async {
    await openDialog(tester, requireConfirmation: true);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'correct-password');
    await tester.enterText(fields.at(1), 'different-password');
    await tester.tap(find.text('백업 만들기'));
    await tester.pumpAndSettle();

    expect(find.textContaining('두 암호가 서로 다릅니다'), findsOneWidget);
  });

  testWidgets('올바른 암호는 그대로 반환된다', (tester) async {
    String? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () async {
                result = await showBackupPasswordDialog(
                  context,
                  title: '백업 암호 입력',
                  description: '테스트',
                  confirmLabel: '복원하기',
                  requireConfirmation: false,
                );
              },
              child: const Text('열기'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('열기'));
    await tester.pumpAndSettle();

    // 복원 모드에서는 확인 필드가 없다.
    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'my-secret-password');
    await tester.tap(find.text('복원하기'));
    await tester.pumpAndSettle();

    expect(result, 'my-secret-password');
  });

  testWidgets('취소하면 null이 돌아온다', (tester) async {
    String? result = 'sentinel';
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () async {
                result = await showBackupPasswordDialog(
                  context,
                  title: '백업 암호 입력',
                  description: '테스트',
                  confirmLabel: '복원하기',
                  requireConfirmation: false,
                );
              },
              child: const Text('열기'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('열기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();

    expect(result, isNull);
  });
}
