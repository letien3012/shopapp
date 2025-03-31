abstract class ListUserCommentEvent {}

class FetchListUserCommentEventByUserId extends ListUserCommentEvent {
  final List<String> userIds;
  FetchListUserCommentEventByUserId(this.userIds);
}

class FetchListUserCommentEventByProductId extends ListUserCommentEvent {
  final String productId;
  FetchListUserCommentEventByProductId(this.productId);
}

class ResetListUserCommentEvent extends ListUserCommentEvent {}
