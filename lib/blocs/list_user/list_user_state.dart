import 'package:luanvan/models/user_info_model.dart';

abstract class ListUserState {}

class ListUserInitial extends ListUserState {}

class ListUserLoading extends ListUserState {}

class AllUserLoaded extends ListUserState {
  final List<UserInfoModel> users;
  AllUserLoaded(this.users);
}

class ListUserOrderedLoaded extends ListUserState {
  final List<UserInfoModel> users;
  ListUserOrderedLoaded(this.users);
}

class ListUserChatLoaded extends ListUserState {
  final List<UserInfoModel> users;
  ListUserChatLoaded(this.users);
}

class ListUserError extends ListUserState {
  final String message;
  ListUserError(this.message);
}
