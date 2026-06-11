import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firestore_service.dart';
import '../domain/product.dart';
import 'catalog_seed.dart';

/// Product data access.
///
/// Firestore structure:
///   products/{productId}          → global catalog (search / barcode lookup)
///   users/{uid}/shelf/{productId} → a user's saved shelf
///
/// When Firestore is unavailable (no config), or the catalog collection is
/// empty, methods fall back to [catalogProducts] so the app works offline.
class ProductRepository {
  ProductRepository(this._db);
  final FirebaseFirestore? _db;

  bool get isOnline => _db != null;

  CollectionReference<Map<String, dynamic>>? get _catalogCol =>
      _db?.collection('products');

  CollectionReference<Map<String, dynamic>>? _shelfCol(String uid) =>
      _db?.collection('users').doc(uid).collection('shelf');

  /// The whole catalog (Firestore if seeded, otherwise the local seed).
  Future<List<Product>> _catalog() async {
    if (!isOnline) return catalogProducts;
    final snap = await _catalogCol!.get();
    if (snap.docs.isEmpty) return catalogProducts;
    return snap.docs.map((d) => Product.fromFirestore(d.data(), d.id)).toList();
  }

  // ── Search ────────────────────────────────────────────────────────────────
  Future<List<Product>> search(String query, {String? category}) async {
    final all = await _catalog();
    final q = query.trim().toLowerCase();
    return all.where((p) {
      final matchesCategory =
          category == null || category == 'All' || p.category == category;
      final matchesQuery = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.brand.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  Future<Product?> byId(String id) async => _firstWhere(await _catalog(), (p) => p.id == id);

  // ── Barcode (used by the scanner) ───────────────────────────────────────────
  Future<Product?> byBarcode(String code) async =>
      _firstWhere(await _catalog(), (p) => p.barcode == code.trim());

  // ── Shelf storage ───────────────────────────────────────────────────────────
  Stream<List<Product>> watchShelf(String uid) {
    final col = _shelfCol(uid);
    if (col == null) return Stream.value(catalogProducts); // offline seed
    return col.orderBy('addedAt', descending: true).snapshots().map(
          (s) => s.docs.map((d) => Product.fromFirestore(d.data(), d.id)).toList(),
        );
  }

  Future<void> addToShelf(String uid, Product product) async {
    await _shelfCol(uid)?.doc(product.id).set(product.toFirestore());
  }

  Future<void> removeFromShelf(String uid, String productId) async {
    await _shelfCol(uid)?.doc(productId).delete();
  }

  Future<void> setFavourite(String uid, String productId, bool favourite) async {
    await _shelfCol(uid)
        ?.doc(productId)
        .set({'isFavourite': favourite}, SetOptions(merge: true));
  }

  /// Synchronous seed for offline-first state initialization.
  List<Product> get seedShelf => catalogProducts;

  static Product? _firstWhere(List<Product> list, bool Function(Product) test) {
    for (final p in list) {
      if (test(p)) return p;
    }
    return null;
  }
}

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.watch(firestoreProvider));
});

/// Reactive product search keyed by `(query, category)`.
final productSearchProvider =
    FutureProvider.family<List<Product>, ({String query, String? category})>(
        (ref, args) {
  return ref.watch(productRepositoryProvider).search(args.query, category: args.category);
});
