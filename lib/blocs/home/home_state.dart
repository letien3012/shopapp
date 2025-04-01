import 'package:luanvan/models/product.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<Product> products;

  HomeLoaded(this.products);
}

class HomeError extends HomeState {
  final String message;

  HomeError(this.message);
}
