import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/list_shop/list_shop_event.dart';
import 'package:luanvan/blocs/list_shop/list_shop_state.dart';
import 'package:luanvan/blocs/listuserordershop/list_user_order_event.dart';
import 'package:luanvan/blocs/listuserordershop/list_user_order_state.dart';
import 'package:luanvan/models/shop.dart';
import 'package:luanvan/services/user_service.dart';

import '../../models/user_info_model.dart';

class ListUserOrderBloc extends Bloc<ListUserOrderEvent, ListUserOrderState> {
  final UserService _userService;

  ListUserOrderBloc(this._userService) : super(ListUserOrderInitial()) {
    on<FetchListUserOrderEventByUserId>(_onFetchListUserOrderByUserId);
    on<ResetListUserOrderEvent>((event, emit) => emit(ListUserOrderInitial()));
  }

  Future<void> _onFetchListUserOrderByUserId(
      FetchListUserOrderEventByUserId event,
      Emitter<ListUserOrderState> emit) async {
    emit(ListUserOrderLoading());
    try {
      final List<UserInfoModel> users =
          await _userService.fetchListUserOrderByUserId(event.userIds);

      emit(ListUserOrderLoaded(users));
    } catch (e) {
      emit(ListUserOrderError(e.toString()));
    }
  }
}
