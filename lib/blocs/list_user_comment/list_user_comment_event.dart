abstract class ListUserCommentEvent {}

class FetchListUserCommentEventByUserId extends ListUserCommentEvent {
  final List<String> userIds;
  FetchListUserCommentEventByUserId(this.userIds);
}

class ResetListUserCommentEvent extends ListUserCommentEvent {}
