import 'package:cinemapedia/config/storage/app_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reactive holder for the user's theme choice. Reads the persisted value
/// from [AppPreferences] at boot and exposes a setter that writes back.
///
/// `MaterialApp.themeMode` reads this so flipping the SegmentedButton in
/// Settings applies on the very next frame.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(_load());

  static ThemeMode _load() {
    final raw = AppPreferences.instance.themeMode;
    return switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await AppPreferences.instance.setThemeMode(_encode(mode));
  }

  String _encode(ThemeMode mode) => switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) => ThemeModeNotifier());
