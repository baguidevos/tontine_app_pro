import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer_model.dart';

class CustomerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<CustomerModel> createCustomer(CustomerModel customer) async {
    final ref = _firestore.collection('customers').doc(customer.id);
    await ref.set(customer.toMap());
    return customer;
  }

  Future<CustomerModel?> getCustomer(String customerId) async {
    final doc = await _firestore.collection('customers').doc(customerId).get();
    if (doc.exists) {
      return CustomerModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Future<List<CustomerModel>> getCustomersByVendor(String vendorId) async {
    final snapshot = await _firestore
        .collection('customers')
        .where('vendorId', isEqualTo: vendorId)
        .get();

    return snapshot.docs
        .map((doc) => CustomerModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Stream<List<CustomerModel>> watchCustomersByVendor(String vendorId) {
    return _firestore
        .collection('customers')
        .where('vendorId', isEqualTo: vendorId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CustomerModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    await _firestore
        .collection('customers')
        .doc(customer.id)
        .set(customer.toMap(), SetOptions(merge: true));
  }

  Future<void> deleteCustomer(String customerId) async {
    await _firestore.collection('customers').doc(customerId).delete();
  }
}
