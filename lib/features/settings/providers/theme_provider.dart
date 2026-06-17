import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/firebase/repositories/user_repository.dart';
import '../../auth/providers/auth_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────

enum AppThemeMode { light, dark }

extension AppThemeModeX on AppThemeMode {
  ThemeMode get flutterMode {
    switch (this) {
      case AppThemeMode.light: return ThemeMode.light;
      case AppThemeMode.dark:  return ThemeMode.dark;
    }
  }

  String get label {
    switch (this) {
      case AppThemeMode.light: return 'Light';
      case AppThemeMode.dark:  return 'Dark';
    }
  }

  String get description {
    switch (this) {
      case AppThemeMode.light: return 'Bright & clean';
      case AppThemeMode.dark:  return 'Easy on the eyes';
    }
  }

  IconData get icon {
    switch (this) {
      case AppThemeMode.light: return Icons.light_mode_rounded;
      case AppThemeMode.dark:  return Icons.dark_mode_rounded;
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
    // Mirror to Firestore (no-op when signed out / Firebase unavailable).
    final uid = ref.read(authStateProvider)?.id;
    final repo = ref.read(userRepositoryProvider);
    if (uid != null && repo != null) {
      await repo.updateFields(uid, {'selectedTheme': mode.name});
    }
  }
}

final themeProvider =
    AsyncNotifierProvider<ThemeNotifier, AppThemeMode>(ThemeNotifier.new);
