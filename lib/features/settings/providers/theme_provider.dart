import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────

enum AppThemeMode { light, dark, system }

extension AppThemeModeX on AppThemeMode {
  ThemeMode get flutterMode {
    switch (this) {
      case AppThemeMode.light:  return ThemeMode.light;
      case AppThemeMode.dark:   return ThemeMode.dark;
      case AppThemeMode.system: return ThemeMode.system;
    }
  }

  String get label {
    switch (this) {
      case AppThemeMode.light:  return 'Light';
      case AppThemeMode.dark:   return 'Dark';
      case AppThemeMode.system: return 'System';
    }
  }

  IconData get icon {
    switch (this) {
      case AppThemeMode.light:  return Icons.light_mode_rounded;
      case AppThemeMode.dark:   return Icons.dark_mode_rounded;
      case AppThemeMode.system: return Icons.brightness_auto_rounded;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────

const _kThemeKey = 'app_theme_mode';

class ThemeNotifier extends AsyncNotifier<AppThemeMode> {
  @override
  Future<AppThemeMode> build() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_kThemeKey);
    if (stored == null) return AppThemeMode.light;
    return AppThemeMode.values.firstWhere(
      (m) => m.name == stored,
      orElse: () => AppThemeMode.light,
    );
  }

  Future<void> setTheme(AppThemeMode mode) async {
    // Update state instantly — no page reload.
    state = AsyncData(mode);
    // Persist locally.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeKey, mode.name);
    // Firebase stub — wire when google-services.json is committed:
    // final uid = ref.read(authStateProvider)?.id;
    // if (uid != null) {
    //   await ref.read(userRepositoryProvider)
    //       ?.updateSettings(uid, {'selectedTheme': mode.name});
    // }
  }
}

final themeProvider =
    AsyncNotifierProvider<ThemeNotifier, AppThemeMode>(ThemeNotifier.new);
