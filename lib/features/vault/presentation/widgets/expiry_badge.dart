import 'package:flutter/material.dart';

import '../../../../core/format.dart';
import '../../../../design/theme.dart';
import '../../../../design/tokens.dart';

/// 만료까지 남은 기간 배지.
///
/// 색만으로 급함을 표현하지 않는다. 아이콘과 문구를 함께 넣어야 색각 이상
/// 사용자와 스크린리더 사용자에게도 전달된다 (WCAG `color-not-only`).
class ExpiryBadge extends StatelessWidget {
  const ExpiryBadge({super.key, required this.daysLeft, this.compact = false});

  final int? daysLeft;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final days = daysLeft;

    final (Color background, Color foreground, IconData icon) = switch (days) {
      null => (colors.fill, colors.labelSecondary, Icons.all_inclusive),
      < 0 => (colors.criticalFill, colors.critical, Icons.block),
      <= 3 => (colors.criticalFill, colors.critical, Icons.priority_high),
      <= 7 => (colors.cautionFill, colors.caution, Icons.schedule),
      _ => (colors.fill, colors.labelSecondary, Icons.event_available),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? Space.sm : Space.md,
        vertical: compact ? Space.xs : Space.sm - 2,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(Radii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 13 : 15, color: foreground),
          const SizedBox(width: Space.xs),
          Text(
            Fmt.expiryLabel(days),
            style:
                (compact ? AppTypography.caption : AppTypography.sectionHeader)
                    .copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}
