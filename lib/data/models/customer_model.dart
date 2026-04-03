import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  final String id;
  final String vendorId;
  final String name;
  final String phone;
  final String? address;
  final String? sexe; // Nouveau champ optionnel
  final double totalCredit; // Total amount owed across all orders
  final DateTime createdAt;

  CustomerModel({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.phone,
    this.address,
    this.sexe,
    this.totalCredit = 0.0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vendorId': vendorId,
      'name': name,
      'phone': phone,
      'address': address,
      'sexe': sexe,
      'totalCredit': totalCredit,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory CustomerModel.fromMap(Map<String, dynamic> map, String id) {
    return CustomerModel(
      id: id,
      vendorId: map['vendorId'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'],
      sexe: map['sexe'], // Gestion rétrocompatible (null si absent)
      totalCredit: (map['totalCredit'] ?? 0.0).toDouble(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  CustomerModel copyWith({
    String? id,
    String? vendorId,
    String? name,
    String? phone,
    String? address,
    String? sexe,
    double? totalCredit,
    DateTime? createdAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      sexe: sexe ?? this.sexe,
      totalCredit: totalCredit ?? this.totalCredit,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
