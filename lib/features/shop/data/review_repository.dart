import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firestore_service.dart';
import 'shop_models.dart';

/// A product review (real, Firestore-backed at `products/{id}/reviews/{uid}`).
class ProductReview {
  final String name;
  final double rating;
  final String text;
  final String date;

  const ProductReview({
    required this.name,
    required this.rating,
    required this.text,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'rating': rating,
        'text': text,
        'date': date,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      };

  factory ProductReview.fromMap(Map<String, dynamic> m) => ProductReview(
        name: m['name'] as String? ?? 'Anonymous',
        rating: (m['rating'] as num?)?.toDouble() ?? 5.0,
        text: m['text'] as String? ?? '',
        date: m['date'] as String? ?? '',
      );
}

class ReviewRepository {
  ReviewRepository(this._db);
  final FirebaseFirestore? _db;

  bool get isOnline => _db != null;

  CollectionReference<Map<String, dynamic>>? _col(String productId) =>
      _db?.collection('products').doc(productId).collection('reviews');

  Stream<List<ProductReview>> watch(String productId) {
    final col = _col(productId);
    if (col == null) return const Stream.empty();
    return col.orderBy('createdAt', descending: true).snapshots().map(
          (s) => s.docs.map((d) => ProductReview.fromMap(d.data())).toList(),
        );
  }

  /// Writes the review to Firestore. Returns true only when the write actually
  /// lands; returns false when offline (no db / no-op) or if the write throws.
  Future<bool> submit(String productId, String uid, ProductReview review) async {
    final col = _col(productId);
    if (col == null) return false; // offline / Firebase unavailable — no-op.
    try {
      await col.doc(uid).set(review.toMap());
      return true;
    } catch (_) {
      return false;
    }
  }
}

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository(ref.watch(firestoreProvider));
});

/// Live reviews for a product. Empty until users submit (caller shows the
/// curated seed in that case).
final productReviewsProvider =
    StreamProvider.family<List<ProductReview>, String>((ref, productId) {
  return ref.watch(reviewRepositoryProvider).watch(productId);
});

/// Curated seed reviews shown when a product has no user reviews yet, so the
/// section never looks empty. Ratings track the product's own rating.
List<ProductReview> seedReviews(ShopProduct p) => [
      ProductReview(
        name: 'Anika S.',
        rating: 5.0,
        text:
            'Absolutely love this! Noticed a visible difference within 2 weeks of use.',
        date: 'May 2026',
      ),
      ProductReview(
        name: 'Rohan M.',
        rating: p.rating.clamp(3.5, 5.0),
        text:
            'Great for the price — lightweight, absorbs quickly. Would repurchase.',
        date: 'Apr 2026',
      ),
      ProductReview(
        name: 'Priya K.',
        rating: (p.rating - 0.3).clamp(3.0, 5.0),
        text: 'Good product overall. Fast shipping, intact packaging.',
        date: 'Mar 2026',
      ),
    ];
