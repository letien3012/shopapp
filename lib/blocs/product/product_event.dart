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
  DeleteProductByIdEvent(this.productId);
}

class FetchProductEventById extends ProductEvent {
  String productId;
  FetchProductEventById(this.productId);
}

class FetchListProductEvent extends ProductEvent {}
