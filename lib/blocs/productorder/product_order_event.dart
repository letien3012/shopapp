abstract class ProductOrderEvent {}

class FetchMultipleProductsOrderEvent extends ProductOrderEvent {
  final List<String> productIds;
  FetchMultipleProductsOrderEvent(this.productIds);
}

class ResetProductOrderEvent extends ProductOrderEvent {}
