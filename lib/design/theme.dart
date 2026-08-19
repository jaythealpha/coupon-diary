import 'package:flutter/material.dart';

import 'tokens.dart';

/// Material `ColorScheme`이 표현하지 못하는 의미 색과 표면 층을 담는다.
///
/// 화면에서는 `context.colors.separator`처럼 접근한다. 라이트/다크 분기를
/// 화면 코드에 두지 않기 위한 장치다.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.groupedBackground,
    required this.surface,
    required this.surfaceRaised,
    required this.label,
    required this.labelSecondary,
    required this.labelTertiary,
    required this.separator,
    required this.fill,
    required this.positive,
    required this.positiveFill,
    required this.caution,
    required this.cautionFill,
    required this.critical,
    required this.criticalFill,
  });

  final Color groupedBackground;
  final Color surface;
  final Color surfaceRaised;
  final Color label;
  final Color labelSecondary;
  final Color labelTertiary;
  final Color separator;
  final Color fill;
  final Color positive;
  final Color positiveFill;
  final Color caution;
  final Color cautionFill;
  final Color critical;
  final Color criticalFill;

  static const light = AppSemanticColors(
    groupedBackground: AppColors.lightGroupedBackground,
    surface: AppColors.lightSurface,
    surfaceRaised: AppColors.lightSurfaceRaised,
    label: AppColors.lightLabel,
    labelSecondary: AppColors.lightLabelSecondary,
    labelTertiary: AppColors.lightLabelTertiary,
    separator: AppColors.lightSeparator,
    fill: AppColors.lightFill,
    positive: AppColors.lightPositive,
    positiveFill: AppColors.lightPositiveFill,
    caution: AppColors.lightCaution,
    cautionFill: AppColors.lightCautionFill,
    critical: AppColors.lightCritical,
    criticalFill: AppColors.lightCriticalFill,
  );

  static const dark = AppSemanticColors(
    groupedBackground: AppColors.darkGroupedBackground,
    surface: AppColors.darkSurface,
    surfaceRaised: AppColors.darkSurfaceRaised,
    label: AppColors.darkLabel,
    labelSecondary: AppColors.darkLabelSecondary,
    labelTertiary: AppColors.darkLabelTertiary,
    separator: AppColors.darkSeparator,
    fill: AppColors.darkFill,
    positive: AppColors.darkPositive,
    positiveFill: AppColors.darkPositiveFill,
    caution: AppColors.darkCaution,
    cautionFill: AppColors.darkCautionFill,
    critical: AppColors.darkCritical,
    criticalFill: AppColors.darkCriticalFill,
  );

  @override
  AppSemanticColors copyWith({
    Color? groupedBackground,
    Color? surface,
    Color? surfaceRaised,
    Color? label,
    Color? labelSecondary,
    Color? labelTertiary,
    Color? separator,
    Color? fill,
    Color? positive,
    Color? positiveFill,
    Color? caution,
    Color? cautionFill,
    Color? critical,
    Color? criticalFill,
  }) => AppSemanticColors(
    groupedBackground: groupedBackground ?? this.groupedBackground,
    surface: surface ?? this.surface,
    surfaceRaised: surfaceRaised ?? this.surfaceRaised,
    label: label ?? this.label,
    labelSecondary: labelSecondary ?? this.labelSecondary,
    labelTertiary: labelTertiary ?? this.labelTertiary,
    separator: separator ?? this.separator,
    fill: fill ?? this.fill,
    positive: positive ?? this.positive,
    positiveFill: positiveFill ?? this.positiveFill,
    caution: caution ?? this.caution,
    cautionFill: cautionFill ?? this.cautionFill,
    critical: critical ?? this.critical,
    criticalFill: criticalFill ?? this.criticalFill,
  );

  @override
  AppSemanticColors lerp(AppSemanticColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppSemanticColors(
      groupedBackground: mix(groupedBackground, other.groupedBackground),
      surface: mix(surface, other.surface),
      surfaceRaised: mix(surfaceRaised, other.surfaceRaised),
      label: mix(label, other.label),
      labelSecondary: mix(labelSecondary, other.labelSecondary),
      labelTertiary: mix(labelTertiary, other.labelTertiary),
      separator: mix(separator, other.separator),
      fill: mix(fill, other.fill),
      positive: mix(positive, other.positive),
      positiveFill: mix(positiveFill, other.positiveFill),
      caution: mix(caution, other.caution),
      cautionFill: mix(cautionFill, other.cautionFill),
      critical: mix(critical, other.critical),
      criticalFill: mix(criticalFill, other.criticalFill),
    );
  }
}

extension AppThemeContext on BuildContext {
  ColorScheme get scheme => Theme.of(this).colorScheme;
  AppSemanticColors get colors =>
      Theme.of(this).extension<AppSemanticColors>() ?? AppSemanticColors.light;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

abstract final class AppTheme {
  static ThemeData light() => _build(
    brightness: Brightness.light,
    semantics: AppSemanticColors.light,
    accent: AppColors.accent,
    onAccent: AppColors.onAccent,
  );

  static ThemeData dark() => _build(
    brightness: Brightness.dark,
    semantics: AppSemanticColors.dark,
    accent: AppColors.darkAccent,
    onAccent: AppColors.onDarkAccent,
  );

  static ThemeData _build({
    required Brightness brightness,
    required AppSemanticColors semantics,
    required Color accent,
    required Color onAccent,
  }) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: accent,
      onPrimary: onAccent,
      secondary: semantics.positive,
      onSecondary: onAccent,
      surface: semantics.surface,
      onSurface: semantics.label,
      error: semantics.critical,
      onError: onAccent,
      outline: semantics.separator,
      outlineVariant: semantics.separator,
    );

