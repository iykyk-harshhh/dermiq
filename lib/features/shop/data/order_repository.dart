import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/foundation.dart';
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

  /// Realtime order history, newest first. Malformed docs are skipped (not
  /// fatal), and a stream error degrades to an empty list instead of crashing
  /// the My Orders screen.
  Stream<List<Order>> watch(String uid) {
    final col = _col(uid);
    if (col == null) return const Stream.empty();
    return col
        .orderBy('placedAt', descending: true)
        .snapshots()
        .map((s) => s.docs
            .map((d) => Order.tryFromMap(d.data()))
            .whereType<Order>()
            .toList())
        .handleError((Object e) {
      debugPrint('[Orders] watch stream error: $e');
    });
  }

  Future<void> save(String uid, Order order) async {
    try {
      await _col(uid)?.doc(order.id).set(order.toMap());
    } catch (e) {
      debugPrint('[Orders] save failed: $e');
    }
  }

  /// Updates status on an EXISTING order doc only — never creates one (avoids
  /// writing partial `{status}`-only docs, e.g. for in-memory demo orders).
  Future<void> updateStatus(String uid, String orderId, OrderStatus status) async {
    try {
      await _col(uid)?.doc(orderId).update({'status': status.name});
    } catch (e) {
      // update() throws not-found if the doc doesn't exist (demo/local order) —
      // that's expected; the change already lives in in-memory state.
      debugPrint('[Orders] updateStatus skipped/failed for $orderId: $e');
    }
  }
}

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(ref.watch(firestoreProvider));
});
