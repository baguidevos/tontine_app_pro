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

    final snapshot = await _firestore
        .collection('products')
        .where(FieldPath.documentId, whereIn: productIds)
        .get();

    return snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
        .toList();
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
