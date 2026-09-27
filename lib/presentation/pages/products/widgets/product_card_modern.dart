import 'package:flutter/material.dart';
import 'package:paya_app/core/theme/app_theme.dart';
import 'package:paya_app/data/models/product_model.dart';
import 'package:paya_app/presentation/widgets/product_image.dart';

class ProductCardModern extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback onViewDetails;
  final VoidCallback onOptionsTap;

  const ProductCardModern({
    super.key,
    required this.product,
    required this.onTap,
    required this.onViewDetails,
    required this.onOptionsTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool inStock = product.stock > 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.slate200.withValues(alpha: 0.8), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppTheme.payaBlue.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Section
              Expanded(
                flex: 5,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ProductImage(
                      product: product,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.zero,
                    ),
                    // Stock Badge on top left
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: inStock
                              ? AppTheme.payaGreen.withValues(alpha: 0.9)
                              : AppTheme.payaRed.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          inStock ? '${product.stock} en stock' : 'Rupture',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    // Options Button on top right
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Material(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: onOptionsTap,
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(Icons.more_horiz_rounded, size: 18, color: AppTheme.darkerBlue),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Info Section
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppTheme.slate900,
                          height: 1.25,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${product.price.toStringAsFixed(0)} F',
                                style: const TextStyle(
                                  color: AppTheme.payaBlue,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                              if (product.prixTTC != null)
                                Text(
                                  'TTC: ${product.prixTTC!.toStringAsFixed(0)} F',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.slate500,
                                  ),
                                ),
                            ],
                          ),
                          InkWell(
                            onTap: onViewDetails,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.payaBlue.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.arrow_forward_rounded,
                                size: 14,
                                color: AppTheme.payaBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
