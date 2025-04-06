import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/list_user/list_user_event.dart';
import 'package:luanvan/blocs/list_user/list_user_state.dart';
import 'package:luanvan/models/user_info_model.dart';
import 'package:luanvan/services/user_service.dart';

class ListUserBloc extends Bloc<ListUserEvent, ListUserState> {
  final UserService _userService;

  ListUserBloc(this._userService) : super(ListUserInitial()) {
    on<FetchListUserOrderedEventByUserId>(_onFetchListUserOrderedByUserId);
    on<FetchListUserChatEventByUserId>(_onFetchListUserChatByUserId);
    on<ResetListUserEvent>((event, emit) => emit(ListUserInitial()));
  }

  Future<void> _onFetchListUserOrderedByUserId(
      FetchListUserOrderedEventByUserId event,
      Emitter<ListUserState> emit) async {
    emit(ListUserLoading());
    try {
      final List<UserInfoModel> users =
          await _userService.fetchListUserByUserId(event.userIds);
      emit(ListUserOrderedLoaded(users));
    } catch (e) {
      emit(ListUserError(e.toString()));
    }
  }

  Future<void> _onFetchListUserChatByUserId(
      FetchListUserChatEventByUserId event, Emitter<ListUserState> emit) async {
    emit(ListUserLoading());
    try {
      final List<UserInfoModel> users =
          await _userService.fetchListUserByUserId(event.userIds);
      emit(ListUserChatLoaded(users));
    } catch (e) {
      emit(ListUserError(e.toString()));
    }
  }
}
