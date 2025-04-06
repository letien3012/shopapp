import 'package:luanvan/models/user_info_model.dart';

abstract class AllUserState {}

class AllUserInitial extends AllUserState {}

class AllUserLoading extends AllUserState {}

class AllUserLoaded extends AllUserState {
  final List<UserInfoModel> users;
  AllUserLoaded(this.users);
}

class AllUserError extends AllUserState {
  final String message;
  AllUserError(this.message);
}
