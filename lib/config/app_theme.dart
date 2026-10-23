/// Material theme built from the Dino Pals tokens.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tokens.dart';

abstract final class AppTheme {
  static ThemeData get current {
    const colors = ColorScheme(
      brightness: Brightness.light,
      surface: AppColors.background,
      primary: AppColors.accent,
      onPrimary: AppColors.onAccent,
      onSurface: AppColors.text,
      secondary: AppColors.text,
      onSecondary: AppColors.background,
      error: AppColors.danger,
      onError: AppColors.highlight,
    );

    TextStyle body(double size, FontWeight weight, Color color) => TextStyle(
      fontFamily: AppFonts.body,
      fontFamilyFallback: AppFonts.fallback,
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: AppType.bodyHeight,
    );

    /// Display face: dark-brown fill + cream halo so Luckiest Guy stays
    /// readable on sand / cream. The sky title opts into the yellow sticker.
    TextStyle display(double size, FontWeight weight, {bool halo = true}) {
      return TextStyle(
        fontFamily: AppFonts.display,
        fontFamilyFallback: AppFonts.fallback,
        fontSize: size,
        fontWeight: weight,
        color: AppColors.text,
        letterSpacing: halo ? AppType.displayTracking : AppType.tightTracking,
        height: AppType.heroHeight,
        shadows: halo ? AppType.displayHalo : null,
      );
    }

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colors,
      fontFamily: AppFonts.body,
      fontFamilyFallback: AppFonts.fallback,
      scaffoldBackgroundColor: AppColors.background,
      splashFactory: InkSparkle.splashFactory,
      textTheme: TextTheme(
        displayLarge: display(AppType.hero, FontWeight.w800),
        displayMedium: display(AppType.display, FontWeight.w700),
        titleLarge: display(AppType.title, FontWeight.w700, halo: false),
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
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceHigh,
        contentTextStyle: body(AppType.bodySmall, FontWeight.w500, AppColors.text),
      ),
      appBarTheme: const AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.transparent,
          systemNavigationBarColor: AppColors.background,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),
    );
  }

  /// Kept for callers that still say `AppTheme.dark`.
  static ThemeData get dark => current;
}
