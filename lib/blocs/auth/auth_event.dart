abstract class AuthEvent {}

class SignUpWithPhoneEvent extends AuthEvent {
  final String phone;
  SignUpWithPhoneEvent(
    this.phone,
  );
}

class VerifyPhoneCodeEvent extends AuthEvent {
  final String verificationId;
  final String smsCode;
  VerifyPhoneCodeEvent(this.verificationId, this.smsCode);
}

class LoginInWithFacebookEvent extends AuthEvent {}

class LoginWithGoogleEvent extends AuthEvent {}

class LoginEvent extends AuthEvent {
  final String userName;
  final String password;
  LoginEvent(this.userName, this.password);
}

class SignOutEvent extends AuthEvent {}
