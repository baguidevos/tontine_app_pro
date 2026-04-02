import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wave_model.dart';

class WaveRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<WaveModel> createWave(WaveModel wave, String vendorId) async {
    final ref = _firestore.collection('waves').doc(wave.id);
    final waveData = wave.toMap();
    waveData['vendorId'] = vendorId;
    await ref.set(waveData);
    return wave;
  }

  Future<WaveModel?> getWave(String waveId) async {
    final doc = await _firestore.collection('waves').doc(waveId).get();
    if (doc.exists) {
      return WaveModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Future<List<WaveModel>> getWavesByVendor(String vendorId) async {
    final snapshot = await _firestore
        .collection('waves')
        .where('vendorId', isEqualTo: vendorId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => WaveModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Stream<List<WaveModel>> watchWavesByVendor(String vendorId) {
    return _firestore
        .collection('waves')
        .where('vendorId', isEqualTo: vendorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => WaveModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> updateWave(WaveModel wave) async {
    await _firestore
        .collection('waves')
        .doc(wave.id)
        .set(wave.toMap(), SetOptions(merge: true));
  }

  Future<void> deleteWave(String waveId) async {
    await _firestore.collection('waves').doc(waveId).delete();
  }

  Future<int> getWaveCountByVendor(String vendorId) async {
    final snapshot = await _firestore
        .collection('waves')
        .where('vendorId', isEqualTo: vendorId)
        .get();
    return snapshot.docs.length;
  }

  Future<void> addProductToWave(String waveId, String productId) async {
    final wave = await getWave(waveId);
    if (wave == null) return;

    if (!wave.productIds.contains(productId)) {
      final updatedProductIds = List<String>.from(wave.productIds)
        ..add(productId);
      final updatedWave = wave.copyWith(productIds: updatedProductIds);
      await updateWave(updatedWave);
    }
  }

  Future<void> removeProductFromWave(String waveId, String productId) async {
    final wave = await getWave(waveId);
    if (wave == null) return;

    final updatedProductIds = wave.productIds
        .where((id) => id != productId)
        .toList();
    final updatedWave = wave.copyWith(productIds: updatedProductIds);
    await updateWave(updatedWave);
  }

  Future<void> setWaveProducts(String waveId, List<String> productIds) async {
    // Directly update Firestore without reading the document first
    // This ensures we only update the specific wave
    await _firestore.collection('waves').doc(waveId).update({
      'productIds': productIds,
    });
  }

  Future<void> replaceWaveProducts(
    String waveId,
    List<String> productIds,
  ) async {
    await setWaveProducts(waveId, productIds);
  }
}
