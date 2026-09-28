import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/preferences_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../calendar/providers/calendar_log_provider.dart';
import '../../streak/providers/streak_provider.dart';
import '../data/routine_models.dart';
import '../data/routine_repository.dart';

/// Owns the AM/PM routine step lists (editable in the builder), today's
/// per-step completion, and the rolling history. Replaces the `_done` set in
/// the detail screen and the `_amSteps`/`_pmSteps` lists in the builder.
class RoutineState {
  final List<RoutineStep> amSteps;
  final List<RoutineStep> pmSteps;
  final Set<String> amDoneIds;
  final Set<String> pmDoneIds;
  final List<RoutineDay> history;

  const RoutineState({
    this.amSteps = const [],
    this.pmSteps = const [],
    this.amDoneIds = const {},
    this.pmDoneIds = const {},
    this.history = const [],
  });

  RoutineState copyWith({
    List<RoutineStep>? amSteps,
    List<RoutineStep>? pmSteps,
    Set<String>? amDoneIds,
    Set<String>? pmDoneIds,
    List<RoutineDay>? history,
  }) {
    return RoutineState(
      amSteps: amSteps ?? this.amSteps,
      pmSteps: pmSteps ?? this.pmSteps,
      amDoneIds: amDoneIds ?? this.amDoneIds,
      pmDoneIds: pmDoneIds ?? this.pmDoneIds,
      history: history ?? this.history,
    );
  }

  List<RoutineStep> stepsFor(bool isAm) => isAm ? amSteps : pmSteps;
  Set<String> doneIdsFor(bool isAm) => isAm ? amDoneIds : pmDoneIds;

  bool allDone(bool isAm) {
    final steps = stepsFor(isAm);
    final done = doneIdsFor(isAm);
    return steps.isNotEmpty && steps.every((s) => done.contains(s.id));
  }

  int minutesFor(bool isAm) =>
      stepsFor(isAm).fold(0, (sum, s) => sum + s.durationMin);

  RoutineDay get today {
    final n = DateTime.now();
    final key =
        '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
    if (history.isNotEmpty && history.first.dateKey == key) {
      return history.first;
    }
    // Newest entry is from a previous day (or no history yet) → fresh today.
    return RoutineDay('Today', false, false, 0, dateKey: key);
  }

  int get currentStreak {
    var streak = 0;
    for (final d in history) {
      if (d.anyDone) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }
}

class RoutineNotifier extends Notifier<RoutineState> {
  RoutineRepository get _repo => ref.read(routineRepositoryProvider);
  String? get _uid => ref.read(authStateProvider)?.id;

  @override
  RoutineState build() {
    final initial = _load();
    // Offline-first Firestore sync: mirror to users/{uid}/routineState/current
    // when signed in + online; SharedPreferences stays the local cache so the
    // routine keeps working fully offline.
    final uid = ref.watch(authStateProvider)?.id;
    if (uid != null && _repo.isOnline) {
      final sub = _repo.watch(uid).listen(
        (data) => _applyRemote(data),
        onError: (Object e) => debugPrint('[Routine] watch error: $e'),
      );
      ref.onDispose(sub.cancel);
    }
    return initial;
  }

  // ── Persistence ────────────────────────────────────────────────────────────
  //
  // Today's per-step completion + the rolling history survive restarts (local
  // storage). Completion auto-resets at the start of a new calendar day. The
  // user's custom AM/PM step definitions are persisted separately (icons +
  // colours serialized) so builder edits also survive restarts.

  RoutineState _load() {
    final (am, pm) = _loadSteps();
    final raw = PreferencesService.routineJson;
    if (raw == null || raw.isEmpty) return _defaults();
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      final isToday = m['date'] == _todayKey();
      final history = (m['history'] as List?)
              ?.map((e) => RoutineDay.fromMap((e as Map).cast<String, dynamic>()))
              .toList() ??
          <RoutineDay>[];
      return RoutineState(
        amSteps: am,
        pmSteps: pm,
        amDoneIds: isToday ? _idSet(m['amDoneIds']) : <String>{},
        pmDoneIds: isToday ? _idSet(m['pmDoneIds']) : <String>{},
        history: _relabel(history),
      );
    } catch (_) {
      return _defaults();
    }
  }

