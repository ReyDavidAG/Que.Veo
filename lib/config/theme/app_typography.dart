import 'package:flutter/material.dart';

/// Type scale on a major third (1.25) from a 13 px base. These are the
/// `TextTheme` slots the code actually assigns.
///
/// Two weights do all the work: 500 (UI controls, tab labels, buttons) and 700
/// (every heading). Body and small body are 400. No weight below 400.
class AppTypography {
  AppTypography._();

  static const double _base = 13;

  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(fontSize: _base * 2.15, fontWeight: FontWeight.w700, height: 1.15, letterSpacing: -0.5),
    displayMedium: TextStyle(fontSize: _base * 1.85, fontWeight: FontWeight.w700, height: 1.20, letterSpacing: -0.4),
    headlineLarge: TextStyle(fontSize: _base * 1.70, fontWeight: FontWeight.w700, height: 1.25, letterSpacing: -0.3),
    headlineMedium: TextStyle(fontSize: _base * 1.40, fontWeight: FontWeight.w700, height: 1.30),
    titleLarge: TextStyle(fontSize: _base * 1.25, fontWeight: FontWeight.w700, height: 1.30, letterSpacing: -0.2),
    titleMedium: TextStyle(fontSize: _base * 1.10, fontWeight: FontWeight.w700, height: 1.35),
    titleSmall: TextStyle(fontSize: _base * 1.00, fontWeight: FontWeight.w500, height: 1.40),
    bodyLarge: TextStyle(fontSize: _base * 1.10, fontWeight: FontWeight.w400, height: 1.50),
    bodyMedium: TextStyle(fontSize: _base * 1.00, fontWeight: FontWeight.w400, height: 1.45),
    bodySmall: TextStyle(fontSize: _base * 0.92, fontWeight: FontWeight.w400, height: 1.40),
    labelLarge: TextStyle(fontSize: _base * 1.00, fontWeight: FontWeight.w500, height: 1.30, letterSpacing: 0.1),
    labelMedium: TextStyle(fontSize: _base * 0.92, fontWeight: FontWeight.w500, height: 1.30, letterSpacing: 0.2),
    labelSmall: TextStyle(fontSize: _base * 0.85, fontWeight: FontWeight.w500, height: 1.25, letterSpacing: 0.5),
  );
}
