import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dermiq/features/routine/data/routine_models.dart';
import 'package:dermiq/features/routine/providers/routine_provider.dart';

void main() {
  ProviderContainer makeContainer() {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    return c;
  }

  test('seeds AM/PM steps and history', () {
    final c = makeContainer();
    final s = c.read(routineProvider);
    expect(s.amSteps.length, amSteps.length);
    expect(s.pmSteps.length, pmSteps.length);
    expect(s.minutesFor(true), amSteps.fold<int>(0, (a, e) => a + e.durationMin));
  });

  test('toggling all AM steps reaches allDone, untoggle clears it', () {
    final c = makeContainer();
    final n = c.read(routineProvider.notifier);
    for (final step in c.read(routineProvider).amSteps) {
      n.toggleStep(true, step.id);
    }
    expect(c.read(routineProvider).allDone(true), isTrue);
    n.toggleStep(true, c.read(routineProvider).amSteps.first.id);
    expect(c.read(routineProvider).allDone(true), isFalse);
  });

  test('currentStreak counts leading active days from seed', () {
    final c = makeContainer();
    // The seed history has 7 consecutive active days before a missed day.
    expect(c.read(routineProvider).currentStreak, 7);
  });

  test('completeRoutine marks today done', () {
    final c = makeContainer();
    final n = c.read(routineProvider.notifier);
    expect(c.read(routineProvider).today.pmDone, isFalse);
    n.completeRoutine(false);
    expect(c.read(routineProvider).today.pmDone, isTrue);
  });

  test('builder add / remove / reorder steps', () {
    final c = makeContainer();
    final n = c.read(routineProvider.notifier);
    const newStep = RoutineStep(
      id: 'new1', stepType: 'Mask', productName: 'Clay Mask',
      description: '', tip: '', icon: Icons.face, color: Colors.teal, durationMin: 3,
    );
    final before = c.read(routineProvider).amSteps.length;
    n.addStep(true, newStep);
    expect(c.read(routineProvider).amSteps.length, before + 1);

    final firstId = c.read(routineProvider).amSteps.first.id;
    n.reorderStep(true, 0, 2);
    expect(c.read(routineProvider).amSteps.first.id, isNot(firstId));

    n.removeStep(true, 'new1');
    expect(c.read(routineProvider).amSteps.length, before);
    expect(c.read(routineProvider).amSteps.any((s) => s.id == 'new1'), isFalse);
  });
}
