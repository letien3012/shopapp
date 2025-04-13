abstract class CheckProductCheckoutEvent {}

class CheckProductCheckoutBeforeCheckoutEvent
    extends CheckProductCheckoutEvent {
  final String userId;
  final Map<String, List<String>> productCheckout;
  CheckProductCheckoutBeforeCheckoutEvent(this.userId, this.productCheckout);
}
