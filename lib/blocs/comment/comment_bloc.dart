import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/comment/comment_event.dart';
import 'package:luanvan/blocs/comment/comment_state.dart';
import 'package:luanvan/services/comment_service.dart';

// Bloc
class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final CommentService _commentService;

  CommentBloc(this._commentService) : super(CommentInitial()) {
    on<AddCommentEvent>(_onAddComment);
    on<LoadCommentsEvent>(_onLoadComments);
    on<UpdateCommentEvent>(_onUpdateComment);
    on<ReplyCommentEvent>(_onReplyComment);
    on<LoadCommentsByUserIdEvent>(_onLoadCommentsByUserId);
    on<LoadCommentsShopIdEvent>(_onLoadCommentsShopId);
  }

  Future<void> _onAddComment(
    AddCommentEvent event,
    Emitter<CommentState> emit,
  ) async {
    try {
      emit(CommentLoading());
      await _commentService.createComment(
        event.comments,
        event.shopComment,
      );
      emit(CommentCreateSuccess());
    } catch (e) {
      emit(CommentError(e.toString()));
    }
  }

  Future<void> _onLoadComments(
      LoadCommentsEvent event, Emitter<CommentState> emit) async {
    try {
      emit(CommentLoading());
      final comments =
          await _commentService.getCommentsByProductId(event.productId);
      if (comments.isEmpty) {
        emit(CommentEmpty());
      } else {
        emit(CommentLoaded(comments));
      }
    } catch (e) {
      emit(CommentError(e.toString()));
    }
  }

  Future<void> _onLoadCommentsByUserId(
      LoadCommentsByUserIdEvent event, Emitter<CommentState> emit) async {
    try {
      emit(CommentLoading());
      final comments = await _commentService.getCommentsByUserId(event.userId);
      if (comments.isEmpty) {
        emit(CommentEmpty());
      } else {
        emit(CommentUserLoaded(comments));
      }
    } catch (e) {
      emit(CommentError(e.toString()));
    }
  }

  Future<void> _onLoadCommentsShopId(
      LoadCommentsShopIdEvent event, Emitter<CommentState> emit) async {
    try {
      emit(CommentLoading());
      final comments = await _commentService.getCommentsByShopId(event.shopId);
      if (comments.isEmpty) {
        emit(CommentEmpty());
      } else {
        emit(CommentShopLoaded(comments));
      }
    } catch (e) {
      emit(CommentError(e.toString()));
    }
  }
  // Future<void> _onLoadUserComments(
  //   LoadUserCommentsEvent event,
  //   Emitter<CommentState> emit,
  // ) async {
  //   try {
  //     emit(CommentLoading());
  //     await emit.forEach(
  //       _commentService.getCommentsByUserId(event.userId),
  //       onData: (List<Comment> comments) => CommentLoaded(comments),
  //     );
  //   } catch (e) {
  //     emit(CommentError(e.toString()));
  //   }
  // }

  // Future<void> _onLoadCommentsWithReply(
  //   LoadCommentsWithReplyEvent event,
  //   Emitter<CommentState> emit,
  // ) async {
  //   try {
  //     emit(CommentLoading());
  //     await emit.forEach(
  //       _commentService.getCommentsWithReply(event.productId),
  //       onData: (List<Comment> comments) => CommentLoaded(comments),
  //     );
  //   } catch (e) {
  //     emit(CommentError(e.toString()));
  //   }
  // }

  // Future<void> _onLoadVerifiedComments(
  //   LoadVerifiedCommentsEvent event,
  //   Emitter<CommentState> emit,
  // ) async {
  //   try {
  //     emit(CommentLoading());
  //     await emit.forEach(
  //       _commentService.getVerifiedComments(event.productId),
  //       onData: (List<Comment> comments) => CommentLoaded(comments),
  //     );
  //   } catch (e) {
  //     emit(CommentError(e.toString()));
  //   }
  // }

  Future<void> _onUpdateComment(
    UpdateCommentEvent event,
    Emitter<CommentState> emit,
  ) async {
    try {
      emit(CommentLoading());
      final updatedComment = await _commentService.updateComment(event.comment);
      if (state is CommentLoaded) {
        final currentComments = (state as CommentLoaded).comments;
        final updatedComments = currentComments.map((comment) {
          return comment.id == updatedComment.id ? updatedComment : comment;
        }).toList();
        emit(CommentLoaded(updatedComments));
      }
    } catch (e) {
      emit(CommentError(e.toString()));
    }
  }

  Future<void> _onReplyComment(
    ReplyCommentEvent event,
    Emitter<CommentState> emit,
  ) async {
    try {
      emit(CommentLoading());
      final updatedComment = await _commentService.updateComment(event.comment);
      emit(CommentLoaded([updatedComment]));
    } catch (e) {
      emit(CommentError(e.toString()));
    }
  }

  // Future<void> _onDeleteComment(
  //   DeleteCommentEvent event,
  //   Emitter<CommentState> emit,
  // ) async {
  //   try {
  //     emit(CommentLoading());
  //     await _commentService.deleteComment(event.commentId);
  //     if (state is CommentLoaded) {
  //       final currentComments = (state as CommentLoaded).comments;
  //       final updatedComments = currentComments
  //           .where((comment) => comment.id != event.commentId)
  //           .toList();
  //       emit(CommentLoaded(updatedComments));
  //     }
  //   } catch (e) {
  //     emit(CommentError(e.toString()));
  //   }
  // }
}
