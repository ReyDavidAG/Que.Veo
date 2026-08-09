import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Builds the two `ThemeData` cinemapedia ships with.
///
/// cinemapedia supports both dark (default) and light. The choice lives in
/// `AppPreferences.themeMode` and is wired into `MaterialApp.themeMode` via
/// `themeModeProvider`. `Theme.of(context).brightness` is the per-widget
/// switch every screen should read.
class AppTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final stack = AppColors.surfaceStack(brightness);
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.accent(brightness),
      onPrimary: AppColors.accentInk,
      secondary: AppColors.accent(brightness),
      onSecondary: AppColors.accentInk,
      tertiary: AppColors.rating(brightness),
      onTertiary: AppColors.text(brightness),
      error: AppColors.danger,
      onError: AppColors.accentInk,
      surface: stack[0],
      onSurface: AppColors.text(brightness),
      surfaceContainerLowest: stack[0],
      surfaceContainerLow: stack[1],
      surfaceContainer: stack[1],
      surfaceContainerHigh: stack[2],
      surfaceContainerHighest: stack[3],
      outline: AppColors.rule(brightness),
      outlineVariant: AppColors.outlineVariant(brightness),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: stack[0],
      textTheme: AppTypography.textTheme.apply(
        bodyColor: AppColors.text(brightness),
        displayColor: AppColors.text(brightness),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.icon(brightness)),
        titleTextStyle: TextStyle(
          color: AppColors.text(brightness),
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      iconTheme: IconThemeData(color: AppColors.icon(brightness)),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.text(brightness),
        unselectedItemColor: AppColors.iconMuted(brightness),
      ),
    );
  }
}
