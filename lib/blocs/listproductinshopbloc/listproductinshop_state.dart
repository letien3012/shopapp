import 'package:luanvan/models/product.dart';

abstract class ListproductinshopState {}

class ListProductInShopInitial extends ListproductinshopState {}

class ListProductInShopLoading extends ListproductinshopState {}

class ListProducInShoptLoaded extends ListproductinshopState {
  final List<Product> listProduct;
  ListProducInShoptLoaded(this.listProduct);
}

class ListProductInShopError extends ListproductinshopState {
  final String message;
  ListProductInShopError(this.message);
}
