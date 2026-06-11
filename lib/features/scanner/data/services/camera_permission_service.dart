import 'package:permission_handler/permission_handler.dart';

/// Result of a camera-permission request.
enum CameraPermission { granted, denied, permanentlyDenied, restricted }

/// Wraps permission_handler so the rest of the app never imports it directly.
class CameraPermissionService {
  const CameraPermissionService();

  Future<CameraPermission> status() => _map(Permission.camera.status);

  Future<CameraPermission> request() => _map(Permission.camera.request());

  /// Opens the OS settings page (for the permanently-denied case).
  Future<bool> openSettings() => openAppSettings();

  Future<CameraPermission> _map(Future<PermissionStatus> future) async {
    final status = await future;
    if (status.isGranted || status.isLimited) return CameraPermission.granted;
    if (status.isPermanentlyDenied) return CameraPermission.permanentlyDenied;
    if (status.isRestricted) return CameraPermission.restricted;
    return CameraPermission.denied;
  }
}
