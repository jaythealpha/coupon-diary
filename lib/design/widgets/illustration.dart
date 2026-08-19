import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme.dart';

/// 일러스트 하나.
///
/// 에셋이 SVG면 벡터로, PNG면 비트맵으로 그린다. 새로 만드는 그림은 SVG로
/// 두는 게 낫다 — 어떤 화면 배율에서도 또렷하고, 배경을 투명하게 유지하려고
/// 흰 바탕을 깎아낼 필요가 없다.
///
/// 그림이 없거나 깨져도 화면은 살아야 하므로 항상 아이콘 대체를 받는다.
class Illustration extends StatelessWidget {
  const Illustration({
    super.key,
    required this.asset,
    required this.size,
    required this.fallbackIcon,
    this.semanticLabel,
  });

  final String asset;
  final double size;
  final IconData fallbackIcon;

  /// 장식용이면 비워둔다. 스크린리더는 옆의 제목·설명으로 충분히 이해한다.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(
      fallbackIcon,
      size: size * 0.48,
      color: context.colors.labelTertiary,
    );

    final Widget picture = asset.endsWith('.svg')
        ? SvgPicture.asset(
            asset,
            width: size,
            height: size,
            placeholderBuilder: (_) => SizedBox(width: size, height: size),
          )
        : Image.asset(
            asset,
            width: size,
            height: size,
            errorBuilder: (context, _, _) =>
                SizedBox(width: size, height: size, child: fallback),
          );

    return ExcludeSemantics(
      excluding: semanticLabel == null,
      child: Semantics(
        label: semanticLabel,
        image: true,
        child: SizedBox(width: size, height: size, child: picture),
      ),
    );
  }
}
