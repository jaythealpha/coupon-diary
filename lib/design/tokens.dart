/// 디자인 토큰. 앱 전체에서 색·간격·곡률·타이포는 **여기서만** 가져온다.
///
/// 기준은 Apple HIG다. 구체적으로 아래 네 가지를 지킨다.
/// 1. **테두리가 아니라 층으로 구분한다.** 회색 1px 선을 두르면 아마추어처럼
///    보인다. 배경을 살짝 눌러 깔고 그 위에 흰 면을 얹어 구분한다.
/// 2. **타입 램프는 iOS 것을 그대로 쓴다.** 큰 글자일수록 자간을 좁힌다.
/// 3. **모서리는 스퀘어클(연속 곡률)이다.** 단순 원호는 각져 보인다.
/// 4. **색은 하나만 강하게.** 나머지는 무채와 의미색으로 절제한다.
///
/// 근거: AGENTS.md 5절.
library;

import 'package:flutter/widgets.dart';

/// 색 역할.
///
/// 값 자체를 화면에서 쓰지 않는다. `context.colors.*`로 접근한다 (theme.dart).
/// 여기 이름은 iOS 시스템 색 역할을 따랐다 — 옮겨 적기 쉽고 의미가 분명하다.
abstract final class AppColors {
  // ─── 브랜드 ──────────────────────────────────────────────────────────────
  /// 상호작용 요소에만 쓴다. 넓은 면을 이 색으로 칠하지 않는다.
  static const accent = Color(0xFF1D4ED8);
  static const accentPressed = Color(0xFF1740B4);
  static const onAccent = Color(0xFFFFFFFF);

  // ─── Light ───────────────────────────────────────────────────────────────
  /// 그룹 리스트가 놓이는 바닥. 흰 카드를 띄우기 위해 한 톤 눌러둔다.
  static const lightGroupedBackground = Color(0xFFF2F2F7);

  /// 카드·행의 면.
  static const lightSurface = Color(0xFFFFFFFF);

  /// 카드 위에 한 겹 더 올라가는 면 (칩, 입력란).
  static const lightSurfaceRaised = Color(0xFFF7F7FA);

  static const lightLabel = Color(0xFF000000);
  static const lightLabelSecondary = Color(0x993C3C43); // 60%
  static const lightLabelTertiary = Color(0x4D3C3C43); // 30%

  /// 그룹 내부를 가르는 실선. 카드 테두리로 쓰지 않는다.
  static const lightSeparator = Color(0x2E3C3C43);

  static const lightFill = Color(0x1F787880); // 채워진 배지 바닥

  // ─── Dark ────────────────────────────────────────────────────────────────
  // 반전이 아니다. 어두운 배경에서는 채도를 낮추고 명도를 올린다.
  static const darkAccent = Color(0xFF6E9BFF);
  static const darkAccentPressed = Color(0xFF8FB2FF);
  static const onDarkAccent = Color(0xFF04122E);

  static const darkGroupedBackground = Color(0xFF000000);
  static const darkSurface = Color(0xFF1C1C1E);
  static const darkSurfaceRaised = Color(0xFF2C2C2E);

  static const darkLabel = Color(0xFFFFFFFF);
  static const darkLabelSecondary = Color(0x99EBEBF5);
  static const darkLabelTertiary = Color(0x4DEBEBF5);
  static const darkSeparator = Color(0x54545658);
  static const darkFill = Color(0x5C787880);

  // ─── 의미색 ──────────────────────────────────────────────────────────────
  // 만료 임박·잔액처럼 뜻이 있는 자리에만. 장식으로 쓰지 않는다.
  static const lightPositive = Color(0xFF1D7A4C);
  static const lightPositiveFill = Color(0xFFDDF4E7);
  static const lightCaution = Color(0xFF9A5B00);
  static const lightCautionFill = Color(0xFFFFF0D6);
  static const lightCritical = Color(0xFFC8102E);
  static const lightCriticalFill = Color(0xFFFFE3E6);

  static const darkPositive = Color(0xFF4ADE9B);
  static const darkPositiveFill = Color(0xFF10331F);
  static const darkCaution = Color(0xFFFFBF4D);
  static const darkCautionFill = Color(0xFF3A2A08);
  static const darkCritical = Color(0xFFFF7A8A);
  static const darkCriticalFill = Color(0xFF3D1218);
}

/// 간격. 4pt 배수만 쓴다.
abstract final class Space {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double x3l = 32;
  static const double x4l = 44;
  static const double x5l = 64;

  /// 그룹 리스트가 화면 가장자리에서 떨어지는 거리.
  static const double gutter = 16;

  /// 리스트 행 안쪽 좌우 여백. 구분선이 여기서부터 시작한다.
  static const double rowInset = 16;
}

/// 모서리 반경.
///
/// 애플의 모서리는 원호가 아니라 스퀘어클이다. 값이 커질수록 차이가 크게
/// 보이므로 카드처럼 큰 면에는 반드시 [AppShapes.card]를 쓴다.
abstract final class Radii {
  static const double xs = 6;
  static const double sm = 8;
  static const double md = 10;
  static const double lg = 14;
  static const double xl = 18;
  static const double xxl = 26;
  static const double pill = 999;
}

