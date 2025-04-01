import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:luanvan/blocs/auth/auth_bloc.dart';
import 'package:luanvan/blocs/auth/auth_state.dart';
import 'package:luanvan/blocs/cart/cart_bloc.dart';
import 'package:luanvan/blocs/cart/cart_event.dart';
import 'package:luanvan/blocs/cart/cart_state.dart';
import 'package:luanvan/blocs/order/order_bloc.dart';
import 'package:luanvan/blocs/order/order_event.dart';
import 'package:luanvan/blocs/product_in_cart/product_cart_bloc.dart';
import 'package:luanvan/blocs/product_in_cart/product_cart_state.dart';
import 'package:luanvan/blocs/user/user_bloc.dart';
import 'package:luanvan/blocs/user/user_event.dart';
import 'package:luanvan/blocs/user/user_state.dart';
import 'package:luanvan/models/address.dart';
import 'package:luanvan/models/cart.dart';
import 'package:luanvan/models/cart_item.dart';
import 'package:luanvan/models/cart_shop.dart';
import 'package:luanvan/models/order.dart';
import 'package:luanvan/models/order_item.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/models/shipping_calculator.dart';
import 'package:luanvan/models/shipping_method.dart';
import 'package:luanvan/ui/checkout/add_location_screen.dart';
import 'package:luanvan/ui/checkout/pick_location_checkout_screen.dart';
import 'package:luanvan/ui/checkout/shop_checkout_item.dart';
import 'package:luanvan/ui/order/order_success_screen.dart';
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
  double totalShipPrice = 0.0;
  double totalProductPrice = 0.0;
  Map<String, ShippingMethod> shipMethod = {};
  Map<String, List<ShippingMethod>> listShipMethod = {};
  int _completedOrders = 0;

  @override
  void initState() {
    super.initState();
    _completedOrders = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUserAddress();
      final arg = ModalRoute.of(context)!.settings.arguments as Map;
      productCheckOut = arg['productCheckOut'];
      listShopId = productCheckOut.keys.toList();

      listShopId.forEach((shopId) {
        listShipMethod[shopId] = [];
      });

      listShopId.forEach((shopId) {
        final cartState = context.read<CartBloc>().state;
        if (cartState is CartLoaded) {
          final cartShop = cartState.cart.getShop(shopId);
          if (cartShop == null) return;

          final listItemId = productCheckOut[shopId]!;
          List<String> productIdChecked = [];
          listItemId.forEach(
            (element) =>
                productIdChecked.add(cartShop.items[element]!.productId),
          );

          List<Product> productChecked = [];
          final productCartState = context.read<ProductCartBloc>().state;
          if (productCartState is ProductCartListLoaded) {
            productCartState.products.forEach(
              (element) {
                if (productIdChecked.contains(element.id)) {
                  productChecked.add(element);
                }
              },
            );

            if (productChecked.isNotEmpty) {
              // Kiểm tra và thêm các phương thức vận chuyển khả dụng
              if (productChecked.every(
                (element) => element.shippingMethods[0].isEnabled,
              )) {
                shipMethod[shopId] = productChecked.first.shippingMethods[0];
                listShipMethod[shopId]!
                    .add(productChecked.first.shippingMethods[0]);
              }
              if (productChecked.every(
                (element) => element.shippingMethods[1].isEnabled,
              )) {
                if (shipMethod[shopId] == null ||
                    productChecked
                            .first.shippingMethods[1].estimatedDeliveryDays <
                        shipMethod[shopId]!.estimatedDeliveryDays) {
                  shipMethod[shopId] = productChecked.first.shippingMethods[1];
                }
                listShipMethod[shopId]!
                    .add(productChecked.first.shippingMethods[1]);
              }
              if (productChecked.every(
                (element) => element.shippingMethods[2].isEnabled,
              )) {
                if (shipMethod[shopId] == null ||
                    productChecked
                            .first.shippingMethods[2].estimatedDeliveryDays <
                        shipMethod[shopId]!.estimatedDeliveryDays) {
                  shipMethod[shopId] = productChecked.first.shippingMethods[2];
                }
                listShipMethod[shopId]!
                    .add(productChecked.first.shippingMethods[2]);
              }
            }

            // Nếu không có phương thức vận chuyển nào được chọn, sử dụng mặc định
            if (shipMethod[shopId] == null) {
              if (productChecked.any(
                (element) => element.shippingMethods[0].isEnabled,
              )) {
                listShipMethod[shopId]!.add(ShippingMethod.defaultMethods[0]);
                shipMethod[shopId] = ShippingMethod.defaultMethods[0];
              } else if (productChecked.any(
                (element) => element.shippingMethods[1].isEnabled,
              )) {
                listShipMethod[shopId]!.add(ShippingMethod.defaultMethods[1]);
                shipMethod[shopId] = ShippingMethod.defaultMethods[1];
              } else if (productChecked.any(
                (element) => element.shippingMethods[2].isEnabled,
              )) {
                listShipMethod[shopId]!.add(ShippingMethod.defaultMethods[2]);
                shipMethod[shopId] = ShippingMethod.defaultMethods[2];
              }
            }
          }
        }
      });

      _calculateTotalProductPrice();
      totalShipPrice = calculateTotalShippingFee();
    });
  }

  String formatPrice(double price) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }

  double calculateTotalShippingFee() {
    double totalShippingFee = 0.0;
    final cartState = context.read<CartBloc>().state;
    final productCartState = context.read<ProductCartBloc>().state;

    if (cartState is CartLoaded && productCartState is ProductCartListLoaded) {
      for (var shopId in listShopId) {
        final cartShop = cartState.cart.getShop(shopId);
        if (cartShop == null) continue;

        final listItemId = productCheckOut[shopId]!;
        List<String> productIdChecked = [];
        listItemId.forEach(
          (element) => productIdChecked.add(cartShop.items[element]!.productId),
        );

        List<Product> productChecked = [];
        productCartState.products.forEach(
          (element) {
            if (productIdChecked.contains(element.id)) {
              productChecked.add(element);
            }
          },
        );

        // Tính maxWeight từ item
        double maxWeight = 0.0;

        for (var itemId in listItemId) {
          final item = cartShop!.items[itemId];
          if (item == null) continue;
          final product = productCartState.products.firstWhere(
            (p) => p.id == item.productId,
          );

          if (product.id.isNotEmpty) {
            if (product.variants.isEmpty &&
                (product.shippingMethods.any(
                  (element) => (element.isEnabled &&
                      element.name == shipMethod[shopId]!.name),
                ))) {
              if (product.weight! > maxWeight) {
                maxWeight = product.weight!;
              }
            } else if (product.variants.length > 1) {
              int i = product.variants[0].options
                  .indexWhere((opt) => opt.id == item.optionId1);
              int j = product.variants[1].options
                  .indexWhere((opt) => opt.id == item.optionId2);
              if (i == -1) i = 0;
              if (j == -1) j = 0;
              if (product
                      .optionInfos[i * product.variants[1].options.length + j]
                      .weight! >
                  maxWeight) {
                maxWeight = product
                    .optionInfos[i * product.variants[1].options.length + j]
                    .weight!;
              }
            }
          }
        }

        // Tính phí vận chuyển cho cửa hàng này
        if (shipMethod[shopId] != null) {
          totalShippingFee += ShippingCalculator.calculateShippingCost(
            methodName: shipMethod[shopId]!.name,
            weight: maxWeight,
            includeDistanceFactor: false,
          );
        }
      }
    }

    return totalShippingFee;
  }

  Future<void> _calculateTotalProductPrice() async {
    // Đợi dữ liệu từ CartBloc và ProductCartBloc
    final cartState = context.read<CartBloc>().state;
    final productCartState = context.read<ProductCartBloc>().state;

    if (cartState is CartLoaded && productCartState is ProductCartListLoaded) {
      double calculatedTotal = 0.0;

      for (var shopId in listShopId) {
        final cartShop = cartState.cart.getShop(shopId);
        if (cartShop == null) continue;

        final listItemId = productCheckOut[shopId]!;
        for (var itemId in listItemId) {
          final item = cartShop.items[itemId];
          if (item == null) continue;

          final product = productCartState.products.firstWhere(
            (p) => p.id == item.productId,
          );

          if (product.id.isNotEmpty) {
            if (product.variants.isEmpty &&
                (product.shippingMethods.any(
                  (element) => (element.isEnabled &&
                      element.name == shipMethod[shopId]!.name),
                ))) {
              calculatedTotal += product.price! * item.quantity;
            } else if (product.variants.length > 1) {
              int i = product.variants[0].options
                  .indexWhere((opt) => opt.id == item.optionId1);
              int j = product.variants[1].options
                  .indexWhere((opt) => opt.id == item.optionId2);
              if (i == -1) i = 0;
              if (j == -1) j = 0;
              calculatedTotal += (product
                      .optionInfos[i * product.variants[1].options.length + j]
                      .price *
                  item.quantity);
            }
          }
        }
      }

      setState(() {
        totalProductPrice = calculatedTotal;
      });
    }
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

  // Address Section
  Widget _buildAddressSection(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Navigate to pick location screen and wait for result
        final selectedAddress = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PickLocationCheckoutScreen(
              selectedAddress: receiverAddress.addressLine.isNotEmpty
                  ? receiverAddress
                  : null,
            ),
          ),
        );

        // Update receiver address if an address was selected
        if (selectedAddress != null) {
          setState(() {
            receiverAddress = selectedAddress as Address;
          });
        }
      },
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
                const SizedBox(height: 10)
              ],
            );
          } else {
            // Use selected address if available, otherwise use default address
            if (receiverAddress.addressLine.isEmpty) {
              receiverAddress = userState.user.addresses.firstWhere(
                (addr) => addr.isDefault,
                orElse: () => userState.user.addresses.first,
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(receiverAddress.receiverName,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(width: 10),
                    Text("(${receiverAddress.receiverPhone})",
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w300)),
                  ],
                ),
                const SizedBox(height: 5),
                Text(receiverAddress.addressLine,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w400)),
                Text(
                    "${receiverAddress.ward}, ${receiverAddress.district}, ${receiverAddress.city}",
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w400),
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
            const SizedBox(height: 10)
          ],
        );
      }),
    );
  }

  // Products Section
  Widget _buildProductsSection() {
    return BlocBuilder<CartBloc, CartState>(
      builder: (BuildContext context, CartState cartState) {
        if (cartState is CartLoaded) {
          return BlocBuilder<ProductCartBloc, ProductCartState>(builder:
              (BuildContext context, ProductCartState productCartState) {
            if (productCartState is ProductCartListLoaded) {
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
                    productCheckOut: productCheckOut,
                    shipMethod: (shipMethod[shopId]!),
                    shipMethods: listShipMethod[shopId]!,
                    onShippingMethodChanged: _updateShippingMethod,
                  );
                },
              );
            }
            return _buildLoading();
          });
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
          _buildPaymentRow("Tổng tiền hàng", totalProductPrice),
          const SizedBox(height: 5),
          _buildPaymentRow("Tổng tiền phí vận chuyển", totalShipPrice),
          const SizedBox(height: 10),
          _buildPaymentRow(
              "Tổng thanh toán", totalProductPrice + totalShipPrice,
              isTotal: true),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: isTotal ? FontWeight.w500 : FontWeight.normal)),
        Text('đ${formatPrice(amount)}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
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
            Row(
              children: [
                Text("Tổng thanh toán ",
                    style: TextStyle(color: Colors.black, fontSize: 13)),
                Icon(FontAwesomeIcons.dongSign, color: Colors.red, size: 15),
                Text(formatPrice(totalProductPrice + totalShipPrice),
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red)),
              ],
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthAuthenticated) {
                  final userState = context.read<UserBloc>().state;
                  if (userState is UserLoaded) {
                    // Kiểm tra xem đã chọn địa chỉ chưa
                    if (receiverAddress.addressLine.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vui lòng chọn địa chỉ nhận hàng'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    Cart cart = Cart(shops: [], id: '', userId: '');
                    final cartState = context.read<CartBloc>().state;
                    if (cartState is CartLoaded) {
                      cart = cartState.cart;
                    }
                    List<Order> orders = [];
                    for (var shopId in listShopId) {
                      final cartShop = cart.getShop(shopId);
                      if (cartShop == null) continue;
                      final listItemId = productCheckOut[shopId]!;
                      final items = listItemId
                          .map((itemId) => cartShop.items[itemId]!)
                          .toList();

                      // Kiểm tra xem phương thức vận chuyển có hợp lệ không
                      bool isValidShippingMethod = true;
                      final productCartState =
                          context.read<ProductCartBloc>().state;
                      if (productCartState is ProductCartListLoaded) {
                        for (var item in items) {
                          final product = productCartState.products.firstWhere(
                            (p) => p.id == item.productId,
                          );
                          if (!product.shippingMethods.any(
                            (method) =>
                                method.isEnabled &&
                                method.name == shipMethod[shopId]?.name,
                          )) {
                            isValidShippingMethod = false;
                            break;
                          }
                        }
                      }

                      if (!isValidShippingMethod) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Phương thức vận chuyển không hợp lệ cho một số sản phẩm'),
                          ),
                        );
                        return;
                      }

                      final now = DateTime.now();
                      final estimatedDays =
                          shipMethod[shopId]?.estimatedDeliveryDays ?? 3;
                      final estimatedDeliveryDate =
                          now.add(Duration(days: estimatedDays));

                      // Tạo danh sách OrderItem từ các sản phẩm được chọn
                      List<OrderItem> orderItems = [];
                      for (var itemId in listItemId) {
                        final cartItem = cartShop.items[itemId];
                        if (cartItem == null) continue;

                        final productState =
                            context.read<ProductCartBloc>().state;
                        if (productState is ProductCartListLoaded) {
                          final product = productState.products.firstWhere(
                            (p) => p.id == cartItem.productId,
                          );

                          // Tính giá sản phẩm dựa trên biến thể
                          double productPrice = 0;
                          if (product.variants.isEmpty) {
                            productPrice = product.price ?? 0;
                          } else if (product.variants.length > 1) {
                            int i = product.variants[0].options.indexWhere(
                                (opt) => opt.id == cartItem.optionId1);
                            int j = product.variants[1].options.indexWhere(
                                (opt) => opt.id == cartItem.optionId2);
                            if (i == -1) i = 0;
                            if (j == -1) j = 0;
                            int optionInfoIndex =
                                i * product.variants[1].options.length + j;
                            if (optionInfoIndex < product.optionInfos.length) {
                              productPrice =
                                  product.optionInfos[optionInfoIndex].price;
                            }
                          }

                          // Tạo OrderItem mới
                          orderItems.add(OrderItem(
                            productId: cartItem.productId,
                            quantity: cartItem.quantity,
                            price: productPrice,
                            productName: product.name,
                            productImage: (product.hasVariantImages &&
                                    product.variants.isNotEmpty)
                                ? (product
                                        .variants[0]
                                        .options[product.variants[0].options
                                            .indexWhere((option) =>
                                                option.id ==
                                                cartItem.optionId1)]
                                        .imageUrl ??
                                    product.imageUrl[0])
                                : product.imageUrl[0],
                            createdAt: now,
                            productVariation: cartItem.optionId1 != null &&
                                    cartItem.optionId2 != null
                                ? '${product.variants.firstWhere((variant) => variant.id == cartItem.variantId1).options.firstWhere((option) => option.id == cartItem.optionId1).name}, ${product.variants.firstWhere((variant) => variant.id == cartItem.variantId2).options.firstWhere((option) => option.id == cartItem.optionId2).name}'
                                : cartItem.optionId1 != null
                                    ? product.variants
                                        .firstWhere((variant) =>
                                            variant.id == cartItem.variantId1)
                                        .options
                                        .firstWhere((option) =>
                                            option.id == cartItem.optionId1)
                                        .name
                                    : cartItem.optionId2 != null
                                        ? product.variants
                                            .firstWhere((variant) =>
                                                variant.id ==
                                                cartItem.variantId2)
                                            .options
                                            .firstWhere((option) =>
                                                option.id == cartItem.optionId2)
                                            .name
                                        : null,
                            productDescription: product.description,
                            productCategory: product.category,
                            productSubCategory:
                                '', // Không có trường này trong model Product
                            productBrand:
                                '', // Không có trường này trong model Product
                          ));
                        }
                      }

                      // Tạo đơn hàng mới với danh sách OrderItem
                      orders.add(Order(
                        id: '', // ID sẽ được Firestore tự động tạo
                        item: orderItems,
                        shopId: shopId,
                        userId: authState.user.uid,
                        createdAt: now,
                        receiveAdress: receiverAddress,
                        totalProductPrice: totalProductPrice,
                        totalShipFee: totalShipPrice,
                        totalPrice: totalProductPrice + totalShipPrice,
                        estimatedDeliveryDate: estimatedDeliveryDate,
                        shipMethod: shipMethod[shopId]!,
                      ));

                      // Xóa sản phẩm khỏi giỏ hàng
                      final updatedItems =
                          Map<String, CartItem>.from(cartShop.items);
                      for (var itemId in listItemId) {
                        updatedItems.remove(itemId);
                      }
                      if (updatedItems.isEmpty) {
                        // Nếu không còn sản phẩm nào, xóa shop khỏi giỏ hàng
                        final updatedShops = List<CartShop>.from(cart.shops);
                        updatedShops
                            .removeWhere((shop) => shop.shopId == shopId);

                        cart = cart.copyWith(shops: updatedShops);
                      } else {
                        // Cập nhật lại shop với các sản phẩm còn lại
                        final updatedShop =
                            cartShop.copyWith(items: updatedItems);
                        final updatedShops = List<CartShop>.from(cart.shops);
                        final shopIndex = updatedShops
                            .indexWhere((shop) => shop.shopId == shopId);
                        if (shopIndex != -1) {
                          updatedShops[shopIndex] = updatedShop;
                        }
                        cart = cart.copyWith(shops: updatedShops);
                      }

                      _handleOrderCreated(cart, orders);
                    }
                  }
                }
              },
              child: Container(
                height: 45,
                width: 110,
                decoration: BoxDecoration(
                    color: Colors.brown,
                    borderRadius: BorderRadius.circular(8)),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Mua hàng",
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

  void _updateShippingMethod(String shopId, ShippingMethod newMethod) {
    setState(() {
      shipMethod[shopId] = newMethod;
      // Tính toán lại phí vận chuyển
      totalShipPrice = calculateTotalShippingFee();
    });
  }

  void _handleOrderCreated(Cart newCart, List<Order> orders) {
    setState(() {
      _completedOrders++;
    });

    // Chỉ chuyển hướng khi tất cả các đơn hàng đã được tạo
    if (_completedOrders == listShopId.length) {
      context.read<CartBloc>().add(UpdateCartEvent(newCart));
      context.read<OrderBloc>().add(CreateOrder(orders));
      Navigator.of(context).pushReplacementNamed(OrderSuccessScreen.routeName);
    }
  }
}
