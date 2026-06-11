import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/ingredient_parser.dart';
import '../../data/datasources/ocr_data_source.dart';
import '../../data/datasources/product_remote_data_source.dart';
import '../../data/repositories/scanner_repository_impl.dart';
import '../../data/services/camera_permission_service.dart';
import '../../domain/repositories/scanner_repository.dart';
import '../../domain/usecases/lookup_product_by_barcode.dart';
import '../../domain/usecases/scan_ingredients_from_image.dart';

// ── Data sources ─────────────────────────────────────────────────────────────

final ocrDataSourceProvider = Provider<OcrDataSource>((ref) {
  final ds = MlKitOcrDataSource();
  ref.onDispose(ds.dispose); // release the native recognizer
  return ds;
});

final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>(
  (ref) => const MockProductRemoteDataSource(),
);

final ingredientParserProvider =
    Provider<IngredientParser>((ref) => const IngredientParser());

final cameraPermissionServiceProvider =
    Provider<CameraPermissionService>((ref) => const CameraPermissionService());

// ── Repository ───────────────────────────────────────────────────────────────

final scannerRepositoryProvider = Provider<ScannerRepository>((ref) {
  return ScannerRepositoryImpl(
    ocr: ref.watch(ocrDataSourceProvider),
    products: ref.watch(productRemoteDataSourceProvider),
    parser: ref.watch(ingredientParserProvider),
  );
});

// ── Use cases ────────────────────────────────────────────────────────────────

final lookupProductByBarcodeProvider = Provider<LookupProductByBarcode>(
  (ref) => LookupProductByBarcode(ref.watch(scannerRepositoryProvider)),
);

final scanIngredientsFromImageProvider = Provider<ScanIngredientsFromImage>(
  (ref) => ScanIngredientsFromImage(ref.watch(scannerRepositoryProvider)),
);
