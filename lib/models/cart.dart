import 'dart:convert';
import 'package:luanvan/models/cart_item.dart';
import 'package:luanvan/models/cart_shop.dart';

class Cart {
  final String id;
  final String userId;
  List<CartShop> shops;

  Cart({
    required this.id,
    required this.userId,
    this.shops = const [],
  });

  Cart copyWith({
    String? id,
    String? userId,
    List<CartShop>? shops,
  }) {
    return Cart(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      shops: shops ?? this.shops,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'shops': shops.map((shop) => shop.toMap()).toList(),
    };
  }

  factory Cart.fromMap(Map<String, dynamic> map) {
    return Cart(
      id: map['id']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      shops: map['shops'] != null && map['shops'] is List
          ? (map['shops'] as List)
              .map((shopMap) =>
                  CartShop.fromMap(shopMap as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  int get totalItems {
    return shops.fold(0, (sum, shop) => sum + shop.totalItems);
  }

  bool get isEmpty => shops.isEmpty;

  bool hasProduct(String productId) {
    return shops.any((shop) => shop.items.containsKey(productId));
  }

  CartItem? getProduct(String productId) {
    for (var shop in shops) {
      if (shop.items.containsKey(productId)) {
        return shop.items[productId];
      }
    }
    return null;
  }

  CartShop? getShop(String shopId) {
    try {
      return shops.firstWhere((shop) => shop.shopId == shopId);
    } catch (e) {
      return null;
    }
  }

  String toJson() => json.encode(toMap());

  factory Cart.fromJson(String source) =>
      Cart.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Cart(id: $id, userId: $userId, shops: $shops)';

  static Cart initial() {
    return Cart(
      id: '',
      userId: '',
      shops: [],
    );
  }
}
