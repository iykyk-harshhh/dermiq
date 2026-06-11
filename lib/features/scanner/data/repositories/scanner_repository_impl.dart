import 'package:flutter/foundation.dart';

import '../../domain/entities/scanned_ingredient.dart';
import '../../domain/entities/scanned_product.dart';
import '../../domain/repositories/scanner_repository.dart';
import '../../domain/scan_failure.dart';
import '../../domain/scan_result.dart';
import '../datasources/ingredient_parser.dart';
import '../datasources/ocr_data_source.dart';
import '../datasources/product_remote_data_source.dart';

/// Concrete repository: composes the OCR source, ingredient parser and product
/// lookup, and translates thrown exceptions into typed [ScanFailure]s.
class ScannerRepositoryImpl implements ScannerRepository {
  ScannerRepositoryImpl({
    required this._ocr,
    required this._products,
    this._parser = const IngredientParser(),
  });

  final OcrDataSource _ocr;
  final ProductRemoteDataSource _products;
  final IngredientParser _parser;

  @override
  Future<Result<ScannedProduct>> lookupByBarcode(String barcode) async {
    try {
      final model = await _products.fetchByBarcode(barcode);
      if (model == null) {
        return Err(ProductNotFoundFailure(barcode));
      }
      return Ok(model.toEntity(_parser));
    } catch (e, st) {
      debugPrint('[Scanner] barcode lookup failed: $e\n$st');
      return const Err(NetworkFailure());
    }
  }

  @override
  Future<Result<List<ScannedIngredient>>> extractIngredientsFromImage(
      String imagePath) async {
    try {
      final text = await _ocr.recognizeText(imagePath);
      final ingredients = _parser.parse(text);
      if (ingredients.isEmpty) {
        return const Err(NoTextDetectedFailure());
      }
      return Ok(ingredients);
    } catch (e, st) {
      debugPrint('[Scanner] OCR failed: $e\n$st');
      return const Err(UnknownScanFailure('Could not read the image.'));
    }
  }
}
