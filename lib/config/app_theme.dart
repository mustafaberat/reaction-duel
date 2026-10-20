/// Material theme built from tokens.
library;

import 'package:flutter/material.dart';

import 'tokens.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    const colors = ColorScheme.dark(
      surface: AppColors.background,
      primary: AppColors.accent,
      onPrimary: AppColors.onAccent,
      onSurface: AppColors.text,
      secondary: AppColors.text,
      error: AppColors.danger,
    );

    TextStyle body(double size, FontWeight weight, Color color) => TextStyle(
      fontFamily: AppFonts.body,
      fontFamilyFallback: AppFonts.fallback,
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: AppType.bodyHeight,
    );

    TextStyle display(double size, FontWeight weight) => TextStyle(
      fontFamily: AppFonts.display,
      fontFamilyFallback: AppFonts.fallback,
      fontSize: size,
      fontWeight: weight,
      color: AppColors.text,
      letterSpacing: AppType.tightTracking,
      height: AppType.heroHeight,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colors,
      fontFamily: AppFonts.body,
      fontFamilyFallback: AppFonts.fallback,
      scaffoldBackgroundColor: AppColors.background,
      splashFactory: InkSparkle.splashFactory,
      textTheme: TextTheme(
        displayLarge: display(AppType.hero, FontWeight.w800),
        displayMedium: display(AppType.display, FontWeight.w700),
        titleLarge: display(AppType.title, FontWeight.w700),
        titleMedium: body(AppType.body, FontWeight.w600, AppColors.text),
        bodyLarge: body(AppType.body, FontWeight.w400, AppColors.text),
        bodyMedium: body(AppType.bodySmall, FontWeight.w400, AppColors.textMuted),
        bodySmall: body(AppType.caption, FontWeight.w500, AppColors.textMuted),
        labelLarge: body(AppType.button, FontWeight.w600, AppColors.text),
        labelSmall: body(
          AppType.overline,
          FontWeight.w600,
          AppColors.textMuted,
        ).copyWith(letterSpacing: AppType.overlineTracking),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.onAccent : AppColors.textMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.accent : AppColors.surfaceHigh,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(AppColors.transparent),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.accent,
        selectionColor: AppColors.hairline,
        selectionHandleColor: AppColors.accent,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        showDragHandle: true,
        dragHandleColor: AppColors.stroke,
      ),
    );
  }
}
