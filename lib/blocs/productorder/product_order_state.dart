import 'package:luanvan/models/product.dart';

abstract class ProductOrderState {}

class ProductOrderInitial extends ProductOrderState {}

class ProductOrderLoading extends ProductOrderState {}

class ProductOrderListLoaded extends ProductOrderState {
  final List<Product> products;
  ProductOrderListLoaded(this.products);
}

class ProductOrderError extends ProductOrderState {
  final String message;
  ProductOrderError(this.message);
}
