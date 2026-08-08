import 'package:flutter/material.dart';

/// Dark palette anchored on cinematic navy. cinemapedia is dark-only — no light mode.
///
/// Every neutral carries a trace of the navy anchor. `paper`, `surface`, and
/// `surfaceRaised` form the three elevation steps; `text` and `textMuted` carry
/// hierarchy on top of any of them.
///
/// The accent is a vibrant coral-pink that reads against navy without competing
/// with amber star ratings. Amber is reserved for ratings and never used as a
/// primary action colour.
class AppColors {
  AppColors._();

  // Surface (paper → highest elevation)
  static const Color paper = Color(0xFF0E1427);
  static const Color surface = Color(0xFF121A34);
  static const Color surfaceRaised = Color(0xFF16213E);
  static const Color surfaceHighest = Color(0xFF1B1B2F);

  // Rule (dividers and outlines)
  static const Color rule = Color(0x1FFFFFFF); // 12% white
  static const Color outlineVariant = Color(0x33FFFFFF); // 20% white

  // Text
  static const Color text = Colors.white;
  static Color get textMuted => Colors.white.withAlpha(179); // 70%
  static Color get textHint => Colors.white.withAlpha(102); // 40%

  // Icon
  static const Color icon = Colors.white;
  static Color get iconMuted => Colors.white.withAlpha(153); // 60%

  // Accent (primary action — favourite, FAB, focused border)
  static const Color accent = Color(0xFFFF4D6D);
  static const Color accentInk = Colors.white;

  // Rating (star badges)
  static const Color rating = Color(0xFFFFC107);

  // Danger (destructive only)
  static const Color danger = Color(0xFFE53935);
}
