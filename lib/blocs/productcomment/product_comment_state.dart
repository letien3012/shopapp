import 'package:luanvan/models/product.dart';

abstract class ProductCommentState {}

class ProductCommentInitial extends ProductCommentState {}

class ProductCommentLoading extends ProductCommentState {}

class ProductCommentListLoaded extends ProductCommentState {
  final List<Product> products;
  ProductCommentListLoaded(this.products);
}

class ProductCommentError extends ProductCommentState {
  final String message;
  ProductCommentError(this.message);
}
