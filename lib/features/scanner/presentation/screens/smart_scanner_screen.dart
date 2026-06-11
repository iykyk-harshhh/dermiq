import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../domain/entities/scanned_ingredient.dart';
import '../../domain/entities/scanned_product.dart';
import '../../domain/scan_failure.dart';
import '../controllers/scanner_controller.dart';

/// Smart Scanner UI — live barcode scanning + capture-and-OCR ingredient
/// reading. Pure presentation over the clean-architecture scanner layer
/// (domain/data) via [scannerControllerProvider].
class SmartScannerScreen extends ConsumerStatefulWidget {
  const SmartScannerScreen({super.key});

  @override
  ConsumerState<SmartScannerScreen> createState() => _SmartScannerScreenState();
}

class _SmartScannerScreenState extends ConsumerState<SmartScannerScreen>
    with WidgetsBindingObserver {
  late final MobileScannerController _camera;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _camera = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      formats: const [
        BarcodeFormat.ean13, BarcodeFormat.ean8,
        BarcodeFormat.upcA, BarcodeFormat.upcE, BarcodeFormat.qrCode,
      ],
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(scannerControllerProvider.notifier).ensurePermission();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _camera.start();
    } else if (state == AppLifecycleState.inactive) {
      _camera.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _camera.dispose();
    super.dispose();
  }

  ScannerController get _controller =>
      ref.read(scannerControllerProvider.notifier);

  Future<void> _capture() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (file == null) return;
    await _controller.scanIngredients(file.path);
  }

  void _toggleTorch() {
    _camera.toggleTorch();
    _controller.toggleTorch();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scannerControllerProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: switch (state.status) {
          ScanStatus.idle ||
          ScanStatus.requestingPermission =>
            const _LoadingView(label: 'Starting camera…'),
          ScanStatus.permissionDenied => _PermissionView(
              permanent: (state.failure is PermissionDeniedFailure) &&
                  (state.failure as PermissionDeniedFailure).permanent,
              onAllow: _controller.ensurePermission,
              onSettings: _controller.openSettings,
              onCancel: () => context.pop(),
            ),
          _ => _ScannerView(
              state: state,
              camera: _camera,
              onToggleTorch: _toggleTorch,
              onModeChanged: _controller.setMode,
              onBarcode: _controller.onBarcodeDetected,
              onCapture: _capture,
              onRetry: _controller.reset,
              onManualSearch: () => context.push('/scan/manual'),
              onAnalyze: (product) => context.push(
                  '/scan/analysis/${product?.barcode ?? 'scan'}'),
              onClose: () => context.pop(),
            ),
        },
      ),
    );
  }
}

// ── Loading ───────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  final String label;
  const _LoadingView({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
          const SizedBox(height: 16),
          Text(label, style: AppTypography.bodyMedium.copyWith(color: Colors.white70)),
        ],
      ),
    );
  }
}

// ── Permission gate ───────────────────────────────────────────────────────────

class _PermissionView extends StatelessWidget {
  final bool permanent;
  final VoidCallback onAllow;
  final VoidCallback onSettings;
  final VoidCallback onCancel;

