import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/auth/auth_bloc.dart';
import 'package:luanvan/blocs/auth/auth_state.dart';
import 'package:luanvan/blocs/order/order_bloc.dart';
import 'package:luanvan/blocs/order/order_event.dart';
import 'package:luanvan/blocs/order/order_state.dart';
import 'package:luanvan/blocs/shop/shop_bloc.dart';
import 'package:luanvan/blocs/shop/shop_state.dart';
import 'package:luanvan/models/address.dart';
import 'package:luanvan/models/order.dart';
import 'package:luanvan/models/order_history.dart';
import 'package:luanvan/models/shop.dart';
import 'package:luanvan/ui/checkout/add_location_screen.dart';
import 'package:luanvan/ui/shop/order_manager/order_prepared_screen.dart';
import 'package:luanvan/ui/shop/shop_manager/location/edit_location_shop_screen.dart';
import 'package:luanvan/ui/widgets/confirm_diablog.dart';

class PickLocationOrderScreen extends StatefulWidget {
  final Address? selectedAddress;
  const PickLocationOrderScreen({super.key, this.selectedAddress});
  static String routeName = "pick_location_order_screen";
  @override
  State<PickLocationOrderScreen> createState() =>
      _PickLocationOrderScreenState();
}

class _PickLocationOrderScreenState extends State<PickLocationOrderScreen> {
  int? selectedAddressIndex = 0;
  late Order order;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      order = ModalRoute.of(context)?.settings.arguments as Order;

      if (widget.selectedAddress != null) {
        final shopState = context.read<ShopBloc>().state;
        if (shopState is ShopLoaded) {
          final index = shopState.shop.addresses.indexWhere((addr) =>
              addr.addressLine == widget.selectedAddress!.addressLine &&
              addr.receiverName == widget.selectedAddress!.receiverName &&
              addr.receiverPhone == widget.selectedAddress!.receiverPhone);
          if (index != -1) {
            setState(() {
              selectedAddressIndex = index;
            });
          }
        }
      }
    });
  }

  Future<bool> _showConfirmAgreeProductDialog() async {
    final confirmed = await ConfirmDialog(
      title: "Xác nhận địa chỉ lấy hàng?",
      cancelText: "Không",
      confirmText: "Đồng ý",
    ).show(context);
    return confirmed;
  }

  Future<void> _handleAddressSelection(Address selectedAddress) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      // Update order with new pickup address and status
      final updatedOrder = order.copyWith(
        pickUpAdress: selectedAddress,
        status: OrderStatus.shipped,
        updateAt: DateTime.now(),
        statusHistory: [
          ...order.statusHistory,
          OrderStatusHistory(
            status: OrderStatus.shipped,
            timestamp: DateTime.now(),
            note:
                "Đã cập nhật địa chỉ lấy hàng: ${selectedAddress.addressLine}",
          ),
        ],
      );

      // Dispatch update event
      context.read<OrderBloc>().add(
            UpdateOrder(updatedOrder),
          );

      // Wait for the update to complete
      await for (final state in context.read<OrderBloc>().stream) {
        if (state is OrderUpdated) {
          // Close loading dialog
          final shopState = context.read<ShopBloc>().state;
          if (shopState is ShopLoaded) {
            context
                .read<OrderBloc>()
                .add(FetchOrdersByShopId(shopState.shop.shopId!));
          }
          Navigator.of(context).pop();
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật thành công'),
            ),
          );
          // Navigate back
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed(
            OrderPreparedScreen.routeName,
            arguments: order.id,
          );
          break;
        }
      }
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: BlocBuilder<AuthBloc, AuthState>(
      builder: (BuildContext context, state) {
        if (state is AuthLoading) {
          return _buildLoading();
        } else if (state is AuthAuthenticated) {
          return BlocBuilder<ShopBloc, ShopState>(
            builder: (context, shopState) {
              if (shopState is ShopLoading) {
                return _buildLoading();
              } else if (shopState is ShopLoaded) {
                return _buildUserContent(context, shopState.shop);
              } else if (shopState is ShopError) {
                return _buildError(shopState.message);
              }
              return _buildInitializing();
            },
          );
        } else if (state is AuthError) {
          return _buildError(state.message);
        } else if (state is AuthUnauthenticated) {
          return _buildNotAuthenticated();
        }
        return _buildInitializing();
      },
    ));
  }

  // Trạng thái đang tải
  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  // Trạng thái lỗi
  Widget _buildError(String message) {
    return Center(child: Text('Error: $message'));
  }

  // Trạng thái khởi tạo
  Widget _buildInitializing() {
    return const Center(child: Text('Đang khởi tạo'));
  }

  Widget _buildNotAuthenticated() {
    return const Center(child: Text("Chưa đăng nhập"));
  }

  Widget _buildUserContent(BuildContext context, Shop shop) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              width: MediaQuery.of(context).size.width,
              color: Colors.grey[200],
              padding: const EdgeInsets.only(top: 90, bottom: 20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    margin: const EdgeInsets.only(bottom: 10),
                    alignment: Alignment.centerLeft,
                    color: Colors.grey[200],
                    height: 20,
                    child: Text("Địa chỉ lấy hàng"),
                  ),
                  // Địa chỉ
                  ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: shop.addresses.length,
                    itemBuilder: (context, index) => Material(
                      color: Colors.white,
                      child: InkWell(
                        onTap: () async {
                          setState(() {
                            selectedAddressIndex = index;
                          });
                          if (await _showConfirmAgreeProductDialog()) {
                            final shopState = context.read<ShopBloc>().state;
                            if (shopState is ShopLoaded) {
                              await _handleAddressSelection(
                                  shopState.shop.addresses[index]);
                            }
                          } else {
                            setState(() {
                              selectedAddressIndex = 0;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  width: 1, color: Colors.grey[200]!),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Radio<int>(
                                value: index,
                                groupValue: selectedAddressIndex,
                                onChanged: (value) async {
                                  setState(() {
                                    selectedAddressIndex = index;
                                  });
                                  if (await _showConfirmAgreeProductDialog()) {
                                    final shopState =
                                        context.read<ShopBloc>().state;
                                    if (shopState is ShopLoaded) {
                                      await _handleAddressSelection(
                                          shopState.shop.addresses[index]);
                                    }
                                  } else {
                                    setState(() {
                                      selectedAddressIndex = 0;
                                    });
                                  }
                                },
                                activeColor: Colors.brown,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          shop.addresses[index].receiverName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          shop.addresses[index].receiverPhone,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      shop.addresses[index].addressLine,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      "${shop.addresses[index].ward}, ${shop.addresses[index].district}, ${shop.addresses[index].city}",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    index == 0
                                        ? Container(
                                            margin:
                                                const EdgeInsets.only(top: 5),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.red,
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                            child: const Text(
                                              'Mặc định',
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 12,
                                              ),
                                            ),
                                          )
                                        : Container()
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    EditLocationShopScreen.routeName,
                                    arguments: {"index": index, "shop": shop},
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  child: const Text(
                                    'Sửa',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                          AddLocationScreen.routeName,
                          arguments: shop);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(
                            width: 1,
                            color: Colors.grey[200]!,
                          ),
                        ),
                      ),
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            color: Colors.brown,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Thêm Địa Chỉ Mới',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.brown,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          // Appbar
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              height: 80,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              padding: const EdgeInsets.only(
                  top: 30, left: 10, right: 10, bottom: 10),
              child: Row(
                children: [
                  //Icon trở về
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.brown,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const SizedBox(
                    height: 40,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Chọn địa chỉ lấy hàng",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
