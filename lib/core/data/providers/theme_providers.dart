import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kThemeModeKey = 'theme_mode';
const _kAccentColorKey = 'accent_color';

// ---------------------------------------------------------------------------
// Accent color presets
// ---------------------------------------------------------------------------

const kAccentPresets = <int>[
  0xFF00897B, // Teal (default)
  0xFF1E88E5, // Blue
  0xFF3949AB, // Indigo
  0xFF8E24AA, // Purple
  0xFFD81B60, // Pink
  0xFFE53935, // Red
  0xFFF4511E, // Deep Orange
  0xFFFB8C00, // Orange
  0xFF43A047, // Green
  0xFF546E7A, // Slate
];

// ---------------------------------------------------------------------------
// Theme mode
// ---------------------------------------------------------------------------

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(SharedPreferences prefs)
      : _prefs = prefs,
        super(_readMode(prefs));

  final SharedPreferences _prefs;

  static ThemeMode _readMode(SharedPreferences prefs) {
    final value = prefs.getString(_kThemeModeKey);
    if (value == null) return ThemeMode.system;
    return ThemeMode.values.firstWhere(
      (m) => m.name == value,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await _prefs.setString(_kThemeModeKey, mode.name);
  }
}

// ---------------------------------------------------------------------------
// Accent color
// ---------------------------------------------------------------------------

class AccentColorNotifier extends StateNotifier<int> {
  AccentColorNotifier(SharedPreferences prefs)
      : _prefs = prefs,
        super(prefs.getInt(_kAccentColorKey) ?? kAccentPresets.first);

  final SharedPreferences _prefs;

  Future<void> setColor(int colorValue) async {
    state = colorValue;
    await _prefs.setInt(_kAccentColorKey, colorValue);
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref.watch(sharedPreferencesProvider));
});

final accentColorProvider =
    StateNotifierProvider<AccentColorNotifier, int>((ref) {
  return AccentColorNotifier(ref.watch(sharedPreferencesProvider));
});
