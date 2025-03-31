import 'package:luanvan/models/cart.dart';

abstract class CartEvent {}

class AddCartEvent extends CartEvent {
  final String userId;
  final int quantity;
  final String productId;
  final String shopId;
  final String? variantId1;
  final String? optionId1;
  final String? variantId2;
  final String? optionId2;

  AddCartEvent(this.productId, this.quantity, this.userId, this.shopId,
      this.variantId1, this.optionId1, this.variantId2, this.optionId2);
}

// class UpdateCartEvent extends CartEvent {
//   final String productId;
//   final int quantity;
//   final String shopId;
//   final String? variant1Id;
//   final String? option1Id;
//   final String? variant2Id;
//   final String? option2Id;

//   UpdateCartEvent(
//     this.productId,
//     this.quantity,
//     this.shopId, {
//     this.variant1Id,
//     this.option1Id,
//     this.variant2Id,
//     this.option2Id,
//   });
// }

class UpdateQuantityEvent extends CartEvent {
  final String userId;
  final String itemId;
  final int quantity;
  final String shopId;
  final String? variant1Id;
  final String? option1Id;
  final String? variant2Id;
  final String? option2Id;

  UpdateQuantityEvent(
    this.userId,
    this.itemId,
    this.quantity,
    this.shopId, {
    this.variant1Id,
    this.option1Id,
    this.variant2Id,
    this.option2Id,
  });
}

class DeleteProductCartEvent extends CartEvent {
  final String productId;

  DeleteProductCartEvent(this.productId);
}

class FetchCartEventUserId extends CartEvent {
  final String userId;

  FetchCartEventUserId(this.userId);
}

class UpdateProductVariantEvent extends CartEvent {
  final String userId;
  final String itemId;
  final String productId;
  final String shopId;
  final String? variant1Id;
  final int quantity;
  final String? option1Id;
  final String? variant2Id;
  final String? option2Id;

  UpdateProductVariantEvent(
    this.productId,
    this.shopId,
    this.userId,
    this.itemId,
    this.quantity, {
    this.variant1Id,
    this.option1Id,
    this.variant2Id,
    this.option2Id,
  });
}

class DeleteCartProductEvent extends CartEvent {
  final String userId;
  final String itemId;
  final String shopId;

  DeleteCartProductEvent(this.itemId, this.shopId, this.userId);
}

class DeleteCartShopEvent extends CartEvent {
  final String userId;
  final String shopId;

  DeleteCartShopEvent(this.shopId, this.userId);
}

class UpdateCartEvent extends CartEvent {
  final Cart cart;
  UpdateCartEvent(this.cart);
}

class ResetCartEvent extends CartEvent {}
