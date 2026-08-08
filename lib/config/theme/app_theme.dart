import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Wires the design tokens into a `ThemeData` cinemapedia can boot with.
///
/// cinemapedia is dark-only. `AppColors`, `AppTypography`, `AppSpacing`, and
/// `AppMotion` are the source of truth — `ThemeData` is the bridge between them
/// and Flutter's widget tree.
class AppTheme {
  ThemeData getTheme() {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.accent,
      onPrimary: AppColors.accentInk,
      secondary: AppColors.accent,
      onSecondary: AppColors.accentInk,
      tertiary: AppColors.rating,
      onTertiary: AppColors.text,
      error: AppColors.danger,
      onError: AppColors.text,
      surface: AppColors.paper,
      onSurface: AppColors.text,
      surfaceContainerLowest: AppColors.paper,
      surfaceContainerLow: AppColors.surface,
      surfaceContainer: AppColors.surface,
      surfaceContainerHigh: AppColors.surfaceRaised,
      surfaceContainerHighest: AppColors.surfaceHighest,
      outline: AppColors.rule,
      outlineVariant: AppColors.outlineVariant,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.paper,
      textTheme: AppTypography.textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.icon),
        titleTextStyle: TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.w700),
      ),
      iconTheme: const IconThemeData(color: AppColors.icon),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.text,
        unselectedItemColor: Color(0x99FFFFFF), // 60% white — to be replaced by token in widget migration
      ),
    );
  }
}
