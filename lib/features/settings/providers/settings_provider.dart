import 'package:flutter_riverpod/flutter_riverpod.dart';

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
}

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() => const SettingsState();

  /// Generic, copyWith-style mutation — keeps the API small while supporting
  /// every field. Usage: `edit((s) => s.copyWith(analytics: v))`.
  void edit(SettingsState Function(SettingsState s) update) =>
      state = update(state);
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);
