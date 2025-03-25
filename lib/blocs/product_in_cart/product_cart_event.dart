abstract class ProductCartEvent {}

class FetchMultipleProductsEvent extends ProductCartEvent {
  final List<String> productIds;
  FetchMultipleProductsEvent(this.productIds);
}

class ResetProductCartEvent extends ProductCartEvent {}
