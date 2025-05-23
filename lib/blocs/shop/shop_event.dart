import 'package:luanvan/models/shop.dart';

abstract class ShopEvent {}

class FetchShopEvent extends ShopEvent {
  final String userId;
  FetchShopEvent(this.userId);
}

class FetchShopEventByShopId extends ShopEvent {
  final String shopId;
  FetchShopEventByShopId(this.shopId);
}

class GetShopEvent extends ShopEvent {}

class UpdateShopEvent extends ShopEvent {
  final Shop shop;
  UpdateShopEvent(this.shop);
}

class HideShopEvent extends ShopEvent {
  final String shopId;
  HideShopEvent(this.shopId);
}

class ResetShopEvent extends ShopEvent {}
