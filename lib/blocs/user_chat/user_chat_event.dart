abstract class UserChatEvent {}

class FetchUserChatEvent extends UserChatEvent {
  final String userId;
  FetchUserChatEvent(this.userId);
}
