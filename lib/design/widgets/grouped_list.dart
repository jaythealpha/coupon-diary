import 'package:flutter/material.dart';

import '../theme.dart';
import '../tokens.dart';

/// 애플식 그룹 인셋 리스트.
///
/// 이 앱이 "완성도 없어 보인다"는 인상의 가장 큰 원인은 모든 카드에 회색
/// 1px 테두리를 두른 것이었다. iOS는 테두리를 쓰지 않는다. 배경을 한 톤
/// 눌러 깔고 흰 면을 얹어 층으로 구분하며, 그룹 **안쪽**만 얇은 실선으로
/// 나눈다. 그 실선도 내용 시작점에서부터 그어 좌측이 트여 보이게 한다.
class GroupedSection extends StatelessWidget {
  const GroupedSection({
    super.key,
    required this.children,
    this.header,
    this.footer,
    this.margin,
  });

  final List<Widget> children;

  /// 그룹 위 머리글. 작고 낮은 톤으로 들어간다.
  final String? header;

  /// 그룹 아래 설명. 규칙이나 주의를 여기 둔다.
  final String? footer;

  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (children.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding:
          margin ??
          const EdgeInsets.fromLTRB(Space.gutter, Space.lg, Space.gutter, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header != null)
            Padding(
              padding: const EdgeInsets.only(
                left: Space.rowInset,
                bottom: Space.sm,
              ),
              child: Text(
                header!,
                style: AppTypography.sectionHeader.copyWith(
                  color: colors.labelSecondary,
                ),
              ),
            ),
          DecoratedBox(
            decoration: ShapeDecoration(
              color: colors.surface,
              shape: AppShapes.card,
            ),
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i != children.length - 1)
                    // 좌측을 내용 시작점까지 들여 그어야 답답해 보이지 않는다.
                    Padding(
                      padding: const EdgeInsets.only(left: Space.rowInset),
                      child: Divider(height: 0.5, color: colors.separator),
                    ),
                ],
              ],
            ),
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.only(
                left: Space.rowInset,
                right: Space.rowInset,
                top: Space.sm,
              ),
              child: Text(
                footer!,
                style: AppTypography.footnote.copyWith(
                  color: colors.labelSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 그룹 안의 한 행.
///
/// 누르면 살짝 눌리는 느낌을 준다. Material 잉크 물결은 쓰지 않는다 —
/// iOS 감각과 어긋나고, 카드 모서리 밖으로 번져 지저분해 보인다.
class GroupedRow extends StatefulWidget {
  const GroupedRow({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final String? semanticLabel;

  @override
  State<GroupedRow> createState() => _GroupedRowState();
}

class _GroupedRowState extends State<GroupedRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final content = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: Layout.rowHeight),
      child: Padding(
        padding:
            widget.padding ??
            const EdgeInsets.symmetric(
              horizontal: Space.rowInset,
              vertical: Space.md,
            ),
        child: widget.child,
      ),
    );

    if (widget.onTap == null) return content;

    return Semantics(
      button: true,
      label: widget.semanticLabel,
      excludeSemantics: widget.semanticLabel != null,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: Motion.instant,
          curve: Motion.enter,
          color: _pressed ? colors.fill : Colors.transparent,
          child: content,
        ),
      ),
    );
  }
}

/// 오른쪽 끝 꺾쇠. iOS에서 "누르면 들어간다"를 알리는 관용 표현이다.
class RowChevron extends StatelessWidget {
  const RowChevron({super.key});

  @override
  Widget build(BuildContext context) => Icon(
    Icons.chevron_right_rounded,
    size: 20,
    color: context.colors.labelTertiary,
  );
}
