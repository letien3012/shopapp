abstract class SearchImageEvent {}

class SearchProductsByImage extends SearchImageEvent {
  final String imageUrl;
  SearchProductsByImage(this.imageUrl);
}

class SearchProductRelated extends SearchImageEvent {
  final String imageUrl;
  SearchProductRelated(this.imageUrl);
}
// class LoadMoreSearchResults extends SearchImageEvent {
//   final String query;
//   final dynamic lastDocument;
//   LoadMoreSearchResults(this.query, this.lastDocument);
// }
