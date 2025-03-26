import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:luanvan/blocs/auth/auth_bloc.dart';
import 'package:luanvan/blocs/auth/auth_state.dart';
import 'package:luanvan/blocs/cart/cart_bloc.dart';
import 'package:luanvan/blocs/cart/cart_state.dart';
import 'package:luanvan/blocs/user/user_bloc.dart';
import 'package:luanvan/blocs/user/user_event.dart';
import 'package:luanvan/blocs/user/user_state.dart';
import 'package:luanvan/models/address.dart';
import 'package:luanvan/ui/checkout/add_location_screen.dart';
import 'package:luanvan/ui/checkout/location_screen.dart';
import 'package:luanvan/ui/checkout/shop_checkout_item.dart';
import 'package:luanvan/ui/widgets/confirm_diablog.dart';

class CheckOutScreen extends StatefulWidget {
  static const String routeName = 'check_out_screen';
  const CheckOutScreen({super.key});

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  Address receiverAddress = Address(
      addressLine: '',
      city: '',
      district: '',
      ward: '',
      isDefault: false,
      receiverName: '',
      receiverPhone: '');
  Map<String, List<String>> productCheckOut = {};
  List<String> productIds = [];
  List<String> listShopId = [];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUserAddress();
      productCheckOut = ModalRoute.of(context)!.settings.arguments
          as Map<String, List<String>>;
      listShopId = productCheckOut.keys.toList();
    });
  }

  Future<void> _checkUserAddress() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<UserBloc>().add(FetchUserEvent(authState.user.uid));
      final userState = context.read<UserBloc>().state;
      if (userState is UserLoaded && userState.user.addresses.isEmpty) {
        if (await _showAddAddressDialog()) {
          Navigator.pushNamed(context, AddLocationScreen.routeName,
              arguments: userState.user);
        } else {
          Navigator.of(context).pop();
        }
      }
    }
  }

  Future<bool> _showAddAddressDialog() async {
    return await ConfirmDialog(
      title: "Không có địa chỉ nhận hàng, vui lòng thêm địa chỉ nhận hàng",
      cancelText: "Thoát",
      confirmText: "Thêm địa chỉ",
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) =>
            _buildAuthStateContent(context, authState),
      ),
    );
  }

  // Auth State Content
  Widget _buildAuthStateContent(BuildContext context, AuthState authState) {
    if (authState is AuthAuthenticated) {
      return BlocBuilder<UserBloc, UserState>(
        builder: (context, userState) {
          if (userState is UserLoaded) return _buildCheckoutContent(context);
          return _buildLoading();
        },
      );
    }
    if (authState is AuthError) return _buildError(authState.message);
    if (authState is AuthUnauthenticated) {
      return _buildMessage('Vui lòng đăng nhập để tiếp tục');
    }
    if (authState is AuthLoading) return _buildLoading();
    return _buildMessage('Đang khởi tạo');
  }

  // Checkout Content
  Widget _buildCheckoutContent(BuildContext context) {
    return Stack(
      children: [
        _buildMainScrollView(context),
        _buildCheckoutAppBar(context),
        _buildCheckoutBottomBar(context),
      ],
    );
  }

  // Main Scroll View
  Widget _buildMainScrollView(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width,
        color: Colors.grey[200],
        padding:
            const EdgeInsets.only(left: 10, right: 10, top: 90, bottom: 70),
        child: Column(
          children: [
            _buildAddressSection(context),
            const SizedBox(height: 10),
            _buildProductsSection(),
            _buildPaymentMethodSection(),
            _buildPaymentDetailsSection(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                'Nhấn "Đặt hàng" đồng nghĩa với việc bạn đồng ý tuân theo điều khoản',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Address Section
  Widget _buildAddressSection(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(LocationScreen.routeName),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 60,
              alignment: Alignment.topCenter,
              child:
                  const Icon(HeroIcons.map_pin, color: Colors.brown, size: 18),
            ),
            const SizedBox(width: 5),
            _buildAddressDetails(),
            const Icon(Icons.arrow_forward_ios, size: 15),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressDetails() {
    return Expanded(
      child: GestureDetector(
        onTap: () {},
        child: BlocBuilder<UserBloc, UserState>(builder: (context, userState) {
          if (userState is UserLoaded) {
            if (userState.user.addresses.isEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Text("Địa chỉ nhận hàng",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                  const SizedBox(height: 5),
                  const Text("Chọn địa chỉ",
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.brown)),
                  const SizedBox(
                    height: 10,
                  )
                ],
              );
            } else {
              receiverAddress = userState.user.addresses[0];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(receiverAddress.receiverName,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      SizedBox(width: 10),
                      Text("(${receiverAddress.receiverPhone})",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w300)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(receiverAddress.addressLine,
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w400)),
                  Text(
                      "${receiverAddress.ward}, ${receiverAddress.district}, ${receiverAddress.city}",
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              );
            }
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Text("Địa chỉ nhận hàng",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
              const SizedBox(height: 5),
              const Text("Chọn địa chỉ",
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.brown)),
              const SizedBox(
                height: 10,
              )
            ],
          );
        }),
      ),
    );
  }

  // Products Section
  Widget _buildProductsSection() {
    return BlocBuilder<CartBloc, CartState>(
      builder: (BuildContext context, CartState cartState) {
        if (cartState is CartLoaded) {
          return ListView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: productCheckOut.length,
            itemBuilder: (context, index) {
              if (index >= listShopId.length) {
                return const SizedBox.shrink();
              }
              final shopId = listShopId[index];
              return ShopCheckoutItem(
                shopId: shopId,
                cart: cartState.cart,
                listItemId: productCheckOut[shopId]!,
              );
            },
          );
        }
        return _buildLoading();
      },
    );
  }

  // Payment Method Section
  Widget _buildPaymentMethodSection() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Phương thức thanh toán",
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                GestureDetector(
                  onTap: () {},
                  child: const Row(
                    children: [
                      Text("Xem tất cả"),
                      SizedBox(width: 5),
                      Icon(Icons.arrow_forward_ios, size: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildDivider(),
          const Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(HeroIcons.currency_dollar,
                        size: 20, color: Colors.brown),
                    SizedBox(width: 10),
                    Text("Thanh toán khi nhận hàng",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500)),
                  ],
                ),
                Icon(HeroIcons.check_circle, size: 20, color: Colors.brown),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Payment Details Section
  Widget _buildPaymentDetailsSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Chi tiết thanh toán",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          _buildPaymentRow("Tổng tiền hàng", "500.000"),
          const SizedBox(height: 5),
          _buildPaymentRow("Tổng tiền phí vận chuyển", "42.500"),
          const SizedBox(height: 10),
          _buildPaymentRow("Tổng thanh toán", "542.500", isTotal: true),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: isTotal ? FontWeight.w500 : FontWeight.normal)),
        Row(
          children: [
            const Icon(FontAwesomeIcons.dongSign, size: 12),
            Text(amount,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ],
    );
  }

  // AppBar
  Widget _buildCheckoutAppBar(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        height: 80,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(color: Colors.white),
        padding:
            const EdgeInsets.only(top: 30, left: 10, right: 10, bottom: 10),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                height: 40,
                width: 40,
                alignment: Alignment.center,
                child:
                    const Icon(Icons.arrow_back, color: Colors.brown, size: 30),
              ),
            ),
            const SizedBox(width: 10),
            const Text("Thanh toán",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400)),
          ],
        ),
      ),
    );
  }

  // Bottom Bar
  Widget _buildCheckoutBottomBar(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        padding: const EdgeInsets.all(10),
        height: 60,
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Row(
              children: [
                Text("Tổng thanh toán ",
                    style: TextStyle(color: Colors.black, fontSize: 13)),
                Icon(FontAwesomeIcons.dongSign, color: Colors.red, size: 15),
                Text("500.000",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red)),
              ],
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () =>
                  Navigator.of(context).pushNamed(CheckOutScreen.routeName),
              child: Container(
                height: 45,
                width: 110,
                decoration: BoxDecoration(
                    color: Colors.brown,
                    borderRadius: BorderRadius.circular(8)),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Mua hàng ",
                        style: TextStyle(fontSize: 14, color: Colors.white)),
                    Text("(0)",
                        style: TextStyle(fontSize: 14, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable Widgets
  Widget _buildDivider() {
    return Container(
      width: double.infinity,
      height: 0.8,
      color: Colors.grey[200],
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildError(String message) {
    return Center(child: Text('Error: $message'));
  }

  Widget _buildMessage(String message) {
    return Center(child: Text(message));
  }
}
