import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/firebase/repositories/user_repository.dart';
import '../../../core/services/preferences_service.dart';
import '../../auth/providers/auth_provider.dart';
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
    // Mirror to Firestore (fire-and-forget; no-op when signed out / offline).
    final uid = ref.read(authStateProvider)?.id;
    final repo = ref.read(userRepositoryProvider);
    if (uid != null && repo != null) {
      repo.updateFields(uid, {'healthScore': score});
    }
  }
}

final healthScoreProvider =
    NotifierProvider<HealthScoreNotifier, int>(HealthScoreNotifier.new);

/// Human-readable band + accent colour for a 0–100 score. Shared by the Home
/// hero card and the Analysis results header so the label stays consistent.
({String label, int color}) scoreBand(int score) {
  if (score >= 80) return (label: 'Great', color: 0xFF22C55E);
  if (score >= 60) return (label: 'Good', color: 0xFF84CC16);
  if (score >= 40) return (label: 'Fair', color: 0xFFF59E0B);
  return (label: 'Needs care', color: 0xFFEF4444);
}
