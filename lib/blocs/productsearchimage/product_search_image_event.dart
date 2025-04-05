abstract class ProductSearchImageEvent {}

class FetchMultipleProductsSearchImageEvent extends ProductSearchImageEvent {
  final List<String> productIds;
  FetchMultipleProductsSearchImageEvent(this.productIds);
}

class ResetProductSearchImageEvent extends ProductSearchImageEvent {}
