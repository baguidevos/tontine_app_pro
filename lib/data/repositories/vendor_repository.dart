import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vendor_model.dart';

class VendorRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<VendorModel> createVendor(VendorModel vendor) async {
    await _firestore.collection('vendors').doc(vendor.id).set(vendor.toMap());
    return vendor;
  }

  Future<VendorModel?> getVendor(String vendorId) async {
    final doc = await _firestore.collection('vendors').doc(vendorId).get();
    if (doc.exists) {
      return VendorModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Future<void> updateVendor(VendorModel vendor) async {
    await _firestore
        .collection('vendors')
        .doc(vendor.id)
        .set(vendor.toMap(), SetOptions(merge: true));
  }

  Stream<VendorModel?> watchVendor(String vendorId) {
    return _firestore.collection('vendors').doc(vendorId).snapshots().map((
      doc,
    ) {
      if (doc.exists) {
        return VendorModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }
}
