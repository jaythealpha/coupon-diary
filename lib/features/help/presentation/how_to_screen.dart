import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';

import '../../../design/theme.dart';
import '../../../design/tokens.dart';
import '../../../design/widgets/app_scaffold.dart';
import '../../../design/widgets/grouped_list.dart';
import '../../../design/widgets/illustration.dart';

/// 사용 방법.
///
/// 첫 실행에 보관함이 비어 있으므로, 이 화면이 사실상 첫인상이다. 원칙은 셋이다.
/// 1. **순서대로 세 걸음.** 등록 → 사용 → 잊지 않기. 기능 목록이 아니라 동선이다.
/// 2. **왜 이렇게 만들었는지도 적는다.** "사진이 기기 밖으로 나가지 않는다"는
///    이 앱을 고르는 이유이므로 설명 안에 녹인다.
/// 3. **읽지 않아도 되게 한다.** 각 단계 끝에 바로 실행할 수 있는 길을 둔다.
class HowToScreen extends ConsumerWidget {
  const HowToScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsSupported = ref.watch(notificationsSupportedProvider);

    return PlainScaffold(
      title: '사용 방법',
      leading: BackChevron(
        onPressed: () =>
            context.canPop() ? context.pop() : context.goNamed('vault'),
      ),
      bottomBar: BottomActionBar(
        child: FilledButton(
          onPressed: () => context.goNamed('add'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
          // 쿠폰이 이미 있는 사람도 설정에서 이 화면에 들어온다.
          // "첫"은 빈 보관함 안내에서만 쓴다.
          child: const Text('쿠폰 등록하기'),
        ),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const _Intro(),
          const _StepSection(),
          GroupedSection(
            header: '알아두면 좋은 것',
            children: [
              const _TipRow(
                icon: Icons.lock_outline_rounded,
                title: '쿠폰은 이 기기에만 저장됩니다',
                body:
                    '쿠폰 이미지와 바코드 번호를 서버로 보내지 않습니다. 인식도 기기 안에서 처리합니다. '
                    '계정도 필요 없습니다.',
              ),
              if (notificationsSupported)
                const _TipRow(
                  icon: Icons.notifications_active_outlined,
                  title: '만료 30·7·3·1일 전에 알려드립니다',
                  body:
                      '설정에서 알림을 켜두면 유효기간이 있는 쿠폰마다 자동으로 예약됩니다. '
                      '이후 등록하는 쿠폰도 함께 걸립니다.',
                )
              else
                const _TipRow(
                  icon: Icons.notifications_off_outlined,
                  title: '웹 체험판에는 만료 알림이 없습니다',
                  body:
                      '앱(iOS·Android)에서는 만료 30·7·3·1일 전 저녁 7시에 알려드립니다. '
                      '브라우저에서는 그 부품을 쓸 수 없습니다.',
                ),
              const _TipRow(
                icon: Icons.savings_outlined,
                title: '금액권은 쓸 때마다 잔액이 줄어듭니다',
                body:
                    '사용 화면을 닫을 때 쓴 금액을 적으면 잔액이 자동으로 계산됩니다. '
                    '잘못 적었다면 상세 화면의 사용 내역에서 지울 수 있습니다.',
              ),
              const _TipRow(
                icon: Icons.replay_rounded,
                title: '유효기간이 지나도 끝이 아닙니다',
                body:
                    '미사용 금액형 상품권은 표준약관상 5년 안에 잔액의 90%를 환불받을 수 있습니다. '
                    '만료된 쿠폰 상세에서 안내해드립니다.',
              ),
              const _TipRow(
                icon: Icons.ios_share_rounded,
                title: '기기를 바꿀 땐 암호화 백업',
                body:
                    '설정에서 비밀번호를 걸어 백업 파일을 만들고, 새 기기에서 같은 비밀번호로 '
                    '복원하면 됩니다. 파일은 비밀번호 없이 열 수 없습니다. '
                    '원본 사진은 백업에 담기지 않지만, 바코드 번호가 그대로 옮겨가므로 '
                    '사용에는 지장이 없습니다.',
              ),
            ],
          ),
          const SizedBox(height: Space.xxl),
        ],
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Space.gutter + Space.xs,
        Space.lg,
        Space.gutter + Space.xs,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '세 걸음이면 끝납니다',
            style: AppTypography.title1.copyWith(color: colors.label),
          ),
          const SizedBox(height: Space.xs),
          Text(
            '기프티콘을 넣어두고, 계산대에서 꺼내고, 기한을 놓치지 않는 것. '
            '이 앱이 하는 일은 이 셋뿐입니다.',
            style: AppTypography.subhead.copyWith(color: colors.labelSecondary),
          ),
        ],
      ),
    );
  }
}

