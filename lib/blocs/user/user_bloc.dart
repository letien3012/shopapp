import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/user/user_event.dart';
import 'package:luanvan/blocs/user/user_state.dart';
import 'package:luanvan/models/shop.dart';
import 'package:luanvan/models/user_info_model.dart';
import 'package:luanvan/services/user_service.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserService _userService;
  // final UserService _userService = getIt<UserService>();
  // final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  UserBloc(this._userService) : super(UserInitial()) {
    on<FetchUserEvent>(_onFetchUser);
    on<UpdateBasicInfoUserEvent>(_onUpdateBasicInfoUser);
    on<UpdateUserNameEvent>(_onUpdateUserName);
    on<UpdateUserEvent>(_onUpdateUser);
    on<AddViewedProductEvent>(_onAddViewedProduct);
    // on<RegistrationSellerEvent>(_onSellerRegistration);
  }
  Future<void> _onFetchUser(
      FetchUserEvent event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final UserInfoModel user = await _userService.fetchUserInfo(event.userId);
      emit(UserLoaded(user));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onUpdateBasicInfoUser(
      UpdateBasicInfoUserEvent event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      await _userService.updateBasicUserInfo(event.user);
      emit(UserLoaded(event.user));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onUpdateUserName(
      UpdateUserNameEvent event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      await _userService.updateUserName(event.userName, event.userId);
      final UserInfoModel user = await _userService.fetchUserInfo(event.userId);
      emit(UserLoaded(user));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onUpdateUser(
      UpdateUserEvent event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      await _userService.updateUser(event.user);
      final UserInfoModel user =
          await _userService.fetchUserInfo(event.user.id);
      emit(UserLoaded(user));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onAddViewedProduct(
      AddViewedProductEvent event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final UserInfoModel user =
          await _userService.addViewedProduct(event.userId, event.productId);
      emit(UserLoaded(user));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  // Future<void> _onSellerRegistration(
  //     RegistrationSellerEvent event, Emitter<UserState> emit) async {
  //   emit(UserLoading());
  //   try {
  //     await _userService.registrationSeller(event.shop);
  //     final UserInfoModel user =
  //         await _userService.fetchUserInfo(event.shop.userId ?? '');
  //     emit(UserLoaded(user));
  //   } catch (e) {
  //     emit(UserError(e.toString()));
  //   }
  // }
}
