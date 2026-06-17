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

    // OBF fields are usually strings but can be missing or another type; read
    // defensively so a malformed payload never crashes the scanner.
    String str(dynamic v) => v is String ? v : '';
    final name = str(p['product_name']).trim();

    return ScannedProductModel(
      barcode: json['code']?.toString() ?? '',
      name: name.isNotEmpty ? name : 'Unknown product',
      brand: str(p['brands']).split(',').firstOrNull?.trim() ?? '',
      category: str(p['categories']).split(',').lastOrNull?.trim() ?? 'Skincare',
      imageUrl: p['image_url'] is String ? p['image_url'] as String : null,
      ingredientsText: str(p['ingredients_text']),
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
