/// Domain-level failures for the scanner. Sealed so callers can exhaustively
/// switch and the UI can show a tailored message + recovery action.
sealed class ScanFailure {
  const ScanFailure(this.message);
  final String message;
}

class PermissionDeniedFailure extends ScanFailure {
  /// True when the user ticked "don't ask again" — must open app settings.
  final bool permanent;
  const PermissionDeniedFailure({this.permanent = false})
      : super('Camera access is needed to scan.');
}

class CameraUnavailableFailure extends ScanFailure {
  const CameraUnavailableFailure() : super('Camera is unavailable on this device.');
}

class NoTextDetectedFailure extends ScanFailure {
  const NoTextDetectedFailure()
      : super('No ingredients detected. Hold steady over the ingredient list.');
}

class ProductNotFoundFailure extends ScanFailure {
  final String barcode;
  const ProductNotFoundFailure(this.barcode)
      : super('No product found for this barcode.');
}

class NetworkFailure extends ScanFailure {
  const NetworkFailure() : super('Network error. Check your connection and retry.');
}

class CancelledFailure extends ScanFailure {
  const CancelledFailure() : super('Scan cancelled.');
}

class UnknownScanFailure extends ScanFailure {
  const UnknownScanFailure([String? message])
      : super(message ?? 'Something went wrong while scanning.');
}
