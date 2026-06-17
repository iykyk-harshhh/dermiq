import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/product_image_service.dart';
import '../../data/shop_models.dart';

/// Shows a real product photo (from Open Beauty Facts) for [product], filling
/// its parent. While loading, on error, or when no image exists it renders
/// [fallback] (the branded gradient/initial) so it never looks broken.
class ProductImage extends ConsumerWidget {
  final ShopProduct product;
  final Widget fallback;
  final BoxFit fit;

  const ProductImage({
    super.key,
    required this.product,
    required this.fallback,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async =
        ref.watch(productImageProvider(productImageQuery(product.brand, product.name)));
    return async.when(
      loading: () => fallback,
      error: (_, _) => fallback,
      data: (url) {
        if (url == null) return fallback;
        return Image.network(
          url,
          fit: fit,
          width: double.infinity,
          height: double.infinity,
          loadingBuilder: (_, child, progress) =>
              progress == null ? child : fallback,
          errorBuilder: (_, _, _) => fallback,
        );
      },
    );
  }
}
