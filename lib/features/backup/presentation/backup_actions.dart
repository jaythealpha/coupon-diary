import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/providers.dart';
import '../../../design/theme.dart';
import '../../../design/tokens.dart';
import '../backup_service.dart';

/// 설정 화면에서 부르는 백업·복원 동작.
///
/// 흐름은 짧게 유지한다: 암호 입력 → 실행 → 결과 스낵바.
/// 파일이 어디로 가는지는 OS 공유 시트/파일 선택기가 정한다 — 우리는
/// 저장 위치를 강제하지 않고 서버로도 보내지 않는다 (AGENTS.md 2절).
abstract final class BackupActions {
  static Future<void> export(BuildContext context, WidgetRef ref) async {
    final password = await _askPassword(
      context,
      title: '백업 암호 만들기',
      description:
          '백업 파일은 이 암호로 암호화됩니다. 암호를 잊으면 어떤 방법으로도 '
          '복원할 수 없으니 암호 관리 앱 등에 안전하게 보관해주세요.',
      confirmLabel: '백업 만들기',
      requireConfirmation: true,
    );
    if (password == null || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      final service = BackupService(ref.read(couponRepositoryProvider));
      final bytes = await service.createBackup(password);

      final stamp = DateTime.now();
      final fileName =
          'coupon-diary-${stamp.year}'
          '${stamp.month.toString().padLeft(2, '0')}'
          '${stamp.day.toString().padLeft(2, '0')}.cpdbak';

      final result = await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              bytes,
              name: fileName,
              mimeType: 'application/octet-stream',
            ),
          ],
          fileNameOverrides: [fileName],
          subject: '쿠폰다이어리 백업',
        ),
      );

      // `success`만 성공으로 보면 웹에서 아무 안내도 뜨지 않는다. share_plus의
      // 웹 구현은 파일을 실제로 내려보낸 뒤에도 unavailable을 반환한다.
      // 그 결과 파일은 받아졌는데 화면은 조용해서, 실패한 줄 알고 계속
      // 다시 누르게 됐다. 확실한 취소(dismissed)만 아무 말도 하지 않는다.
      if (result.status == ShareResultStatus.dismissed) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            kIsWeb
                ? '백업 파일을 내려받았습니다. 다운로드 폴더를 확인하세요. 암호를 잊지 마세요.'
                : '백업 파일을 내보냈습니다. 암호를 잊지 마세요.',
          ),
        ),
      );
    } on Exception {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            kIsWeb
                ? '백업 파일을 내려받지 못했습니다. 브라우저의 다운로드 차단 설정을 확인해주세요.'
                : '백업 파일을 만들지 못했습니다. 저장 공간을 확인하고 다시 시도해주세요.',
          ),
        ),
      );
    }
  }

  static Future<void> import(BuildContext context, WidgetRef ref) async {
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(label: '쿠폰다이어리 백업', extensions: ['cpdbak']),
      ],
    );
    if (file == null || !context.mounted) return;

    final password = await _askPassword(
      context,
      title: '백업 암호 입력',
      description: '이 백업을 만들 때 정한 암호를 입력해주세요.',
      confirmLabel: '복원하기',
    );
    if (password == null || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      final bytes = Uint8List.fromList(await file.readAsBytes());
      final service = BackupService(ref.read(couponRepositoryProvider));
      final result = await service.restore(bytes, password);

      switch (result) {
        case RestoreSucceeded(:final summary):
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                summary.imported == 0
                    ? '모든 쿠폰이 이미 있어 새로 가져온 것이 없습니다.'
                    : '쿠폰 ${summary.imported}장을 복원했습니다.'
                          '${summary.skipped > 0 ? ' (이미 있던 ${summary.skipped}장은 건너뜀)' : ''}',
              ),
            ),
          );
        case RestoreFailed(:final message):
          messenger.showSnackBar(
            SnackBar(
              content: Text(message),
              duration: const Duration(seconds: 6),
            ),
          );
      }
    } on Exception {
      messenger.showSnackBar(
        const SnackBar(content: Text('파일을 읽지 못했습니다. 백업 파일이 맞는지 확인해주세요.')),
      );
    }
  }

  static Future<String?> _askPassword(
    BuildContext context, {
    required String title,
    required String description,
    required String confirmLabel,
    bool requireConfirmation = false,
  }) {
    return showBackupPasswordDialog(
      context,
      title: title,
      description: description,
      confirmLabel: confirmLabel,
      requireConfirmation: requireConfirmation,
    );
  }
}

/// 위젯 테스트에서 다이얼로그의 검증 규칙을 직접 확인할 수 있게 공개한다.
Future<String?> showBackupPasswordDialog(
  BuildContext context, {
  required String title,
  required String description,
  required String confirmLabel,
  required bool requireConfirmation,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _PasswordDialog(
      title: title,
      description: description,
      confirmLabel: confirmLabel,
      requireConfirmation: requireConfirmation,
    ),
  );
}

class _PasswordDialog extends StatefulWidget {
  const _PasswordDialog({
    required this.title,
    required this.description,
    required this.confirmLabel,
    required this.requireConfirmation,
  });

  final String title;
  final String description;
  final String confirmLabel;
  final bool requireConfirmation;

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    final password = _password.text;
    if (password.length < 8) {
      setState(() => _error = '암호는 8자 이상이어야 합니다.');
      return;
    }
    if (widget.requireConfirmation && password != _confirm.text) {
      setState(() => _error = '두 암호가 서로 다릅니다. 같은 암호를 다시 입력해주세요.');
      return;
    }
    Navigator.of(context).pop(password);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.description,
            style: AppTypography.footnote.copyWith(
              color: colors.labelSecondary,
            ),
          ),
          const SizedBox(height: Space.lg),
          TextField(
            controller: _password,
            obscureText: _obscure,
            autofocus: true,
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            onSubmitted: widget.requireConfirmation ? null : (_) => _submit(),
            decoration: InputDecoration(
              labelText: '암호',
              errorText: _error,
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                tooltip: _obscure ? '암호 보기' : '암호 숨기기',
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          if (widget.requireConfirmation) ...[
            const SizedBox(height: Space.md),
            TextField(
              controller: _confirm,
              obscureText: _obscure,
              onSubmitted: (_) => _submit(),
              decoration: const InputDecoration(labelText: '암호 확인'),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        FilledButton(onPressed: _submit, child: Text(widget.confirmLabel)),
      ],
    );
  }
}
