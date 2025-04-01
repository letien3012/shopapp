import 'package:luanvan/models/comment.dart';
import 'package:luanvan/models/shop_comment.dart';

abstract class CommentEvent {}

class AddCommentEvent extends CommentEvent {
  final List<Comment> comments;
  final ShopComment shopComment;
  AddCommentEvent({
    required this.comments,
    required this.shopComment,
  });
}

class UpdateCommentEvent extends CommentEvent {
  final Comment comment;
  UpdateCommentEvent(this.comment);
}

class ReplyCommentEvent extends CommentEvent {
  final Comment comment;
  ReplyCommentEvent(this.comment);
}

class LoadCommentsByUserIdEvent extends CommentEvent {
  final String userId;
  LoadCommentsByUserIdEvent(this.userId);
}

class LoadCommentsShopIdEvent extends CommentEvent {
  final String shopId;
  LoadCommentsShopIdEvent(this.shopId);
}

class LoadCommentsEvent extends CommentEvent {
  final String productId;
  LoadCommentsEvent(this.productId);
}
