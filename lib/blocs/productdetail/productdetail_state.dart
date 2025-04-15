import 'package:luanvan/models/product.dart';

abstract class ProductdetailState {}

class ProductdetailInitial extends ProductdetailState {}

class ProductdetailLoading extends ProductdetailState {}

class ProductdetailLoaded extends ProductdetailState {
  final Product product;
  ProductdetailLoaded(this.product);
}

class ProductdetailError extends ProductdetailState {
  final String message;
  ProductdetailError(this.message);
}
