abstract class CheckEvent {}

class CheckPhoneNumberEvent extends CheckEvent {
  final String phoneNumber;
  CheckPhoneNumberEvent(this.phoneNumber);
}

class CheckEmailEvent extends CheckEvent {
  final String email;
  CheckEmailEvent(this.email);
}
