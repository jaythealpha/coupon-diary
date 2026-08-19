import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme.dart';
import '../tokens.dart';
import 'state_views.dart';

/// 스크롤에 반응하는 라지 타이틀 화면 뼈대.
///
/// 애플 앱의 첫인상을 만드는 두 가지를 구현한다.
/// 1. **라지 타이틀** — 처음엔 크게 놓였다가 스크롤하면 상단 바로 접힌다.
///    제목이 처음부터 작게 박혀 있으면 화면이 납작해 보인다.
/// 2. **반투명 재질** — 접힌 바 뒤로 내용이 비쳐 흐려진다. 콘텐츠가 바 밑으로
///    사라지는 게 아니라 지나간다는 감각을 준다.
class LargeTitleScaffold extends StatelessWidget {
  const LargeTitleScaffold({
    super.key,
    required this.title,
    required this.slivers,
    this.leading,
    this.actions,
    this.floatingActionButton,
    this.bottomBar,
  });

  final String title;
  final List<Widget> slivers;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  /// 화면 하단에 고정되는 영역. 재질 위에 얹힌다.
  final Widget? bottomBar;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.groupedBackground,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomBar,
      body: SafeArea(
        bottom: false,
        child: ContentWidth(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverAppBar.large(
                pinned: true,
                leading: leading,
                actions: actions,
                // SliverAppBar.large가 라지 타이틀 축소를 직접 다룬다.
                // flexibleSpace를 덮어쓰면 그 동작이 사라지므로 건드리지 않고,
                // 대신 배경을 불투명하게 둔다.
                backgroundColor: colors.groupedBackground,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                expandedHeight: 116,
                title: Text(title),
                titleTextStyle: AppTypography.largeTitle.copyWith(
                  color: colors.label,
                ),
              ),
              ...slivers,
              // 하단 고정 바·FAB에 마지막 항목이 가리지 않도록 비워둔다.
              SliverPadding(
                padding: EdgeInsets.only(
                  bottom:
                      MediaQuery.paddingOf(context).bottom +
                      (bottomBar != null ? Space.xxl : Space.x5l + Space.xxl),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 하단 고정 액션 바. 뒤로 내용이 비치는 재질 위에 놓인다.
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.groupedBackground.withValues(alpha: 0.86),
            border: Border(
              top: BorderSide(color: colors.separator, width: 0.5),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.gutter,
                Space.md,
                Space.gutter,
                Space.md,
              ),
              child: ContentWidth(child: child),
            ),
          ),
        ),
      ),
    );
  }
}

/// 라지 타이틀이 필요 없는 화면(상세·폼)용 단순 뼈대.
class PlainScaffold extends StatelessWidget {
  const PlainScaffold({
    super.key,
    required this.title,
    required this.child,
    this.leading,
    this.actions,
    this.bottomBar,
  });

  final String title;
  final Widget child;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? bottomBar;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.groupedBackground,
      appBar: AppBar(
        backgroundColor: colors.groupedBackground.withValues(alpha: 0.82),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: leading,
        actions: actions,
        // 흐림은 flexibleSpace로 넣는다. AppBar를 BackdropFilter로 감싸면
        // 상태 표시줄 높이가 계산에서 빠져 기기에서 제목이 잘린다.
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: const SizedBox.expand(),
          ),
        ),
        title: Text(
          title,
          style: AppTypography.title2.copyWith(color: colors.label),
        ),
      ),
      bottomNavigationBar: bottomBar,
      body: SafeArea(bottom: false, child: ContentWidth(child: child)),
    );
  }
}

/// 뒤로 가기 버튼. iOS 관용에 맞춘 꺾쇠.
class BackChevron extends StatelessWidget {
  const BackChevron({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: onPressed,
    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
    tooltip: '뒤로',
  );
}
