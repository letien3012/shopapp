import 'package:luanvan/models/user_info_model.dart';

abstract class ListUserCommentState {}

class ListUserCommentInitial extends ListUserCommentState {}

class ListUserCommentLoading extends ListUserCommentState {}

class ListUserCommentLoaded extends ListUserCommentState {
  final List<UserInfoModel> users;
  ListUserCommentLoaded(this.users);
}

class ListUserCommentError extends ListUserCommentState {
  final String message;
  ListUserCommentError(this.message);
}
