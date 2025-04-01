import 'package:luanvan/models/comment.dart';

abstract class CommentState {}

class CommentInitial extends CommentState {}

class CommentLoading extends CommentState {}

class CommentCreateSuccess extends CommentState {}

class CommentEmpty extends CommentState {}

class CommentLoaded extends CommentState {
  final List<Comment> comments;
  CommentLoaded(this.comments);
}

class CommentUserLoaded extends CommentState {
  final List<Comment> comments;
  CommentUserLoaded(this.comments);
}

class CommentShopLoaded extends CommentState {
  final List<Comment> comments;
  CommentShopLoaded(this.comments);
}

class CommentError extends CommentState {
  final String message;

  CommentError(this.message);
}
