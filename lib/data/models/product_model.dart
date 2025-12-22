class ProductModel {
  final String id;
  final String waveId;
  final String name;
  final double price;
  final String localImagePath;
  final int stock;

  ProductModel({
    required this.id,
    required this.waveId,
    required this.name,
    required this.price,
    required this.localImagePath,
    required this.stock,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'waveId': waveId,
      'name': name,
      'price': price,
      'localImagePath': localImagePath,
      'stock': stock,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductModel(
      id: id,
      waveId: map['waveId'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      localImagePath: map['localImagePath'] ?? '',
      stock: map['stock'] ?? 0,
    );
  }

  ProductModel copyWith({
    String? id,
    String? waveId,
    String? name,
    double? price,
    String? localImagePath,
    int? stock,
  }) {
    return ProductModel(
      id: id ?? this.id,
      waveId: waveId ?? this.waveId,
      name: name ?? this.name,
      price: price ?? this.price,
      localImagePath: localImagePath ?? this.localImagePath,
      stock: stock ?? this.stock,
    );
  }
}
