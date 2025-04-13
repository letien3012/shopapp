abstract class CheckProductCheckoutState {}

class CheckProductCheckoutInitial extends CheckProductCheckoutState {}

class CheckProductCheckoutLoading extends CheckProductCheckoutState {}

class CheckProductCheckoutSuccess extends CheckProductCheckoutState {}

class CheckProductCheckoutError extends CheckProductCheckoutState {
  final String message;
  CheckProductCheckoutError(this.message);
}