/// 자주 쓰는 도형. 스퀘어클을 기본으로 한다.
abstract final class AppShapes {
  static const card = RoundedSuperellipseBorder(
    borderRadius: BorderRadius.all(Radius.circular(Radii.lg)),
  );
  static const sheet = RoundedSuperellipseBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.xxl)),
  );
  static const control = RoundedSuperellipseBorder(
    borderRadius: BorderRadius.all(Radius.circular(Radii.md)),
  );
  static const hero = RoundedSuperellipseBorder(
    borderRadius: BorderRadius.all(Radius.circular(Radii.xl)),
  );

  static BorderRadius get cardRadius =>
      const BorderRadius.all(Radius.circular(Radii.lg));
}

/// iOS 타입 램프.
///
/// 크기·행간·자간이 한 벌로 묶여 있다. 임의로 fontSize만 바꾸지 않는다.
/// 큰 글자일수록 자간을 좁히는 것이 핵심이다 — 이걸 안 하면 제목이 헐거워
/// 보이고, 그게 "완성도 없어 보인다"의 큰 원인이다.
abstract final class AppTypography {
  /// 시스템 폰트를 쓴다. iOS는 Apple SD Gothic Neo, Android는 Noto Sans KR로
  /// 각 플랫폼이 가장 잘 다듬어둔 한글 서체가 잡힌다. 전용 서체(Pretendard 등)로
  /// 바꾸려면 이 한 곳만 고치면 된다.
  static const String? family = null;

  static const largeTitle = TextStyle(
    fontFamily: family,
    fontSize: 34,
    height: 41 / 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.8,
  );
  static const title1 = TextStyle(
    fontFamily: family,
    fontSize: 28,
    height: 34 / 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
  );
  static const title2 = TextStyle(
    fontFamily: family,
    fontSize: 22,
    height: 28 / 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
  );
  static const title3 = TextStyle(
    fontFamily: family,
    fontSize: 20,
    height: 25 / 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
  );

  /// 행의 주 텍스트. 목록에서 가장 많이 쓰인다.
  static const headline = TextStyle(
    fontFamily: family,
    fontSize: 17,
    height: 22 / 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
  );
  static const body = TextStyle(
    fontFamily: family,
    fontSize: 17,
    height: 22 / 17,
    letterSpacing: -0.4,
  );
  static const callout = TextStyle(
    fontFamily: family,
    fontSize: 16,
    height: 21 / 16,
    letterSpacing: -0.3,
  );
  static const subhead = TextStyle(
    fontFamily: family,
    fontSize: 15,
    height: 20 / 15,
    letterSpacing: -0.2,
  );
  static const footnote = TextStyle(
    fontFamily: family,
    fontSize: 13,
    height: 18 / 13,
    letterSpacing: -0.1,
  );
  static const caption = TextStyle(
    fontFamily: family,
    fontSize: 12,
    height: 16 / 12,
  );
  static const caption2 = TextStyle(
    fontFamily: family,
    fontSize: 11,
    height: 13 / 11,
  );

  /// 그룹 리스트 위에 붙는 머리글. 대문자 느낌으로 작고 낮게.
  static const sectionHeader = TextStyle(
    fontFamily: family,
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
  );

  /// 금액·날짜처럼 자릿수가 바뀌어도 흔들리면 안 되는 숫자.
  static const numeric = TextStyle(
    fontFamily: family,
    fontSize: 17,
    height: 22 / 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// 잔액처럼 화면의 주인공이 되는 숫자.
  static const numericDisplay = TextStyle(
    fontFamily: family,
    fontSize: 34,
    height: 40 / 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.2,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}

/// 모션.
///
/// 애플의 움직임은 시간이 아니라 물리로 정의된다. 곡선을 쓰더라도
/// 감속이 강한 것을 골라 "무게가 있는" 느낌을 낸다.
abstract final class Motion {
  static const Duration instant = Duration(milliseconds: 120);
  static const Duration fast = Duration(milliseconds: 220);
  static const Duration normal = Duration(milliseconds: 320);

  /// 나타날 때. 빠르게 시작해 부드럽게 멎는다.
  static const Curve enter = Cubic(0.2, 0.9, 0.2, 1);

  /// 사라질 때. 들어올 때보다 짧게 (Material motion 원칙).
  static const Curve exit = Cubic(0.4, 0, 1, 1);

  /// 눌렀을 때 살짝 들어가는 정도.
  static const double pressScale = 0.97;
}

/// 층. 그림자는 거의 쓰지 않는다 — 배경 대비로 층을 만든다.
abstract final class Elevation {
  /// 떠 있는 요소(FAB, 시트)에만. 아주 옅게.
  static const List<BoxShadow> floating = [
    BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x0A000000), blurRadius: 2, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> none = [];
}

abstract final class Layout {
  /// 태블릿·데스크톱에서 본문이 무한정 넓어지지 않게.
  static const double maxContentWidth = 560;

  /// 터치 타깃 최소 (iOS 44pt / Android 48dp 중 큰 값).
  static const double minTouchTarget = 48;

  /// 리스트 행 최소 높이.
  static const double rowHeight = 44;

  static const double breakpointTablet = 768;
}
