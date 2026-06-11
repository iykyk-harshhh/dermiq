import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuizState {
  final String? skinType;
  final String? sensitivity;
  final List<String> goals;
  final Map<String, String> lifestyle;
  final List<String> concerns;
  final int currentStep;

  const QuizState({
    this.skinType,
    this.sensitivity,
    this.goals = const [],
    this.lifestyle = const {},
    this.concerns = const [],
    this.currentStep = 0,
  });

  QuizState copyWith({
    String? skinType,
    String? sensitivity,
    List<String>? goals,
    Map<String, String>? lifestyle,
    List<String>? concerns,
    int? currentStep,
  }) {
    return QuizState(
      skinType: skinType ?? this.skinType,
      sensitivity: sensitivity ?? this.sensitivity,
      goals: goals ?? this.goals,
      lifestyle: lifestyle ?? this.lifestyle,
      concerns: concerns ?? this.concerns,
      currentStep: currentStep ?? this.currentStep,
    );
  }

  bool get isComplete =>
      skinType != null && sensitivity != null && goals.isNotEmpty;
}

class QuizNotifier extends StateNotifier<QuizState> {
  QuizNotifier() : super(const QuizState());

  void setSkinType(String type) => state = state.copyWith(skinType: type);
  void setSensitivity(String s) => state = state.copyWith(sensitivity: s);

  void toggleGoal(String goal) {
    final goals = [...state.goals];
    goals.contains(goal) ? goals.remove(goal) : goals.add(goal);
    state = state.copyWith(goals: goals);
  }

  void toggleConcern(String concern) {
    final concerns = [...state.concerns];
    concerns.contains(concern)
        ? concerns.remove(concern)
        : concerns.add(concern);
    state = state.copyWith(concerns: concerns);
  }

  void setLifestyle(String key, String value) {
    final lifestyle = {...state.lifestyle, key: value};
    state = state.copyWith(lifestyle: lifestyle);
  }

  void nextStep() => state = state.copyWith(currentStep: state.currentStep + 1);
  void prevStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }
}

final quizProvider = StateNotifierProvider<QuizNotifier, QuizState>(
  (ref) => QuizNotifier(),
);
