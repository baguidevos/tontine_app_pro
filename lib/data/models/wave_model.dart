enum WaveStatus { draft, active, closed }

class WaveModel {
  final String id;
  final String name;
  final WaveStatus status;
  final DateTime createdAt;
  final DateTime? openDate; // Date d'ouverture de la vague
  final DateTime? closeDate; // Date de fermeture de la vague
  final List<String> productIds;

  WaveModel({
    required this.id,
    required this.name,
    required this.status,
    required this.createdAt,
    this.openDate,
    this.closeDate,
    this.productIds = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'openDate': openDate?.toIso8601String(),
      'closeDate': closeDate?.toIso8601String(),
      'productIds': productIds,
    };
  }

  factory WaveModel.fromMap(Map<String, dynamic> map, String id) {
    final productIdsRaw = map['productIds'] as List<dynamic>?;
    return WaveModel(
      id: id,
      name: map['name'] ?? '',
      status: WaveStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => WaveStatus.draft,
      ),
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      openDate: map['openDate'] != null
          ? DateTime.parse(map['openDate'])
          : null,
      closeDate: map['closeDate'] != null
          ? DateTime.parse(map['closeDate'])
          : null,
      productIds: productIdsRaw?.map((e) => e.toString()).toList() ?? [],
    );
  }

  WaveModel copyWith({
    String? id,
    String? name,
    WaveStatus? status,
    DateTime? createdAt,
    DateTime? openDate,
    DateTime? closeDate,
    List<String>? productIds,
  }) {
    return WaveModel(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      openDate: openDate ?? this.openDate,
      closeDate: closeDate ?? this.closeDate,
      productIds: productIds ?? this.productIds,
    );
  }
}
