import 'package:cinemapedia/config/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Convenience getters that read the current brightness from `Theme.of(context)`
/// and return the right token. Every widget that paints with a brand colour
/// should reach for these instead of importing AppColors directly — that way
/// the colour tracks the active theme for free.
///
/// Usage:
///
///     Widget build(BuildContext context) {
///       return Container(color: context.colors.surface);
///     }
extension AppColorsContext on BuildContext {
  AppColorsResolver get colors {
    final brightness = Theme.of(this).brightness;
    return AppColorsResolver(brightness);
  }
}

/// Lightweight wrapper that exposes the resolved tokens for one brightness.
/// Read this from [BuildContext.colors] inside a widget's `build` method —
/// do not cache it across rebuilds.
class AppColorsResolver {
  AppColorsResolver(this.brightness);

  final Brightness brightness;

  Color get paper => AppColors.paper(brightness);
  Color get surface => AppColors.surface(brightness);
  Color get surfaceRaised => AppColors.surfaceRaised(brightness);
  Color get surfaceHighest => AppColors.surfaceHighest(brightness);
  Color get rule => AppColors.rule(brightness);
  Color get outlineVariant => AppColors.outlineVariant(brightness);
  Color get text => AppColors.text(brightness);
  Color get textMuted => AppColors.textMuted(brightness);
  Color get textHint => AppColors.textHint(brightness);
  Color get icon => AppColors.icon(brightness);
  Color get iconMuted => AppColors.iconMuted(brightness);
  Color get accent => AppColors.accent(brightness);
  Color get accentInk => AppColors.accentInk;
  Color get rating => AppColors.rating(brightness);
  Color get danger => AppColors.danger;

  List<Color> get heroGradient => AppColors.heroGradient(brightness);
  Color get heroTopShade => AppColors.heroTopShade(brightness);
  List<Color> get glassGradient => AppColors.glassGradient(brightness);
  Color get chipBorder => AppColors.chipBorder(brightness);
}
