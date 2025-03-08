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
  List<String> imageUrl;
  String category;
  String videoUrl;

  Product({
    required this.id,
    required this.name,
    required this.quantity,
    required this.quantitySold,
    required this.description,
    required this.averageRating,
    required this.variants,
    this.imageUrl = const [],
    this.category = '',
    this.videoUrl = '',
  });

  Product copyWith({
    String? id,
    String? name,
    int? quantity,
    int? quantitySold,
    String? description,
    double? averageRating,
    List<ProductVariant>? variants,
    List<String>? imageUrl,
    String? category,
    String? videoUrl,
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
      category: category ?? this.category,
      videoUrl: videoUrl ?? this.videoUrl,
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
      'category': category,
      'videoUrl': videoUrl,
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
      imageUrl: List<String>.from(map['imageUrl'] as List<dynamic>? ?? []),
      category: map['category'] as String? ?? '',
      videoUrl: map['videoUrl'] as String? ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Product.fromJson(String source) =>
      Product.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Product(id: $id, name: $name, quantity: $quantity, quantitySold: $quantitySold, description: $description, averageRating: $averageRating, variants: $variants, imageUrl: $imageUrl, category: $category, videoUrl: $videoUrl)';
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
        listEquals(other.imageUrl, imageUrl) &&
        other.category == category &&
        other.videoUrl == videoUrl;
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
        imageUrl.hashCode ^
        category.hashCode ^
        videoUrl.hashCode;
  }
}
