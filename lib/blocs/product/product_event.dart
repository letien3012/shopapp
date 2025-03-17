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

class DeleteProductByIdEvent extends ProductEvent {
  String productId;
  String shopId;
  DeleteProductByIdEvent(this.productId, this.shopId);
}

class FetchProductEventById extends ProductEvent {
  String productId;
  FetchProductEventById(this.productId);
}

class FetchProductEventByShopId extends ProductEvent {
  String shopId;
  FetchProductEventByShopId(this.shopId);
}

class FetchProductEventByProductId extends ProductEvent {
  String productId;
  FetchProductEventByProductId(this.productId);
}

class FetchListProductEvent extends ProductEvent {}
