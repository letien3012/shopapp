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

class LoadCommentsEvent extends CommentEvent {
  final String productId;
  LoadCommentsEvent(this.productId);
}
