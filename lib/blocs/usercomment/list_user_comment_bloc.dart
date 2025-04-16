import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/usercomment/list_user_comment_event.dart';
import 'package:luanvan/blocs/usercomment/list_user_comment_state.dart';
import 'package:luanvan/models/user_info_model.dart';
import 'package:luanvan/services/user_service.dart';

class ListUserCommentBloc
    extends Bloc<ListUserCommentEvent, ListUserCommentState> {
  final UserService _userService;

  ListUserCommentBloc(this._userService) : super(ListUserCommentInitial()) {
    on<FetchListUserCommentEventByUserId>(_onFetchListUserCommentByUserId);
    on<ResetListUserCommentEvent>(
        (event, emit) => emit(ListUserCommentInitial()));
  }

  Future<void> _onFetchListUserCommentByUserId(
      FetchListUserCommentEventByUserId event,
      Emitter<ListUserCommentState> emit) async {
    emit(ListUserCommentLoading());
    try {
      if (event.userIds.isNotEmpty) {
        final List<UserInfoModel> users =
            await _userService.fetchListUserByUserId(event.userIds);
        emit(ListUserCommentLoaded(users));
      } else {
        emit(ListUserCommentEmpty());
      }
    } catch (e) {
      emit(ListUserCommentError(e.toString()));
    }
  }
}
