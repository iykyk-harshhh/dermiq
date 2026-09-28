import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/preferences_service.dart';
import '../../../core/firebase/repositories/user_repository.dart';
import '../../auth/providers/auth_provider.dart';

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

  Map<String, dynamic> toMap() => {
        'name': name,
        'gender': gender,
        'email': email,
        'age': age,
        'skinType': skinType,
        'skinConcerns': skinConcerns,
        'skinAllergies': skinAllergies,
        'fitzpatrick': fitzpatrick,
        'hairType': hairType,
        'scalpType': scalpType,
        'hairConcerns': hairConcerns,
        'hairTreatments': hairTreatments,
      };

  /// True when any skin/hair/profile answer is present — used to decide whether
  /// a remote Firestore doc is worth hydrating from.
  bool get hasAnyProfileData =>
      name != null ||
      gender != null ||
      email != null ||
      age != null ||
      skinType != null ||
      skinConcerns.isNotEmpty ||
      skinAllergies.isNotEmpty ||
      fitzpatrick != null ||
      hairType != null ||
      scalpType != null ||
      hairConcerns.isNotEmpty ||
      hairTreatments.isNotEmpty;

  /// Merges a remote profile into this local one: remote values win when present
  /// (non-null / non-empty), otherwise the local cache value is kept. This lets
  /// a returning user on a new device pull their saved profile without wiping any
  /// answer the remote doc happens to be missing.
  QuizState mergeRemote(QuizState remote) => QuizState(
        name: remote.name ?? name,
        gender: remote.gender ?? gender,
        email: remote.email ?? email,
        age: remote.age ?? age,
        skinType: remote.skinType ?? skinType,
        skinConcerns:
            remote.skinConcerns.isNotEmpty ? remote.skinConcerns : skinConcerns,
        skinAllergies: remote.skinAllergies.isNotEmpty
            ? remote.skinAllergies
            : skinAllergies,
        fitzpatrick: remote.fitzpatrick ?? fitzpatrick,
        hairType: remote.hairType ?? hairType,
        scalpType: remote.scalpType ?? scalpType,
        hairConcerns:
            remote.hairConcerns.isNotEmpty ? remote.hairConcerns : hairConcerns,
        hairTreatments: remote.hairTreatments.isNotEmpty
            ? remote.hairTreatments
            : hairTreatments,
      );

  factory QuizState.fromMap(Map<String, dynamic> m) {
    List<String> list(String k) =>
        (m[k] as List?)?.whereType<String>().toList() ?? const [];
    return QuizState(
      name: m['name'] as String?,
      gender: m['gender'] as String?,
      email: m['email'] as String?,
      age: (m['age'] as num?)?.toInt(),
      skinType: m['skinType'] as String?,
      skinConcerns: list('skinConcerns'),
      skinAllergies: list('skinAllergies'),
      fitzpatrick: m['fitzpatrick'] as String?,
      hairType: m['hairType'] as String?,
      scalpType: m['scalpType'] as String?,
      hairConcerns: list('hairConcerns'),
      hairTreatments: list('hairTreatments'),
    );
  }
}

class QuizNotifier extends StateNotifier<QuizState> {
  QuizNotifier(this._ref) : super(_load());

  final Ref _ref;

  /// Loads persisted answers (synchronous — `PreferencesService` is ready at
  /// startup) so the skin/hair profile survives restarts.
  static QuizState _load() {
    final raw = PreferencesService.quizJson;
    if (raw == null || raw.isEmpty) return const QuizState();
    try {
      return QuizState.fromMap(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const QuizState();
    }
  }

  void _set(QuizState s) {
    state = s;
    PreferencesService.setQuizJson(jsonEncode(s.toMap()));
  }

  void setName(String v)               => _set(state.copyWith(name: v));
  void setGender(String v)             => _set(state.copyWith(gender: v));
  void setEmail(String v)              => _set(state.copyWith(email: v));
  void setAge(int v)                   => _set(state.copyWith(age: v));
  void setSkinType(String v)           => _set(state.copyWith(skinType: v));
  void setSkinConcerns(List<String> v) => _set(state.copyWith(skinConcerns: v));
  void setSkinAllergies(List<String> v)=> _set(state.copyWith(skinAllergies: v));
  void setFitzpatrick(String v)        => _set(state.copyWith(fitzpatrick: v));
  void setHairType(String v)           => _set(state.copyWith(hairType: v));
  void setScalpType(String v)          => _set(state.copyWith(scalpType: v));
  void setHairConcerns(List<String> v) => _set(state.copyWith(hairConcerns: v));
  void setHairTreatments(List<String> v)=>_set(state.copyWith(hairTreatments: v));

  void toggleSkinConcern(String v) {
    final list = List<String>.from(state.skinConcerns);
    list.contains(v) ? list.remove(v) : list.add(v);
    _set(state.copyWith(skinConcerns: list));
  }

  void toggleSkinAllergy(String v) {
    final list = List<String>.from(state.skinAllergies);
    list.contains(v) ? list.remove(v) : list.add(v);
    _set(state.copyWith(skinAllergies: list));
  }

  void toggleHairConcern(String v) {
    final list = List<String>.from(state.hairConcerns);
    list.contains(v) ? list.remove(v) : list.add(v);
    _set(state.copyWith(hairConcerns: list));
  }

  void toggleHairTreatment(String v) {
    final list = List<String>.from(state.hairTreatments);
    list.contains(v) ? list.remove(v) : list.add(v);
    _set(state.copyWith(hairTreatments: list));
  }

  void reset() {
    state = const QuizState();
    PreferencesService.setQuizJson(jsonEncode(const QuizState().toMap()));
  }

  // ── Firestore sync (offline-first) ──────────────────────────────────────────
  // Prefs remain the local cache/source-of-truth; these mirror to / hydrate from
  // `users/{uid}` so the profile survives reinstall and follows the user across
  // devices. All are safe no-ops when signed out or Firebase is unavailable.

  UserRepository? get _repo => _ref.read(userRepositoryProvider);
  String? get _uid => _ref.read(authStateProvider)?.id;

  /// Mirrors the current quiz answers to Firestore. No-op offline / signed out.
  Future<void> syncToFirestore() async {
    final uid = _uid;
    final repo = _repo;
    if (uid == null || repo == null) return;
    try {
      await repo.saveProfileAnswers(uid, state.toMap());
    } catch (_) {
      // Best-effort: local prefs cache already holds the answers.
    }
  }

  /// Pulls the saved profile from Firestore and merges it into local state (and
  /// the prefs cache) so a returning user on a new device recovers their answers.
  /// No-op offline / signed out / when the remote doc has no profile data.
  Future<void> hydrateFromFirestore() async {
    final uid = _uid;
    final repo = _repo;
    if (uid == null || repo == null) return;
    try {
      final data = await repo.fetchProfileAnswers(uid);
      if (data == null) return;
      final remote = QuizState.fromMap(data);
      if (!remote.hasAnyProfileData) return;
      _set(state.mergeRemote(remote));
    } catch (_) {
      // Best-effort: fall back to whatever the local prefs cache holds.
    }
  }
}

final quizProvider = StateNotifierProvider<QuizNotifier, QuizState>(
    (ref) => QuizNotifier(ref));
