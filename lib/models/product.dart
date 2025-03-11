import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luanvan/models/product_variant.dart';

class Product {
  String id;
  String name;
  int? quantity;
  int quantitySold;
  String description;
  double averageRating;
  List<ProductVariant> variants;
  List<String> imageUrl;
  String category;
  String videoUrl;
  String shopId;
  bool isDeleted;
  bool isHidden;
  bool hasVariantImages;

  Product({
    required this.id,
    required this.name,
    this.quantity,
    required this.quantitySold,
    required this.description,
    required this.averageRating,
    required this.variants,
    this.imageUrl = const [],
    this.category = '',
    this.videoUrl = '',
    required this.shopId,
    this.isDeleted = false,
    this.isHidden = false,
    this.hasVariantImages = false,
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
    String? shopId,
    bool? isDeleted,
    bool? isHidden,
    bool? hasVariantImages,
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
      shopId: shopId ?? this.shopId,
      isDeleted: isDeleted ?? this.isDeleted,
      isHidden: isHidden ?? this.isHidden,
      hasVariantImages: hasVariantImages ?? this.hasVariantImages,
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
      'shopId': shopId,
      'isDeleted': isDeleted,
      'isHidden': isHidden,
      'hasVariantImages': hasVariantImages,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      quantity: map['quantity'] as int?,
      quantitySold: map['quantitySold'] as int,
      description: map['description'] as String,
      averageRating: map['averageRating'] as double,
      variants: List<ProductVariant>.from(
        (map['variants'] as List<dynamic>).map<ProductVariant>(
          (x) => ProductVariant.fromMap(x as Map<String, dynamic>),
        ),
      ),
      imageUrl: List<String>.from(map['imageUrl'] as List<dynamic>? ?? []),
      category: map['category'] as String? ?? '',
      videoUrl: map['videoUrl'] as String? ?? '',
      shopId: map['shopId'] as String,
      isDeleted: map['isDeleted'] as bool? ?? false,
      isHidden: map['isHidden'] as bool? ?? false,
      hasVariantImages: map['hasVariantImages'] as bool? ?? false,
    );
  }
  factory Product.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Product(
      id: doc.id,
      name: data['name'] as String? ?? '',
      quantity: data['quantity'] as int?,
      quantitySold: data['quantitySold'] as int? ?? 0,
      description: data['description'] as String? ?? '',
      averageRating: (data['averageRating'] as num?)?.toDouble() ?? 0.0,
      variants: data['variants'] != null
          ? List<ProductVariant>.from(
              (data['variants'] as List<dynamic>).map<ProductVariant>(
                (x) => ProductVariant.fromMap(x as Map<String, dynamic>),
              ),
            )
          : [],
      imageUrl: data['imageUrl'] != null
          ? List<String>.from(data['imageUrl'] as List<dynamic>)
          : [],
      category: data['category'] as String? ?? '',
      videoUrl: data['videoUrl'] as String? ?? '',
      shopId: data['shopId'] as String? ?? '',
      isDeleted: data['isDeleted'] as bool? ?? false,
      isHidden: data['isHidden'] as bool? ?? false,
      hasVariantImages: data['hasVariantImages'] as bool? ?? false,
    );
  }
  String toJson() => json.encode(toMap());

  factory Product.fromJson(String source) =>
      Product.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Product(id: $id, name: $name, quantity: $quantity, quantitySold: $quantitySold, description: $description, averageRating: $averageRating, variants: $variants, imageUrl: $imageUrl, category: $category, videoUrl: $videoUrl, shopId: $shopId, isDeleted: $isDeleted, isHidden: $isHidden, hasVariantImages: $hasVariantImages)';
  }

  double getMaxOptionPrice() {
    if (variants.isEmpty) return 0.0;

    List<double> allPrices = variants
        .expand((variant) => variant.options.map((option) => option.price))
        .toList();

    if (allPrices.isEmpty) return 0.0;

    return allPrices.reduce((a, b) => a > b ? a : b);
  }

  double getMinOptionPrice() {
    if (variants.isEmpty) return 0.0;

    List<double> allPrices = variants
        .expand((variant) => variant.options.map((option) => option.price))
        .toList();

    if (allPrices.isEmpty) return 0.0;

    return allPrices.reduce((a, b) => a < b ? a : b);
  }

  int getMaxOptionStock() {
    if (variants.isEmpty) return 0;

    List<int> allStocks = variants
        .expand((variant) => variant.options.map((option) => option.stock))
        .toList();

    if (allStocks.isEmpty) return 0;

    return allStocks.reduce((a, b) => a > b ? a : b);
  }

  int getMinOptionStock() {
    if (variants.isEmpty) return 0;

    List<int> allStocks = variants
        .expand((variant) => variant.options.map((option) => option.stock))
        .toList();

    if (allStocks.isEmpty) return 0;

    return allStocks.reduce((a, b) => a < b ? a : b);
  }
}
