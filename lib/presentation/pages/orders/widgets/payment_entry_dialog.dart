import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paya_app/core/theme/app_theme.dart';
import 'package:paya_app/data/models/order_model.dart';

class PaymentEntryDialog extends StatefulWidget {
  final OrderItemModel item;
  final Function(double amount) onConfirm;

  const PaymentEntryDialog({
    super.key,
    required this.item,
    required this.onConfirm,
  });

  @override
  State<PaymentEntryDialog> createState() => _PaymentEntryDialogState();
}

class _PaymentEntryDialogState extends State<PaymentEntryDialog> {
  late TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.item.balance.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _errorText = 'Veuillez saisir un montant');
      return;
    }

    final amount = double.tryParse(text);
    if (amount == null || amount <= 0) {
      setState(() => _errorText = 'Montant invalide');
      return;
    }

    if (amount > widget.item.balance + 1) {
      setState(() => _errorText = 'Le montant dépasse le reste à payer');
      return;
    }

    widget.onConfirm(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      elevation: 10,
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 380),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    Icons.payments_rounded,
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
                        'Encaisser un versement',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.slate500,
                        ),
                      ),
                      Text(
                        widget.item.name,
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

            // Balance Pill Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.slate50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.slate200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Reste à payer',
                    style: TextStyle(
                      color: AppTheme.slate600,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '${widget.item.balance.toStringAsFixed(0)} FCFA',
                    style: const TextStyle(
                      color: AppTheme.payaBlue,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Amount Input
            TextField(
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.darkerBlue,
              ),
              decoration: InputDecoration(
                labelText: 'Montant du versement',
                suffixText: 'FCFA',
                errorText: _errorText,
                filled: true,
                fillColor: AppTheme.slate50,
              ),
              onChanged: (_) {
                if (_errorText != null) {
                  setState(() => _errorText = null);
                }
              },
              onSubmitted: (_) => _validateAndSubmit(),
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
                    onPressed: _validateAndSubmit,
                    child: const Text('Valider'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
