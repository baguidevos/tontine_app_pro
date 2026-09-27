import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paya_app/core/theme/app_theme.dart';
import 'package:paya_app/data/models/product_model.dart';

class QuantityDialog extends StatefulWidget {
  final ProductModel product;
  final Function(int quantity) onConfirm;

  const QuantityDialog({
    super.key,
    required this.product,
    required this.onConfirm,
  });

  @override
  State<QuantityDialog> createState() => _QuantityDialogState();
}

class _QuantityDialogState extends State<QuantityDialog> {
  late TextEditingController _controller;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '1');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateQuantity(int newQuantity) {
    if (newQuantity < 1) return;
    setState(() {
      _quantity = newQuantity;
      _controller.text = _quantity.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double totalPrice = _quantity * widget.product.price;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      elevation: 10,
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 380),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.payaBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.add_shopping_cart_rounded,
                    color: AppTheme.payaBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ajouter au panier',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.slate500,
                        ),
                      ),
                      Text(
                        widget.product.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.darkerBlue,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Price & Stock Tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.slate50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.slate200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Prix unitaire',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.slate600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${widget.product.price.toStringAsFixed(0)} FCFA',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.payaBlue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Modern Quantity Selector (+ / -)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildQuantityButton(
                  icon: Icons.remove_rounded,
                  onTap: () => _updateQuantity(_quantity - 1),
                  enabled: _quantity > 1,
                ),
                Container(
                  width: 70,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  child: Text(
                    '$_quantity',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.darkerBlue,
                    ),
                  ),
                ),
                _buildQuantityButton(
                  icon: Icons.add_rounded,
                  onTap: () => _updateQuantity(_quantity + 1),
                  enabled: true,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Total Price Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.payaBlue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.payaBlue.withValues(alpha: 0.12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Sous-total :',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppTheme.slate700,
                    ),
                  ),
                  Text(
                    '${totalPrice.toStringAsFixed(0)} FCFA',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: AppTheme.darkerBlue,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onConfirm(_quantity);
                      Get.back();
                    },
                    child: const Text('Confirmer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: enabled ? AppTheme.payaBlue.withValues(alpha: 0.08) : AppTheme.slate100,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: enabled ? AppTheme.payaBlue.withValues(alpha: 0.2) : AppTheme.slate200,
            ),
          ),
          child: Icon(
            icon,
            color: enabled ? AppTheme.payaBlue : AppTheme.slate400,
            size: 22,
          ),
        ),
      ),
    );
  }
}
