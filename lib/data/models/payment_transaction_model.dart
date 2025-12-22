import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentTransactionModel {
  final String id;
  final String orderId;
  final String orderItemId;
  final double amount;
  final String method;
  final DateTime date;

  PaymentTransactionModel({
    required this.id,
    required this.orderId,
    required this.orderItemId,
    required this.amount,
    required this.method,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'orderItemId': orderItemId,
      'amount': amount,
      'method': method,
      'date': Timestamp.fromDate(date),
    };
  }

  factory PaymentTransactionModel.fromMap(Map<String, dynamic> map, String id) {
    return PaymentTransactionModel(
      id: id,
      orderId: map['orderId'] ?? '',
      orderItemId: map['orderItemId'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      method: map['method'] ?? 'cash',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