class _StepSection extends ConsumerWidget {
  const _StepSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 자동 인식은 기기 안에서 도는 부품이라 웹 체험판에는 없다.
    // 없는 걸 있다고 쓰면 눌러보고 흐려진 항목을 만나게 된다.
    final scannerSupported = ref.watch(scannerSupportedProvider);
    final brightnessSupported = ref.watch(brightnessSupportedProvider);

    return Column(
      children: [
        _StepCard(
          number: 1,
          illustration: 'assets/illustrations/step_collect.svg',
          fallbackIcon: Icons.photo_library_outlined,
          title: '등록한다',
          body: scannerSupported
              ? '갤러리에 쌓인 기프티콘 캡처를 앱이 찾아줍니다. 사진을 고르면 브랜드·상품명·'
                    '유효기간·바코드를 읽어 채워두니, 맞는지만 확인하고 저장하면 됩니다. '
                    '카톡 선물함 캡처, 종이 영수증, 직접 입력도 됩니다.'
              : '브랜드·상품명·유효기간·바코드를 입력해 등록합니다.\n\n'
                    '앱(iOS·Android)에서는 갤러리에 쌓인 기프티콘 캡처를 자동으로 찾아 이 항목들을 '
                    '대신 채워줍니다. 지금 보시는 웹 체험판에는 그 인식 부품이 없어 직접 입력만 됩니다.',
          actionLabel: '등록 화면 열기',
          routeName: 'add',
        ),
        _StepCard(
          number: 2,
          illustration: 'assets/illustrations/step_scan.svg',
          fallbackIcon: Icons.qr_code_2_rounded,
          title: '계산대에서 보여준다',
          body: brightnessSupported
              ? '쿠폰을 눌러 “사용하기”를 누르면 화면 밝기가 최대로 올라가고 바코드가 '
                    '크게 뜹니다. 직원이 찍기만 하면 됩니다. 번호 복사도 됩니다.'
              : '쿠폰을 눌러 “사용하기”를 누르면 바코드가 화면 가득 뜹니다. '
                    '직원이 찍기만 하면 됩니다. 번호 복사도 됩니다.\n\n'
                    '앱(iOS·Android)에서는 이때 화면 밝기도 자동으로 최대가 됩니다.',
        ),
        const _StepCard(
          number: 3,
          illustration: 'assets/illustrations/step_done.svg',
          fallbackIcon: Icons.check_circle_outline_rounded,
          title: '쓴 만큼만 남긴다',
          body:
              '사용 화면을 닫으면 “쓰셨어요?”를 한 번 물어봅니다. 여기서 답하면 끝입니다. '
              '사용 완료를 따로 기억해서 누를 필요가 없습니다.',
        ),
      ],
    );
  }
}

/// 한 걸음. 번호를 눈에 띄게 두어 순서가 읽히게 한다.
class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.number,
    required this.illustration,
    required this.fallbackIcon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.routeName,
  });

  final int number;
  final String illustration;
  final IconData fallbackIcon;
  final String title;
  final String body;
  final String? actionLabel;
  final String? routeName;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Space.gutter,
        Space.lg,
        Space.gutter,
        0,
      ),
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: colors.surface,
          shape: AppShapes.card,
        ),
        child: Padding(
          padding: const EdgeInsets.all(Space.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 그림은 제목 줄 옆에만 둔다. 본문 옆에 세우면 한글 문장이
              // 좁은 기둥으로 흘러 읽기 어려워진다.
              Row(
                children: [
                  _StepNumber(number: number),
                  const SizedBox(width: Space.md),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTypography.headline.copyWith(
                        color: colors.label,
                      ),
                    ),
                  ),
                  const SizedBox(width: Space.sm),
                  Illustration(
                    asset: illustration,
                    size: 56,
                    fallbackIcon: fallbackIcon,
                  ),
                ],
              ),
              const SizedBox(height: Space.md),
              Text(
                body,
                style: AppTypography.subhead.copyWith(
                  color: colors.labelSecondary,
                ),
              ),
              if (actionLabel != null && routeName != null) ...[
                const SizedBox(height: Space.sm),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => context.goNamed(routeName!),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 36),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(actionLabel!),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StepNumber extends StatelessWidget {
  const _StepNumber({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: ShapeDecoration(color: accent, shape: const CircleBorder()),
      child: Text(
        '$number',
        style: AppTypography.footnote.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GroupedRow(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 20, color: colors.labelSecondary),
          ),
          const SizedBox(width: Space.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.callout.copyWith(
                    color: colors.label,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: AppTypography.footnote.copyWith(
                    color: colors.labelSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
