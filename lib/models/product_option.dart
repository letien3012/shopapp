// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ProductOption {
  final String id;
  final String productId;
  final double price;
  final int stock;
  ProductOption({
    required this.id,
    required this.productId,
    required this.price,
    required this.stock,
  });

  ProductOption copyWith({
    String? id,
    String? productId,
    double? price,
    int? stock,
  }) {
    return ProductOption(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      price: price ?? this.price,
      stock: stock ?? this.stock,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'productId': productId,
      'price': price,
      'stock': stock,
    };
  }

  factory ProductOption.fromMap(Map<String, dynamic> map) {
    return ProductOption(
      id: map['id'] as String,
      productId: map['productId'] as String,
      price: map['price'] as double,
      stock: map['stock'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProductOption.fromJson(String source) =>
      ProductOption.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ProductOption(id: $id, productId: $productId, price: $price, stock: $stock)';
  }

  @override
  bool operator ==(covariant ProductOption other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.productId == productId &&
        other.price == price &&
        other.stock == stock;
  }

  @override
  int get hashCode {
    return id.hashCode ^ productId.hashCode ^ price.hashCode ^ stock.hashCode;
  }
}
