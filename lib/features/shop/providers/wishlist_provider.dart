import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../data/shop_models.dart';
import '../data/wishlist_repository.dart';

/// Owns the user's shop wishlist.
///
/// Free-tier & offline-first, mirroring the shelf/order providers: when signed
/// in with Firebase available, it streams `users/{uid}/wishlist` (survives
/// restarts); otherwise it keeps an in-memory session list. All writes guard on
/// `uid != null && isOnline` before touching Firestore.
class WishlistNotifier extends Notifier<List<ShopProduct>> {
  WishlistRepository get _repo => ref.read(wishlistRepositoryProvider);
  String? get _uid => ref.read(authStateProvider)?.id;

  @override
  List<ShopProduct> build() {
    final uid = ref.watch(authStateProvider)?.id;
    if (uid != null && _repo.isOnline) {
      final sub = _repo.watch(uid).listen(
            (items) => state = items,
            onError: (Object e) => debugPrint('[Wishlist] watch error: $e'),
          );
      ref.onDispose(sub.cancel);
    }
    return const [];
  }

  bool contains(String productId) =>
      state.any((p) => p.id == productId);

  /// Adds the product if absent (no duplicates). Persists when signed in.
  void add(ShopProduct product) {
    if (contains(product.id)) return;
    state = [product, ...state];
    final uid = _uid;
    if (uid != null && _repo.isOnline) _repo.add(uid, product);
  }

  void remove(String productId) {
    state = state.where((p) => p.id != productId).toList();
    final uid = _uid;
    if (uid != null && _repo.isOnline) _repo.remove(uid, productId);
  }

  /// Toggles wishlist membership; returns the new state (true = now wishlisted).
  bool toggle(ShopProduct product) {
    if (contains(product.id)) {
      remove(product.id);
      return false;
    }
    add(product);
    return true;
  }
}

final wishlistProvider =
    NotifierProvider<WishlistNotifier, List<ShopProduct>>(
        WishlistNotifier.new);

/// Convenience: is a given product currently wishlisted?
final isWishlistedProvider = Provider.family<bool, String>((ref, productId) {
  return ref.watch(wishlistProvider).any((p) => p.id == productId);
});
