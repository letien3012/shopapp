abstract class ListProductEvent {}

class FetchListProductEventByShopId extends ListProductEvent {
  String shopId;
  FetchListProductEventByShopId(this.shopId);
}

class FetchListProductEvent extends ListProductEvent {}
