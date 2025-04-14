import 'package:luanvan/models/shop.dart';
import 'package:luanvan/models/user_info_model.dart';

abstract class UserEvent {}

class FetchUserEvent extends UserEvent {
  final String userId;
  FetchUserEvent(this.userId);
}

class UpdateBasicInfoUserEvent extends UserEvent {
  final UserInfoModel user;
  UpdateBasicInfoUserEvent(this.user);
}

class UpdateUserNameEvent extends UserEvent {
  final String userName;
  final String userId;
  UpdateUserNameEvent(this.userName, this.userId);
}

class UpdateUserEvent extends UserEvent {
  final UserInfoModel user;
  UpdateUserEvent(this.user);
}

class AddViewedProductEvent extends UserEvent {
  final String userId;
  final String productId;
  AddViewedProductEvent(this.userId, this.productId);
}

class RegistrationSellerEvent extends UserEvent {
  final Shop shop;
  RegistrationSellerEvent(this.shop);
}
