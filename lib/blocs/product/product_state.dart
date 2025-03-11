import 'package:luanvan/models/product.dart';

abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final Product product;
  ProductLoaded(this.product);
}

class ListProductLoaded extends ProductState {
  final List<Product> listProduct;
  ListProductLoaded(this.listProduct);
}

class ProductError extends ProductState {
  final String message;
  ProductError(this.message);
}
