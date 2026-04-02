import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<OrderModel> createOrder(OrderModel order) async {
    final ref = _firestore.collection('orders').doc(order.id);
    await ref.set(order.toMap());
    return order;
  }

  Future<OrderModel?> getOrder(String orderId) async {
    final doc = await _firestore.collection('orders').doc(orderId).get();
    if (doc.exists) {
      return OrderModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Future<List<OrderModel>> getOrdersByVendor(String vendorId) async {
    final snapshot = await _firestore
        .collection('orders')
        .where('vendorId', isEqualTo: vendorId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<OrderModel>> getOrdersByCustomer(String customerId) async {
    final snapshot = await _firestore
        .collection('orders')
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Stream<List<OrderModel>> watchOrdersByVendor(String vendorId) {
    return _firestore
        .collection('orders')
        .where('vendorId', isEqualTo: vendorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Récupère les commandes associées à une vague spécifique
  Future<List<OrderModel>> getOrdersByWave(String waveId) async {
    final snapshot = await _firestore
        .collection('orders')
        .where('waveId', isEqualTo: waveId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Stream des commandes associées à une vague spécifique
  Stream<List<OrderModel>> watchOrdersByWave(String waveId) {
    return _firestore
        .collection('orders')
        .where('waveId', isEqualTo: waveId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> updateOrder(OrderModel order) async {
    await _firestore
        .collection('orders')
        .doc(order.id)
        .set(order.toMap(), SetOptions(merge: true));
  }

  Future<void> deleteOrder(String orderId) async {
    await _firestore.collection('orders').doc(orderId).delete();
  }
}
