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

class UpdateUserEvent extends UserEvent {
  final UserInfoModel user;
  UpdateUserEvent(this.user);
}
