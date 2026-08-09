import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around SharedPreferences for the few flags cinemapedia stores
/// locally: onboarding completion, theme mode, last search terms.
///
/// All getters return defaults if the key is missing. All setters are
/// fire-and-forget; the in-memory cache is updated immediately so the next
/// read sees the new value.
class AppPreferences {
  AppPreferences._(this._prefs);

  final SharedPreferences _prefs;

  static AppPreferences? _instance;

  static Future<AppPreferences> create() async {
    final prefs = await SharedPreferences.getInstance();
    _instance = AppPreferences._(prefs);
    return _instance!;
  }

  static AppPreferences get instance {
    final i = _instance;
    if (i == null) {
      throw StateError('AppPreferences.create() must be awaited before use');
    }
    return i;
  }

  // Onboarding
  bool get onboardingDone => _prefs.getBool('onboarding_done') ?? false;
  Future<void> setOnboardingDone() => _prefs.setBool('onboarding_done', true);

  // Theme mode — 'system' | 'light' | 'dark'
  String get themeMode => _prefs.getString('theme_mode') ?? 'dark';
  Future<void> setThemeMode(String value) => _prefs.setString('theme_mode', value);

  // Recent searches (last 5)
  List<String> get recentSearches => _prefs.getStringList('recent_searches') ?? const <String>[];
  Future<void> setRecentSearches(List<String> values) =>
      _prefs.setStringList('recent_searches', values);
}
