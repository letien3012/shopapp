abstract class ListShopEvent {}

class FetchListShopEventByShopId extends ListShopEvent {
  final List<String> shopIds;
  FetchListShopEventByShopId(this.shopIds);
}

class ResetListShopEvent extends ListShopEvent {}
