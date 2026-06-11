import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/product.dart';
import '../domain/product_analysis.dart';
import 'ingredient_repository.dart';

/// Analyzes a product's ingredient list against the ingredient catalog to
/// produce a safety score, matched entries, caution flags and unknowns.
class ProductAnalysisService {
  ProductAnalysisService(this._ingredients);
  final IngredientRepository _ingredients;

  Future<ProductAnalysis> analyze(Product product) async {
    final names = product.allIngredients;
    if (names.isEmpty) {
      return ProductAnalysis(
        overallScore: product.score,
        matched: const [],
        flagged: const [],
        unknown: const [],
      );
    }

    final matched = await _ingredients.getMany(names);
    final matchedKeys = matched.map((i) => i.key).toSet();
    final unknown = names
        .where((n) => !matchedKeys.any(
            (k) => n.toLowerCase().contains(k) || k.contains(n.toLowerCase())))
        .toList();
    final flagged = matched.where((i) => i.flagged).toList();

    final int overall;
    if (matched.isEmpty) {
      overall = product.score;
    } else {
      final avg =
          matched.map((i) => i.safetyScore).reduce((a, b) => a + b) / matched.length;
      // Penalise each flagged ingredient; clamp to 0–100.
      overall = (avg - flagged.length * 5).clamp(0, 100).round();
    }

    return ProductAnalysis(
      overallScore: overall,
      matched: matched,
      flagged: flagged,
      unknown: unknown,
    );
  }
}

final analysisServiceProvider = Provider<ProductAnalysisService>((ref) {
  return ProductAnalysisService(ref.watch(ingredientRepositoryProvider));
});

/// Analysis for a given product, computed on demand.
final productAnalysisProvider =
    FutureProvider.family<ProductAnalysis, Product>((ref, product) {
  return ref.watch(analysisServiceProvider).analyze(product);
});
