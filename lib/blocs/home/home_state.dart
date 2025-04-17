import 'package:luanvan/models/product.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<Product> products;
  final bool hasMore;
  HomeLoaded(this.products, {this.hasMore = true});
}

class MoreProductLoaded extends HomeState {
  final List<Product> newProduct;
  final bool hasMore;
  MoreProductLoaded(this.newProduct, {this.hasMore = true});
}

class HomeError extends HomeState {
  final String message;

  HomeError(this.message);
}
