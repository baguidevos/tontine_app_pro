import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String vendorId;
  final String customerId;
  final List<OrderItemModel> items;
  final double totalAmount;
  final double totalPaid;
  final String status;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.vendorId,
    required this.customerId,
    required this.items,
    required this.totalAmount,
    required this.totalPaid,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vendorId': vendorId,
      'customerId': customerId,
      'items': items.map((x) => x.toMap()).toList(),
      'totalAmount': totalAmount,
      'totalPaid': totalPaid,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      id: id,
      vendorId: map['vendorId'] ?? '',
      customerId: map['customerId'] ?? '',
      items: List<OrderItemModel>.from(
        (map['items'] as List? ?? []).map((x) => OrderItemModel.fromMap(x)),
      ),
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      totalPaid: (map['totalPaid'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class OrderItemModel {
  final String id;
  final String productId;
  final String name;
  final double unitPrice;
  final int quantity;
  final double paidAmount;

  OrderItemModel({
    required this.id,
    required this.productId,
    required this.name,
    required this.unitPrice,
    required this.quantity,
    required this.paidAmount,
  });

  double get totalPrice => unitPrice * quantity;
  double get balance => totalPrice - paidAmount;
  bool get isReadyForDelivery => balance <= 0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'paidAmount': paidAmount,
    };
  }

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      id: map['id'] ?? '',
      productId: map['productId'] ?? '',
      name: map['name'] ?? '',
      unitPrice: (map['unitPrice'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 0,
      paidAmount: (map['paidAmount'] ?? 0.0).toDouble(),
    );
  }

  OrderItemModel copyWith({
    String? id,
    String? productId,
    String? name,
    double? unitPrice,
    int? quantity,
    double? paidAmount,
  }) {
    return OrderItemModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      paidAmount: paidAmount ?? this.paidAmount,
    );
  }
}
