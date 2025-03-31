import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/auth/auth_event.dart';
import 'package:luanvan/blocs/auth/auth_state.dart';
import 'package:luanvan/blocs/checkPhoneAndEmail/check_event.dart';
import 'package:luanvan/blocs/checkPhoneAndEmail/check_state.dart';
import 'package:luanvan/services/auth_service.dart';

class CheckBloc extends Bloc<CheckEvent, CheckState> {
  final AuthService _authService;

  CheckBloc(this._authService) : super(CheckInitial()) {
    on<CheckPhoneNumberEvent>(_onCheckPhoneNumber);
    // on<CheckEmailEvent>(_onCheckEmail);
  }

  Future<void> _onCheckPhoneNumber(
    CheckPhoneNumberEvent event,
    Emitter<CheckState> emit,
  ) async {
    emit(CheckLoading());
    try {
      final bool exists =
          await _authService.checkPhoneNumberExists(event.phoneNumber);
      if (exists) {
        emit(PhoneNumberExists());
      } else {
        emit(PhoneNumberAvailable());
      }
    } catch (e) {
      emit(CheckError('Lỗi kiểm tra số điện thoại: ${e.toString()}'));
    }
  }

  // Future<void> _onCheckEmail(
  //   CheckEmailEvent event,
  //   Emitter<AuthState> emit,
  // ) async {
  //   emit(AuthLoading());
  //   try {
  //     final bool exists = await _authService.checkEmailExists(event.email);
  //     if (exists) {
  //       emit(EmailExists());
  //     } else {
  //       emit(EmailAvailable());
  //     }
  //   } catch (e) {
  //     emit(AuthError('Lỗi kiểm tra email: ${e.toString()}'));
  //   }
  // }
}
