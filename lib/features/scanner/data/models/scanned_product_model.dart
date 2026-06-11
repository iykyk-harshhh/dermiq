import '../../domain/entities/scanned_product.dart';
import '../datasources/ingredient_parser.dart';

/// Data-layer model for a product fetched from a barcode database. Maps the
/// raw API shape into a domain [ScannedProduct] (classifying ingredients on
/// the way out via [IngredientParser]).
class ScannedProductModel {
  final String barcode;
  final String name;
  final String brand;
  final String category;
  final String? imageUrl;
  final String ingredientsText;

  const ScannedProductModel({
    required this.barcode,
    required this.name,
    required this.brand,
    required this.category,
    this.imageUrl,
    this.ingredientsText = '',
  });

  /// Parses the Open Beauty Facts JSON shape
  /// (`world.openbeautyfacts.org/api/v2/product/{barcode}.json`).
  factory ScannedProductModel.fromOpenBeautyFacts(Map<String, dynamic> json) {
    final p = (json['product'] as Map<String, dynamic>?) ?? const {};
    return ScannedProductModel(
      barcode: json['code']?.toString() ?? '',
      name: (p['product_name'] as String?)?.trim().isNotEmpty == true
          ? p['product_name'] as String
          : 'Unknown product',
      brand: (p['brands'] as String?)?.split(',').first.trim() ?? '',
      category:
          (p['categories'] as String?)?.split(',').last.trim() ?? 'Skincare',
      imageUrl: p['image_url'] as String?,
      ingredientsText: (p['ingredients_text'] as String?) ?? '',
    );
  }

  ScannedProduct toEntity(IngredientParser parser) => ScannedProduct(
        barcode: barcode,
        name: name,
        brand: brand,
        category: category,
        imageUrl: imageUrl,
        ingredients: parser.parse(ingredientsText),
      );
}