  const _PermissionView({
    required this.permanent,
    required this.onAllow,
    required this.onSettings,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88, height: 88,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.photo_camera_rounded, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),
            Text('Camera access needed',
                style: AppTypography.h3.copyWith(color: Colors.white),
                textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text(
              permanent
                  ? 'Camera access is blocked. Enable it in Settings to scan products.'
                  : 'DermIQ needs your camera to scan barcodes and read ingredient labels.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: Colors.white70, height: 1.5),
            ),
            const SizedBox(height: 28),
            _FilledButton(
              label: permanent ? 'Open Settings' : 'Allow Camera',
              icon: permanent ? Icons.settings_rounded : Icons.check_rounded,
              onTap: permanent ? onSettings : onAllow,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onCancel,
              child: Text('Not now',
                  style: AppTypography.buttonSmall.copyWith(color: Colors.white60)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Live scanner ──────────────────────────────────────────────────────────────

class _ScannerView extends StatelessWidget {
  final ScannerState state;
  final MobileScannerController camera;
  final VoidCallback onToggleTorch;
  final ValueChanged<ScanMode> onModeChanged;
  final ValueChanged<String> onBarcode;
  final VoidCallback onCapture;
  final VoidCallback onRetry;
  final VoidCallback onManualSearch;
  final ValueChanged<ScannedProduct?> onAnalyze;
  final VoidCallback onClose;

  const _ScannerView({
    required this.state,
    required this.camera,
    required this.onToggleTorch,
    required this.onModeChanged,
    required this.onBarcode,
    required this.onCapture,
    required this.onRetry,
    required this.onManualSearch,
    required this.onAnalyze,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final mode = state.mode;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (mode == ScanMode.barcode)
          MobileScanner(
            controller: camera,
            onDetect: (capture) {
              final code = capture.barcodes.firstOrNull?.rawValue;
              if (code != null && code.isNotEmpty) onBarcode(code);
            },
            errorBuilder: (context, error, child) => _CameraError(
              message: error.errorDetails?.message ?? 'Camera error',
              onRetry: onRetry,
            ),
          )
        else
          const ColoredBox(color: Color(0xFF101014)),

        const _Reticle(),

        // Top bar.
        Positioned(
          top: 8, left: 8, right: 8,
          child: Row(
            children: [
              _CircleIcon(icon: Icons.close_rounded, onTap: onClose),
              const Spacer(),
              if (mode == ScanMode.barcode)
                _CircleIcon(
                  icon: state.torchOn
                      ? Icons.flashlight_on_rounded
                      : Icons.flashlight_off_rounded,
                  onTap: onToggleTorch,
                ),
            ],
          ),
        ),

        // Mode toggle + instructions.
        Positioned(
          left: 0, right: 0, bottom: 0,
          child: _BottomPanel(
            mode: mode,
            onModeChanged: onModeChanged,
            onCapture: onCapture,
          ),
        ),

        // State overlays.
        if (state.isProcessing)
          const _Overlay(child: _LoadingView(label: 'Analyzing…')),
        if (state.status == ScanStatus.error && state.failure != null)
          _Overlay(
            child: _ErrorCard(
              failure: state.failure!,
              onRetry: onRetry,
              onManualSearch: onManualSearch,
            ),
          ),
        if (state.status == ScanStatus.success && state.product != null)
          _Overlay(
            child: _ProductResultCard(
              product: state.product!,
              onAnalyze: () => onAnalyze(state.product),
              onRescan: onRetry,
            ),
          ),
        if (state.status == ScanStatus.success && state.ingredients != null)
          _Overlay(
            child: _IngredientResultCard(
              ingredients: state.ingredients!,
              onAnalyze: () => onAnalyze(null),
              onRescan: onRetry,
            ),
          ),
      ],
    );
  }
}

// ── Reticle + bottom panel ────────────────────────────────────────────────────

class _Reticle extends StatelessWidget {
  const _Reticle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 260, height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 2),
        ),
      ),
    );
  }
}

class _BottomPanel extends StatelessWidget {
  final ScanMode mode;
  final ValueChanged<ScanMode> onModeChanged;
  final VoidCallback onCapture;

  const _BottomPanel({
    required this.mode,
    required this.onModeChanged,
    required this.onCapture,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.85)],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            mode == ScanMode.barcode
                ? 'Point at a product barcode'
                : 'Frame the ingredient list, then capture',
            style: AppTypography.bodyMedium.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),
          if (mode == ScanMode.ingredients)
            _FilledButton(
              label: 'Capture Label',
              icon: Icons.camera_alt_rounded,
              onTap: onCapture,
            ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ModeTab(
                  label: 'Barcode', icon: Icons.qr_code_scanner_rounded,
                  selected: mode == ScanMode.barcode,
                  onTap: () => onModeChanged(ScanMode.barcode),
                ),
                _ModeTab(
                  label: 'Ingredients', icon: Icons.text_fields_rounded,
                  selected: mode == ScanMode.ingredients,
                  onTap: () => onModeChanged(ScanMode.ingredients),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _ModeTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: selected ? AppColors.primary : Colors.white70),
            const SizedBox(width: 6),
            Text(label,
                style: AppTypography.buttonSmall.copyWith(
                    color: selected ? AppColors.primary : Colors.white70)),
          ],
        ),
      ),
    );
  }
}

// ── Overlays / result cards ───────────────────────────────────────────────────

class _Overlay extends StatelessWidget {
  final Widget child;
  const _Overlay({required this.child});

  @override
  Widget build(BuildContext context) => Positioned.fill(
        child: ColoredBox(
          color: Colors.black.withValues(alpha: 0.78),
          child: Center(
            child: Padding(padding: const EdgeInsets.all(24), child: child),
          ),
        ),
      );
}

class _ErrorCard extends StatelessWidget {
  final ScanFailure failure;
  final VoidCallback onRetry;
  final VoidCallback onManualSearch;
  const _ErrorCard({
    required this.failure,
    required this.onRetry,
    required this.onManualSearch,
  });

