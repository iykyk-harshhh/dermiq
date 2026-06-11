import 'scanned_ingredient.dart';

/// A product recognised from a barcode (and optionally enriched with an OCR'd
/// ingredient list). Pure domain entity — no framework or serialization here.
class ScannedProduct {
  final String barcode;
  final String name;
  final String brand;
  final String category;
  final String? imageUrl;
  final List<ScannedIngredient> ingredients;

  const ScannedProduct({
    required this.barcode,
    required this.name,
    required this.brand,
    required this.category,
    this.imageUrl,
    this.ingredients = const [],
  });

  /// A 0–100 safety score derived from the ingredient classifications.
  /// `avoid` weighs heaviest, `caution` moderate; unknowns are neutral.
  int get safetyScore {
    if (ingredients.isEmpty) return 0;
    var penalty = 0;
    for (final i in ingredients) {
      penalty += switch (i.safety) {
        IngredientSafety.avoid => 18,
        IngredientSafety.caution => 7,
        IngredientSafety.safe => 0,
        IngredientSafety.unknown => 2,
      };
    }
    return (100 - penalty).clamp(0, 100);
  }

  int get cautionCount =>
      ingredients.where((i) => i.safety == IngredientSafety.caution).length;

  int get avoidCount =>
      ingredients.where((i) => i.safety == IngredientSafety.avoid).length;

  ScannedProduct copyWith({List<ScannedIngredient>? ingredients}) =>
      ScannedProduct(
        barcode: barcode,
        name: name,
        brand: brand,
        category: category,
        imageUrl: imageUrl,
        ingredients: ingredients ?? this.ingredients,
      );
}
