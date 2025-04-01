abstract class ProductCommentEvent {}

class FetchMultipleProductsCommentEvent extends ProductCommentEvent {
  final List<String> productIds;
  FetchMultipleProductsCommentEvent(this.productIds);
}

class ResetProductCommentEvent extends ProductCommentEvent {}
