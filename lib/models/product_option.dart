import 'dart:convert';

class ProductOption {
  double price;
  int stock;
  String name;
  String? imageUrl;

  ProductOption({
    required this.price,
    required this.stock,
    required this.name,
    this.imageUrl,
  });

  ProductOption copyWith({
    String? productId,
    double? price,
    int? stock,
    String? name,
    String? imageUrl,
  }) {
    return ProductOption(
      price: price ?? this.price,
      stock: stock ?? this.stock,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'price': price,
      'stock': stock,
      'name': name,
      'imageUrl': imageUrl,
    };
  }

  factory ProductOption.fromMap(Map<String, dynamic> map) {
    return ProductOption(
      price: map['price'] as double,
      stock: map['stock'] as int,
      name: map['name'] as String,
      imageUrl: map['imageUrl'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProductOption.fromJson(String source) =>
      ProductOption.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ProductOption(price: $price, stock: $stock, name: $name, imageUrl: $imageUrl)';
  }
}
