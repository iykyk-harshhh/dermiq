import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dermiq/core/services/preferences_service.dart';
import 'package:dermiq/features/routine/data/routine_models.dart';
import 'package:dermiq/features/routine/providers/routine_provider.dart';

void main() {
  test('RoutineDay round-trips through toMap/fromMap', () {
    const day = RoutineDay('Monday', true, false, 88);
    final back = RoutineDay.fromMap(day.toMap());
    expect(back.label, 'Monday');
    expect(back.amDone, isTrue);
    expect(back.pmDone, isFalse);
    expect(back.score, 88);
  });

  test('toggleStep persists today completion and reloads', () async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesService.init();

    final c1 = ProviderContainer();
    final n1 = c1.read(routineProvider.notifier);
    n1.toggleStep(true, 'am1');
    n1.toggleStep(true, 'am2');
    expect(c1.read(routineProvider).amDoneIds, containsAll(['am1', 'am2']));
    c1.dispose();

    // A fresh container simulates an app restart — completion should survive.
    final c2 = ProviderContainer();
    expect(c2.read(routineProvider).amDoneIds, containsAll(['am1', 'am2']));
    c2.dispose();
  });

  test('completion from a previous day resets, history is kept', () async {
    // Seed storage as if completed "yesterday" (a date that is not today).
    SharedPreferences.setMockInitialValues({
      'routine_state':
          '{"date":"2000-1-1","amDoneIds":["am1"],"pmDoneIds":["pm1"],'
              '"history":[{"label":"Old","amDone":true,"pmDone":true,"score":90}]}',
    });
    await PreferencesService.init();

    final c = ProviderContainer();
    final state = c.read(routineProvider);
    // New calendar day → today's completion is cleared…
    expect(state.amDoneIds, isEmpty);
    expect(state.pmDoneIds, isEmpty);
    // …but history persists.
    expect(state.history.first.label, 'Old');
    c.dispose();
  });
}
