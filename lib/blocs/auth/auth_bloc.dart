import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/auth/auth_event.dart';
import 'package:luanvan/blocs/auth/auth_state.dart';
import 'package:luanvan/services/auth_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc(this._authService) : super(AuthInitial()) {
    on<SignUpWithPhoneEvent>(_onSignUpWithPhone);
    on<VerifyPhoneCodeEvent>(_onVerifyPhoneCode);
    on<LoginInWithFacebookEvent>(_onSignInWithFacebook);
    on<LoginWithGoogleEvent>(_onSignInWithGoogle);
    on<LoginEvent>(_onLogin);
    on<SignOutEvent>(_onSignOut);
  }

  Future<void> _onSignUpWithPhone(
      SignUpWithPhoneEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authService.signUpWithPhone(event.phone, (verificationId) {
        emit(AuthCodeSent(verificationId));
      });
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onVerifyPhoneCode(
      VerifyPhoneCodeEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      UserCredential userCredential = await _authService.verifyPhoneCode(
        event.verificationId,
        event.smsCode,
      );
      emit(AuthAuthenticated(userCredential.user!));
    } catch (e) {
      emit(AuthError('Mã xác thực không đúng: ${e.toString()}'));
    }
  }

  Future<void> _onSignInWithFacebook(
      LoginInWithFacebookEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      UserCredential userCredential = await _authService.signInWithFacebook();
      emit(AuthAuthenticated(userCredential.user!));
    } catch (e) {
      emit(AuthError('Lỗi đăng nhập Facebook: ${e.toString()}'));
    }
  }

  Future<void> _onSignInWithGoogle(
      LoginWithGoogleEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      UserCredential userCredential = await _authService.signInWithGoogle();
      emit(AuthAuthenticated(userCredential.user!));
    } catch (e) {
      emit(AuthError('Lỗi đăng nhập Google: ${e.toString()}'));
    }
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    // Xử lý đăng nhập bằng email/password nếu cần
    emit(AuthLoading());
    try {
      // Thêm logic đăng nhập nếu bạn có LoginEvent cụ thể
    } catch (e) {
      emit(AuthError('Lỗi đăng nhập: ${e.toString()}'));
    }
  }

  Future<void> _onSignOut(SignOutEvent event, Emitter<AuthState> emit) async {
    try {
      await _authService.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Lỗi đăng xuất: ${e.toString()}'));
    }
  }
}
