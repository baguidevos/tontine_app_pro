import 'package:cloud_firestore/cloud_firestore.dart';

class VendorModel {
  final String id;
  final String email;
  final String businessName;
  final String phone;
  final String plan; // 'free' or 'premium'
  final DateTime? premiumExpiryDate;
  final int waveLimit;
  final int productLimit;
  final DateTime createdAt;

  VendorModel({
    required this.id,
    required this.email,
    required this.businessName,
    required this.phone,
    this.plan = 'free',
    this.premiumExpiryDate,
    this.waveLimit = 5,
    this.productLimit = 10,
    required this.createdAt,
  });

  bool get isPremium =>
      plan == 'premium' &&
      (premiumExpiryDate == null || premiumExpiryDate!.isAfter(DateTime.now()));

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'businessName': businessName,
      'phone': phone,
      'plan': plan,
      'premiumExpiryDate': premiumExpiryDate != null
          ? Timestamp.fromDate(premiumExpiryDate!)
          : null,
      'waveLimit': waveLimit,
      'productLimit': productLimit,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory VendorModel.fromMap(Map<String, dynamic> map, String id) {
    return VendorModel(
      id: id,
      email: map['email'] ?? '',
      businessName: map['businessName'] ?? '',
      phone: map['phone'] ?? '',
      plan: map['plan'] ?? 'free',
      premiumExpiryDate: (map['premiumExpiryDate'] as Timestamp?)?.toDate(),
      waveLimit: map['waveLimit'] ?? 5,
      productLimit: map['productLimit'] ?? 10,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  VendorModel copyWith({
    String? id,
    String? email,
    String? businessName,
    String? phone,
    String? plan,
    DateTime? premiumExpiryDate,
    int? waveLimit,
    int? productLimit,
    DateTime? createdAt,
  }) {
    return VendorModel(
      id: id ?? this.id,
      email: email ?? this.email,
      businessName: businessName ?? this.businessName,
      phone: phone ?? this.phone,
      plan: plan ?? this.plan,
      premiumExpiryDate: premiumExpiryDate ?? this.premiumExpiryDate,
      waveLimit: waveLimit ?? this.waveLimit,
      productLimit: productLimit ?? this.productLimit,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
