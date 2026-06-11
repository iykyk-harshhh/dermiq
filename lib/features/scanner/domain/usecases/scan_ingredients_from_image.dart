import '../entities/scanned_ingredient.dart';
import '../repositories/scanner_repository.dart';
import '../scan_result.dart';

/// Use case: OCR + parse an ingredient-list photo into classified ingredients.
class ScanIngredientsFromImage {
  const ScanIngredientsFromImage(this._repository);
  final ScannerRepository _repository;

  Future<Result<List<ScannedIngredient>>> call(String imagePath) {
    return _repository.extractIngredientsFromImage(imagePath);
  }
}
