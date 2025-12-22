import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment_transaction_model.dart';

class PaymentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<PaymentTransactionModel> createTransaction(
    PaymentTransactionModel transaction,
  ) async {
    final ref = _firestore
        .collection('payment_transactions')
        .doc(transaction.id);
    await ref.set(transaction.toMap());
    return transaction;
  }

  Future<List<PaymentTransactionModel>> getTransactionsByOrder(
    String orderId,
  ) async {
    final snapshot = await _firestore
        .collection('payment_transactions')
        .where('orderId', isEqualTo: orderId)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => PaymentTransactionModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<PaymentTransactionModel>> getTransactionsByOrderItem(
    String orderItemId,
  ) async {
    final snapshot = await _firestore
        .collection('payment_transactions')
        .where('orderItemId', isEqualTo: orderItemId)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => PaymentTransactionModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Stream<List<PaymentTransactionModel>> watchTransactionsByOrderItem(
    String orderItemId,
  ) {
    return _firestore
        .collection('payment_transactions')
        .where('orderItemId', isEqualTo: orderItemId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PaymentTransactionModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> deleteTransaction(String transactionId) async {
    await _firestore
        .collection('payment_transactions')
        .doc(transactionId)
        .delete();
  }
}
