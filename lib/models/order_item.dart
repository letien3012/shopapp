import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  String productId;
  int quantity;
  double price;
  String productName;
  String productImage;
  String? productVariation;
  String? productCategory;
  String? optionId1;
  String? optionId2;
  DateTime createdAt;

  OrderItem({
    required this.productId,
    required this.quantity,
    required this.price,
    required this.productName,
    required this.productImage,
    this.productVariation,
    this.productCategory,
    this.optionId1,
    this.optionId2,
    required this.createdAt,
  });

  OrderItem copyWith({
    String? productId,
    int? quantity,
    double? price,
    String? productName,
    String? productImage,
    String? productVariation,
    String? productCategory,
    String? optionId1,
    String? optionId2,
    DateTime? createdAt,
  }) {
    return OrderItem(
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      productVariation: productVariation ?? this.productVariation,
      productCategory: productCategory ?? this.productCategory,
      optionId1: optionId1 ?? this.optionId1,
      optionId2: optionId2 ?? this.optionId2,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'quantity': quantity,
      'price': price,
      'productName': productName,
      'productImage': productImage,
      'productVariation': productVariation,
      'productCategory': productCategory,
      'optionId1': optionId1,
      'optionId2': optionId2,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] as String,
      quantity: map['quantity'] as int,
      price: (map['price'] as num).toDouble(),
      productName: map['productName'] as String,
      productImage: map['productImage'] as String,
      productVariation: map['productVariation'] as String?,
      productCategory: map['productCategory'] as String?,
      optionId1: map['optionId1'] as String?,
      optionId2: map['optionId2'] as String?,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  factory OrderItem.fromFirestore(Map<String, dynamic> data) {
    return OrderItem(
      productId: data['productId'] as String? ?? '',
      quantity: data['quantity'] as int? ?? 0,
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      productName: data['productName'] as String? ?? '',
      productImage: data['productImage'] as String? ?? '',
      productVariation: data['productVariation'] as String?,
      productCategory: data['productCategory'] as String? ?? '',
      optionId1: data['optionId1'] as String?,
      optionId2: data['optionId2'] as String?,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderItem.fromJson(String source) =>
      OrderItem.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'OrderItem(productId: $productId, quantity: $quantity, price: $price, productName: $productName, productImage: $productImage, productVariation: $productVariation, productCategory: $productCategory, optionId1: $optionId1, optionId2: $optionId2, createdAt: $createdAt)';
  }
}
