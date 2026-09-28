import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/preferences_service.dart';
import '../../../core/utils/formatters.dart';

/// App-wide settings: notification toggles, privacy choices and user
/// preferences (units / region). Single source of truth for the three
/// settings screens that previously held their own `setState` booleans.
class SettingsState {
  // ── Notifications ──────────────────────────────────────────────────────────
  final bool allNotifications;
  final bool routineReminders;
  final bool skinScoreUpdates;
  final bool productExpiryAlerts;
  final bool specialistReminders;
  final bool rewardAlerts;
  final bool orderUpdates;
  final bool promotions;
  final bool quietHours;

  // ── Privacy ────────────────────────────────────────────────────────────────
  final bool analytics;
  final bool personalization;
  final bool shareWithPartners;
  final bool biometricLock;

  // ── Preferences: reminders ─────────────────────────────────────────────────
  final bool amReminder;
  final bool pmReminder;
  final bool checkInReminder;

  // ── Preferences: notifications ─────────────────────────────────────────────
  final bool prefExpiryAlerts;
  final bool prefScoreUpdates;
  final bool tipsArticles;
  final bool appointmentReminders;

  // ── Preferences: units & region ────────────────────────────────────────────
  final String currency;
  final String volumeUnit;
  final String firstDayOfWeek;
  final String language;

  const SettingsState({
    this.allNotifications = true,
    this.routineReminders = true,
    this.skinScoreUpdates = true,
    this.productExpiryAlerts = true,
    this.specialistReminders = false,
    this.rewardAlerts = true,
    this.orderUpdates = true,
    this.promotions = false,
    this.quietHours = true,
    this.analytics = true,
    this.personalization = true,
    this.shareWithPartners = false,
    this.biometricLock = false,
    this.amReminder = true,
    this.pmReminder = true,
    this.checkInReminder = false,
    this.prefExpiryAlerts = true,
    this.prefScoreUpdates = true,
    this.tipsArticles = false,
    this.appointmentReminders = true,
    this.currency = 'USD',
    this.volumeUnit = 'ml',
    this.firstDayOfWeek = 'Sunday',
    this.language = 'English',
  });

  SettingsState copyWith({
    bool? allNotifications,
    bool? routineReminders,
    bool? skinScoreUpdates,
    bool? productExpiryAlerts,
    bool? specialistReminders,
    bool? rewardAlerts,
    bool? orderUpdates,
    bool? promotions,
    bool? quietHours,
    bool? analytics,
    bool? personalization,
    bool? shareWithPartners,
    bool? biometricLock,
    bool? amReminder,
    bool? pmReminder,
    bool? checkInReminder,
    bool? prefExpiryAlerts,
    bool? prefScoreUpdates,
    bool? tipsArticles,
    bool? appointmentReminders,
    String? currency,
    String? volumeUnit,
    String? firstDayOfWeek,
    String? language,
  }) {
    return SettingsState(
      allNotifications: allNotifications ?? this.allNotifications,
      routineReminders: routineReminders ?? this.routineReminders,
      skinScoreUpdates: skinScoreUpdates ?? this.skinScoreUpdates,
      productExpiryAlerts: productExpiryAlerts ?? this.productExpiryAlerts,
      specialistReminders: specialistReminders ?? this.specialistReminders,
      rewardAlerts: rewardAlerts ?? this.rewardAlerts,
      orderUpdates: orderUpdates ?? this.orderUpdates,
      promotions: promotions ?? this.promotions,
      quietHours: quietHours ?? this.quietHours,
      analytics: analytics ?? this.analytics,
      personalization: personalization ?? this.personalization,
      shareWithPartners: shareWithPartners ?? this.shareWithPartners,
      biometricLock: biometricLock ?? this.biometricLock,
      amReminder: amReminder ?? this.amReminder,
      pmReminder: pmReminder ?? this.pmReminder,
      checkInReminder: checkInReminder ?? this.checkInReminder,
      prefExpiryAlerts: prefExpiryAlerts ?? this.prefExpiryAlerts,
      prefScoreUpdates: prefScoreUpdates ?? this.prefScoreUpdates,
      tipsArticles: tipsArticles ?? this.tipsArticles,
      appointmentReminders: appointmentReminders ?? this.appointmentReminders,
      currency: currency ?? this.currency,
      volumeUnit: volumeUnit ?? this.volumeUnit,
      firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
      language: language ?? this.language,
    );
  }

