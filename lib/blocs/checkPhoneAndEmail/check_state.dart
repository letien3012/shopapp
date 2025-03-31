abstract class CheckState {}

class CheckInitial extends CheckState {}

class CheckLoading extends CheckState {}

class CheckError extends CheckState {
  final String message;
  CheckError(this.message);
}

class PhoneNumberExists extends CheckState {}

class PhoneNumberAvailable extends CheckState {}

class EmailExists extends CheckState {}

class EmailAvailable extends CheckState {}
