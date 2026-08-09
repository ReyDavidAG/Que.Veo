import 'package:flutter/material.dart';

/// Two palettes for cinemapedia. Dark is the original cinematic navy; light
/// is its daytime counterpart — cool gray paper, navy text, same coral
/// accent. Both anchor on the navy hue so the brand stays consistent.
///
/// Every neutral carries a trace of the anchor. The accent is the same coral
/// on both grounds. Amber rating is reserved for star badges only.
class AppColors {
  AppColors._();

  // ── DARK ─────────────────────────────────────────────────────────────────
  static const Color _darkPaper = Color(0xFF0E1427);
  static const Color _darkSurface = Color(0xFF121A34);
  static const Color _darkSurfaceRaised = Color(0xFF16213E);
  static const Color _darkSurfaceHighest = Color(0xFF1B1B2F);

  // ── LIGHT ────────────────────────────────────────────────────────────────
  static const Color _lightPaper = Color(0xFFF5F5F7);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightSurfaceRaised = Color(0xFFEBEBEF);
  static const Color _lightSurfaceHighest = Color(0xFFE0E0E5);

  /// Returns the four-step elevation stack for the given brightness.
  static List<Color> surfaceStack(Brightness b) => b == Brightness.dark
      ? [_darkPaper, _darkSurface, _darkSurfaceRaised, _darkSurfaceHighest]
      : [_lightPaper, _lightSurface, _lightSurfaceRaised, _lightSurfaceHighest];

  static Color paper(Brightness b) => b == Brightness.dark ? _darkPaper : _lightPaper;
  static Color surface(Brightness b) => b == Brightness.dark ? _darkSurface : _lightSurface;
  static Color surfaceRaised(Brightness b) =>
      b == Brightness.dark ? _darkSurfaceRaised : _lightSurfaceRaised;
  static Color surfaceHighest(Brightness b) =>
      b == Brightness.dark ? _darkSurfaceHighest : _lightSurfaceHighest;

  /// Outline + dividers. Dark uses translucent white; light uses translucent black.
  static Color rule(Brightness b) =>
      b == Brightness.dark ? const Color(0x1FFFFFFF) : const Color(0x1F000000);
  static Color outlineVariant(Brightness b) =>
      b == Brightness.dark ? const Color(0x33FFFFFF) : const Color(0x33000000);

  /// Text. Light mode keeps ink close to pure black to read on white surfaces.
  static Color text(Brightness b) =>
      b == Brightness.dark ? Colors.white : const Color(0xFF0E1427);

  static Color textMuted(Brightness b) => b == Brightness.dark
      ? Colors.white.withAlpha(179) // 70 %
      : const Color(0x990E1427); // navy at 60 %

  static Color textHint(Brightness b) => b == Brightness.dark
      ? Colors.white.withAlpha(102) // 40 %
      : const Color(0x660E1427); // navy at 40 %

  /// Icons follow text.
  static Color icon(Brightness b) =>
      b == Brightness.dark ? Colors.white : const Color(0xFF0E1427);
  static Color iconMuted(Brightness b) => b == Brightness.dark
      ? Colors.white.withAlpha(153) // 60 %
      : const Color(0x990E1427);

  /// Accent is the same coral on both grounds. Slightly darker on light
  /// for better contrast on white surfaces.
  static const Color _accentDark = Color(0xFFFF4D6D);
  static const Color _accentLight = Color(0xFFE63E5E);

  static Color accent(Brightness b) => b == Brightness.dark ? _accentDark : _accentLight;
  static const Color accentInk = Colors.white;

  /// Rating amber — slightly muted on light so it does not shout.
  static const Color _ratingDark = Color(0xFFFFC107);
  static const Color _ratingLight = Color(0xFFF5A300);

  static Color rating(Brightness b) => b == Brightness.dark ? _ratingDark : _ratingLight;

  /// Danger keeps the same red on both grounds.
  static const Color danger = Color(0xFFE53935);

  /// Hero gradient stacks for full-bleed surfaces (HomeView, CategoriesView,
  /// FavoritesView, FullScreenLoader, MoviesByGenreScreen).
  static List<Color> heroGradient(Brightness b) => b == Brightness.dark
      ? const [Colors.black, Color(0xFF0E1427), Color(0xFF121A34)]
      : const [Color(0xFFE8EAF0), Color(0xFFF5F5F7), Color(0xFFFFFFFF)];

  /// Top-of-hero shade (the dark band that fades to transparent).
  static Color heroTopShade(Brightness b) => b == Brightness.dark
      ? Colors.black.withAlpha(200)
      : Colors.white.withAlpha(230);

  /// Glass overlay for the floating appbar.
  static List<Color> glassGradient(Brightness b) => b == Brightness.dark
      ? [
          Colors.black.withAlpha(200),
          Colors.black.withAlpha(80),
          Colors.transparent,
        ]
      : [
          Colors.white.withAlpha(220),
          Colors.white.withAlpha(140),
          Colors.transparent,
        ];

  /// Chip border on the watch providers row.
  static Color chipBorder(Brightness b) => b == Brightness.dark
      ? Colors.white24
      : const Color(0x33000000);
}
