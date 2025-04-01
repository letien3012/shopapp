import 'package:luanvan/models/cart_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartShop {
  String shopId;
  Map<String, CartItem> items;
  Timestamp updatedAt;

  CartShop({
    required this.shopId,
    required this.items,
    Timestamp? updatedAt,
  }) : updatedAt = updatedAt ?? Timestamp.now();

  CartShop copyWith({
    String? shopId,
    Map<String, CartItem>? items,
    Timestamp? updatedAt,
  }) {
    return CartShop(
      shopId: shopId ?? this.shopId,
      items: items ?? this.items,
      updatedAt: updatedAt ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shopId': shopId,
      'items': items.map((key, value) => MapEntry(key, value.toMap())),
      'updatedAt': updatedAt,
    };
  }

  factory CartShop.fromMap(Map<String, dynamic> map) {
    return CartShop(
      shopId: map['shopId'] as String,
      items: (map['items'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, CartItem.fromMap(value)),
      ),
      updatedAt: map['updatedAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  // int get totalItems =>
  //     items.values.fold(0, (sum, item) => sum + item.quantity);
}
