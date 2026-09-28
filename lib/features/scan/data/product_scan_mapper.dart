import '../../catalog/data/catalog_seed.dart';
import '../../catalog/domain/ingredient.dart';
import '../../catalog/domain/product.dart';
import '../../scanner/domain/entities/scanned_ingredient.dart';
import '../../scanner/domain/entities/scanned_product.dart';

/// Maps a local catalog [Product] into a [ScannedProduct] so the shared
/// `ProductAnalysisScreen` renders that product's REAL fields (name, brand,
/// category, ingredient breakdown) instead of the CeraVe fallback mock.
///
/// Ingredient classifications and functions come from [catalogIngredients];
/// names not found there fall back to a neutral "safe / caution" split based
/// on which list they appear in.
ScannedProduct scannedFromProduct(Product product) {
  Ingredient? lookup(String name) {
    final key = name.toLowerCase().trim();
    for (final ing in catalogIngredients) {
      if (ing.key == key) return ing;
    }
    return null;
  }

  ScannedIngredient map(String name, {required bool fromCautionList}) {
    final match = lookup(name);
    final IngredientSafety safety;
    if (fromCautionList) {
      safety = (match != null && match.safetyScore < 55)
          ? IngredientSafety.avoid
          : IngredientSafety.caution;
    } else {
      safety = (match != null && match.flagged)
          ? IngredientSafety.caution
          : IngredientSafety.safe;
    }
    String? note;
    if (match != null) {
      note = match.concerns.isNotEmpty
          ? match.concerns.join(' · ')
          : match.description;
    }
    return ScannedIngredient(
      name: match?.name ?? name,
      function: match?.function,
      safety: safety,
      note: note,
    );
  }

  final ingredients = <ScannedIngredient>[
    for (final n in product.safeIngredients) map(n, fromCautionList: false),
    for (final n in product.cautionIngredients) map(n, fromCautionList: true),
  ];

  return ScannedProduct(
    barcode: product.barcode ?? product.id,
    name: product.name,
    brand: product.brand,
    category: product.category,
    imageUrl: product.imageUrl,
    ingredients: ingredients,
  );
}