  @override
  Widget build(BuildContext context) {
    final notFound = failure is ProductNotFoundFailure;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: context.dColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 30),
          ),
          const SizedBox(height: 16),
          Text(notFound ? 'Product not found' : 'Scan failed',
              style: AppTypography.h4, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(failure.message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(height: 1.5)),
          const SizedBox(height: 20),
          _FilledButton(label: 'Try Again', icon: Icons.refresh_rounded, onTap: onRetry, dark: true),
          const SizedBox(height: 10),
          TextButton(
            onPressed: onManualSearch,
            child: Text('Search manually instead',
                style: AppTypography.buttonSmall.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

class _ProductResultCard extends StatelessWidget {
  final ScannedProduct product;
  final VoidCallback onAnalyze;
  final VoidCallback onRescan;
  const _ProductResultCard({
    required this.product,
    required this.onAnalyze,
    required this.onRescan,
  });

  Color get _scoreColor {
    if (product.safetyScore >= 85) return AppColors.success;
    if (product.safetyScore >= 70) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.dColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: _scoreColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text('${product.safetyScore}',
                    style: AppTypography.metricSmall.copyWith(color: _scoreColor)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: AppTypography.labelLarge,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('${product.brand} · ${product.category}',
                        style: AppTypography.caption.copyWith(color: context.dColors.textSecondary),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          if (product.ingredients.isNotEmpty) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                _SafetyPill(
                    count: product.avoidCount, label: 'avoid', color: AppColors.error),
                const SizedBox(width: 8),
                _SafetyPill(
                    count: product.cautionCount, label: 'caution', color: AppColors.warning),
              ],
            ),
          ],
          const SizedBox(height: 18),
          _FilledButton(
              label: 'View Full Analysis', icon: Icons.science_rounded,
              onTap: onAnalyze, dark: true),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: onRescan,
              child: Text('Scan another',
                  style: AppTypography.buttonSmall.copyWith(color: AppColors.primary)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SafetyPill extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  const _SafetyPill({required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text('$count $label',
          style: AppTypography.caption.copyWith(color: color, fontWeight: FontWeight.w700)),
    );
  }
}

class _IngredientResultCard extends StatelessWidget {
  final List<ScannedIngredient> ingredients;
  final VoidCallback onAnalyze;
  final VoidCallback onRescan;
  const _IngredientResultCard({
    required this.ingredients,
    required this.onAnalyze,
    required this.onRescan,
  });

  static Color _color(BuildContext context, IngredientSafety s) => switch (s) {
        IngredientSafety.safe => AppColors.success,
        IngredientSafety.caution => AppColors.warning,
        IngredientSafety.avoid => AppColors.error,
        IngredientSafety.unknown => context.dColors.textTertiary,
      };

  @override
  Widget build(BuildContext context) {
    final flagged = ingredients
        .where((i) =>
            i.safety == IngredientSafety.caution ||
            i.safety == IngredientSafety.avoid)
        .toList();
    return Container(
      padding: const EdgeInsets.all(20),
      constraints: const BoxConstraints(maxHeight: 480),
      decoration: BoxDecoration(
        color: context.dColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 22),
              const SizedBox(width: 8),
              Text('${ingredients.length} ingredients read',
                  style: AppTypography.labelLarge),
            ],
          ),
          if (flagged.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('${flagged.length} flagged for review',
                style: AppTypography.caption.copyWith(color: AppColors.warning)),
          ],
          const SizedBox(height: 14),
          Flexible(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 6, runSpacing: 6,
                children: ingredients
                    .map((i) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: _color(context, i.safety).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(i.name,
                              style: AppTypography.caption.copyWith(color: _color(context, i.safety))),
                        ))
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 18),
          _FilledButton(
              label: 'Analyze', icon: Icons.science_rounded, onTap: onAnalyze, dark: true),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: onRescan,
              child: Text('Rescan',
                  style: AppTypography.buttonSmall.copyWith(color: AppColors.primary)),
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _CameraError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.videocam_off_rounded, color: Colors.white54, size: 40),
          const SizedBox(height: 12),
          Text(message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: Colors.white70)),
          const SizedBox(height: 16),
          _FilledButton(label: 'Retry', icon: Icons.refresh_rounded, onTap: onRetry),
        ],
      ),
    );
  }
}

// ── Buttons ───────────────────────────────────────────────────────────────────

class _FilledButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool dark;
  const _FilledButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: dark ? AppColors.gradientPrimary : null,
          color: dark ? null : Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: dark ? Colors.white : AppColors.primary),
            const SizedBox(width: 8),
            Text(label,
                style: AppTypography.button
                    .copyWith(color: dark ? Colors.white : AppColors.primary)),
          ],
        ),
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}
