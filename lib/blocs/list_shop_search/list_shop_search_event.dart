abstract class ListShopSearchEvent {}

class FetchListShopSearchEventByShopId extends ListShopSearchEvent {
  final List<String> shopIds;
  FetchListShopSearchEventByShopId(this.shopIds);
}

class ResetListShopSearchEvent extends ListShopSearchEvent {}
