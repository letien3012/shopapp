class CartItem {
  final String productId;
  final int quantity;
  final String? variantId1;
  final String? optionId1;
  final String? variantId2;
  final String? optionId2;

  CartItem({
    required this.productId,
    required this.quantity,
    this.variantId1,
    this.optionId1,
    this.variantId2,
    this.optionId2,
  });

  CartItem copyWith({
    String? productId,
    int? quantity,
    String? variantId1,
    String? optionId1,
    String? variantId2,
    String? optionId2,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      variantId1: variantId1 ?? this.variantId1,
      optionId1: optionId1 ?? this.optionId1,
      variantId2: variantId2 ?? this.variantId2,
      optionId2: optionId2 ?? this.optionId2,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'quantity': quantity,
      'variantId1': variantId1,
      'optionId1': optionId1,
      'variantId2': variantId2,
      'optionId2': optionId2,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      productId: map['productId'] as String,
      quantity: map['quantity'] as int,
      variantId1: map['variantId1'] as String?,
      optionId1: map['optionId1'] as String?,
      variantId2: map['variantId2'] as String?,
      optionId2: map['optionId2'] as String?,
    );
  }
}
