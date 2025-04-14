import 'package:cloud_firestore/cloud_firestore.dart';

class ViewedProduct {
  final String productId;
  Timestamp? viewedAt;

  ViewedProduct({
    required this.productId,
    Timestamp? viewedAt,
  }) : viewedAt = viewedAt ?? Timestamp.now();

  factory ViewedProduct.fromMap(Map<String, dynamic> map) {
    return ViewedProduct(
      productId: map['productId'] as String,
      viewedAt: map['viewedAt'] as Timestamp? ?? Timestamp.now(),
    );
  }
  factory ViewedProduct.fromJson(Map<String, dynamic> json) {
    return ViewedProduct(
      productId: json['productId'],
      viewedAt: json['viewedAt'],
    );
  }
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'productId': productId,
      'viewedAt': viewedAt,
    };
  }

  ViewedProduct copyWith({
    String? productId,
    Timestamp? viewedAt,
  }) {
    return ViewedProduct(
      productId: productId ?? this.productId,
      viewedAt: viewedAt ?? this.viewedAt,
    );
  }

  @override
  String toString() =>
      'ViewedProduct(productId: $productId, viewedAt: $viewedAt)';
}
