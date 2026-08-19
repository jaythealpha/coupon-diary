import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';

import '../../../design/theme.dart';
import '../../../design/tokens.dart';
import '../../../design/widgets/state_views.dart';
import '../../backup/presentation/backup_actions.dart';
import '../../notification/notification_service.dart';
import '../application/settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final notificationsSupported = ref.watch(notificationsSupportedProvider);
    final controller = ref.read(settingsControllerProvider.notifier);

    return Scaffold(
      appBar: AppTopBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: '뒤로',
          onPressed: () =>
              context.canPop() ? context.pop() : context.goNamed('vault'),
        ),
        title: '설정',
      ),
      body: SafeArea(
        child: ContentWidth(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: Space.md),
            children: [
              const _SectionHeader('도움말'),
              _ActionTile(
                icon: Icons.menu_book_outlined,
                title: '사용 방법',
                description: '등록부터 사용, 잔액 관리까지 세 걸음으로 정리했습니다.',
                onTap: () => context.goNamed('help'),
              ),

              const _SectionHeader('알림'),
              _SwitchTile(
                title: '만료 알림',
                description:
                    '만료 30·7·3·1일 전 저녁 7시에 알려드립니다. '
                    '같은 날 여러 장이면 하나로 묶어 보냅니다.',
                value: settings.notificationsEnabled,
                onChanged: (value) =>
                    _toggleNotifications(context, ref, enabled: value),
                unavailableReason: notificationsSupported
                    ? null
                    : '웹 체험판에서는 알림을 쓸 수 없습니다. '
                          '앱(iOS·Android)에서 만료 30·7·3·1일 전에 알려드립니다.',
              ),
              if (settings.notificationsEnabled && settings.scheduledCount > 0)
                _InfoTile(
                  icon: Icons.event_available_outlined,
                  text: '현재 ${settings.scheduledCount}건의 알림이 예약되어 있습니다.',
                ),

              const _SectionHeader('보안'),
              const _InfoTile(
                icon: Icons.lock_outline,
                text:
                    '쿠폰 이미지와 바코드 번호는 이 기기 안에만 저장되며 '
                    '어떤 서버로도 전송되지 않습니다.',
                highlight: true,
              ),

              const _SectionHeader('백업'),
              _ActionTile(
                icon: Icons.upload_outlined,
                title: '암호화 백업 만들기',
                description:
                    '모든 쿠폰과 사용 내역을 암호화된 파일 하나로 내보냅니다. '
                    'iCloud, Google Drive 등 원하는 곳에 보관하세요.',
                onTap: () => BackupActions.export(context, ref),
              ),
              _ActionTile(
                icon: Icons.download_outlined,
                title: '백업에서 복원',
                description:
                    '백업 파일을 골라 쿠폰을 되살립니다. 지금 있는 쿠폰은 지워지지 않고, '
                    '백업에만 있는 쿠폰이 추가됩니다.',
                onTap: () => BackupActions.import(context, ref),
              ),

              const _SectionHeader('화면'),
              _ThemeTile(
                value: settings.themeMode,
                onChanged: controller.setThemeMode,
              ),

              const _SectionHeader('앱 정보'),
              const _InfoTile(icon: Icons.info_outline, text: '쿠폰다이어리 1.0.0'),
              const _InfoTile(
                icon: Icons.block_outlined,
                text: '이 앱에는 광고와 사용자 추적이 없습니다.',
              ),
              const SizedBox(height: Space.x3l),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleNotifications(
    BuildContext context,
    WidgetRef ref, {
    required bool enabled,
  }) async {
    final controller = ref.read(settingsControllerProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    final service = NotificationService();

    if (!enabled) {
      await service.cancelAll();
      await controller.setNotificationsEnabled(false);
      controller.setScheduledCount(0);
      return;
    }

    if (!service.isSupported) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('이 환경에서는 알림을 사용할 수 없습니다. iOS·Android 앱에서 동작합니다.'),
        ),
      );
      return;
    }

    final granted = await service.requestPermission();
    if (!granted) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            '알림 권한이 거부되어 만료 알림을 보낼 수 없습니다. '
            '설정 > 쿠폰다이어리 > 알림에서 허용해주세요.',
          ),
          duration: Duration(seconds: 5),
        ),
      );
      return;
    }

    // 여기서 직접 예약하지 않는다. notificationSyncProvider가 쿠폰 스트림을
    // 구독하고 있어, 플래그를 켜면 곧바로 전량 재예약하고 건수까지 갱신한다.
    // 예전에는 이 자리에서 한 번만 예약해서, 이후 등록한 쿠폰이 누락됐다.
    await controller.setNotificationsEnabled(true);
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Space.lg,
        Space.xl,
        Space.lg,
        Space.sm,
      ),
      child: Text(
        title,
        style: AppTypography.sectionHeader.copyWith(
          color: context.scheme.primary,
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
    this.unavailableReason,
  });

  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  /// 이 환경에서 쓸 수 없는 이유. 있으면 스위치를 끄고 이유를 함께 보여준다.
  ///
  /// 예전에는 멀쩡한 스위치로 그려놓고 **누른 뒤에야** 스낵바로 거절했다.
  /// 눌러봐야 아는 건 거짓 약속이다. 등록 화면은 이미 `enabled:` 패턴을
  /// 쓰고 있었는데 설정 화면만 따르지 않았다.
  final String? unavailableReason;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final available = unavailableReason == null;
    return Opacity(
      opacity: available ? 1 : 0.55,
      child: SwitchListTile.adaptive(
        value: available && value,
        onChanged: available ? onChanged : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: Space.lg),
        title: Text(title, style: AppTypography.callout),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: Space.xxs),
          child: Text(
            available ? description : unavailableReason!,
            style: AppTypography.footnote.copyWith(
              color: colors.labelSecondary,
            ),
          ),
        ),
        isThreeLine: true,
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: Space.lg),
      leading: Icon(icon, color: colors.labelSecondary),
      title: Text(title, style: AppTypography.callout),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: Space.xxs),
        child: Text(
          description,
          style: AppTypography.footnote.copyWith(color: colors.labelSecondary),
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: colors.labelTertiary),
      isThreeLine: true,
    );
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({required this.value, required this.onChanged});

  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Space.lg,
        vertical: Space.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('테마', style: AppTypography.callout),
          const SizedBox(height: Space.sm),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.system, label: Text('시스템')),
              ButtonSegment(value: ThemeMode.light, label: Text('밝게')),
              ButtonSegment(value: ThemeMode.dark, label: Text('어둡게')),
            ],
            selected: {value},
            showSelectedIcon: false,
            onSelectionChanged: (selection) => onChanged(selection.first),
          ),
          const SizedBox(height: Space.xs),
          Text(
            '어둡게를 선택해도 바코드를 보여주는 사용 화면은 항상 밝게 표시됩니다. '
            '매장 스캐너 인식률 때문입니다.',
            style: AppTypography.caption.copyWith(
              color: context.colors.labelSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.text,
    this.highlight = false,
  });

  final IconData icon;
  final String text;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Space.lg,
        Space.sm,
        Space.lg,
        Space.sm,
      ),
      child: Container(
        padding: const EdgeInsets.all(Space.md),
        decoration: BoxDecoration(
          color: highlight ? colors.positiveFill : colors.fill,
          borderRadius: BorderRadius.circular(Radii.md),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 18,
              color: highlight ? colors.positive : colors.labelSecondary,
            ),
            const SizedBox(width: Space.md),
            Expanded(
              child: Text(
                text,
                style: AppTypography.footnote.copyWith(
                  color: highlight ? colors.positive : colors.labelSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
