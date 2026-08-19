import 'package:flutter/material.dart';

import '../../../../core/format.dart';
import '../../../../design/theme.dart';
import '../../../../design/tokens.dart';
import '../../../../design/widgets/grouped_list.dart';
import '../../../../domain/model/coupon.dart';

/// 카테고리 표식. 브랜드 로고는 상표 문제로 쓰지 않는다.
IconData iconForCategory(CouponCategory category) => switch (category) {
  CouponCategory.cafe => Icons.local_cafe_rounded,
  CouponCategory.convenience => Icons.storefront_rounded,
  CouponCategory.chickenPizza => Icons.local_pizza_rounded,
  CouponCategory.bakery => Icons.cake_rounded,
  CouponCategory.dining => Icons.restaurant_rounded,
  CouponCategory.culture => Icons.local_activity_rounded,
  CouponCategory.voucher => Icons.card_giftcard_rounded,
  CouponCategory.beauty => Icons.spa_rounded,
  CouponCategory.etc => Icons.confirmation_number_rounded,
};

/// 보관함 목록의 한 행.
///
/// 이전 카드형에서 행으로 바꿨다. 카드는 한 화면에 4장밖에 못 담았고
/// 테두리가 반복돼 시끄러웠다. 행은 같은 높이에 더 많이 들어가면서
/// 정보 위계는 오히려 뚜렷해진다.
class CouponRow extends StatelessWidget {
  const CouponRow({
    super.key,
    required this.coupon,
    required this.now,
    required this.onTap,
  });

  final Coupon coupon;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final daysLeft = coupon.daysLeftFrom(now);
    final urgency = _Urgency.of(daysLeft, colors);
    final isInactive = !coupon.status.isOpen;

    return GroupedRow(
      onTap: onTap,
      semanticLabel: Fmt.couponSemanticLabel(coupon, now),
      child: Opacity(
        opacity: isInactive ? 0.45 : 1,
        child: Row(
          children: [
            _CategoryMark(coupon: coupon, urgency: urgency),
            const SizedBox(width: Space.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    coupon.productName,
                    style: AppTypography.title2.copyWith(color: colors.label),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  _SubLine(
                    coupon: coupon,
                    daysLeft: daysLeft,
                    urgency: urgency,
                  ),
                ],
              ),
            ),
            const SizedBox(width: Space.sm),
            _Trailing(coupon: coupon, urgency: urgency, inactive: isInactive),
          ],
        ),
      ),
    );
  }
}

/// 남은 기간에 따른 색과 문구. 색만으로 급함을 표현하지 않는다.
class _Urgency {
  const _Urgency(this.color, this.fill, this.isUrgent);

  final Color color;
  final Color fill;
  final bool isUrgent;

  static _Urgency of(int? daysLeft, AppSemanticColors c) => switch (daysLeft) {
    null => _Urgency(c.labelSecondary, c.fill, false),
    < 0 => _Urgency(c.critical, c.criticalFill, false),
    <= 3 => _Urgency(c.critical, c.criticalFill, true),
    <= 7 => _Urgency(c.caution, c.cautionFill, true),
    _ => _Urgency(c.labelSecondary, c.fill, false),
  };
}

class _CategoryMark extends StatelessWidget {
  const _CategoryMark({required this.coupon, required this.urgency});

  final Coupon coupon;
  final _Urgency urgency;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // 임박한 쿠폰만 표식에 색을 넣는다. 전부 색을 주면 아무것도 강조되지 않는다.
    final tinted = urgency.isUrgent;

    return Container(
      width: 34,
      height: 34,
      decoration: ShapeDecoration(
        color: tinted ? urgency.fill : colors.fill,
        shape: const RoundedSuperellipseBorder(
          borderRadius: BorderRadius.all(Radius.circular(Radii.sm)),
        ),
      ),
      child: Icon(
        iconForCategory(coupon.category),
        size: 18,
        color: tinted ? urgency.color : colors.labelSecondary,
      ),
    );
  }
}

class _SubLine extends StatelessWidget {
  const _SubLine({
    required this.coupon,
    required this.daysLeft,
    required this.urgency,
  });

  final Coupon coupon;
  final int? daysLeft;
  final _Urgency urgency;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Flexible(
          child: Text(
            coupon.brand,
            style: AppTypography.footnote.copyWith(
              color: colors.labelSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          '  ·  ',
          style: AppTypography.footnote.copyWith(color: colors.labelTertiary),
        ),
        Text(
          Fmt.expiryLabel(daysLeft),
          style: AppTypography.footnote.copyWith(
            color: urgency.color,
            fontWeight: urgency.isUrgent ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

/// 오른쪽 끝. 금액권은 잔액을, 그 외에는 상태나 꺾쇠를 보여준다.
class _Trailing extends StatelessWidget {
  const _Trailing({
    required this.coupon,
    required this.urgency,
    required this.inactive,
  });

  final Coupon coupon;
  final _Urgency urgency;
  final bool inactive;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (inactive) {
      return Text(
        coupon.status.label,
        style: AppTypography.footnote.copyWith(color: colors.labelSecondary),
      );
    }

    if (coupon.kind == CouponKind.amount) {
      final balance = coupon.balance ?? coupon.faceValue ?? 0;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            Fmt.won(balance),
            style: AppTypography.numeric.copyWith(
              fontSize: 15,
              color: balance == 0 ? colors.labelTertiary : colors.label,
            ),
          ),
        ],
      );
    }

    // 꺾쇠를 두지 않는다. 한글 상품명은 길어서 28px가 아쉽고, 그룹 리스트에서는
    // 행 전체가 눌린다는 것이 이미 관용으로 통한다 (Apple Wallet도 같은 방식).
    return const SizedBox.shrink();
  }
}
