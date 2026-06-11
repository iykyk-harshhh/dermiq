import 'ingredient.dart';

/// Result of analysing a product's ingredient list against the catalog.
class ProductAnalysis {
  /// 0–100 composite safety score.
  final int overallScore;

  /// Catalog ingredients that were matched in the product.
  final List<Ingredient> matched;

  /// Matched ingredients on the caution watchlist.
  final List<Ingredient> flagged;

  /// Ingredient names that weren't found in the catalog.
  final List<String> unknown;

  const ProductAnalysis({
    required this.overallScore,
    required this.matched,
    required this.flagged,
    required this.unknown,
  });

  bool get isClean => flagged.isEmpty;

  String get verdict {
    if (overallScore >= 85) return 'Excellent';
    if (overallScore >= 70) return 'Good';
    if (overallScore >= 50) return 'Fair';
    return 'Use with caution';
  }

  static const empty = ProductAnalysis(
    overallScore: 0, matched: [], flagged: [], unknown: [],
  );
}
