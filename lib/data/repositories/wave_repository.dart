import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wave_model.dart';

class WaveRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<WaveModel> createWave(WaveModel wave, String vendorId) async {
    final ref = _firestore.collection('waves').doc(wave.id);
    final waveData = wave.toMap();
    waveData['vendorId'] = vendorId; // Add vendorId for multi-tenancy
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
}
