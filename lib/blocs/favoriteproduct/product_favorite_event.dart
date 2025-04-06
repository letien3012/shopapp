abstract class ProductFavoriteEvent {}

class AddFavoriteProductEvent extends ProductFavoriteEvent {
  String productId;
  String userId;
  AddFavoriteProductEvent(this.productId, this.userId);
}

class RemoveFavoriteProductEvent extends ProductFavoriteEvent {
  String productId;
  String userId;
  RemoveFavoriteProductEvent(this.productId, this.userId);
}

class FetchFavoriteProductEvent extends ProductFavoriteEvent {
  String userId;
  FetchFavoriteProductEvent(this.userId);
}
