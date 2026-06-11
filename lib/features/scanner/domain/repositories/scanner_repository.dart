import '../entities/scanned_ingredient.dart';
import '../entities/scanned_product.dart';
import '../scan_result.dart';

/// The scanner's domain contract. The presentation layer depends only on this;
/// the data layer provides the implementation (ML Kit OCR + product lookup).
abstract interface class ScannerRepository {
  /// Resolve a scanned barcode to a known product.
  Future<Result<ScannedProduct>> lookupByBarcode(String barcode);

  /// Run OCR on a captured image of an ingredient list and parse it into
  /// classified ingredients.
  Future<Result<List<ScannedIngredient>>> extractIngredientsFromImage(
      String imagePath);
}
