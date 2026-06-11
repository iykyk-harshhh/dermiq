import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/product_model.dart';
import '../firestore_service.dart';

/// Realtime CRUD for the user's shelf — `users/{uid}/products`.
class ProductRepository {
  ProductRepository(this._refs);
  final FirestoreRefs _refs;

  Stream<List<ProductModel>> watchAll(String uid) {
    return _refs
        .products(uid)
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ProductModel.fromMap({...d.data(), 'id': d.id}))
            .toList());
  }

  Future<void> add(String uid, ProductModel product) {
    return _refs.products(uid).doc(product.id).set(product.toMap());
  }

  Future<void> update(String uid, ProductModel product) {
    return _refs.products(uid).doc(product.id).set(product.toMap());
  }

  Future<void> remove(String uid, String productId) {
    return _refs.products(uid).doc(productId).delete();
  }
}

final productRepositoryProvider = Provider<ProductRepository?>((ref) {
  final refs = ref.watch(firestoreRefsProvider);
  return refs == null ? null : ProductRepository(refs);
});
