class ProductModel {
  final String id;
  final String? waveId;
  final String name;
  final double price;
  final double? prixTTC; // Nouveau champ optionnel
  final String localImagePath;
  final int stock;

  ProductModel({
    required this.id,
    this.waveId,
    required this.name,
    required this.price,
    this.prixTTC,
    required this.localImagePath,
    required this.stock,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'waveId': waveId,
      'name': name,
      'price': price,
      'prixTTC': prixTTC,
      'localImagePath': localImagePath,
      'stock': stock,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductModel(
      id: id,
      waveId: map['waveId'],
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      prixTTC: map['prixTTC']
          ?.toDouble(), // Gestion rétrocompatible (null si absent)
      localImagePath: map['localImagePath'] ?? '',
      stock: map['stock'] ?? 0,
    );
  }

  ProductModel copyWith({
    String? id,
    String? waveId,
    String? name,
    double? price,
    double? prixTTC,
    String? localImagePath,
    int? stock,
  }) {
    return ProductModel(
      id: id ?? this.id,
      waveId: waveId ?? this.waveId,
      name: name ?? this.name,
      price: price ?? this.price,
      prixTTC: prixTTC ?? this.prixTTC,
      localImagePath: localImagePath ?? this.localImagePath,
      stock: stock ?? this.stock,
    );
  }
}
