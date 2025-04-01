abstract class ListproductinshopEvent {}

class FetchListproductinshopEventByShopId extends ListproductinshopEvent {
  String shopId;
  FetchListproductinshopEventByShopId(this.shopId);
}

class FetchListproductinshopEvent extends ListproductinshopEvent {}
