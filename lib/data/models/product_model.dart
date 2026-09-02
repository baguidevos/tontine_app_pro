class ProductModel {
  final String id;
  final String? waveId;
  final String name;
  final double price;
  final double? prixTTC; // Nouveau champ optionnel
  final String localImagePath;
  final String? imageUrl; // URL en ligne sur le serveur d'images
  final String? imageId; // ID unique du média sur le serveur d'images
  final int stock;

  ProductModel({
    required this.id,
    this.waveId,
    required this.name,
    required this.price,
    this.prixTTC,
    required this.localImagePath,
    this.imageUrl,
    this.imageId,
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
      'imageUrl': imageUrl,
      'imageId': imageId,
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
      imageUrl: map['imageUrl'],
      imageId: map['imageId'],
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
    String? imageUrl,
    String? imageId,
    int? stock,
  }) {
    return ProductModel(
      id: id ?? this.id,
      waveId: waveId ?? this.waveId,
      name: name ?? this.name,
      price: price ?? this.price,
      prixTTC: prixTTC ?? this.prixTTC,
      localImagePath: localImagePath ?? this.localImagePath,
      imageUrl: imageUrl ?? this.imageUrl,
      imageId: imageId ?? this.imageId,
      stock: stock ?? this.stock,
    );
  }
}
