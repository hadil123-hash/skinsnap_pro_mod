import 'package:flutter/material.dart';

import '../models/firestore_content.dart';

class ProductImageView extends StatelessWidget {
  const ProductImageView({
    super.key,
    required this.product,
    required this.size,
    this.fit = BoxFit.cover,
    this.borderRadius = 20,
  });

  final ProductItem product;
  final double size;
  final BoxFit fit;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final source = product.safeImageUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: size,
        height: size,
        color: product.color.withValues(alpha: .10),
        child: _buildImage(source),
      ),
    );
  }

  Widget _buildImage(String source) {
    if (source.isEmpty) {
      return Icon(product.icon, color: product.color, size: size * .48);
    }

    if (source.startsWith('assets/')) {
      return Image.asset(
        source,
        width: size,
        height: size,
        fit: fit,
        errorBuilder: (_, __, ___) => _fallbackIcon(),
      );
    }

    return Image.network(
      source,
      width: size,
      height: size,
      fit: fit,
      errorBuilder: (_, __, ___) => _fallbackIcon(),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Center(
          child: SizedBox(
            width: size * .32,
            height: size * .32,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: product.color,
            ),
          ),
        );
      },
    );
  }

  Widget _fallbackIcon() {
    return Icon(Icons.image_not_supported_rounded, color: product.color, size: size * .42);
  }
}
