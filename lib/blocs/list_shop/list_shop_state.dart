import 'package:luanvan/models/shop.dart';

abstract class ListShopState {}

class ListShopInitial extends ListShopState {}

class ListShopLoading extends ListShopState {}

class ListShopLoaded extends ListShopState {
  final List<Shop> shops;
  ListShopLoaded(this.shops);
}

class ListShopSearchLoaded extends ListShopState {
  final List<Shop> shops;
  ListShopSearchLoaded(this.shops);
}

class ListShopError extends ListShopState {
  final String message;
  ListShopError(this.message);
}
