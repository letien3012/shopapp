import 'package:luanvan/models/user_info_model.dart';

abstract class UserChatState {}

class UserChatInitial extends UserChatState {}

class UserChatLoading extends UserChatState {}

class UserChatLoaded extends UserChatState {
  final UserInfoModel user;
  UserChatLoaded(this.user);
}

class UserChatError extends UserChatState {
  final String message;
  UserChatError(this.message);
}
