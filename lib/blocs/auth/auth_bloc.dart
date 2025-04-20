import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/auth/auth_event.dart';
import 'package:luanvan/blocs/auth/auth_state.dart';
import 'package:luanvan/services/auth_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc(this._authService) : super(AuthInitial()) {
    on<SignUpWithEmailAndPasswordEvent>(_onSignUpWithEmailAndPassword);
    on<LoginWithEmailAndPasswordEvent>(_onLoginWithEmailAndPassword);
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<ChangeEmailEvent>(_onChangeEmail);
    on<VerifyEmailEvent>(_onVerifyEmail);
    on<SendEmailVerificationBeforeUpdateEmailEvent>(
        _onSendEmailVerificationBeforeUpdateEmail);
    // on<CheckPhoneNumberEvent>(_onCheckPhoneNumber);
    on<SignUpWithPhoneEvent>(_onSignUpWithPhone);
    on<VerifyPhoneCodeEvent>(_onVerifyPhoneCode);
    on<LoginInWithFacebookEvent>(_onSignInWithFacebook);
    on<LoginWithGoogleEvent>(_onSignInWithGoogle);
    on<LoginEvent>(_onLogin);
    on<SignOutEvent>(_onSignOut);
    on<SendEmailVerificationEvent>(_onSendEmailVerification);
    // on<CheckEmailEvent>(_onCheckEmail);
    on<ChangePasswordEvent>(_onChangePassword);
    on<VerifyPasswordEvent>(_onVerifyPassword);
    on<CheckLoginStatus>(_onCheckLoginStaus);
  }

  Future<void> _onSignUpWithEmailAndPassword(
    SignUpWithEmailAndPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authService.onSignUpWithEmailAndPassword(
        event.email,
        event.password,
      );

      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthError('Không tìm thấy tài khoản'));
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

  Future<void> _onChangeEmail(
    ChangeEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authService.changeEmail(event.email);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError('Lỗi thay đổi email: ${e.toString()}'));
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

      final shop = await _authService.checkAdmin(event.email);
      if (shop != null) {
        emit(AdminAuthenticated(shop));
      } else {
        emit(AuthAuthenticated(userCredential.user!));
      }
    } catch (e) {
      emit(AuthError(e.toString().split(':')[1]));
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
      final user = await _authService.getCurrentUser();
      if (user == null) {
        emit(AuthError('Không tìm thấy người dùng'));
        return;
      }
      await user.reload();
      if (!user.emailVerified) {
        emit(AuthError('Email chưa được xác thực'));
        return;
      }

      emit(AuthEmailVerified());
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
      await _authService.sendEmailVerification(event.email);
      emit(AuthEmailVerificationSent());
    } catch (e) {
      emit(AuthError('Gửi email xác thực thất bại: ${e.toString()}'));
    }
  }

  Future<void> _onSendEmailVerificationBeforeUpdateEmail(
    SendEmailVerificationBeforeUpdateEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authService.sendEmailVerificationBeforeUpdateEmail(event.email);
      emit(AuthEmailVerificationSent());
    } catch (e) {
      emit(AuthError('Gửi email xác thực thất bại: ${e.toString()}'));
    }
  }

  String formatPhoneNumber(String phoneNumber) {
    phoneNumber = phoneNumber.trim();
    phoneNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (phoneNumber.startsWith('0')) {
      phoneNumber = '+84${phoneNumber.substring(1)}';
    } else if (!phoneNumber.startsWith('+')) {
      phoneNumber = '+84$phoneNumber';
    }
    return phoneNumber;
  }

  Future<void> _onSignUpWithPhone(
    SignUpWithPhoneEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final formattedPhone = formatPhoneNumber(event.phone);
      await _authService.signUpWithPhone(formattedPhone, (verificationId) {
        if (!emit.isDone) {
          emit(AuthCodeSent(verificationId));
        }
      });
    } catch (e) {
      emit(AuthError('Lỗi gửi mã xác thực: ${e.toString()}'));
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
      final UserCredential? userCredential =
          await _authService.signInWithFacebook();
      if (userCredential != null) {
        emit(AuthAuthenticated(userCredential.user!));
      } else {
        emit(AuthError('Đăng nhập thất bại'));
      }
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

  // Future<void> _onCheckPhoneNumber(
  //   CheckPhoneNumberEvent event,
  //   Emitter<AuthState> emit,
  // ) async {
  //   emit(AuthLoading());
  //   try {
  //     final bool exists =
  //         await _authService.checkPhoneNumberExists(event.phoneNumber);
  //     if (exists) {
  //       emit(PhoneNumberExists());
  //     } else {
  //       emit(PhoneNumberAvailable());
  //     }
  //   } catch (e) {
  //     emit(AuthError('Lỗi kiểm tra số điện thoại: ${e.toString()}'));
  //   }
  // }

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

  Future<void> _onChangePassword(
    ChangePasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) {
        emit(AuthError('Không tìm thấy người dùng'));
        return;
      }

      // Kiểm tra nếu là đăng nhập bằng Google
      bool isGoogleSignIn = false;
      for (var info in user.providerData) {
        if (info.providerId == 'google.com') {
          isGoogleSignIn = true;
          break;
        }
      }

      if (!isGoogleSignIn) {
        // Xác thực lại với mật khẩu cũ nếu không phải đăng nhập Google
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: event.oldPassword,
        );
        await user.reauthenticateWithCredential(credential);
      }

      // Đổi mật khẩu mới
      await user.updatePassword(event.newPassword);
      emit(AuthAuthenticated(user));
      // emit(AuthPasswordChanged());
    } on FirebaseAuthException catch (e) {
      String message = 'Đã xảy ra lỗi';
      if (e.code == 'wrong-password') {
        message = 'Mật khẩu hiện tại không chính xác';
      } else if (e.code == 'weak-password') {
        message = 'Mật khẩu mới quá yếu';
      } else if (e.code == 'requires-recent-login') {
        message = 'Vui lòng đăng nhập lại để thực hiện thao tác này';
      }
      emit(AuthError(message));
    } catch (e) {
      emit(AuthError('Đổi mật khẩu thất bại: ${e.toString()}'));
    }
  }

  Future<void> _onVerifyPassword(
    VerifyPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) {
        emit(AuthError('Không tìm thấy người dùng'));
        return;
      }

      // Xác thực lại với mật khẩu cũ
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: event.password,
      );

      await user.reauthenticateWithCredential(credential);
      emit(PasswordVerified());
    } on FirebaseAuthException catch (e) {
      String message = 'Đã xảy ra lỗi';
      if (e.code == 'wrong-password') {
        message = 'Mật khẩu không chính xác';
      } else if (e.code == 'requires-recent-login') {
        message = 'Vui lòng đăng nhập lại để thực hiện thao tác này';
      }
      emit(AuthError(message));
    } catch (e) {
      emit(AuthError('Xác thực mật khẩu thất bại: ${e.toString()}'));
    }
  }

  Future<void> _onCheckLoginStaus(
      CheckLoginStatus event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) {
        emit(AuthUnauthenticated());
      } else {
        final shop = await _authService.checkAdmin(user.email!);
        if (shop != null) {
          emit(AdminAuthenticated(shop));
        } else {
          emit(AuthAuthenticated(user));
        }
      }
    } catch (e) {
      emit(
          AuthError('Kiểm tra trạng thái đăng nhập thất bại: ${e.toString()}'));
    }
  }
}
