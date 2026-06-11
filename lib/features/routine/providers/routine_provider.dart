import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/routine_models.dart';

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

  RoutineDay get today => history.isNotEmpty
      ? history.first
      : const RoutineDay('Today', false, false, 0);

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
  @override
  RoutineState build() => RoutineState(
        amSteps: List.of(amSteps),
        pmSteps: List.of(pmSteps),
        amDoneIds: {},
        pmDoneIds: {},
        history: List.of(routineHistory),
      );

  void toggleStep(bool isAm, String id) {
    final done = {...state.doneIdsFor(isAm)};
    done.contains(id) ? done.remove(id) : done.add(id);
    state = isAm
        ? state.copyWith(amDoneIds: done)
        : state.copyWith(pmDoneIds: done);
  }

  /// Marks today's routine (AM or PM) complete in the history.
  void completeRoutine(bool isAm) {
    if (state.history.isEmpty) return;
    final t = state.history.first;
    final updated = RoutineDay(
      t.label,
      isAm ? true : t.amDone,
      isAm ? t.pmDone : true,
      t.score,
    );
    state = state.copyWith(history: [updated, ...state.history.skip(1)]);
  }

  // ── Builder edits ──────────────────────────────────────────────────────────

  void addStep(bool isAm, RoutineStep step) {
    final list = [...state.stepsFor(isAm), step];
    state = isAm ? state.copyWith(amSteps: list) : state.copyWith(pmSteps: list);
  }

  void removeStep(bool isAm, String id) {
    final list = state.stepsFor(isAm).where((s) => s.id != id).toList();
    state = isAm ? state.copyWith(amSteps: list) : state.copyWith(pmSteps: list);
  }

  void reorderStep(bool isAm, int oldIndex, int newIndex) {
    final list = [...state.stepsFor(isAm)];
    if (newIndex > oldIndex) newIndex--;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    state = isAm ? state.copyWith(amSteps: list) : state.copyWith(pmSteps: list);
  }
}

final routineProvider =
    NotifierProvider<RoutineNotifier, RoutineState>(RoutineNotifier.new);
