import 'package:firebase_auth/firebase_auth.dart';
import 'package:luanvan/models/shop.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  AuthAuthenticated(this.user);
}

class AdminAuthenticated extends AuthState {
  final Shop shop;
  AdminAuthenticated(this.shop);
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class AuthCodeSent extends AuthState {
  final String verificationId;
  AuthCodeSent(this.verificationId);
}

class AuthEmailVerificationSent extends AuthState {}

class AuthEmailNotVerified extends AuthState {}

class AuthEmailVerified extends AuthState {}

class AuthPasswordResetEmailSent extends AuthState {}

class AuthPasswordChanged extends AuthState {}

class PasswordVerified extends AuthState {}

// class EmailExists extends AuthState {}

// class EmailAvailable extends AuthState {}

// class PhoneNumberExists extends AuthState {}

// class PhoneNumberAvailable extends AuthState {}
