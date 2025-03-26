import 'package:luanvan/models/cart_item.dart';

class CartShop {
  final String shopId;
  final Map<String, CartItem> items;
  final DateTime updatedAt;

  CartShop({
    required this.shopId,
    required this.items,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  CartShop copyWith({
    String? shopId,
    Map<String, CartItem>? items,
    DateTime? updatedAt,
  }) {
    return CartShop(
      shopId: shopId ?? this.shopId,
      items: items ?? this.items,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shopId': shopId,
      'items': items.map((key, value) => MapEntry(key, value.toMap())),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CartShop.fromMap(Map<String, dynamic> map) {
    return CartShop(
      shopId: map['shopId'] as String,
      items: (map['items'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, CartItem.fromMap(value)),
      ),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  // int get totalItems =>
  //     items.values.fold(0, (sum, item) => sum + item.quantity);
}
