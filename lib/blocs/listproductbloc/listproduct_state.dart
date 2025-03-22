import 'package:luanvan/models/product.dart';

abstract class ListProductState {}

class ListProductInitial extends ListProductState {}

class ListProductLoading extends ListProductState {}

class ListProductLoaded extends ListProductState {
  final List<Product> listProduct;
  ListProductLoaded(this.listProduct);
}

class ListProductError extends ListProductState {
  final String message;
  ListProductError(this.message);
}
