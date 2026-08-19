import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 없는 기능을 있다고 말하지 못하게 막는다.
///
/// 실제로 두 번 터진 문제다. 코드는 멀쩡한데 **문구를 새로 쓰면서** 깨졌다.
/// 첫 실행 안내가 "갤러리에서 기프티콘을 찾아 등록"을 1번으로 내세웠는데 웹에는
/// ML Kit이 없었고, 그걸 고치면서 만든 고지에서 이번엔 밝기 자동 최대화가
/// 빠졌다. 사람이 매번 기억해야 하는 규칙은 반드시 다시 깨진다.
///
/// 그래서 소스 자체를 검사한다. 환경에 따라 갈리는 기능을 약속하는 문구가
/// 있는 파일은, 그 기능의 capability provider를 반드시 읽어야 한다.
void main() {
  /// 환경 의존 기능 → (약속 문구에 나타나는 표현, 게이트로 인정하는 식별자)
  const gated = <String, ({List<String> phrases, List<String> gates})>{
    // `GalleryScanUnsupported`는 provider가 아니라 컨트롤러의 sealed 상태로
    // 거르는 방식이다. 게이트로서는 동등하므로 인정한다 — 갤러리 스캔 화면이
    // 실제로 이 방식을 쓴다.
    '갤러리 자동 인식': (
      phrases: ['갤러리에 쌓인', '갤러리에서 기프티콘', '자동으로 찾아'],
      gates: [
        'scannerSupportedProvider',
        'ScannerCapability',
        'GalleryScanUnsupported',
      ],
    ),
    '화면 밝기 자동 최대화': (
      phrases: ['밝기를 최대로', '밝기가 최대로'],
      gates: ['brightnessSupportedProvider'],
    ),
    '만료 알림': (
      phrases: ['알려드립니다', '알림이 오지 않습니다', '자동으로 예약'],
      gates: ['notificationsSupportedProvider', 'isSupported'],
    ),
  };

  /// 검사 대상은 사용자에게 문구를 보여주는 화면 코드뿐이다.
  List<File> screenFiles() {
    final dir = Directory('lib/features');
    return dir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => f.path.contains('/presentation/'))
        .toList();
  }

  test('환경에 따라 갈리는 기능을 약속하는 화면은 capability를 확인해야 한다', () {
    final violations = <String>[];

    for (final file in screenFiles()) {
      final source = file.readAsStringSync();

      for (final entry in gated.entries) {
        final promises = entry.value.phrases
            .where(source.contains)
            .toList(growable: false);
        if (promises.isEmpty) continue;

        final gated = entry.value.gates.any(source.contains);
        if (gated) continue;

        violations.add(
          '${file.path}\n'
          '  "${entry.key}"을(를) 약속하는 문구가 있다: ${promises.join(", ")}\n'
          '  그런데 ${entry.value.gates.join(" 또는 ")} 중 어느 것도 읽지 않는다.\n'
          '  → 환경별로 문구를 갈라주거나, 같은 화면에 사전 고지를 넣어라.',
        );
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          '\n없는 기능을 있다고 말하는 화면이 있다. '
          '웹 체험판에는 이 기능들이 없다.\n\n${violations.join("\n\n")}\n',
    );
  });

  test('스텁은 성공한 척하지 않는다', () {
    // 스텁이 조용히 true나 0이 아닌 값을 돌려주면, 그 위에 게이트를 세우는
    // 순간 통과해 버린다. app_lock_stub이 실제로 그랬다.
    final stubs = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('_stub.dart'));

    expect(stubs, isNotEmpty, reason: '스텁을 하나도 못 찾았다면 경로 규칙이 바뀐 것이다');

    for (final stub in stubs) {
      final source = stub.readAsStringSync();
      expect(
        source,
        isNot(contains('async => true')),
        reason: '${stub.path}: 스텁이 성공을 흉내 낸다. false 또는 UnsupportedError로.',
      );
    }
  });
}
