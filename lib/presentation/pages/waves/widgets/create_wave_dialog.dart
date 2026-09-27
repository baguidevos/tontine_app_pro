import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paya_app/core/theme/app_theme.dart';
import 'package:paya_app/data/models/wave_model.dart';
import 'package:paya_app/presentation/controllers/product_controller.dart';
import 'package:paya_app/presentation/controllers/wave_controller.dart';
import 'product_selection_sheet.dart';

class CreateWaveDialog extends StatefulWidget {
  final WaveModel? wave;

  const CreateWaveDialog({super.key, this.wave});

  @override
  State<CreateWaveDialog> createState() => _CreateWaveDialogState();
}

class _CreateWaveDialogState extends State<CreateWaveDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late WaveStatus _status;
  late WaveController _waveController;
  DateTime? _openDate;
  DateTime? _closeDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.wave?.name ?? '');
    _status = widget.wave?.status ?? WaveStatus.draft;
    _openDate = widget.wave?.openDate;
    _closeDate = widget.wave?.closeDate;
    _waveController = Get.find<WaveController>();

    if (!Get.isRegistered<ProductController>()) {
      Get.put(ProductController());
    }

    if (widget.wave != null && widget.wave!.productIds.isNotEmpty) {
      _waveController.clearSelectedProducts();
      _waveController.setSelectedProducts(widget.wave!.productIds);
      _waveController.loadLinkedProducts(widget.wave!.productIds);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.wave != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      elevation: 12,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 680),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 16, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.deepBlue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isEditing ? Icons.edit_rounded : Icons.add_circle_outline_rounded,
                      color: AppTheme.deepBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? 'Modifier la Vague' : 'Nouvelle Vague',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.slate900,
                          ),
                        ),
                        Text(
                          isEditing
                              ? 'Modifiez les informations de la vague'
                              : 'Définissez la période et les produits associés',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.slate500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close_rounded, color: AppTheme.slate400),
                    splashRadius: 20,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppTheme.slate200),

            // Form Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nom de la vague
                      const Text(
                        'Nom de la vague *',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.slate800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: 'ex: Vague Ramadan, Décembre 2025...',
                          prefixIcon: const Icon(
                            Icons.waves_rounded,
                            color: AppTheme.deepBlue,
                            size: 20,
                          ),
                          filled: true,
                          fillColor: AppTheme.slate50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppTheme.slate200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppTheme.slate200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: AppTheme.deepBlue,
                              width: 1.8,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Veuillez entrer un nom';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Statut
                      const Text(
                        'Statut de la vague',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.slate800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: WaveStatus.values.map((status) {
                            final isSelected = _status == status;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                selected: isSelected,
                                label: Text(_getStatusLabel(status)),
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _status = status;
                                    });
                                  }
                                },
                                selectedColor: AppTheme.deepBlue,
                                backgroundColor: AppTheme.slate100,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : AppTheme.slate700,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  fontSize: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: isSelected ? AppTheme.deepBlue : Colors.transparent,
                                  ),
                                ),
                                showCheckmark: false,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Dates
                      const Text(
                        'Période de validité',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.slate800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDatePickerField(
                              label: 'Date début',
                              date: _openDate,
                              icon: Icons.calendar_today_rounded,
                              onTap: () => _selectDate(context, isOpenDate: true),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildDatePickerField(
                              label: 'Date fin / clôture',
                              date: _closeDate,
                              icon: Icons.event_available_rounded,
                              onTap: () => _selectDate(context, isCloseDate: true),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),

                      // Produits associés
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Produits associés',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.slate800,
                            ),
                          ),
                          Obx(() {
                            final count = _waveController.selectedProductIds.length;
                            return Text(
                              '$count produit(s)',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.slate500,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Obx(() {
                        final linkedProducts = _waveController.linkedProducts;
                        final hasProducts = linkedProducts.isNotEmpty;

                        return Column(
                          children: [
                            if (hasProducts)
                              Container(
                                constraints: const BoxConstraints(maxHeight: 180),
                                decoration: BoxDecoration(
                                  color: AppTheme.slate50,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppTheme.slate200),
                                ),
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.all(10),
                                  itemCount: linkedProducts.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 6),
                                  itemBuilder: (context, index) {
                                    final product = linkedProducts[index];
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppTheme.slate200),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 34,
                                            height: 34,
                                            decoration: BoxDecoration(
                                              color: AppTheme.deepBlue.withValues(alpha: 0.08),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.shopping_bag_outlined,
                                              color: AppTheme.deepBlue,
                                              size: 18,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  product.name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 13,
                                                    color: AppTheme.slate900,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  '${product.price.toStringAsFixed(0)} FCFA',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: AppTheme.slate500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.close_rounded,
                                              color: AppTheme.softRed,
                                              size: 18,
                                            ),
                                            tooltip: 'Retirer',
                                            onPressed: () {
                                              _waveController.removeSelectedProduct(
                                                product.id,
                                              );
                                              _waveController.linkedProducts.remove(
                                                product,
                                              );
                                            },
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              )
                            else
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppTheme.slate50,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppTheme.slate200),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.inventory_2_outlined,
                                      color: AppTheme.slate400,
                                      size: 24,
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Aucun produit lié actuellement',
                                        style: TextStyle(
                                          color: AppTheme.slate500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  final currentIds = _waveController
                                      .selectedProductIds
                                      .toList();
                                  Get.bottomSheet(
                                    ProductSelectionSheet(
                                      initialProductIds: currentIds,
                                    ),
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                  );
                                },
                                icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                                label: const Text('Sélectionner des produits'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.deepBlue,
                                  side: const BorderSide(color: AppTheme.deepBlue),
                                  padding: const EdgeInsets.symmetric(vertical: 11),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),

            const Divider(height: 1, color: AppTheme.slate200),

            // Actions Footer
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.slate700,
                        side: const BorderSide(color: AppTheme.slate300),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Annuler', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isSaving
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() => _isSaving = true);
                                try {
                                  if (isEditing) {
                                    final updatedWave = WaveModel(
                                      id: widget.wave!.id,
                                      name: _nameController.text.trim(),
                                      status: _status,
                                      createdAt: widget.wave!.createdAt,
                                      openDate: _openDate,
                                      closeDate: _closeDate,
                                      productIds: _waveController.selectedProductIds.toList(),
                                    );
                                    await _waveController.updateWave(updatedWave);
                                    await _waveController.setWaveProducts(
                                      widget.wave!.id,
                                      _waveController.selectedProductIds.toList(),
                                    );
                                  } else {
                                    final newWave = WaveModel(
                                      id: '',
                                      name: _nameController.text.trim(),
                                      status: _status,
                                      createdAt: DateTime.now(),
                                      openDate: _openDate,
                                      closeDate: _closeDate,
                                    );
                                    await _waveController.createWave(newWave);
                                  }
                                  Get.back();
                                } finally {
                                  if (mounted) setState(() => _isSaving = false);
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.deepBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              isEditing ? 'Mettre à jour' : 'Créer la vague',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusLabel(WaveStatus status) {
    switch (status) {
      case WaveStatus.active:
        return 'Active';
      case WaveStatus.closed:
        return 'Clôturée';
      case WaveStatus.draft:
        return 'Brouillon';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _selectDate(
    BuildContext context, {
    bool isOpenDate = false,
    bool isCloseDate = false,
  }) async {
    final initialDate = isOpenDate
        ? _openDate
        : (isCloseDate ? _closeDate : DateTime.now());
    final firstDate = DateTime.now().subtract(const Duration(days: 365));
    final lastDate = DateTime.now().add(const Duration(days: 365 * 2));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.deepBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.deepBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isOpenDate) {
          _openDate = picked;
        } else if (isCloseDate) {
          _closeDate = picked;
        }
      });
    }
  }

  Widget _buildDatePickerField({
    required String label,
    required DateTime? date,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.slate50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.slate200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: AppTheme.deepBlue),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.slate500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              date != null ? _formatDate(date) : 'Sélectionner',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: date != null ? AppTheme.slate900 : AppTheme.slate400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
