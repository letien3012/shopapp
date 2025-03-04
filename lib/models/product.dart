// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:luanvan/models/product_variant.dart';

class Product {
  String id;
  String name;
  int quantity;
  int quantitySold;
  String description;
  double averageRating;
  final List<ProductVariant> variants;
  String imageUrl;
  Product({
    required this.id,
    required this.name,
    required this.quantity,
    required this.quantitySold,
    required this.description,
    required this.averageRating,
    required this.variants,
    required this.imageUrl,
  });

  Product copyWith({
    String? id,
    String? name,
    int? quantity,
    int? quantitySold,
    String? description,
    double? averageRating,
    List<ProductVariant>? variants,
    String? imageUrl,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      quantitySold: quantitySold ?? this.quantitySold,
      description: description ?? this.description,
      averageRating: averageRating ?? this.averageRating,
      variants: variants ?? this.variants,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'quantity': quantity,
      'quantitySold': quantitySold,
      'description': description,
      'averageRating': averageRating,
      'variants': variants.map((x) => x.toMap()).toList(),
      'imageUrl': imageUrl,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      quantity: map['quantity'] as int,
      quantitySold: map['quantitySold'] as int,
      description: map['description'] as String,
      averageRating: map['averageRating'] as double,
      variants: List<ProductVariant>.from(
        (map['variants'] as List<int>).map<ProductVariant>(
          (x) => ProductVariant.fromMap(x as Map<String, dynamic>),
        ),
      ),
      imageUrl: map['imageUrl'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Product.fromJson(String source) =>
      Product.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Product(id: $id, name: $name, quantity: $quantity, quantitySold: $quantitySold, description: $description, averageRating: $averageRating, variants: $variants, imageUrl: $imageUrl)';
  }

  @override
  bool operator ==(covariant Product other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.quantity == quantity &&
        other.quantitySold == quantitySold &&
        other.description == description &&
        other.averageRating == averageRating &&
        listEquals(other.variants, variants) &&
        other.imageUrl == imageUrl;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        quantity.hashCode ^
        quantitySold.hashCode ^
        description.hashCode ^
        averageRating.hashCode ^
        variants.hashCode ^
        imageUrl.hashCode;
  }
}
