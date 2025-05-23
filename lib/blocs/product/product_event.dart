import 'package:luanvan/models/product.dart';

abstract class ProductEvent {}

class AddProductEvent extends ProductEvent {
  final Product product;
  AddProductEvent(this.product);
}

class UpdateProductEvent extends ProductEvent {
  final Product product;
  UpdateProductEvent(this.product);
}

class UpdateProductViewCountEvent extends ProductEvent {
  final String productId;
  UpdateProductViewCountEvent(this.productId);
}

class IncrementProductFavoriteCountEvent extends ProductEvent {
  final String productId;

  IncrementProductFavoriteCountEvent(this.productId);
}

class DecrementProductFavoriteCountEvent extends ProductEvent {
  final String productId;
  DecrementProductFavoriteCountEvent(this.productId);
}

class DeleteProductByIdEvent extends ProductEvent {
  String productId;
  String shopId;
  DeleteProductByIdEvent(this.productId, this.shopId);
}

class FetchProductEventById extends ProductEvent {
  String productId;
  FetchProductEventById(this.productId);
}

class FetchProductEventByProductId extends ProductEvent {
  String productId;
  FetchProductEventByProductId(this.productId);
}

class FetchListProductEvent extends ProductEvent {}

class ResetProductEvent extends ProductEvent {}
