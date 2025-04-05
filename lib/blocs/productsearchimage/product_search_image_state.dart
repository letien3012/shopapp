import 'package:luanvan/models/product.dart';

abstract class ProductSearchImageState {}

class ProductSearchImageInitial extends ProductSearchImageState {}

class ProductSearchImageLoading extends ProductSearchImageState {}

class ProductSearchImageListLoaded extends ProductSearchImageState {
  final List<Product> products;
  ProductSearchImageListLoaded(this.products);
}

class ProductSearchImageError extends ProductSearchImageState {
  final String message;
  ProductSearchImageError(this.message);
}
