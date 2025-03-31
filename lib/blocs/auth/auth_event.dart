abstract class AuthEvent {}

class SignUpWithEmailAndPasswordEvent extends AuthEvent {
  final String email;
  final String password;
  SignUpWithEmailAndPasswordEvent(this.email, this.password);
}

class LoginWithEmailAndPasswordEvent extends AuthEvent {
  final String email;
  final String password;
  LoginWithEmailAndPasswordEvent(this.email, this.password);
}

class SendEmailVerificationEvent extends AuthEvent {
  final String email;
  SendEmailVerificationEvent(this.email);
}

class ForgotPasswordEvent extends AuthEvent {
  final String email;
  ForgotPasswordEvent({required this.email});
}

class VerifyEmailEvent extends AuthEvent {
  final String password;
  VerifyEmailEvent({this.password = ''});
}

// class CheckPhoneNumberEvent extends AuthEvent {
//   final String phoneNumber;
//   CheckPhoneNumberEvent(this.phoneNumber);
// }

class SignUpWithPhoneEvent extends AuthEvent {
  final String phone;
  SignUpWithPhoneEvent(this.phone);
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

class CheckEmailEvent extends AuthEvent {
  final String email;
  CheckEmailEvent(this.email);
}
