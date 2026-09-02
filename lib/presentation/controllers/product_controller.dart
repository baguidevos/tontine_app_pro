import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:paya_app/core/services/auth_service.dart';
import 'package:paya_app/core/services/image_server_service.dart';
import 'package:paya_app/core/services/subscription_service.dart';
import 'package:paya_app/data/models/product_model.dart';
import 'package:paya_app/data/repositories/product_repository.dart';

class ProductController extends GetxController {
  final ProductRepository productRepository = ProductRepository();
  final AuthService _authService = Get.find<AuthService>();
  final SubscriptionService _subscriptionService =
      Get.find<SubscriptionService>();

  ImageServerService? get _imageServerService =>
      Get.isRegistered<ImageServerService>()
          ? Get.find<ImageServerService>()
          : null;

  var products = <ProductModel>[].obs;
  var isLoading = false.obs;

  // Filtering
  final Rx<String?> filterWaveId = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    // Debounce filter changes to avoid rapid reloading
    debounce(
      filterWaveId,
      (_) => loadProducts(),
      time: const Duration(milliseconds: 300),
    );
    loadProducts();
  }

  void setWaveFilter(String? waveId) {
    filterWaveId.value = waveId;
  }

  void loadProducts() {
    final vendorId = _authService.currentVendorId;
    if (vendorId != null) {
      isLoading.value = true;

      Future<List<ProductModel>> fetchTask;

      if (filterWaveId.value != null) {
        fetchTask = productRepository.getProductsByWave(filterWaveId.value!);
      } else {
        fetchTask = productRepository.getProductsByVendor(vendorId);
      }

      fetchTask
          .then((productList) {
            products.value = productList;
          })
          .catchError((e) {
            Get.snackbar('Erreur', 'Impossible de charger les produits: $e');
          })
          .whenComplete(() {
            isLoading.value = false;
          });
    }
  }

  Future<void> createProduct({
    required String waveId,
    required String name,
    required double price,
    double? prixTTC,
    required String localImagePath,
    required int stock,
  }) async {
    final vendorId = _authService.currentVendorId;
    if (vendorId == null) return;

    // Check subscription limits
    final currentCount = await productRepository.getProductCountByVendor(
      vendorId,
    );
    if (!_subscriptionService.canCreateProduct(currentCount)) {
      Get.snackbar(
        'Limite Atteinte',
        'Vous avez atteint votre limite de produits. Passez au Premium pour plus.',
      );
      Get.toNamed('/subscription');
      return;
    }

    try {
      isLoading.value = true;

      String finalLocalPath = localImagePath;
      String? imageUrl;
      String? imageId;

      if (_imageServerService != null && localImagePath.isNotEmpty) {
        final sourceFile = File(localImagePath);
        if (await sourceFile.exists()) {
          // 1. Sauvegarde locale permanente dans le stockage interne de l'application
          finalLocalPath =
              await _imageServerService!.saveImagePermanently(sourceFile);

          // 2. Upload vers le serveur d'images Laravel
          final uploadResult =
              await _imageServerService!.uploadImage(File(finalLocalPath));
          if (uploadResult.success) {
            imageUrl = uploadResult.downloadUrl;
            imageId = uploadResult.imageId;
            debugPrint('[ProductController] Image en ligne liée: $imageUrl');
          } else {
            debugPrint(
              '[ProductController] Échec upload distant: ${uploadResult.error}. Utilisation locale.',
            );
          }
        }
      }

      final product = ProductModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        waveId: waveId,
        name: name,
        price: price,
        prixTTC: prixTTC,
        localImagePath: finalLocalPath,
        imageUrl: imageUrl,
        imageId: imageId,
        stock: stock,
      );

      await productRepository.createProduct(product, vendorId);

      Get.snackbar(
        'Succès',
        imageUrl != null
            ? 'Produit créé avec succès (synchronisé en ligne)'
            : 'Produit créé avec succès (image locale conservée)',
      );
      loadProducts();
    } catch (e) {
      Get.snackbar('Erreur', 'Échec de la création: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> duplicateProduct(
    ProductModel product,
    String targetWaveId,
  ) async {
    final vendorId = _authService.currentVendorId;
    if (vendorId == null) return;

    // Check subscription limits
    final currentCount = await productRepository.getProductCountByVendor(
      vendorId,
    );
    if (!_subscriptionService.canCreateProduct(currentCount)) {
      Get.snackbar(
        'Limite Atteinte',
        'Vous avez atteint votre limite de produits. Passez au Premium pour plus.',
      );
      Get.toNamed('/subscription');
      return;
    }

    try {
      isLoading.value = true;

      // Create a new product instance with a new ID and the target wave ID
      final duplicatedProduct = product.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        waveId: targetWaveId,
      );

      await productRepository.createProduct(duplicatedProduct, vendorId);

      Get.snackbar('Succès', 'Produit dupliqué avec succès');
      loadProducts();
    } catch (e) {
      Get.snackbar('Erreur', 'Échec de la duplication: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProduct(
    ProductModel product, {
    String? newLocalImagePath,
  }) async {
    try {
      isLoading.value = true;
      ProductModel toUpdate = product;

      // Détecter si une nouvelle image a été sélectionnée
      final bool hasNewImage = newLocalImagePath != null &&
          newLocalImagePath.isNotEmpty &&
          newLocalImagePath != product.localImagePath;

      // Déterminer si le produit a besoin d'être synchronisé sur le serveur
      // (soit nouvelle image, soit imageId / imageUrl manquants)
      final bool needsServerUpload = (product.imageUrl == null ||
              product.imageUrl!.isEmpty ||
              product.imageId == null ||
              product.imageId!.isEmpty) &&
          (newLocalImagePath != null && newLocalImagePath.isNotEmpty);

      ImageUploadResult? uploadResult;

      if (_imageServerService != null && (hasNewImage || needsServerUpload)) {
        final imagePathToProcess = newLocalImagePath;
        if (imagePathToProcess.isNotEmpty) {
          final sourceFile = File(imagePathToProcess);
          if (await sourceFile.exists()) {
            // Sauvegarde locale permanente si nouveau fichier sélectionné
            final permanentPath = hasNewImage
                ? await _imageServerService!.saveImagePermanently(sourceFile)
                : imagePathToProcess;

            // Upload vers le serveur d'images
            uploadResult =
                await _imageServerService!.uploadImage(File(permanentPath));

            if (uploadResult.success) {
              // Si une ancienne image distante existait et a été remplacée, la supprimer du serveur
              if (hasNewImage &&
                  product.imageId != null &&
                  product.imageId!.isNotEmpty &&
                  product.imageId != uploadResult.imageId) {
                await _imageServerService!.deleteImage(product.imageId!);
              }

              toUpdate = toUpdate.copyWith(
                localImagePath: permanentPath,
                imageUrl: uploadResult.downloadUrl,
                imageId: uploadResult.imageId,
              );
            } else {
              debugPrint(
                '[ProductController] Échec upload distant: ${uploadResult.errorMessage}',
              );
              // Conserver la copie locale
              toUpdate = toUpdate.copyWith(
                localImagePath: permanentPath,
              );
            }
          }
        }
      }

      await productRepository.updateProduct(toUpdate);

      if (uploadResult != null) {
        if (uploadResult.success) {
          Get.snackbar(
            'Succès',
            'Produit et image synchronisés sur le serveur avec succès',
          );
        } else {
          Get.snackbar(
            'Attention',
            'Produit mis à jour localement, mais échec serveur: ${uploadResult.errorMessage}',
            duration: const Duration(seconds: 5),
          );
        }
      } else {
        Get.snackbar('Succès', 'Produit mis à jour');
      }

      loadProducts();
    } catch (e) {
      Get.snackbar('Erreur', 'Échec de la mise à jour: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      if (_imageServerService != null) {
        final product = await productRepository.getProduct(productId);
        if (product != null &&
            product.imageId != null &&
            product.imageId!.isNotEmpty) {
          await _imageServerService!.deleteImage(product.imageId!);
        }
      }

      await productRepository.deleteProduct(productId);
      Get.snackbar('Succès', 'Produit supprimé');
      loadProducts();
    } catch (e) {
      Get.snackbar('Erreur', 'Échec de la suppression: $e');
    }
  }

  Future<List<ProductModel>> getProductsByWave(String waveId) async {
    return await productRepository.getProductsByWave(waveId);
  }
}
