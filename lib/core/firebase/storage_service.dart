import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_bootstrap.dart';

/// Cloud Storage wrapper for user images (profile photos, scan captures).
/// Paths are namespaced per-user so security rules can scope access.
class StorageService {
  StorageService(this._storage);

  final FirebaseStorage? _storage;

  bool get isAvailable => _storage != null;

  /// Uploads a profile photo and returns its download URL.
  Future<String> uploadProfilePhoto(String userId, File file) {
    return _uploadFile('users/$userId/profile/avatar.jpg', file,
        contentType: 'image/jpeg');
  }

  /// Uploads a scan capture; returns the download URL.
  Future<String> uploadScanImage(String userId, String scanId, File file) {
    return _uploadFile('users/$userId/scans/$scanId.jpg', file,
        contentType: 'image/jpeg');
  }

  /// Uploads raw bytes (e.g. a cropped/processed image from memory).
  Future<String> uploadBytes(String path, Uint8List bytes,
      {String contentType = 'image/jpeg'}) async {
    _require();
    final ref = _storage!.ref(path);
    await ref.putData(bytes, SettableMetadata(contentType: contentType));
    return ref.getDownloadURL();
  }

  Future<String> _uploadFile(String path, File file,
      {required String contentType}) async {
    _require();
    final ref = _storage!.ref(path);
    await ref.putFile(file, SettableMetadata(contentType: contentType));
    return ref.getDownloadURL();
  }

  Future<void> delete(String path) async {
    _require();
    await _storage!.ref(path).delete();
  }

  void _require() {
    if (!isAvailable) {
      throw StateError('Storage unavailable — Firebase is not configured.');
    }
  }
}

final storageServiceProvider = Provider<StorageService>((ref) {
  if (!FirebaseBootstrap.isAvailable) return StorageService(null);
  return StorageService(FirebaseStorage.instance);
});