    final text = TextTheme(
      displayLarge: AppTypography.largeTitle,
      headlineLarge: AppTypography.title1,
      headlineMedium: AppTypography.title2,
      headlineSmall: AppTypography.title3,
      titleMedium: AppTypography.headline,
      bodyLarge: AppTypography.body,
      bodyMedium: AppTypography.callout,
      bodySmall: AppTypography.footnote,
      labelLarge: AppTypography.headline,
      labelMedium: AppTypography.subhead,
      labelSmall: AppTypography.caption,
    ).apply(bodyColor: semantics.label, displayColor: semantics.label);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: semantics.groupedBackground,
      textTheme: text,
      extensions: [semantics],
      // 물결 잉크는 iOS 감각과 어긋난다. 눌림은 색과 축소로 표현한다.
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,

      appBarTheme: AppBarTheme(
        backgroundColor: semantics.groupedBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.headline.copyWith(color: semantics.label),
        iconTheme: IconThemeData(color: accent, size: 22),
        actionsIconTheme: IconThemeData(color: accent, size: 22),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 50),
          backgroundColor: accent,
          foregroundColor: onAccent,
          disabledBackgroundColor: semantics.fill,
          disabledForegroundColor: semantics.labelTertiary,
          shape: AppShapes.control,
          textStyle: AppTypography.headline,
          padding: const EdgeInsets.symmetric(horizontal: Space.xl),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 50),
          foregroundColor: accent,
          // 테두리 대신 옅은 채움. 애플은 보조 버튼에 선을 잘 쓰지 않는다.
          backgroundColor: semantics.fill,
          side: BorderSide.none,
          shape: AppShapes.control,
          textStyle: AppTypography.headline,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, Layout.minTouchTarget),
          foregroundColor: accent,
          textStyle: AppTypography.body,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: semantics.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Space.lg,
          vertical: 14,
        ),
        border: _fieldBorder(Colors.transparent),
        enabledBorder: _fieldBorder(Colors.transparent),
        focusedBorder: _fieldBorder(accent, width: 2),
        errorBorder: _fieldBorder(semantics.critical),
        focusedErrorBorder: _fieldBorder(semantics.critical, width: 2),
        hintStyle: AppTypography.body.copyWith(color: semantics.labelTertiary),
        labelStyle: AppTypography.body.copyWith(
          color: semantics.labelSecondary,
        ),
        floatingLabelStyle: AppTypography.footnote.copyWith(color: accent),
        helperStyle: AppTypography.footnote.copyWith(
          color: semantics.labelSecondary,
        ),
        helperMaxLines: 3,
        errorStyle: AppTypography.footnote.copyWith(color: semantics.critical),
        errorMaxLines: 3,
      ),

      dividerTheme: DividerThemeData(
        color: semantics.separator,
        space: 1,
        thickness: 0.5,
      ),

      cardTheme: CardThemeData(
        color: semantics.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: AppShapes.card,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: semantics.fill,
        selectedColor: accent,
        checkmarkColor: onAccent,
        side: BorderSide.none,
        showCheckmark: false,
        labelStyle: AppTypography.subhead.copyWith(color: semantics.label),
        secondaryLabelStyle: AppTypography.subhead.copyWith(color: onAccent),
        shape: const RoundedSuperellipseBorder(
          borderRadius: BorderRadius.all(Radius.circular(Radii.pill)),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: Space.md,
          vertical: Space.sm,
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        insetPadding: const EdgeInsets.all(Space.lg),
        backgroundColor: brightness == Brightness.light
            ? const Color(0xF21C1C1E)
            : const Color(0xF2F2F2F7),
        contentTextStyle: AppTypography.subhead.copyWith(
          color: brightness == Brightness.light
              ? AppColors.lightSurface
              : AppColors.lightLabel,
        ),
        actionTextColor: brightness == Brightness.light
            ? AppColors.darkAccent
            : AppColors.accent,
        shape: AppShapes.control,
        elevation: 0,
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: semantics.groupedBackground,
        surfaceTintColor: Colors.transparent,
        shape: AppShapes.sheet,
        elevation: 0,
        showDragHandle: true,
        dragHandleColor: semantics.labelTertiary,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: semantics.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: AppShapes.hero,
        titleTextStyle: AppTypography.title3.copyWith(color: semantics.label),
        contentTextStyle: AppTypography.subhead.copyWith(
          color: semantics.labelSecondary,
        ),
      ),

      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          textStyle: const WidgetStatePropertyAll(AppTypography.subhead),
          side: const WidgetStatePropertyAll(BorderSide.none),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? semantics.surface
                : Colors.transparent,
          ),
          foregroundColor: WidgetStatePropertyAll(semantics.label),
          shape: const WidgetStatePropertyAll(
            RoundedSuperellipseBorder(
              borderRadius: BorderRadius.all(Radius.circular(Radii.sm)),
            ),
          ),
        ),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: accent,
        linearTrackColor: semantics.fill,
        linearMinHeight: 6,
        circularTrackColor: Colors.transparent,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? semantics.positive
              : semantics.fill,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: Space.rowInset),
        minVerticalPadding: Space.md,
        titleTextStyle: AppTypography.body.copyWith(color: semantics.label),
        subtitleTextStyle: AppTypography.footnote.copyWith(
          color: semantics.labelSecondary,
        ),
        iconColor: semantics.labelSecondary,
      ),
    );
  }

  static OutlineInputBorder _fieldBorder(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: AppShapes.cardRadius,
        borderSide: color == Colors.transparent
            ? BorderSide.none
            : BorderSide(color: color, width: width),
      );
}
