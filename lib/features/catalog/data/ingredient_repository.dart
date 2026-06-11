import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firestore_service.dart';
import '../domain/ingredient.dart';
import 'catalog_seed.dart';

/// Ingredient catalog access.
///
/// Firestore structure:  `ingredients/{ingredientId}` (global, read-only to
/// clients). Falls back to [catalogIngredients] when offline / unseeded.
class IngredientRepository {
  IngredientRepository(this._db);
  final FirebaseFirestore? _db;

  bool get isOnline => _db != null;

  CollectionReference<Map<String, dynamic>>? get _col =>
      _db?.collection('ingredients');

  Future<List<Ingredient>> _all() async {
    if (!isOnline) return catalogIngredients;
    final snap = await _col!.get();
    if (snap.docs.isEmpty) return catalogIngredients;
    return snap.docs.map((d) => Ingredient.fromFirestore(d.data(), d.id)).toList();
  }

  // ── Search ────────────────────────────────────────────────────────────────
  Future<List<Ingredient>> search(String query) async {
    final all = await _all();
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all
        .where((i) =>
            i.name.toLowerCase().contains(q) ||
            i.inciName.toLowerCase().contains(q) ||
            i.function.toLowerCase().contains(q))
        .toList();
  }

  Future<Ingredient?> byName(String name) async {
    final all = await _all();
    final key = name.toLowerCase().trim();
    for (final i in all) {
      if (i.key == key || key.contains(i.key) || i.key.contains(key)) return i;
    }
    return null;
  }

  /// Resolves a product's free-text ingredient list to catalog entries
  /// (fuzzy contains-match in both directions). Used by the analysis service.
  Future<List<Ingredient>> getMany(List<String> names) async {
    final all = await _all();
    final lower = names.map((n) => n.toLowerCase().trim()).toList();
    return all
        .where((i) => lower.any((n) => n.contains(i.key) || i.key.contains(n)))
        .toList();
  }
}

final ingredientRepositoryProvider = Provider<IngredientRepository>((ref) {
  return IngredientRepository(ref.watch(firestoreProvider));
});

final ingredientSearchProvider =
    FutureProvider.family<List<Ingredient>, String>((ref, query) {
  return ref.watch(ingredientRepositoryProvider).search(query);
});
