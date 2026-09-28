import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings_provider.dart';

/// The languages the Settings → Units & Region selector offers, in the exact
/// display-string form the chip group uses, mapped to their [Locale].
///
/// Keys MUST match the option strings in user_preferences_screen's Language
/// _ChoiceRow: ['English', 'Español', 'Français', 'हिन्दी'].
const Map<String, Locale> kSupportedLanguages = {
  'English': Locale('en'),
  'Español': Locale('es'),
  'Français': Locale('fr'),
  'हिन्दी': Locale('hi'),
};

/// Reverse lookup: a Locale's languageCode → the display string used by the
/// settings selector (so a Locale restored from prefs maps back to a chip).
String languageLabelForLocale(Locale locale) {
  for (final entry in kSupportedLanguages.entries) {
    if (entry.value.languageCode == locale.languageCode) return entry.key;
  }
  return 'English';
}

/// The app's current [Locale], derived from the `language` preference.
///
/// main.dart wires this into MaterialApp via `locale: ref.watch(localeProvider)`
/// so changing the language on the Settings screen re-renders the whole app in
/// the new language. Watching this at startup also builds [settingsProvider],
/// which syncs [Fmt] currency/unit statics (see SettingsNotifier).
final localeProvider = Provider<Locale>((ref) {
  final language = ref.watch(settingsProvider.select((s) => s.language));
  return kSupportedLanguages[language] ?? const Locale('en');
});

/// The active currency code (USD/EUR/GBP/INR) from settings. Widgets that want
/// to rebuild live when the currency changes can watch this; the actual
/// formatting lives in [Fmt] (kept in sync by SettingsNotifier).
final currencyProvider = Provider<String>((ref) {
  return ref.watch(settingsProvider.select((s) => s.currency));
});

/// The active volume unit ('ml'/'oz') from settings.
final volumeUnitProvider = Provider<String>((ref) {
  return ref.watch(settingsProvider.select((s) => s.volumeUnit));
});
