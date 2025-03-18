import 'dart:convert';

class ProductOption {
  double price;
  int stock;
  String name;
  String? imageUrl;
  double? weight;

  ProductOption({
    required this.price,
    required this.stock,
    required this.name,
    this.imageUrl,
    this.weight,
  });

  ProductOption copyWith({
    String? productId,
    double? price,
    int? stock,
    String? name,
    String? imageUrl,
    double? weight,
  }) {
    return ProductOption(
      price: price ?? this.price,
      stock: stock ?? this.stock,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      weight: weight ?? this.weight,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'price': price,
      'stock': stock,
      'name': name,
      'imageUrl': imageUrl,
      'weight': weight,
    };
  }

  factory ProductOption.fromMap(Map<String, dynamic> map) {
    return ProductOption(
      price: map['price'] as double,
      stock: map['stock'] as int,
      name: map['name'] as String,
      imageUrl: map['imageUrl'] as String?,
      weight: map['weight'] as double?,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProductOption.fromJson(String source) =>
      ProductOption.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ProductOption(price: $price, stock: $stock, name: $name, imageUrl: $imageUrl, weight: $weight)';
  }
}
