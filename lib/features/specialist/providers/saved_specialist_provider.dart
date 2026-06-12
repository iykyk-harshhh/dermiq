import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/preferences_service.dart';

/// The set of specialist IDs the user has saved (bookmarked), persisted locally.
/// Surfaced on the specialist detail screen and Profile → Saved Specialists.
class SavedSpecialistNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => PreferencesService.savedSpecialists.toSet();

  bool isSaved(String id) => state.contains(id);

  void toggle(String id) {
    final next = Set<String>.from(state);
    if (!next.add(id)) next.remove(id); // add returns false if already present
    state = next;
    PreferencesService.setSavedSpecialists(next.toList());
  }
}

final savedSpecialistProvider =
    NotifierProvider<SavedSpecialistNotifier, Set<String>>(
        SavedSpecialistNotifier.new);
