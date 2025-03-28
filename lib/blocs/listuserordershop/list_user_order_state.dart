import 'package:luanvan/models/user_info_model.dart';

abstract class ListUserOrderState {}

class ListUserOrderInitial extends ListUserOrderState {}

class ListUserOrderLoading extends ListUserOrderState {}

class ListUserOrderLoaded extends ListUserOrderState {
  final List<UserInfoModel> users;
  ListUserOrderLoaded(this.users);
}

class ListUserOrderError extends ListUserOrderState {
  final String message;
  ListUserOrderError(this.message);
}
