import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:paya_app/core/config/api_config.dart';
import 'package:paya_app/core/services/auth_service.dart';
import 'package:paya_app/core/theme/app_theme.dart';
import 'package:paya_app/core/utils/platform_file_image.dart';
import 'package:paya_app/data/models/customer_model.dart';
import 'package:paya_app/data/models/product_model.dart';
import 'package:paya_app/data/models/wave_model.dart';
import 'package:paya_app/data/repositories/customer_repository.dart';
import 'package:paya_app/data/repositories/order_repository.dart';
import 'package:paya_app/presentation/controllers/product_controller.dart';
import 'package:paya_app/presentation/controllers/product_details_controller.dart';
import 'package:paya_app/presentation/controllers/wave_controller.dart';
import 'package:paya_app/presentation/widgets/product_image.dart';
import 'package:share_plus/share_plus.dart';

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
  bool _isSaving = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Vérifier si édition ou vague pré-sélectionnée
    if (Get.arguments is ProductModel) {
      _editingProduct = Get.arguments as ProductModel;
      final wId = _editingProduct?.waveId;
      _selectedWaveId = (wId != null && wId.isNotEmpty) ? wId : null;
    } else if (Get.arguments is Map) {
      final map = Get.arguments as Map;
      if (map['editingProduct'] is ProductModel) {
        _editingProduct = map['editingProduct'] as ProductModel;
        final wId = _editingProduct?.waveId;
        _selectedWaveId = (wId != null && wId.isNotEmpty) ? wId : null;
      }
      if (map['preselectedWaveId'] != null) {
        final pre = map['preselectedWaveId'].toString();
        _selectedWaveId = pre.isNotEmpty ? pre : null;
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
    if (_isSaving) return;

    if (_formKey.currentState!.validate()) {
      if ((_localImagePath == null || _localImagePath!.isEmpty) &&
          _newImageBytes == null &&
          (_editingProduct?.imageUrl == null ||
              _editingProduct!.imageUrl!.isEmpty)) {
        Get.snackbar(
          'Image requise',
          'Veuillez ajouter une image pour le produit',
          backgroundColor: AppTheme.softRed,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      final productController = Get.find<ProductController>();

      final name = _nameController.text.trim();
      final price = double.parse(_priceController.text);
      final prixTTC = _prixTTCController.text.isEmpty
          ? null
          : double.parse(_prixTTCController.text);
      final stock = 0;

      final waveIdToSave = _selectedWaveId ?? "";
      final waveIdsToSave =
          (waveIdToSave.isNotEmpty) ? [waveIdToSave] : <String>[];

      setState(() => _isSaving = true);

      try {
        final bool isEditing = _editingProduct != null;

        if (isEditing) {
          // Update
          final existingWaveIds = List<String>.from(_editingProduct!.waveIds);
          if (waveIdToSave.isNotEmpty &&
              !existingWaveIds.contains(waveIdToSave)) {
            existingWaveIds.add(waveIdToSave);
          }

          final updatedProduct = _editingProduct!.copyWith(
            name: name,
            price: price,
            prixTTC: prixTTC,
            stock: stock,
            waveId: waveIdToSave,
            waveIds:
                existingWaveIds.isNotEmpty ? existingWaveIds : waveIdsToSave,
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

        // Fermer la page d'édition
        Get.back();

        // Afficher la notification sur l'écran parent
        Get.snackbar(
          'Succès',
          isEditing
              ? 'Produit "$name" modifié avec succès'
              : 'Produit "$name" créé avec succès',
          backgroundColor: AppTheme.successGreen,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      } catch (e) {
        Get.snackbar(
          'Erreur',
          'Impossible d\'enregistrer le produit: $e',
          backgroundColor: AppTheme.softRed,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
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
        actions: [
          if (_editingProduct != null)
            IconButton(
              icon: const Icon(Icons.share_rounded, color: AppTheme.deepBlue),
              tooltip: 'Partager sur WhatsApp',
              onPressed: _shareToWhatsApp,
            ),
        ],
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

                // Sécuriser la sélection pour éviter l'assertion error DropdownButton
                final bool isValid = _selectedWaveId != null &&
                    _selectedWaveId!.isNotEmpty &&
                    activeWaves.any((w) => w.id == _selectedWaveId);
                final String? dropdownValue = isValid ? _selectedWaveId : null;

                return DropdownButtonFormField<String?>(
                  value: dropdownValue,
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
                  onPressed: _isSaving ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.deepBlue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppTheme.deepBlue.withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 5,
                    shadowColor: AppTheme.deepBlue.withOpacity(0.4),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
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

              if (_editingProduct != null) ...[
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton.icon(
                    onPressed: _shareToWhatsApp,
                    icon: const Icon(Icons.share_rounded,
                        color: AppTheme.successGreen),
                    label: const Text(
                      'Partager sur WhatsApp',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.successGreen,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: AppTheme.successGreen, width: 1.8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _shareToWhatsApp() async {
    if (_editingProduct == null) return;

    final currentProduct = _editingProduct!;
    final name = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : currentProduct.name;
    final price =
        double.tryParse(_priceController.text) ?? currentProduct.price;
    final prixTTC = _prixTTCController.text.isNotEmpty
        ? double.tryParse(_prixTTCController.text) ??
            (currentProduct.prixTTC ?? price)
        : (currentProduct.prixTTC ?? price);

    String? targetWaveId = _selectedWaveId;
    if (targetWaveId == null || targetWaveId.isEmpty) {
      targetWaveId = currentProduct.waveId;
    }

    final waveController = Get.isRegistered<WaveController>()
        ? Get.find<WaveController>()
        : Get.put(WaveController());
    final waves = waveController.waves;

    // Si le produit appartient à plusieurs vagues et aucune sélectionnée
    if (targetWaveId == null || targetWaveId.isEmpty) {
      final activeWavesForProduct = waves.where((w) {
        return w.status == WaveStatus.active &&
            (w.productIds.contains(currentProduct.id) ||
                currentProduct.waveIds.contains(w.id));
      }).toList();

      if (activeWavesForProduct.length > 1) {
        final selected = await Get.bottomSheet<String>(
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Choisir la vague à partager',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.deepBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ce produit est associé à plusieurs vagues actives. Choisissez celle pour laquelle vous lancez les commandes :',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                ...activeWavesForProduct.map((w) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      leading:
                          const Icon(Icons.waves, color: AppTheme.deepBlue),
                      title: Text(
                        w.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: w.closeDate != null
                          ? Text(
                              'Clôture le ${w.closeDate!.day}/${w.closeDate!.month}/${w.closeDate!.year}',
                            )
                          : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      tileColor: AppTheme.warmCream.withOpacity(0.5),
                      trailing:
                          const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                      onTap: () => Get.back(result: w.id),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Annuler'),
                  ),
                ),
              ],
            ),
          ),
        );

        if (selected == null) return;
        targetWaveId = selected;
      } else if (activeWavesForProduct.length == 1) {
        targetWaveId = activeWavesForProduct.first.id;
      }
    }

    // Nom de vague et date de clôture
    String waveName = 'Toutes les vagues';
    DateTime? closeDate;
    if (targetWaveId != null && targetWaveId.isNotEmpty) {
      for (final w in waves) {
        if (w.id == targetWaveId) {
          waveName = w.name;
          closeDate = w.closeDate;
          break;
        }
      }
    }

    final closeDateString = closeDate != null
        ? '${closeDate.day} ${_getMonthName(closeDate.month)} ${closeDate.year}'
        : 'À venir';

    final StringBuffer buffer = StringBuffer();
    buffer.writeln('Nouvelle commande du $name 😁😇');
    buffer.writeln('');
    buffer.writeln(
        'PTT(toutes taxes comprises) : ${prixTTC.toStringAsFixed(0)}f');
    buffer.writeln('Vague : $waveName');
    buffer.writeln('');

    final vendorId = Get.isRegistered<AuthService>()
        ? Get.find<AuthService>().currentVendorId
        : null;

    // Charger les commandes pour ce produit
    List<CustomerPaymentEntry> entries = [];
    if (Get.isRegistered<ProductDetailsController>()) {
      final detailsCtrl = Get.find<ProductDetailsController>();
      entries = detailsCtrl.customerPayments.toList();
      if (targetWaveId != null && targetWaveId.isNotEmpty) {
        entries =
            entries.where((e) => e.order.waveId == targetWaveId).toList();
      }
    } else if (vendorId != null && vendorId.isNotEmpty) {
      try {
        final orderRepo = OrderRepository();
        final customerRepo = CustomerRepository();
        final allOrders = await orderRepo.getOrdersByVendor(vendorId);
        final allCustomers = await customerRepo.getCustomersByVendor(vendorId);

        for (final o in allOrders) {
          if (targetWaveId != null &&
              targetWaveId.isNotEmpty &&
              o.waveId != targetWaveId) {
            continue;
          }
          for (final item in o.items) {
            if (item.productId == currentProduct.id) {
              final cust = allCustomers.firstWhere(
                (c) => c.id == o.customerId,
                orElse: () => CustomerModel(
                  id: o.customerId,
                  vendorId: vendorId,
                  name: 'Client inconnu',
                  phone: '',
                  createdAt: DateTime.now(),
                ),
              );
              entries.add(CustomerPaymentEntry(
                customer: cust,
                order: o,
                orderItem: item,
              ));
            }
          }
        }
      } catch (e) {
        debugPrint('[Share] Erreur chargement commandes pour partage: $e');
      }
    }

    int index = 1;
    for (final entry in entries) {
      final qty = entry.orderItem.quantity;
      final unitStr = qty > 1 ? 'pcs' : 'pc';

      final isFullyPaid = entry.orderItem.isReadyForDelivery ||
          (entry.orderItem.paidAmount >= entry.orderItem.totalPrice &&
              entry.orderItem.totalPrice > 0);
      final isPartiallyPaid = !isFullyPaid && entry.orderItem.paidAmount > 0;

      String statusSuffix = '';
      if (isFullyPaid) {
        statusSuffix = ' ✅';
      } else if (isPartiallyPaid) {
        statusSuffix = ' (Avance 👍)';
      }

      buffer.writeln(
          '$index. ${entry.customer.name} - $qty $unitStr$statusSuffix');
      index++;
    }

    // Emplacements vides jusqu'à 10
    for (int i = index; i <= 10; i++) {
      buffer.writeln('$i.');
    }

    // Lien de commande client direct
    if (vendorId != null && vendorId.isNotEmpty) {
      final orderUrl = ApiConfig.buildOrderShareUrl(
        productId: currentProduct.id,
        vendorId: vendorId,
        waveId: targetWaveId,
      );
      buffer.writeln('');
      buffer.writeln('👉 Commandez directement ici :');
      buffer.writeln(orderUrl);
    }

    buffer.writeln('');
    buffer.writeln('Date de clôture : $closeDateString');

    final message = buffer.toString();

    // Afficher la boîte de prévisualisation et options de partage
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Partager sur WhatsApp',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.deepBlue,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              constraints: const BoxConstraints(maxHeight: 180),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  message,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Copier le texte
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: message));
                  Get.back();
                  Get.snackbar(
                    'Copié !',
                    'Texte copié dans le presse-papiers',
                    backgroundColor: AppTheme.successGreen,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.TOP,
                  );
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copier le texte'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.deepBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Partager avec photo
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  Get.back();
                  await _sendWhatsAppWithImage(currentProduct, message);
                },
                icon: const Icon(Icons.share),
                label: const Text('Partager avec photo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Annuler',
                  style: TextStyle(color: AppTheme.payaGray)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendWhatsAppWithImage(
      ProductModel prod, String message) async {
    final localPath = _localImagePath ?? prod.localImagePath;

    if (hasValidPlatformFile(localPath)) {
      try {
        await Share.shareXFiles([XFile(localPath)], text: message);
        return;
      } catch (e) {
        debugPrint('[Share] Échec partage image locale: $e');
      }
    }

    final onlineUrl = prod.imageUrl;
    if (onlineUrl != null && onlineUrl.isNotEmpty) {
      try {
        final res = await http.get(Uri.parse(onlineUrl));
        if (res.statusCode == 200 && res.bodyBytes.isNotEmpty) {
          final xFile = XFile.fromData(
            res.bodyBytes,
            mimeType: 'image/jpeg',
            name: '${prod.name}.jpg',
          );
          await Share.shareXFiles([xFile], text: message);
          return;
        }
      } catch (e) {
        debugPrint('[Share] Échec téléchargement image en ligne: $e');
      }
    }

    await Share.share(message);
  }

  String _getMonthName(int month) {
    const months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    return (month >= 1 && month <= 12) ? months[month - 1] : '';
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
