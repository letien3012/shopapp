import 'package:luanvan/models/shop.dart';

abstract class ListShopSearchState {}

class ListShopSearchInitial extends ListShopSearchState {}

class ListShopSearchLoading extends ListShopSearchState {}

class ListShopSearchLoaded extends ListShopSearchState {
  final List<Shop> shops;
  ListShopSearchLoaded(this.shops);
}

class ListShopSearchError extends ListShopSearchState {
  final String message;
  ListShopSearchError(this.message);
}
