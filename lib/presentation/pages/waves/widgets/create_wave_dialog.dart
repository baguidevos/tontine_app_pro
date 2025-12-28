import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../controllers/wave_controller.dart';
import '../../../../data/models/wave_model.dart';

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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.wave?.name ?? '');
    _status = widget.wave?.status ?? WaveStatus.draft;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final waveController = Get.put(WaveController());
    final isEditing = widget.wave != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: AppTheme.warmCream,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isEditing
                          ? Icons.edit_outlined
                          : Icons.add_circle_outline,
                      size: 32,
                      color: AppTheme.deepBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    isEditing ? 'Modifier la Vague' : 'Nouvelle Vague',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.deepBlue,
                    ),
                  ),
                ),
                if (isEditing) ...[
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Créée le ${_formatDate(widget.wave!.createdAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 32),

                // Name Input
                Text(
                  'Nom de la vague',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'ex: Décembre 2025',
                    prefixIcon: const Icon(
                      Icons.waves,
                      color: AppTheme.deepBlue,
                    ),
                    filled: true,
                    fillColor: AppTheme.warmCream.withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppTheme.deepBlue,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un nom';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Status Selection
                Text(
                  'Statut',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: WaveStatus.values.map((status) {
                      final isSelected = _status == status;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: isSelected,
                          label: Text(_getStatusLabel(status)),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _status = status;
                              });
                            }
                          },
                          backgroundColor: AppTheme.warmCream,
                          selectedColor: AppTheme.deepBlue,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppTheme.deepBlue,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.transparent
                                  : AppTheme.deepBlue.withOpacity(0.2),
                            ),
                          ),
                          showCheckmark: false,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 32),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Annuler',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            if (isEditing) {
                              final updatedWave = WaveModel(
                                id: widget.wave!.id,
                                name: _nameController.text,
                                status: _status,
                                createdAt: widget.wave!.createdAt,
                              );
                              await waveController.updateWave(updatedWave);
                            } else {
                              final newWave = WaveModel(
                                id: '', // Generated by repo
                                name: _nameController.text,
                                status: _status,
                                createdAt: DateTime.now(),
                              );
                              await waveController.createWave(newWave);
                            }
                            Get.back();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.deepBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          isEditing ? 'Modifier' : 'Créer',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
    return '${date.day}/${date.month}/${date.year}';
  }
}
