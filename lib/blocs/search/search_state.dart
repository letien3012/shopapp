import 'package:luanvan/models/product.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchSuggestLoaded extends SearchState {
  final List<String> suggestions;
  SearchSuggestLoaded(this.suggestions);
}

class SearchLoaded extends SearchState {
  final List<Product> products;
  final bool hasMore;
  SearchLoaded(this.products, {this.hasMore = true});
}

class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
}
