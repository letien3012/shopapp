import 'package:luanvan/models/product.dart';

abstract class SearchImageState {}

class SearchImageInitial extends SearchImageState {}

class SearchImageLoading extends SearchImageState {}

class SearchImageLoaded extends SearchImageState {
  final List<Product> products;
  final bool hasMore;
  SearchImageLoaded(this.products, {this.hasMore = true});
}

class SearchImageError extends SearchImageState {
  final String message;
  SearchImageError(this.message);
}
