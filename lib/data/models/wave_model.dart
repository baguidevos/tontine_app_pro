enum WaveStatus { draft, active, closed }

class WaveModel {
  final String id;
  final String name;
  final WaveStatus status;
  final DateTime createdAt;

  WaveModel({
    required this.id,
    required this.name,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory WaveModel.fromMap(Map<String, dynamic> map, String id) {
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
    );
  }
}
