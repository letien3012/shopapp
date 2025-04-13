import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/checkcartproduct/check_product_checkout.dart';
import 'package:luanvan/blocs/checkcartproduct/check_product_checkout_state.dart';
import 'package:luanvan/services/product_service.dart';

class CheckProductCheckoutBloc
    extends Bloc<CheckProductCheckoutEvent, CheckProductCheckoutState> {
  final ProductService productService;
  CheckProductCheckoutBloc(this.productService)
      : super(CheckProductCheckoutInitial()) {
    on<CheckProductCheckoutBeforeCheckoutEvent>(
        _onCheckProductCheckoutBeforeCheckoutEvent);
  }

  void _onCheckProductCheckoutBeforeCheckoutEvent(
      CheckProductCheckoutBeforeCheckoutEvent event,
      Emitter<CheckProductCheckoutState> emit) async {
    emit(CheckProductCheckoutLoading());
    try {
      final result = await productService.checkProductCheckout(
          event.userId, event.productCheckout);
      if (result) {
        emit(CheckProductCheckoutSuccess());
      } else {
        emit(CheckProductCheckoutError('Sản phẩm không còn hàng'));
      }
    } catch (e) {
      emit(CheckProductCheckoutError(e.toString()));
    }
  }
}