  Map<String, dynamic> toMap() => {
        'allNotifications': allNotifications,
        'routineReminders': routineReminders,
        'skinScoreUpdates': skinScoreUpdates,
        'productExpiryAlerts': productExpiryAlerts,
        'specialistReminders': specialistReminders,
        'rewardAlerts': rewardAlerts,
        'orderUpdates': orderUpdates,
        'promotions': promotions,
        'quietHours': quietHours,
        'analytics': analytics,
        'personalization': personalization,
        'shareWithPartners': shareWithPartners,
        'biometricLock': biometricLock,
        'amReminder': amReminder,
        'pmReminder': pmReminder,
        'checkInReminder': checkInReminder,
        'prefExpiryAlerts': prefExpiryAlerts,
        'prefScoreUpdates': prefScoreUpdates,
        'tipsArticles': tipsArticles,
        'appointmentReminders': appointmentReminders,
        'currency': currency,
        'volumeUnit': volumeUnit,
        'firstDayOfWeek': firstDayOfWeek,
        'language': language,
      };

  factory SettingsState.fromMap(Map<String, dynamic> m) {
    bool b(String k, bool d) => m[k] is bool ? m[k] as bool : d;
    String s(String k, String d) => m[k] is String ? m[k] as String : d;
    const def = SettingsState();
    return SettingsState(
      allNotifications: b('allNotifications', def.allNotifications),
      routineReminders: b('routineReminders', def.routineReminders),
      skinScoreUpdates: b('skinScoreUpdates', def.skinScoreUpdates),
      productExpiryAlerts: b('productExpiryAlerts', def.productExpiryAlerts),
      specialistReminders: b('specialistReminders', def.specialistReminders),
      rewardAlerts: b('rewardAlerts', def.rewardAlerts),
      orderUpdates: b('orderUpdates', def.orderUpdates),
      promotions: b('promotions', def.promotions),
      quietHours: b('quietHours', def.quietHours),
      analytics: b('analytics', def.analytics),
      personalization: b('personalization', def.personalization),
      shareWithPartners: b('shareWithPartners', def.shareWithPartners),
      biometricLock: b('biometricLock', def.biometricLock),
      amReminder: b('amReminder', def.amReminder),
      pmReminder: b('pmReminder', def.pmReminder),
      checkInReminder: b('checkInReminder', def.checkInReminder),
      prefExpiryAlerts: b('prefExpiryAlerts', def.prefExpiryAlerts),
      prefScoreUpdates: b('prefScoreUpdates', def.prefScoreUpdates),
      tipsArticles: b('tipsArticles', def.tipsArticles),
      appointmentReminders: b('appointmentReminders', def.appointmentReminders),
      currency: s('currency', def.currency),
      volumeUnit: s('volumeUnit', def.volumeUnit),
      firstDayOfWeek: s('firstDayOfWeek', def.firstDayOfWeek),
      language: s('language', def.language),
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    final raw = PreferencesService.settingsJson;
    SettingsState s;
    if (raw == null || raw.isEmpty) {
      s = const SettingsState();
    } else {
      try {
        s = SettingsState.fromMap(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {
        s = const SettingsState();
      }
    }
    // Sync the app-wide display formatters to the loaded prefs so currency /
    // volume units render correctly from first paint. (localeProvider watches
    // this notifier, and main.dart watches localeProvider, so this build runs
    // at startup.)
    _syncFormatters(s);
    return s;
  }

  /// Generic, copyWith-style mutation — keeps the API small while supporting
  /// every field. Usage: `edit((s) => s.copyWith(analytics: v))`.
  void edit(SettingsState Function(SettingsState s) update) {
    state = update(state);
    _syncFormatters(state);
    PreferencesService.setSettingsJson(jsonEncode(state.toMap()));
  }

  /// Pushes the currency + volume-unit choices into [Fmt]'s static formatters.
  void _syncFormatters(SettingsState s) {
    Fmt.setCurrency(s.currency);
    Fmt.setVolumeUnit(s.volumeUnit);
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);
