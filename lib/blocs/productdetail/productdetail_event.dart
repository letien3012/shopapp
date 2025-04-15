abstract class ProductdetailEvent {}

class FetchProductdetailEventByProductId extends ProductdetailEvent {
  String productId;
  FetchProductdetailEventByProductId(this.productId);
}
