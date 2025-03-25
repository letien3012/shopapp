import 'package:luanvan/models/product.dart';

abstract class ProductCartState {}

class ProductCartInitial extends ProductCartState {}

class ProductCartLoading extends ProductCartState {}

class ProductCartListLoaded extends ProductCartState {
  final List<Product> products;
  ProductCartListLoaded(this.products);
}

class ProductCartError extends ProductCartState {
  final String message;
  ProductCartError(this.message);
}
