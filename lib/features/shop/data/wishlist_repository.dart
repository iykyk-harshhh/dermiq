import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firestore_service.dart';
import 'shop_models.dart';

/// Persists a user's wishlist at `users/{uid}/wishlist/{productId}`.
///
/// Free-tier only: plain Firestore documents (no paid services). Falls back to
/// no-ops / an empty stream when Firebase is unavailable, so the wishlist keeps
/// working offline (it then lives only in memory for the session).
class WishlistRepository {
  WishlistRepository(this._db);
  final FirebaseFirestore? _db;

  bool get isOnline => _db != null;

  CollectionReference<Map<String, dynamic>>? _col(String uid) =>
      _db?.collection('users').doc(uid).collection('wishlist');

  /// Realtime wishlist, newest first. Malformed docs are skipped, and a stream
  /// error degrades to an empty list instead of crashing the screen.
  Stream<List<ShopProduct>> watch(String uid) {
    final col = _col(uid);
    if (col == null) return const Stream.empty();
    return col
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((s) => s.docs
            .map((d) {
              try {
                return ShopProduct.fromMap(d.data());
              } catch (_) {
                return null;
              }
            })
            .whereType<ShopProduct>()
            .toList())
        .handleError((Object e) {
      debugPrint('[Wishlist] watch stream error: $e');
    });
  }

  Future<void> add(String uid, ShopProduct product) async {
    try {
      await _col(uid)?.doc(product.id).set({
        ...product.toMap(),
        'addedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      debugPrint('[Wishlist] add failed: $e');
    }
  }

  Future<void> remove(String uid, String productId) async {
    try {
      await _col(uid)?.doc(productId).delete();
    } catch (e) {
      debugPrint('[Wishlist] remove failed: $e');
    }
  }
}

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  return WishlistRepository(ref.watch(firestoreProvider));
});
