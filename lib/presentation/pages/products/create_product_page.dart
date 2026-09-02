import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:paya_app/core/theme/app_theme.dart';
import 'package:paya_app/data/models/product_model.dart';
import 'package:paya_app/data/models/wave_model.dart';
import 'package:paya_app/presentation/controllers/product_controller.dart';
import 'package:paya_app/presentation/controllers/wave_controller.dart';
import 'package:paya_app/presentation/widgets/product_image.dart';

class CreateProductPage extends StatefulWidget {
  const CreateProductPage({super.key});

  @override
  State<CreateProductPage> createState() => _CreateProductPageState();
}

class _CreateProductPageState extends State<CreateProductPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _prixTTCController;
  late TextEditingController _stockController;

  String? _localImagePath;
  Uint8List? _newImageBytes;
  String? _newImageName;
  ProductModel? _editingProduct;
  String? _selectedWaveId;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Vérifier si édition ou vague pré-sélectionnée
    if (Get.arguments is ProductModel) {
      _editingProduct = Get.arguments as ProductModel;
      _selectedWaveId = _editingProduct?.waveId;
    } else if (Get.arguments is Map) {
      final map = Get.arguments as Map;
      if (map['editingProduct'] is ProductModel) {
        _editingProduct = map['editingProduct'] as ProductModel;
        _selectedWaveId = _editingProduct?.waveId;
      }
      if (map['preselectedWaveId'] != null) {
        _selectedWaveId = map['preselectedWaveId'].toString();
      }
    }

    _nameController = TextEditingController(text: _editingProduct?.name ?? '');
    _priceController = TextEditingController(
      text: _editingProduct?.price.toInt().toString() ?? '',
    );
    _prixTTCController = TextEditingController(
      text: _editingProduct?.prixTTC?.toInt().toString() ?? '',
    );
    _stockController = TextEditingController(
      text: _editingProduct?.stock.toString() ?? 0.toString(),
    );
    _localImagePath = _editingProduct?.localImagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _prixTTCController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _localImagePath = image.path;
        _newImageBytes = bytes;
        _newImageName = image.name;
      });
    }
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      if ((_localImagePath == null || _localImagePath!.isEmpty) &&
          _newImageBytes == null &&
          (_editingProduct?.imageUrl == null ||
              _editingProduct!.imageUrl!.isEmpty)) {
        Get.snackbar('Erreur', 'Veuillez ajouter une image');
        return;
      }

      final productController = Get.find<ProductController>();

      final name = _nameController.text;
      final price = double.parse(_priceController.text);
      final prixTTC = _prixTTCController.text.isEmpty
          ? null
          : double.parse(_prixTTCController.text);
      final stock = 0;

      final waveIdToSave = _selectedWaveId ?? "";
      final waveIdsToSave =
          (waveIdToSave.isNotEmpty) ? [waveIdToSave] : <String>[];

      if (_editingProduct != null) {
        // Update
        final existingWaveIds = List<String>.from(_editingProduct!.waveIds);
        if (waveIdToSave.isNotEmpty && !existingWaveIds.contains(waveIdToSave)) {
          existingWaveIds.add(waveIdToSave);
        }

        final updatedProduct = _editingProduct!.copyWith(
          name: name,
          price: price,
          prixTTC: prixTTC,
          stock: stock,
          waveId: waveIdToSave,
          waveIds: existingWaveIds.isNotEmpty ? existingWaveIds : waveIdsToSave,
        );
        await productController.updateProduct(
          updatedProduct,
          newLocalImagePath: _localImagePath,
          newImageBytes: _newImageBytes,
          newImageName: _newImageName,
        );
      } else {
        // Create
        await productController.createProduct(
          name: name,
          price: price,
          prixTTC: prixTTC,
          stock: stock,
          waveId: waveIdToSave,
          waveIds: waveIdsToSave,
          localImagePath: _localImagePath ?? '',
          imageBytes: _newImageBytes,
          imageName: _newImageName,
        );
      }
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.warmCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.deepBlue),
          onPressed: () => Get.back(),
        ),
        title: Text(
          _editingProduct != null ? 'Modifier le Produit' : 'Nouveau Produit',
          style: const TextStyle(
            color: AppTheme.deepBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Picker
              Center(
                child: GestureDetector(
                  onTap: () => _showImageSourceModal(),                  child: Builder(
                    builder: (context) {
                      final hasImage = _newImageBytes != null ||
                          (_localImagePath != null &&
                              _localImagePath!.isNotEmpty) ||
                          (_editingProduct?.imageUrl != null &&
                              _editingProduct!.imageUrl!.isNotEmpty);

                      return Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppTheme.deepBlue.withOpacity(0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: hasImage
                            ? Stack(
                                children: [
                                  Positioned.fill(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(24),
                                      child: _newImageBytes != null
                                          ? Image.memory(
                                              _newImageBytes!,
                                              fit: BoxFit.cover,
                                            )
                                          : ProductImage(
                                              product: _editingProduct,
                                              localImagePath: _localImagePath,
                                              width: 200,
                                              height: 200,
                                              fit: BoxFit.cover,
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                            ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 10,
                                    right: 10,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.deepBlue.withOpacity(0.85),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo_outlined,
                                    size: 48,
                                    color: AppTheme.deepBlue.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Ajouter une photo',
                                    style: TextStyle(
                                      color: AppTheme.deepBlue.withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Fields
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nom du produit',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: 'Prix (FCFA)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Champ requis'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Expanded(
                  //   child: TextFormField(
                  //     controller: _prixTTCController,
                  //     decoration: InputDecoration(
                  //       labelText: 'Prix TTC (FCFA)',
                  //       border: OutlineInputBorder(
                  //         borderRadius: BorderRadius.circular(16),
                  //       ),
                  //       filled: true,
                  //       fillColor: Colors.white,
                  //     ),
                  //     keyboardType: TextInputType.number,
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 16),

              // Wave Selection (Optionnelle)
              Obx(() {
                final waveController = Get.isRegistered<WaveController>()
                    ? Get.find<WaveController>()
                    : Get.put(WaveController());
                final waves = waveController.waves;
                final activeWaves = waves
                    .where((w) => w.status != WaveStatus.closed)
                    .toList();

                return DropdownButtonFormField<String?>(
                  value: _selectedWaveId,
                  decoration: InputDecoration(
                    labelText: 'Vague associée (optionnel)',
                    prefixIcon:
                        const Icon(Icons.waves, color: AppTheme.deepBlue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Aucune vague'),
                    ),
                    ...activeWaves.map((wave) {
                      return DropdownMenuItem<String?>(
                        value: wave.id,
                        child: Text(wave.name),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedWaveId = value;
                    });
                  },
                );
              }),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.deepBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 5,
                    shadowColor: AppTheme.deepBlue.withOpacity(0.4),
                  ),
                  child: Text(
                    _editingProduct != null
                        ? 'Mettre à jour'
                        : 'Créer le produit',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageSourceModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Prendre une photo'),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choisir depuis la galerie'),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
