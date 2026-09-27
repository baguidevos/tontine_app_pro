import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paya_app/presentation/controllers/customer_controller.dart';
import 'package:paya_app/core/theme/app_theme.dart';
import 'package:paya_app/data/models/customer_model.dart';
import 'package:paya_app/presentation/widgets/confirmation_dialog.dart';

class CreateCustomerPage extends StatefulWidget {
  final CustomerModel? customer;
  const CreateCustomerPage({super.key, this.customer});

  @override
  State<CreateCustomerPage> createState() => _CreateCustomerPageState();
}

class _CreateCustomerPageState extends State<CreateCustomerPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  String? _selectedSexe;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer?.name ?? '');
    _phoneController = TextEditingController(
      text: widget.customer?.phone ?? '',
    );
    _addressController = TextEditingController(
      text: widget.customer?.address ?? '',
    );
    _selectedSexe = widget.customer?.sexe;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customerController = Get.find<CustomerController>();
    final isEditing = widget.customer != null;

    return Scaffold(
      backgroundColor: AppTheme.warmCream,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Modifier le Client' : 'Nouveau Client',
          style: const TextStyle(
            color: AppTheme.deepBlue,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppTheme.deepBlue),
          onPressed: () => Get.back(),
        ),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.softRed),
              tooltip: 'Supprimer',
              onPressed: () {
                Get.dialog(
                  ConfirmationDialog(
                    title: 'Supprimer le client',
                    message: 'Voulez-vous vraiment supprimer "${widget.customer!.name}" ?',
                    confirmText: 'Supprimer',
                    isDanger: true,
                    onConfirm: () async {
                      Get.back();
                      final success = await customerController.deleteCustomer(
                        widget.customer!.id,
                      );
                      if (success) {
                        Get.back();
                      }
                    },
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile icon banner
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppTheme.deepBlue.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 38,
                        color: AppTheme.deepBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      isEditing ? widget.customer!.name : 'Coordonnées du client',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.slate900,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Renseignez les coordonnées pour simplifier le suivi',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.slate500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Container for form fields
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.slate200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nom complet
                        const Text(
                          'Nom complet *',
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
                          decoration: _inputDecoration(
                            hint: 'Ex: Aïcha Ouédraogo',
                            icon: Icons.person_outline_rounded,
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty ? 'Le nom est obligatoire' : null,
                        ),
                        const SizedBox(height: 20),

                        // Téléphone
                        const Text(
                          'Numéro de téléphone *',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.slate800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          decoration: _inputDecoration(
                            hint: 'Ex: +226 70 00 00 00',
                            icon: Icons.phone_outlined,
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty ? 'Le téléphone est obligatoire' : null,
                        ),
                        const SizedBox(height: 20),

                        // Adresse
                        const Text(
                          'Adresse de livraison (Optionnel)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.slate800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _addressController,
                          style: const TextStyle(fontSize: 14),
                          decoration: _inputDecoration(
                            hint: 'Ex: Quartier 1200 Logements',
                            icon: Icons.location_on_outlined,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Genre / Sexe
                        const Text(
                          'Genre (Optionnel)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.slate800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildGenderChip('Femme', Icons.female_rounded),
                            const SizedBox(width: 10),
                            _buildGenderChip('Homme', Icons.male_rounded),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSaving
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() => _isSaving = true);
                                try {
                                  if (isEditing) {
                                    final updated = widget.customer!.copyWith(
                                      name: _nameController.text.trim(),
                                      phone: _phoneController.text.trim(),
                                      address: _addressController.text.trim(),
                                      sexe: _selectedSexe,
                                    );
                                    await customerController.updateCustomer(updated);
                                    Get.back();
                                  } else {
                                    final success = await customerController.createCustomer(
                                      name: _nameController.text.trim(),
                                      phone: _phoneController.text.trim(),
                                      address: _addressController.text.trim(),
                                      sexe: _selectedSexe,
                                    );
                                    if (success) {
                                      Get.back();
                                    }
                                  }
                                } finally {
                                  if (mounted) setState(() => _isSaving = false);
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.deepBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              isEditing ? 'Mettre à jour' : 'Enregistrer le client',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderChip(String label, IconData icon) {
    final isSelected = _selectedSexe == label;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedSexe = isSelected ? null : label;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.deepBlue.withValues(alpha: 0.08) : AppTheme.slate50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.deepBlue : AppTheme.slate200,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? AppTheme.deepBlue : AppTheme.slate500,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppTheme.deepBlue : AppTheme.slate700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: AppTheme.slate400),
      prefixIcon: Icon(icon, color: AppTheme.deepBlue, size: 20),
      filled: true,
      fillColor: AppTheme.slate50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        borderSide: const BorderSide(color: AppTheme.deepBlue, width: 1.8),
      ),
    );
  }
}
