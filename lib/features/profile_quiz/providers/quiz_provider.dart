import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  QUIZ STATE  — skin + hair profile
// ─────────────────────────────────────────────────────────────────────────────

class QuizState {
  // Profile setup
  final String? name;
  final String? gender;
  final String? email;
  final int? age;

  // Skin
  final String? skinType;
  final List<String> skinConcerns;
  final List<String> skinAllergies;
  final String? fitzpatrick;

  // Hair
  final String? hairType;
  final String? scalpType;
  final List<String> hairConcerns;
  final List<String> hairTreatments;

  const QuizState({
    this.name,
    this.gender,
    this.email,
    this.age,
    this.skinType,
    this.skinConcerns = const [],
    this.skinAllergies = const [],
    this.fitzpatrick,
    this.hairType,
    this.scalpType,
    this.hairConcerns = const [],
    this.hairTreatments = const [],
  });

  bool get setupComplete =>
      (name?.isNotEmpty ?? false) && gender != null;

  bool get skinComplete =>
      skinType != null && skinConcerns.isNotEmpty && fitzpatrick != null;

  bool get hairComplete =>
      hairType != null && scalpType != null;

  QuizState copyWith({
    String? name,
    String? gender,
    String? email,
    int? age,
    String? skinType,
    List<String>? skinConcerns,
    List<String>? skinAllergies,
    String? fitzpatrick,
    String? hairType,
    String? scalpType,
    List<String>? hairConcerns,
    List<String>? hairTreatments,
  }) =>
      QuizState(
        name:           name           ?? this.name,
        gender:         gender         ?? this.gender,
        email:          email          ?? this.email,
        age:            age            ?? this.age,
        skinType:       skinType       ?? this.skinType,
        skinConcerns:   skinConcerns   ?? this.skinConcerns,
        skinAllergies:  skinAllergies  ?? this.skinAllergies,
        fitzpatrick:    fitzpatrick    ?? this.fitzpatrick,
        hairType:       hairType       ?? this.hairType,
        scalpType:      scalpType      ?? this.scalpType,
        hairConcerns:   hairConcerns   ?? this.hairConcerns,
        hairTreatments: hairTreatments ?? this.hairTreatments,
      );
}

class QuizNotifier extends StateNotifier<QuizState> {
  QuizNotifier() : super(const QuizState());

  void setName(String v)               => state = state.copyWith(name: v);
  void setGender(String v)             => state = state.copyWith(gender: v);
  void setEmail(String v)              => state = state.copyWith(email: v);
  void setAge(int v)                   => state = state.copyWith(age: v);
  void setSkinType(String v)           => state = state.copyWith(skinType: v);
  void setSkinConcerns(List<String> v) => state = state.copyWith(skinConcerns: v);
  void setSkinAllergies(List<String> v)=> state = state.copyWith(skinAllergies: v);
  void setFitzpatrick(String v)        => state = state.copyWith(fitzpatrick: v);
  void setHairType(String v)           => state = state.copyWith(hairType: v);
  void setScalpType(String v)          => state = state.copyWith(scalpType: v);
  void setHairConcerns(List<String> v) => state = state.copyWith(hairConcerns: v);
  void setHairTreatments(List<String> v)=>state = state.copyWith(hairTreatments: v);

  void toggleSkinConcern(String v) {
    final list = List<String>.from(state.skinConcerns);
    list.contains(v) ? list.remove(v) : list.add(v);
    state = state.copyWith(skinConcerns: list);
  }

  void toggleSkinAllergy(String v) {
    final list = List<String>.from(state.skinAllergies);
    list.contains(v) ? list.remove(v) : list.add(v);
    state = state.copyWith(skinAllergies: list);
  }

  void toggleHairConcern(String v) {
    final list = List<String>.from(state.hairConcerns);
    list.contains(v) ? list.remove(v) : list.add(v);
    state = state.copyWith(hairConcerns: list);
  }

  void toggleHairTreatment(String v) {
    final list = List<String>.from(state.hairTreatments);
    list.contains(v) ? list.remove(v) : list.add(v);
    state = state.copyWith(hairTreatments: list);
  }

  void reset() => state = const QuizState();
}

final quizProvider =
    StateNotifierProvider<QuizNotifier, QuizState>((_) => QuizNotifier());
