import 'package:luanvan/models/shop.dart';

abstract class ShopState {}

class ShopInitial extends ShopState {}

class ShopLoading extends ShopState {}

class ShopLoaded extends ShopState {
  final Shop shop;
  ShopLoaded(this.shop);
}

class ShopError extends ShopState {
  final String message;
  ShopError(this.message);
}
