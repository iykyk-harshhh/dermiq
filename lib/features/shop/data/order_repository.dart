import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firestore_service.dart';
import 'shop_models.dart';

/// Persists a user's orders at `users/{uid}/orders/{orderId}`.
///
/// Falls back to no-ops / an empty stream when Firebase is unavailable, so the
/// shop keeps working offline (orders then live only in memory for the session).
class OrderRepository {
  OrderRepository(this._db);
  final FirebaseFirestore? _db;

  bool get isOnline => _db != null;

  CollectionReference<Map<String, dynamic>>? _col(String uid) =>
      _db?.collection('users').doc(uid).collection('orders');

  /// Realtime order history, newest first.
  Stream<List<Order>> watch(String uid) {
    final col = _col(uid);
    if (col == null) return const Stream.empty();
    return col.orderBy('placedAt', descending: true).snapshots().map(
          (s) => s.docs.map((d) => Order.fromMap(d.data())).toList(),
        );
  }

  Future<void> save(String uid, Order order) async {
    await _col(uid)?.doc(order.id).set(order.toMap());
  }

  Future<void> updateStatus(String uid, String orderId, OrderStatus status) async {
    await _col(uid)
        ?.doc(orderId)
        .set({'status': status.name}, SetOptions(merge: true));
  }
}

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(ref.watch(firestoreProvider));
});