  RoutineState _defaults() {
    final (am, pm) = _loadSteps();
    // Fresh install → truthful empty history (no fabricated scored days).
    return RoutineState(
      amSteps: am,
      pmSteps: pm,
      amDoneIds: const {},
      pmDoneIds: const {},
      history: const [],
    );
  }

  /// Loads the user's custom step definitions, falling back to the seeded
  /// defaults when nothing has been saved (or the payload is unreadable).
  static (List<RoutineStep>, List<RoutineStep>) _loadSteps() {
    final raw = PreferencesService.routineStepsJson;
    if (raw == null || raw.isEmpty) return (List.of(amSteps), List.of(pmSteps));
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      final am = (m['am'] as List?)
          ?.map((e) => RoutineStep.fromMap((e as Map).cast<String, dynamic>()))
          .toList();
      final pm = (m['pm'] as List?)
          ?.map((e) => RoutineStep.fromMap((e as Map).cast<String, dynamic>()))
          .toList();
      return (am ?? List.of(amSteps), pm ?? List.of(pmSteps));
    } catch (_) {
      return (List.of(amSteps), List.of(pmSteps));
    }
  }

  void _persistSteps() {
    PreferencesService.setRoutineStepsJson(jsonEncode({
      'am': state.amSteps.map((s) => s.toMap()).toList(),
      'pm': state.pmSteps.map((s) => s.toMap()).toList(),
    }));
  }

  static Set<String> _idSet(dynamic v) =>
      (v as List?)?.map((e) => e as String).toSet() ?? <String>{};

  static String _todayKey() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  /// Relabels history entries ('Today' / 'Yesterday' / weekday) from their
  /// stored dateKey so labels stay truthful as days pass. Legacy entries
  /// without a dateKey keep their stored label.
  static List<RoutineDay> _relabel(List<RoutineDay> history) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    const wd = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return history.map((d) {
      final key = d.dateKey;
      if (key == null) return d;
      final parts = key.split('-');
      if (parts.length != 3) return d;
      final dt = DateTime(
          int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      final diff = today.difference(dt).inDays;
      final label = diff == 0
          ? 'Today'
          : diff == 1
              ? 'Yesterday'
              : wd[dt.weekday - 1];
      return RoutineDay(label, d.amDone, d.pmDone, d.score, dateKey: key);
    }).toList();
  }

  void _persist() {
    PreferencesService.setRoutineJson(jsonEncode(_stateMap()));
  }

  Map<String, dynamic> _stateMap() => {
        'date': _todayKey(),
        'amDoneIds': state.amDoneIds.toList(),
        'pmDoneIds': state.pmDoneIds.toList(),
        'history': state.history.map((d) => d.toMap()).toList(),
      };

  void _pushRemote() {
    final uid = _uid;
    if (uid == null) return;
    _repo.save(uid, {
      ..._stateMap(),
      'amSteps': state.amSteps.map((s) => s.toMap()).toList(),
      'pmSteps': state.pmSteps.map((s) => s.toMap()).toList(),
    });
  }

  void _applyRemote(Map<String, dynamic>? data) {
    if (data == null) {
      // No remote doc yet — back up the local state.
      _pushRemote();
      return;
    }
    try {
      final isToday = data['date'] == _todayKey();
      final am = (data['amSteps'] as List?)
              ?.map((e) => RoutineStep.fromMap((e as Map).cast<String, dynamic>()))
              .toList() ??
          state.amSteps;
      final pm = (data['pmSteps'] as List?)
              ?.map((e) => RoutineStep.fromMap((e as Map).cast<String, dynamic>()))
              .toList() ??
          state.pmSteps;
      final history = (data['history'] as List?)
              ?.map((e) => RoutineDay.fromMap((e as Map).cast<String, dynamic>()))
              .toList() ??
          state.history;
      state = RoutineState(
        amSteps: am,
        pmSteps: pm,
        amDoneIds: isToday ? _idSet(data['amDoneIds']) : <String>{},
        pmDoneIds: isToday ? _idSet(data['pmDoneIds']) : <String>{},
        history: _relabel(history),
      );
      // Reconcile local cache with the remote snapshot.
      _persist();
      _persistSteps();
    } catch (e) {
      debugPrint('[Routine] applyRemote failed: $e');
    }
  }

  /// Real per-day score from the AM+PM step completion ratio (0–100).
  int _computeScore() {
    final total = state.amSteps.length + state.pmSteps.length;
    if (total == 0) return 0;
    final done =
        state.amSteps.where((s) => state.amDoneIds.contains(s.id)).length +
            state.pmSteps.where((s) => state.pmDoneIds.contains(s.id)).length;
    return (done / total * 100).round();
  }

  /// Writes today's completion + computed score into the rolling history, the
  /// calendar completion log, and the streak — then persists everywhere.
  void _syncToday() {
    final amDone = state.allDone(true);
    final pmDone = state.allDone(false);
    final score = _computeScore();
    final key = _todayKey();
    final entry = RoutineDay('Today', amDone, pmDone, score, dateKey: key);

    final history = [...state.history];
    if (history.isNotEmpty && history.first.dateKey == key) {
      history[0] = entry;
    } else {
      history.insert(0, entry);
    }
    state = state.copyWith(history: history);

    _persist();
    _pushRemote();

    // Recolour the calendar reactively + keep the streak real.
    ref.read(calendarLogProvider.notifier).setDay(DateTime.now(), am: amDone, pm: pmDone);
    ref.read(streakProvider.notifier).recordDayActivity(amDone: amDone, pmDone: pmDone);
  }

  void toggleStep(bool isAm, String id) {
    final done = {...state.doneIdsFor(isAm)};
    done.contains(id) ? done.remove(id) : done.add(id);
    state = isAm
        ? state.copyWith(amDoneIds: done)
        : state.copyWith(pmDoneIds: done);
    _syncToday();
  }

  /// Marks today's routine (AM or PM) complete — marks every step of that
  /// routine done, then recomputes today's real score + history.
  void completeRoutine(bool isAm) {
    final ids = state.stepsFor(isAm).map((s) => s.id).toSet();
    state = isAm
        ? state.copyWith(amDoneIds: ids)
        : state.copyWith(pmDoneIds: ids);
    _syncToday();
  }

  // ── Builder edits ──────────────────────────────────────────────────────────

  void addStep(bool isAm, RoutineStep step) {
    final list = [...state.stepsFor(isAm), step];
    state = isAm ? state.copyWith(amSteps: list) : state.copyWith(pmSteps: list);
    _persistSteps();
    _pushRemote();
  }

  void removeStep(bool isAm, String id) {
    final list = state.stepsFor(isAm).where((s) => s.id != id).toList();
    state = isAm ? state.copyWith(amSteps: list) : state.copyWith(pmSteps: list);
    _persistSteps();
    _pushRemote();
  }

  void reorderStep(bool isAm, int oldIndex, int newIndex) {
    final list = [...state.stepsFor(isAm)];
    if (newIndex > oldIndex) newIndex--;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    state = isAm ? state.copyWith(amSteps: list) : state.copyWith(pmSteps: list);
    _persistSteps();
    _pushRemote();
  }

  /// Replaces both AM/PM step lists at once (used by the Routine Builder's
  /// Save action) and persists the new definitions.
  void setSteps({required List<RoutineStep> am, required List<RoutineStep> pm}) {
    state = state.copyWith(amSteps: am, pmSteps: pm);
    _persistSteps();
    _pushRemote();
  }
}

final routineProvider =
    NotifierProvider<RoutineNotifier, RoutineState>(RoutineNotifier.new);
