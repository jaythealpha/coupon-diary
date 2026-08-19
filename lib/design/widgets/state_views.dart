import 'package:flutter/material.dart';

import '../theme.dart';
import '../tokens.dart';

/// 로딩 상태.
///
/// 스피너 대신 스켈레톤을 쓴다. 목록의 최종 형태를 미리 보여줘야 레이아웃이
/// 흔들리지 않는다 (레이아웃 시프트 방지).
class CouponListSkeleton extends StatefulWidget {
  const CouponListSkeleton({super.key, this.itemCount = 5});

  final int itemCount;

  @override
  State<CouponListSkeleton> createState() => _CouponListSkeletonState();
}

class _CouponListSkeletonState extends State<CouponListSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void initState() {
    super.initState();
    // 모션 감소 설정을 켠 사용자에게는 깜빡임을 주지 않는다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!MediaQuery.disableAnimationsOf(context)) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ExcludeSemantics(
      child: Padding(
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
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final alpha = 0.55 + (_controller.value * 0.35);
              return Column(
                children: [
                  for (var i = 0; i < widget.itemCount; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Space.rowInset,
                        vertical: Space.md,
                      ),
                      child: Row(
                        children: [
                          _Block(
                            width: 40,
                            height: 40,
                            radius: Radii.md,
                            alpha: alpha,
                          ),
                          const SizedBox(width: Space.md),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Block(
                                width: 150,
                                height: 15,
                                radius: Radii.xs,
                                alpha: alpha,
                              ),
                              const SizedBox(height: Space.sm),
                              _Block(
                                width: 96,
                                height: 11,
                                radius: Radii.xs,
                                alpha: alpha,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({
    required this.width,
    required this.height,
    required this.radius,
    required this.alpha,
  });

  final double width;
  final double height;
  final double radius;
  final double alpha;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: ShapeDecoration(
      color: context.colors.fill.withValues(alpha: alpha * 0.5),
      shape: RoundedSuperellipseBorder(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
      ),
    ),
  );
}

/// 비어 있는 상태. 무엇이 없는지 + 무엇을 하면 되는지를 함께 준다.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.illustration,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String description;

  /// assets/illustrations/ 안의 에셋 경로.
  final String? illustration;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Space.x3l,
          Space.x3l,
          Space.x3l,
          Space.x5l,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (illustration != null)
              Image.asset(
                illustration!,
                width: 156,
                height: 156,
                // 에셋이 깨져도 빈 상태 화면 자체는 살아야 한다.
                errorBuilder: (context, _, _) =>
                    _IconMark(icon: icon, colors: colors),
              )
            else
              _IconMark(icon: icon, colors: colors),
            const SizedBox(height: Space.xl),
            Text(
              title,
              style: AppTypography.title3.copyWith(color: colors.label),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Space.sm),
            Text(
              description,
              style: AppTypography.subhead.copyWith(
                color: colors.labelSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: Space.xxl),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class _IconMark extends StatelessWidget {
  const _IconMark({required this.icon, required this.colors});

  final IconData icon;
  final AppSemanticColors colors;

  @override
  Widget build(BuildContext context) => Container(
    width: 64,
    height: 64,
    decoration: ShapeDecoration(
      color: colors.fill,
      shape: const RoundedSuperellipseBorder(
        borderRadius: BorderRadius.all(Radius.circular(Radii.xl)),
      ),
    ),
    child: Icon(icon, size: 28, color: colors.labelSecondary),
  );
}

/// 오류 상태. "오류가 발생했습니다"로 끝내지 않는다 — 원인과 다음 행동을 준다.
class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key,
    required this.title,
    required this.description,
    this.onRetry,
    this.retryLabel = '다시 시도',
  });

  final String title;
  final String description;
  final VoidCallback? onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Space.x3l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: ShapeDecoration(
                color: colors.criticalFill,
                shape: const RoundedSuperellipseBorder(
                  borderRadius: BorderRadius.all(Radius.circular(Radii.xl)),
                ),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 28,
                color: colors.critical,
              ),
            ),
            const SizedBox(height: Space.xl),
            Text(
              title,
              style: AppTypography.title3.copyWith(color: colors.label),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Space.sm),
            Text(
              description,
              style: AppTypography.subhead.copyWith(
                color: colors.labelSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: Space.xxl),
              OutlinedButton(onPressed: onRetry, child: Text(retryLabel)),
            ],
          ],
        ),
      ),
    );
  }
}

/// 본문과 같은 폭으로 정렬되는 앱바. 넓은 화면에서 제목과 본문이 어긋나지 않게.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({super.key, required this.title, this.leading, this.actions});

  final String title;
  final Widget? leading;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => ContentWidth(
    child: AppBar(title: Text(title), leading: leading, actions: actions),
  );
}

/// 본문 폭 제한. 태블릿·데스크톱에서 한 줄이 지나치게 길어지는 것을 막는다.
class ContentWidth extends StatelessWidget {
  const ContentWidth({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    // heightFactor가 핵심이다. 없으면 세로로도 최대치까지 부풀어, 하단 액션 바처럼
    // 느슨한 제약을 받는 자리에서 화면 전체를 차지하고 본문을 0높이로 짓누른다.
    heightFactor: 1,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Layout.maxContentWidth),
      child: child,
    ),
  );
}
