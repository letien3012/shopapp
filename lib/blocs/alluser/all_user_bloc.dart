import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/alluser/all_user_event.dart';
import 'package:luanvan/blocs/alluser/all_user_state.dart';
import 'package:luanvan/models/user_info_model.dart';
import 'package:luanvan/services/user_service.dart';

class AllUserBloc extends Bloc<AllUserEvent, AllUserState> {
  final UserService _userService;

  AllUserBloc(this._userService) : super(AllUserInitial()) {
    on<FetchAllUserEvent>(_onFetchAllUser);
    on<ResetAllUserEvent>((event, emit) => emit(AllUserInitial()));
  }
  Future<void> _onFetchAllUser(
      FetchAllUserEvent event, Emitter<AllUserState> emit) async {
    emit(AllUserLoading());
    try {
      final List<UserInfoModel> users = await _userService.fetchAllUser();
      emit(AllUserLoaded(users));
    } catch (e) {
      emit(AllUserError(e.toString()));
    }
  }
}
