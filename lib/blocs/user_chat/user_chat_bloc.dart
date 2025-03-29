import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/user_chat/user_chat_event.dart';
import 'package:luanvan/blocs/user_chat/user_chat_state.dart';
import 'package:luanvan/models/user_info_model.dart';
import 'package:luanvan/services/user_service.dart';

class UserChatBloc extends Bloc<UserChatEvent, UserChatState> {
  final UserService _userService;
  UserChatBloc(this._userService) : super(UserChatInitial()) {
    on<FetchUserChatEvent>(_onFetchUserChat);
  }

  Future<void> _onFetchUserChat(
      FetchUserChatEvent event, Emitter<UserChatState> emit) async {
    emit(UserChatLoading());
    try {
      final UserInfoModel user = await _userService.fetchUserInfo(event.userId);
      emit(UserChatLoaded(user));
    } catch (e) {
      emit(UserChatError(e.toString()));
    }
  }
}
