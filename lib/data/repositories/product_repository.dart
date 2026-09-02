import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<ProductModel> createProduct(
    ProductModel product,
    String vendorId,
  ) async {
    final ref = _firestore.collection('products').doc(product.id);
    final productData = product.toMap();
    productData['vendorId'] = vendorId;
    await ref.set(productData);
    return product;
  }

  Future<ProductModel?> getProduct(String productId) async {
    final doc = await _firestore.collection('products').doc(productId).get();
    if (doc.exists) {
      return ProductModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Future<List<ProductModel>> getProductsByWave(String waveId) async {
    try {
      final waveDoc = await _firestore.collection('waves').doc(waveId).get();
      if (waveDoc.exists && waveDoc.data() != null) {
        final productIds =
            List<String>.from(waveDoc.data()!['productIds'] ?? []);
        if (productIds.isNotEmpty) {
          return await getProductsByIds(productIds);
        }
      }
    } catch (_) {}

    // Fallback rétrocompatible
    final snapshot = await _firestore
        .collection('products')
        .where('waveId', isEqualTo: waveId)
        .get();

    return snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<ProductModel>> getProductsByVendor(String vendorId) async {
    final snapshot = await _firestore
        .collection('products')
        .where('vendorId', isEqualTo: vendorId)
        .get();

    return snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<ProductModel>> getProductsByIds(List<String> productIds) async {
    if (productIds.isEmpty) return [];

    // Nettoyer les doublons et IDs vides
    final cleanIds = productIds.where((id) => id.isNotEmpty).toSet().toList();
    if (cleanIds.isEmpty) return [];

    final List<ProductModel> results = [];

    // Firestore limite whereIn à 30 éléments maximum
    const chunkSize = 30;
    for (var i = 0; i < cleanIds.length; i += chunkSize) {
      final end =
          (i + chunkSize < cleanIds.length) ? i + chunkSize : cleanIds.length;
      final chunk = cleanIds.sublist(i, end);

      final snapshot = await _firestore
          .collection('products')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      results.addAll(
        snapshot.docs.map((doc) => ProductModel.fromMap(doc.data(), doc.id)),
      );
    }

    return results;
  }

  Stream<List<ProductModel>> watchProductsByWave(String waveId) {
    return _firestore
        .collection('products')
        .where('waveId', isEqualTo: waveId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Stream<List<ProductModel>> watchProductsByIds(List<String> productIds) {
    if (productIds.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection('products')
        .where(FieldPath.documentId, whereIn: productIds)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> updateProduct(ProductModel product) async {
    await _firestore
        .collection('products')
        .doc(product.id)
        .set(product.toMap(), SetOptions(merge: true));
  }

  Future<void> deleteProduct(String productId) async {
    await _firestore.collection('products').doc(productId).delete();
  }

  Future<int> getProductCountByVendor(String vendorId) async {
    final snapshot = await _firestore
        .collection('products')
        .where('vendorId', isEqualTo: vendorId)
        .get();
    return snapshot.docs.length;
  }
}
