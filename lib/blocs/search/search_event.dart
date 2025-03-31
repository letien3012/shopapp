abstract class SearchEvent {}

class SuggestSearch extends SearchEvent {
  final String keyword;
  SuggestSearch(this.keyword);
}

class SearchProducts extends SearchEvent {
  final String query;
  SearchProducts(this.query);
}

class SearchProductsByShop extends SearchEvent {
  final String shopId;
  final String query;
  SearchProductsByShop(this.shopId, this.query);
}

class LoadMoreSearchResults extends SearchEvent {
  final String query;
  final dynamic lastDocument;
  LoadMoreSearchResults(this.query, this.lastDocument);
}
