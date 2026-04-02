import 'package:get/get.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/subscription_service.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';

class ProductController extends GetxController {
  final ProductRepository productRepository = ProductRepository();
  final AuthService _authService = Get.find<AuthService>();
  final SubscriptionService _subscriptionService =
      Get.find<SubscriptionService>();

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

      final product = ProductModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        waveId: waveId,
        name: name,
        price: price,
        localImagePath: localImagePath,
        stock: 0,
      );

      await productRepository.createProduct(product, vendorId);

      Get.snackbar('Succès', 'Produit créé avec succès');
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

  Future<void> updateProduct(ProductModel product) async {
    try {
      await productRepository.updateProduct(product);
      Get.snackbar('Succès', 'Produit mis à jour');
      loadProducts();
    } catch (e) {
      Get.snackbar('Erreur', 'Échec de la mise à jour: $e');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
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
