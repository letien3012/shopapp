abstract class CartEvent {}

class AddCartEvent extends CartEvent {
  final String userId;
  final int quantity;
  final String productId;
  final String shopId;
  final int variantIndex;
  final int optionIndex;

  AddCartEvent(this.productId, this.quantity, this.userId, this.shopId,
      this.variantIndex, this.optionIndex);
}

class UpdateCartEvent extends CartEvent {
  final String userId;
  final int quantity;
  final String productId;
  final int? variantIndex;
  final int? optionIndex;

  UpdateCartEvent(this.quantity, this.productId, this.userId,
      {this.variantIndex, this.optionIndex});
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
  final String productId;
  final int variantIndex;
  final int optionIndex;

  UpdateProductVariantEvent(
      this.productId, this.variantIndex, this.optionIndex);
}
