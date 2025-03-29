abstract class ListUserEvent {}

class FetchListUserChatEventByUserId extends ListUserEvent {
  final List<String> userIds;
  FetchListUserChatEventByUserId(this.userIds);
}

class FetchListUserOrderedEventByUserId extends ListUserEvent {
  final List<String> userIds;
  FetchListUserOrderedEventByUserId(this.userIds);
}

class ResetListUserEvent extends ListUserEvent {}
