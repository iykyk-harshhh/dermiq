import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../profile_quiz/providers/quiz_provider.dart';

/// A read-model that composes the authenticated identity (`authStateProvider`)
/// with the skin + hair profile (`quizProvider`) into one object screens can
/// watch. The skin/hair fields remain edited through `quizProvider` (the store)
/// — this provider just presents them together and derives completion.
class UserProfile {
  final String name;
  final String email;
  final String? photoUrl;

  final String? skinType;
  final String? fitzpatrick;
  final List<String> skinConcerns;
  final List<String> skinAllergies;

  final String? hairType;
  final String? scalpType;
  final List<String> hairConcerns;
  final List<String> hairTreatments;

  const UserProfile({
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.skinType,
    required this.fitzpatrick,
    required this.skinConcerns,
    required this.skinAllergies,
    required this.hairType,
    required this.scalpType,
    required this.hairConcerns,
    required this.hairTreatments,
  });

  String get initial => name.isNotEmpty ? name[0].toUpperCase() : 'S';

  /// Profile completion 0–100 across the six core attributes.
  int get completionPercent {
    var filled = 0;
    const total = 6;
    if (skinType != null) filled++;
    if (skinConcerns.isNotEmpty) filled++;
    if (fitzpatrick != null) filled++;
    if (hairType != null) filled++;
    if (scalpType != null) filled++;
    if (hairConcerns.isNotEmpty) filled++;
    return ((filled / total) * 100).round();
  }

  bool get isComplete => completionPercent == 100;
}

/// Composed, reactive user profile. Recomputes whenever auth or quiz changes.
final profileProvider = Provider<UserProfile>((ref) {
  final user = ref.watch(authStateProvider);
  final quiz = ref.watch(quizProvider);

  return UserProfile(
    name: user?.displayName ?? 'Sarah Johnson',
    email: user?.email ?? 'sarah.johnson@email.com',
    photoUrl: null,
    skinType: quiz.skinType,
    fitzpatrick: quiz.fitzpatrick,
    skinConcerns: quiz.skinConcerns,
    skinAllergies: quiz.skinAllergies,
    hairType: quiz.hairType,
    scalpType: quiz.scalpType,
    hairConcerns: quiz.hairConcerns,
    hairTreatments: quiz.hairTreatments,
  );
});
