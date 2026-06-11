import '../entities/scanned_product.dart';
import '../repositories/scanner_repository.dart';
import '../scan_failure.dart';
import '../scan_result.dart';

/// Use case: turn a raw barcode string into a recognised product.
/// Validates input before delegating to the repository.
class LookupProductByBarcode {
  const LookupProductByBarcode(this._repository);
  final ScannerRepository _repository;

  Future<Result<ScannedProduct>> call(String barcode) {
    final code = barcode.trim();
    if (code.isEmpty) {
      return Future.value(const Err(UnknownScanFailure('Empty barcode.')));
    }
    return _repository.lookupByBarcode(code);
  }
}
