import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_delivery_status.dart';

class OrderModel {
  final String id;
  final String vendorId;
  final String customerId;
  final String? waveId;
  final List<OrderItemModel> items;
  final double totalAmount;
  final double totalPaid;
  final String status; // 'pending', 'completed', 'cancelled'
  final String deliveryStatus; // 'received', 'confirmed', 'paid', 'processing', 'delivered', 'undelivered'
  final String? deliveryNotes;
  final DateTime? deliveryStatusUpdatedAt;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.vendorId,
    required this.customerId,
    this.waveId,
    required this.items,
    required this.totalAmount,
    required this.totalPaid,
    required this.status,
    this.deliveryStatus = 'received',
    this.deliveryNotes,
    this.deliveryStatusUpdatedAt,
    required this.createdAt,
  });

  OrderDeliveryStatus get trackingStatus =>
      OrderDeliveryStatus.fromString(deliveryStatus);

  bool get isFullyPaid => totalPaid >= totalAmount;

  double get remainingBalance =>
      (totalAmount - totalPaid) > 0 ? (totalAmount - totalPaid) : 0.0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vendorId': vendorId,
      'customerId': customerId,
      'waveId': waveId,
      'items': items.map((x) => x.toMap()).toList(),
      'totalAmount': totalAmount,
      'totalPaid': totalPaid,
      'status': status,
      'deliveryStatus': deliveryStatus,
      'deliveryNotes': deliveryNotes,
      'deliveryStatusUpdatedAt': deliveryStatusUpdatedAt != null
          ? Timestamp.fromDate(deliveryStatusUpdatedAt!)
          : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    final status = map['status'] ?? 'pending';
    final fallbackDelivery = status == 'completed' ? 'delivered' : 'received';

    return OrderModel(
      id: id,
      vendorId: map['vendorId'] ?? '',
      customerId: map['customerId'] ?? '',
      waveId: map['waveId'],
      items: List<OrderItemModel>.from(
        (map['items'] as List? ?? []).map((x) => OrderItemModel.fromMap(x)),
      ),
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      totalPaid: (map['totalPaid'] ?? 0.0).toDouble(),
      status: status,
      deliveryStatus: map['deliveryStatus'] ?? fallbackDelivery,
      deliveryNotes: map['deliveryNotes'],
      deliveryStatusUpdatedAt: (map['deliveryStatusUpdatedAt'] as Timestamp?)?.toDate(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  OrderModel copyWith({
    String? id,
    String? vendorId,
    String? customerId,
    String? waveId,
    List<OrderItemModel>? items,
    double? totalAmount,
    double? totalPaid,
    String? status,
    String? deliveryStatus,
    String? deliveryNotes,
    DateTime? deliveryStatusUpdatedAt,
    DateTime? createdAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      customerId: customerId ?? this.customerId,
      waveId: waveId ?? this.waveId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      totalPaid: totalPaid ?? this.totalPaid,
      status: status ?? this.status,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      deliveryNotes: deliveryNotes ?? this.deliveryNotes,
      deliveryStatusUpdatedAt:
          deliveryStatusUpdatedAt ?? this.deliveryStatusUpdatedAt,
      createdAt: createdAt ?? this.createdAt,
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
  bool get isReadyForDelivery => paidAmount >= totalPrice && totalPrice > 0;

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
      quantity: map['quantity'] ?? 1,
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
