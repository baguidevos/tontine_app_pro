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

    // Synchronisation bidirectionnelle sur le document du produit (support multi-vagues)
    try {
      await _firestore.collection('products').doc(productId).update({
        'waveIds': FieldValue.arrayUnion([waveId]),
        'waveId': waveId,
      });
    } catch (_) {}
  }

  Future<void> removeProductFromWave(String waveId, String productId) async {
    final wave = await getWave(waveId);
    if (wave == null) return;

    final updatedProductIds = wave.productIds
        .where((id) => id != productId)
        .toList();
    final updatedWave = wave.copyWith(productIds: updatedProductIds);
    await updateWave(updatedWave);

    // Déliement sur le document du produit pour cette vague
    try {
      await _firestore.collection('products').doc(productId).update({
        'waveIds': FieldValue.arrayRemove([waveId]),
      });
    } catch (_) {}
  }

  Future<void> setWaveProducts(
    String waveId,
    List<String> productIds, {
    List<String>? previousProductIds,
  }) async {
    // 1. Mettre à jour la liste des IDs dans le document de la vague
    await _firestore.collection('waves').doc(waveId).update({
      'productIds': productIds,
    });

    // 2. Synchronisation en batch sur les documents de la collection products (support multi-vagues)
    try {
      final batch = _firestore.batch();

      // Assigner la vague aux produits sélectionnés sans écraser les autres vagues
      for (final id in productIds) {
        batch.update(_firestore.collection('products').doc(id), {
          'waveIds': FieldValue.arrayUnion([waveId]),
          'waveId': waveId,
        });
      }

      // Retirer cette vague des produits qui en ont été retirés
      if (previousProductIds != null) {
        final removed =
            previousProductIds.where((id) => !productIds.contains(id));
        for (final id in removed) {
          batch.update(_firestore.collection('products').doc(id), {
            'waveIds': FieldValue.arrayRemove([waveId]),
          });
        }
      }

      await batch.commit();
    } catch (e) {
      // Ignorer si un produit n'existe plus ou échec batch individuel
    }
  }

  Future<void> replaceWaveProducts(
    String waveId,
    List<String> productIds,
  ) async {
    await setWaveProducts(waveId, productIds);
  }
}
