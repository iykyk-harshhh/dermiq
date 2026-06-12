import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/preferences_service.dart';
import '../../routine/data/routine_models.dart';

/// The combined **DermIQ Health Score** (0–100).
///
/// Starts at 0 and rises with recent routine activity over a rolling window:
///   • AM routine completion        (30%)
///   • PM routine completion        (30%)
///   • Weekly consistency (any step) (20%)
///   • Full-routine adherence (AM+PM)(20%)
int computeHealthScore({int window = 7}) {
  final days = routineHistory.take(window).toList();
  if (days.isEmpty) return 0;
  final n = days.length;
  final am = days.where((d) => d.amDone).length / n;
  final pm = days.where((d) => d.pmDone).length / n;
  final consistency = days.where((d) => d.anyDone).length / n;
  final adherence = days.where((d) => d.fullDone).length / n;
  final raw = 0.30 * am + 0.30 * pm + 0.20 * consistency + 0.20 * adherence;
  return (raw * 100).round().clamp(0, 100);
}

/// The current health score, recomputed from routine activity and persisted
/// locally (Firestore-ready). Watch this for the Home dashboard hero card.
class HealthScoreNotifier extends Notifier<int> {
  @override
  int build() {
    final score = computeHealthScore();
    _persist(score); // fire-and-forget cache + Firestore stub
    return score;
  }

  /// Recompute after a routine day is logged (AM/PM steps completed).
  void refresh() {
    final score = computeHealthScore();
    state = score;
    _persist(score);
  }

  void _persist(int score) {
    // Local cache (SharedPreferences, via PreferencesService).
    PreferencesService.setHealthScore(score);
    // Firebase stub — wire when google-services.json is committed:
    // final uid = ref.read(authStateProvider)?.id;
    // if (uid != null) {
    //   await ref.read(userRepositoryProvider)
    //       ?.updateSettings(uid, {'healthScore': score});
    // }
  }
}

final healthScoreProvider =
    NotifierProvider<HealthScoreNotifier, int>(HealthScoreNotifier.new);
