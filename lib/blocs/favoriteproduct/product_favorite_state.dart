import 'package:luanvan/models/product.dart';

abstract class ProductFavoriteState {}

class ProductFavoriteInitial extends ProductFavoriteState {}

class ProductFavoriteLoading extends ProductFavoriteState {}

class ProductFavoriteLoaded extends ProductFavoriteState {
  final List<Product> listProduct;
  ProductFavoriteLoaded(this.listProduct);
}

class ProductFavoriteAdded extends ProductFavoriteState {}

class ProductFavoriteRemoved extends ProductFavoriteState {}

class ProductFavoriteError extends ProductFavoriteState {
  final String message;
  ProductFavoriteError(this.message);
}
