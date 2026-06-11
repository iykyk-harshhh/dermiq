import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/camera_permission_service.dart';
import '../../domain/entities/scanned_ingredient.dart';
import '../../domain/entities/scanned_product.dart';
import '../../domain/scan_failure.dart';
import '../providers/scanner_providers.dart';

enum ScanMode { barcode, ingredients }

/// The scanner's lifecycle: from permission → live scanning → processing →
/// a terminal success/error the UI renders.
enum ScanStatus {
  idle,
  requestingPermission,
  permissionDenied,
  ready,
  processing,
  success,
  error,
}

class ScannerState {
  final ScanMode mode;
  final ScanStatus status;
  final ScannedProduct? product;
  final List<ScannedIngredient>? ingredients;
  final ScanFailure? failure;
  final bool torchOn;

  const ScannerState({
    this.mode = ScanMode.barcode,
    this.status = ScanStatus.idle,
    this.product,
    this.ingredients,
    this.failure,
    this.torchOn = false,
  });

  bool get isProcessing => status == ScanStatus.processing;
  bool get isScanning => status == ScanStatus.ready;
  bool get hasResult => status == ScanStatus.success;

  ScannerState copyWith({
    ScanMode? mode,
    ScanStatus? status,
    ScannedProduct? product,
    List<ScannedIngredient>? ingredients,
    ScanFailure? failure,
    bool? torchOn,
    bool clearResult = false,
  }) {
    return ScannerState(
      mode: mode ?? this.mode,
      status: status ?? this.status,
      product: clearResult ? null : (product ?? this.product),
      ingredients: clearResult ? null : (ingredients ?? this.ingredients),
      failure: clearResult ? null : (failure ?? this.failure),
      torchOn: torchOn ?? this.torchOn,
    );
  }
}

class ScannerController extends Notifier<ScannerState> {
  CameraPermissionService get _permissions =>
      ref.read(cameraPermissionServiceProvider);

  @override
  ScannerState build() => const ScannerState();

  /// Request camera access; transitions to [ScanStatus.ready] or
  /// [ScanStatus.permissionDenied].
  Future<void> ensurePermission() async {
    state = state.copyWith(status: ScanStatus.requestingPermission);
    final result = await _permissions.request();
    if (result == CameraPermission.granted) {
      state = state.copyWith(status: ScanStatus.ready, clearResult: true);
    } else {
      state = state.copyWith(
        status: ScanStatus.permissionDenied,
        failure: PermissionDeniedFailure(
            permanent: result == CameraPermission.permanentlyDenied),
      );
    }
  }

  Future<void> openSettings() => _permissions.openSettings();

  void setMode(ScanMode mode) {
    if (mode == state.mode) return;
    state = state.copyWith(
      mode: mode,
      status: ScanStatus.ready,
      clearResult: true,
    );
  }

  void toggleTorch() => state = state.copyWith(torchOn: !state.torchOn);

  /// Called by the live barcode stream. Ignores detections unless we're idle
  /// and ready, so a single scan doesn't fire the lookup repeatedly.
  Future<void> onBarcodeDetected(String code) async {
    if (state.status != ScanStatus.ready || state.mode != ScanMode.barcode) {
      return;
    }
    state = state.copyWith(status: ScanStatus.processing);
    final result = await ref.read(lookupProductByBarcodeProvider)(code);
    state = result.fold(
      (product) => state.copyWith(status: ScanStatus.success, product: product),
      (failure) => state.copyWith(status: ScanStatus.error, failure: failure),
    );
  }

  /// Called after the user captures a photo of an ingredient list.
  Future<void> scanIngredients(String imagePath) async {
    state = state.copyWith(status: ScanStatus.processing);
    final result = await ref.read(scanIngredientsFromImageProvider)(imagePath);
    state = result.fold(
      (ingredients) =>
          state.copyWith(status: ScanStatus.success, ingredients: ingredients),
      (failure) => state.copyWith(status: ScanStatus.error, failure: failure),
    );
  }

  /// Dismiss a result/error and return to live scanning.
  void reset() =>
      state = state.copyWith(status: ScanStatus.ready, clearResult: true);
}

final scannerControllerProvider =
    NotifierProvider<ScannerController, ScannerState>(ScannerController.new);
