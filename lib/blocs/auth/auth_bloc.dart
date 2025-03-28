import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/auth/auth_event.dart';
import 'package:luanvan/blocs/auth/auth_state.dart';
import 'package:luanvan/services/auth_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  String? _pendingEmail;
  String? _pendingPassword;
  String? _verificationId;

  AuthBloc(this._authService) : super(AuthInitial()) {
    on<SignUpWithEmailAndPasswordEvent>(_onSignUpWithEmailAndPassword);
    on<LoginWithEmailAndPasswordEvent>(_onLoginWithEmailAndPassword);
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<VerifyEmailEvent>(_onVerifyEmail);
    on<SignUpWithPhoneEvent>(_onSignUpWithPhone);
    on<VerifyPhoneCodeEvent>(_onVerifyPhoneCode);
    on<LoginInWithFacebookEvent>(_onSignInWithFacebook);
    on<LoginWithGoogleEvent>(_onSignInWithGoogle);
    on<LoginEvent>(_onLogin);
    on<SignOutEvent>(_onSignOut);
    on<SendEmailVerificationEvent>(_onSendEmailVerification);
  }

  Future<void> _onSignUpWithEmailAndPassword(
    SignUpWithEmailAndPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      if (event.password.isEmpty) {
        // Bước 1: Lưu email và gửi mã xác thực
        _pendingEmail = event.email;
        final UserCredential userCredential =
            await _authService.signUpWithEmailAndPassword(
          event.email,
          'temporary_password', // Mật khẩu tạm thời
        );

        if (userCredential.user != null) {
          // Gửi mã xác thực qua email
          await _authService.sendEmailVerificationCode(event.email);
          emit(AuthEmailVerificationSent());
        }
      } else {
        // Bước 2: Cập nhật mật khẩu sau khi xác thực email
        if (_pendingEmail == null) {
          emit(AuthError('Vui lòng đăng ký lại từ đầu'));
          return;
        }

        // Cập nhật mật khẩu cho tài khoản
        final user = await _authService.getCurrentUser();
        if (user != null) {
          await user.updatePassword(event.password);
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthError('Không tìm thấy tài khoản'));
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Đã xảy ra lỗi';
      if (e.code == 'weak-password') {
        message = 'Mật khẩu quá yếu';
      } else if (e.code == 'email-already-in-use') {
        message = 'Email đã được sử dụng';
      } else if (e.code == 'invalid-email') {
        message = 'Email không hợp lệ';
      }
      emit(AuthError(message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLoginWithEmailAndPassword(
    LoginWithEmailAndPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final UserCredential userCredential =
          await _authService.signInWithEmailAndPassword(
        event.email,
        event.password,
      );

      if (userCredential.user != null) {
        final bool isVerified = await _authService.isEmailVerified();
        if (!isVerified) {
          emit(AuthEmailNotVerified());
        } else {
          emit(AuthAuthenticated(userCredential.user!));
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Đã xảy ra lỗi';
      if (e.code == 'user-not-found') {
        message = 'Không tìm thấy tài khoản với email này';
      } else if (e.code == 'wrong-password') {
        message = 'Mật khẩu không chính xác';
      } else if (e.code == 'invalid-email') {
        message = 'Email không hợp lệ';
      }
      emit(AuthError(message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onForgotPassword(
    ForgotPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authService.sendPasswordResetEmail(event.email);
      emit(AuthPasswordResetEmailSent());
    } on FirebaseAuthException catch (e) {
      String message = 'Đã xảy ra lỗi';
      if (e.code == 'user-not-found') {
        message = 'Không tìm thấy tài khoản với email này';
      } else if (e.code == 'invalid-email') {
        message = 'Email không hợp lệ';
      }
      emit(AuthError(message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onVerifyEmail(
    VerifyEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final bool isVerified = await _authService.verifyEmailCode(
        event.verificationId,
        event.code,
      );
      if (isVerified) {
        emit(AuthEmailVerified());
      } else {
        emit(AuthError('Mã xác thực không đúng'));
      }
    } catch (e) {
      emit(AuthError('Xác thực email thất bại: ${e.toString()}'));
    }
  }

  Future<void> _onSendEmailVerification(
    SendEmailVerificationEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authService.sendEmailVerification();
      emit(AuthEmailVerificationSent());
    } catch (e) {
      emit(AuthError('Gửi email xác thực thất bại: ${e.toString()}'));
    }
  }

  Future<void> _onSignUpWithPhone(
    SignUpWithPhoneEvent event,
    Emitter<AuthState> emit,
  ) async {
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
    VerifyPhoneCodeEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final UserCredential userCredential = await _authService.verifyPhoneCode(
        event.verificationId,
        event.smsCode,
      );
      emit(AuthAuthenticated(userCredential.user!));
    } catch (e) {
      emit(AuthError('Mã xác thực không đúng: ${e.toString()}'));
    }
  }

  Future<void> _onSignInWithFacebook(
    LoginInWithFacebookEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final UserCredential userCredential =
          await _authService.signInWithFacebook();
      emit(AuthAuthenticated(userCredential.user!));
    } catch (e) {
      emit(AuthError('Lỗi đăng nhập Facebook: ${e.toString()}'));
    }
  }

  Future<void> _onSignInWithGoogle(
    LoginWithGoogleEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final UserCredential userCredential =
          await _authService.signInWithGoogle();
      emit(AuthAuthenticated(userCredential.user!));
    } catch (e) {
      emit(AuthError('Lỗi đăng nhập Google: ${e.toString()}'));
    }
  }

  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // Thêm logic đăng nhập nếu bạn có LoginEvent cụ thể
    } catch (e) {
      emit(AuthError('Lỗi đăng nhập: ${e.toString()}'));
    }
  }

  Future<void> _onSignOut(
    SignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authService.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Lỗi đăng xuất: ${e.toString()}'));
    }
  }
}
