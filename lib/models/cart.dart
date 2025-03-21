import 'dart:convert';

class Cart {
  String id;
  String userId;
  Map<String, int> productIdAndQuantity;
  List<String> listShopId;
  Map<String, int?> productVariantIndexes;
  Map<String, int?> productOptionIndexes;

  Cart({
    required this.id,
    required this.userId,
    required this.productIdAndQuantity,
    required this.listShopId,
    required this.productVariantIndexes,
    required this.productOptionIndexes,
  });

  Cart copyWith({
    String? id,
    String? userId,
    Map<String, int>? productIdAndQuantity,
    List<String>? listShopId,
    Map<String, int?>? productVariantIndexes,
    Map<String, int?>? productOptionIndexes,
  }) {
    return Cart(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productIdAndQuantity: productIdAndQuantity ?? this.productIdAndQuantity,
      listShopId: listShopId ?? this.listShopId,
      productVariantIndexes:
          productVariantIndexes ?? this.productVariantIndexes,
      productOptionIndexes: productOptionIndexes ?? this.productOptionIndexes,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'productIdAndQuantity': productIdAndQuantity,
      'listShopId': listShopId,
      'productVariantIndexes': productVariantIndexes,
      'productOptionIndexes': productOptionIndexes,
    };
  }

  factory Cart.fromMap(Map<String, dynamic> map) {
    return Cart(
      id: map['id'] as String,
      userId: map['userId'] as String,
      productIdAndQuantity:
          Map<String, int>.from(map['productIdAndQuantity'] ?? {}),
      listShopId: List<String>.from(map['listShopId'] ?? []),
      productVariantIndexes:
          Map<String, int?>.from(map['productVariantIndexes'] ?? {}),
      productOptionIndexes:
          Map<String, int?>.from(map['productOptionIndexes'] ?? {}),
    );
  }

  factory Cart.fromFirestore(
      Map<String, dynamic> firestoreData, String documentId) {
    return Cart(
      id: documentId,
      userId: firestoreData['userId'] as String? ?? '',
      productIdAndQuantity:
          Map<String, int>.from(firestoreData['productIdAndQuantity'] ?? {}),
      listShopId: List<String>.from(firestoreData['listShopId'] ?? []),
      productVariantIndexes:
          Map<String, int?>.from(firestoreData['productVariantIndexes'] ?? {}),
      productOptionIndexes:
          Map<String, int?>.from(firestoreData['productOptionIndexes'] ?? {}),
    );
  }

  String toJson() => json.encode(toMap());

  factory Cart.fromJson(String source) =>
      Cart.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Cart(id: $id, userId: $userId, productIdAndQuantity: $productIdAndQuantity, listShopId: $listShopId, productVariantIndexes: $productVariantIndexes, productOptionIndexes: $productOptionIndexes)';

  static Cart initial() {
    return Cart(
      id: '',
      userId: '',
      productIdAndQuantity: {},
      listShopId: [],
      productVariantIndexes: {},
      productOptionIndexes: {},
    );
  }
}
