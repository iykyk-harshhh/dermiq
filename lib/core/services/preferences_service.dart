import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Device-local flags that drive first-launch routing. `_prefs` is nullable so
/// reads are safe before [init] (e.g. in unit tests) — they just default.
class PreferencesService {
  PreferencesService._();

  static const _kOnboarding = 'onboarding_seen';
  static const _kProfileComplete = 'profile_complete';
  static const _kHealthScore = 'health_score';
  static const _kSavedSpecialists = 'saved_specialists';
  static const _kCart = 'cart_items';
  static const _kRoutine = 'routine_state';
  static const _kSettings = 'app_settings';
  static const _kQuiz = 'quiz_state';
  static const _kRoutineLog = 'routine_log';
  static const _kRoutineSteps = 'routine_steps';
  static const _kCheckInLog = 'checkin_log';
  static const _kReminders = 'reminders_state';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static bool get onboardingSeen => _prefs?.getBool(_kOnboarding) ?? false;
  static Future<void> setOnboardingSeen(bool v) async =>
      _prefs?.setBool(_kOnboarding, v);

  static bool get profileComplete => _prefs?.getBool(_kProfileComplete) ?? false;
  static Future<void> setProfileComplete(bool v) async =>
      _prefs?.setBool(_kProfileComplete, v);

  /// Last computed DermIQ Health Score (0–100), cached for instant startup.
  static int get healthScore => _prefs?.getInt(_kHealthScore) ?? 0;
  static Future<void> setHealthScore(int v) async =>
      _prefs?.setInt(_kHealthScore, v);

  /// IDs of specialists the user has saved/bookmarked.
  static List<String> get savedSpecialists =>
      _prefs?.getStringList(_kSavedSpecialists) ?? const [];
  static Future<void> setSavedSpecialists(List<String> ids) async =>
      _prefs?.setStringList(_kSavedSpecialists, ids);

  /// The shopping cart, persisted locally as a JSON string so it survives
  /// app restarts. Null when nothing has been saved yet.
  static String? get cartJson => _prefs?.getString(_kCart);
  static Future<void> setCartJson(String v) async =>
      _prefs?.setString(_kCart, v);

  /// Routine progress (today's completion + history) as a JSON string.
  static String? get routineJson => _prefs?.getString(_kRoutine);
  static Future<void> setRoutineJson(String v) async =>
      _prefs?.setString(_kRoutine, v);

  /// App settings (notification/privacy toggles, units) as a JSON string.
  static String? get settingsJson => _prefs?.getString(_kSettings);
  static Future<void> setSettingsJson(String v) async =>
      _prefs?.setString(_kSettings, v);

  /// Skin + hair quiz answers as a JSON string.
  static String? get quizJson => _prefs?.getString(_kQuiz);
  static Future<void> setQuizJson(String v) async =>
      _prefs?.setString(_kQuiz, v);

  /// Per-date routine completion log {`yyyy-mm-dd`: [amDone, pmDone]} as JSON.
  static String? get routineLogJson => _prefs?.getString(_kRoutineLog);
  static Future<void> setRoutineLogJson(String v) async =>
      _prefs?.setString(_kRoutineLog, v);

  /// User's custom AM/PM routine step definitions {`am`: [...], `pm`: [...]}
  /// as JSON, so builder edits survive app restarts.
  static String? get routineStepsJson => _prefs?.getString(_kRoutineSteps);
  static Future<void> setRoutineStepsJson(String v) async =>
      _prefs?.setString(_kRoutineSteps, v);

  /// Per-date skin check-in scores {`yyyy-mm-dd`: score(0–100)} as JSON.
  static String? get checkInLogJson => _prefs?.getString(_kCheckInLog);
  static Future<void> setCheckInLogJson(String v) async =>
      _prefs?.setString(_kCheckInLog, v);

  /// Routine/check-in reminders: master toggle, repeat days, and the reminder
  /// list, persisted as a JSON string so scheduled notifications survive
  /// restarts and can be rescheduled on launch.
  static String? get remindersJson => _prefs?.getString(_kReminders);
  static Future<void> setRemindersJson(String v) async =>
      _prefs?.setString(_kReminders, v);

  /// Clears per-session state on logout (keeps onboardingSeen so onboarding
  /// never reappears for a returning user — per the flow spec).
  static Future<void> clearSession() async {
    await _prefs?.remove(_kProfileComplete);
  }

  /// Wipes everything (used by Delete Account).
  static Future<void> clearAll() async => _prefs?.clear();
}

/// Whether onboarding has ever been completed on this device.
final onboardingSeenProvider =
    StateProvider<bool>((_) => PreferencesService.onboardingSeen);

/// Whether the signed-in user finished profile setup + quizzes.
final profileCompleteProvider =
    StateProvider<bool>((_) => PreferencesService.profileComplete);
