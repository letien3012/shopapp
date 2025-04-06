import 'package:luanvan/models/product.dart';

abstract class ListProductByCategoryState {}

class ListProductByCategoryInitial extends ListProductByCategoryState {}

class ListProductByCategoryLoading extends ListProductByCategoryState {}

class ListProductByCategoryLoaded extends ListProductByCategoryState {
  final List<Product> listProduct;
  ListProductByCategoryLoaded(this.listProduct);
}

class ListProductByCategoryError extends ListProductByCategoryState {
  final String message;
  ListProductByCategoryError(this.message);
}
