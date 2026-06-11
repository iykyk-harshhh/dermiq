import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dermiq/features/profile/providers/profile_provider.dart';
import 'package:dermiq/features/profile_quiz/providers/quiz_provider.dart';

void main() {
  test('defaults: 0% complete with fallback identity', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final p = c.read(profileProvider);
    expect(p.completionPercent, 0);
    expect(p.isComplete, isFalse);
    expect(p.name, 'Sarah Johnson');
    expect(p.initial, 'S');
  });

  test('completion reaches 100% as the quiz is filled', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final quiz = c.read(quizProvider.notifier);
    quiz.setSkinType('Oily');
    quiz.toggleSkinConcern('Acne');
    quiz.setFitzpatrick('Type III');
    quiz.setHairType('Wavy');
    quiz.setScalpType('Oily');
    quiz.toggleHairConcern('Frizz');

    final p = c.read(profileProvider);
    expect(p.skinType, 'Oily');
    expect(p.skinConcerns, contains('Acne'));
    expect(p.completionPercent, 100);
    expect(p.isComplete, isTrue);
  });

  test('partial completion is proportional', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(quizProvider.notifier).setSkinType('Dry');
    // 1 of 6 attributes → ~17%.
    expect(c.read(profileProvider).completionPercent, 17);
  });
}
