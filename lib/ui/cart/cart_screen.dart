import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:luanvan/blocs/auth/auth_bloc.dart';
import 'package:luanvan/blocs/auth/auth_state.dart';
import 'package:luanvan/blocs/cart/cart_bloc.dart';
import 'package:luanvan/blocs/cart/cart_event.dart';
import 'package:luanvan/blocs/cart/cart_state.dart';
import 'package:luanvan/blocs/list_shop/list_shop_bloc.dart';
import 'package:luanvan/blocs/list_shop/list_shop_event.dart';
import 'package:luanvan/blocs/product_in_cart/product_cart_bloc.dart';
import 'package:luanvan/blocs/product_in_cart/product_cart_event.dart';
import 'package:luanvan/blocs/product_in_cart/product_cart_state.dart';
import 'package:luanvan/models/cart.dart';
import 'package:luanvan/models/cart_item.dart';
import 'package:luanvan/models/cart_shop.dart';
import 'package:luanvan/ui/cart/shop_item.dart';
import 'package:luanvan/ui/checkout/check_out_screen.dart';
import 'package:luanvan/ui/helper/icon_helper.dart';
import 'package:luanvan/ui/widgets/alert_diablog.dart';
import 'package:luanvan/ui/widgets/confirm_diablog.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  static String routeName = "cart_screen";

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<String> listProductId = [];
  List<String> listShopId = [];
  List<bool> checkedShop = [];
  Map<String, List<bool>> checkedProduct = {};
  Map<String, List<String>> productCheckOut = {};
  bool checkAllProduct = false;
  bool editProduct = false;
  Map<String, TextEditingController> quantityControllers = {};
  final double _maxSwipe = 80;
  List<String> listItemId = [];

  Future<bool> _showConfirmDeleteProductDialog() async {
    final confirmed = await ConfirmDialog(
      title: "Bạn có chắc muốn bỏ sản phẩm này?",
      cancelText: "Không",
      confirmText: "ĐỒng ý",
    ).show(context);
    return confirmed;
  }

  Future<void> _showAlertDialog() async {
    await showAlertDialog(
      context,
      message: "Bạn chưa chọn sản phẩm nào để mua",
      iconPath: IconHelper.warning,
      duration: Duration(seconds: 1),
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(ResetCartEvent());
    context.read<ProductCartBloc>().add(ResetProductCartEvent());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        context.read<CartBloc>().add(FetchCartEventUserId(authState.user.uid));
      }
      final cartState = context.read<CartBloc>().state;

      if (cartState is CartLoaded) {
        listShopId = cartState.cart.shops.map((shop) => shop.shopId).toList();
        listProductId = cartState.cart.shops
            .expand((shop) => shop.items.values)
            .map((item) => item.productId)
            .toList();
        listItemId =
            cartState.cart.shops.expand((shop) => shop.items.keys).toList();

        if (listShopId.isNotEmpty) {
          context
              .read<ListShopBloc>()
              .add(FetchListShopEventByShopId(listShopId));
        }
        if (listProductId.isNotEmpty) {
          context
              .read<ProductCartBloc>()
              .add(FetchMultipleProductsEvent(listProductId));
        }

        for (var shop in cartState.cart.shops) {
          for (var item in shop.items.entries) {
            final key = '${shop.shopId}_${item.key}';
            if (!quantityControllers.containsKey(key)) {
              quantityControllers[key] =
                  TextEditingController(text: item.value.quantity.toString());
            }
          }
        }

        if (checkedShop.length != listShopId.length) {
          checkedShop = List.generate(listShopId.length, (index) => false);
        }
        for (var shopId in listShopId) {
          final shop = cartState.cart.getShop(shopId);
          if (shop != null) {
            if (!checkedProduct.containsKey(shopId) ||
                checkedProduct[shopId]!.length != shop.items.length) {
              checkedProduct[shopId] =
                  List.generate(shop.items.length, (index) => false);
            }
          }
        }
      }
    });
  }

  @override
  void dispose() {
    quantityControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  String formatPrice(double price) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }

  double _calculateTotalPrice(Cart cart) {
    double total = 0.0;

    for (int shopIndex = 0; shopIndex < listShopId.length; shopIndex++) {
      final shopId = listShopId[shopIndex];
      final shop = cart.getShop(shopId);
      if (shop != null) {
        final checkedProducts = checkedProduct[shopId] ?? [];
        for (int productIndex = 0;
            productIndex < shop.items.length;
            productIndex++) {
          if (checkedProducts.isNotEmpty && checkedProducts[productIndex]) {
            final item = shop.items.values.elementAt(productIndex);
            final product =
                (context.read<ProductCartBloc>().state as ProductCartListLoaded)
                    .products
                    .firstWhere((p) => p.id == item.productId);
            double productPrice = _getProductPrice(product, item);
            total += productPrice * item.quantity;
          }
        }
      }
    }
    return total;
  }

  double _getProductPrice(dynamic product, CartItem item) {
    if (product.variants.isEmpty) {
      return product.price!;
    } else if (product.variants.length > 1) {
      int i = product.variants[0].options
          .indexWhere((element) => element.id == item.optionId1);
      int j = product.variants[1].options
          .indexWhere((element) => element.id == item.optionId2);
      if (i == -1) i = 0;
      if (j == -1) j = 0;
      return product
          .optionInfos[i * product.variants[1].options.length + j].price;
    }
    return 0.0;
  }

  void _updateQuantity(String shopId, String itemId, int newQuantity) {
    final userId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.uid;
    if (newQuantity > 0) {
      context.read<CartBloc>().add(
            UpdateQuantityEvent(userId, itemId, newQuantity, shopId),
          );
    }
  }

  void _deleteProduct(String shopId, String itemId) {
    final userId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.uid;
    context
        .read<CartBloc>()
        .add(DeleteCartProductEvent(itemId, shopId, userId));
  }

  void _deleteShop(String shopId) {
    final userId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.uid;
    context.read<CartBloc>().add(DeleteCartShopEvent(shopId, userId));
  }

  void onCheckedShopChanged(List<bool> newCheckedShop) {
    setState(() {
      checkedShop = newCheckedShop;
    });
  }

  void onCheckedProductChanged(Map<String, List<bool>> newCheckedProduct) {
    setState(() {
      checkedProduct = newCheckedProduct;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthLoading) return _buildLoading();
          if (authState is AuthAuthenticated) {
            return BlocBuilder<CartBloc, CartState>(
              builder: (context, cartState) {
                if (cartState is CartLoading) return _buildLoading();
                if (cartState is CartLoaded) {
                  return _buildCartScreen(context, cartState.cart);
                } else if (cartState is CartError) {
                  return _buildError(cartState.message);
                }
                return _buildInitializing();
              },
            );
          } else if (authState is AuthError) {
            return _buildError(authState.message);
          }
          return _buildInitializing();
        },
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildError(String message) {
    return Center(child: Text('Error: $message'));
  }

  Widget _buildInitializing() {
    return const Center(child: Text('Đang khởi tạo'));
  }

  Widget _buildCartScreen(BuildContext context, Cart cart) {
    double totalPrice = _calculateTotalPrice(cart);
    int selectedItemsCount =
        checkedProduct.values.expand((e) => e).where((e) => e).length;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.only(
                  left: 10, right: 10, top: 90, bottom: 60),
              constraints:
                  BoxConstraints(minHeight: MediaQuery.of(context).size.height),
              child: Column(
                children: [
                  ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: cart.shops.length,
                    itemBuilder: (context, index) {
                      if (index >= listShopId.length) {
                        return const SizedBox.shrink();
                      }
                      final shopId = listShopId[index];

                      return ShopItemWidget(
                        shopId: shopId,
                        cart: cart,
                        checkedShop: checkedShop,
                        onCheckedShopChanged: onCheckedShopChanged,
                        checkedProduct: checkedProduct,
                        onCheckedProductChanged: onCheckedProductChanged,
                        quantityControllers: quantityControllers,
                        maxSwipe: _maxSwipe,
                        onDeleteProduct: _deleteProduct,
                        onDeleteShop: _deleteShop,
                        onUpdateQuantity: _updateQuantity,
                        onShowConfirmDelete: _showConfirmDeleteProductDialog,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: AnimatedContainer(
              height: 80,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(color: Colors.white),
              padding: const EdgeInsets.only(
                  top: 30, left: 10, right: 10, bottom: 10),
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeInOut,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      height: 40,
                      width: 40,
                      alignment: Alignment.center,
                      child: const Icon(Icons.arrow_back,
                          color: Colors.brown, size: 30),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {},
                      child: SizedBox(
                        height: 40,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "Giỏ hàng",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w500),
                            ),
                            BlocSelector<CartBloc, CartState, String>(
                              selector: (state) {
                                if (state is CartLoaded) {
                                  return state.cart.totalItems.toString();
                                }
                                return '0';
                              },
                              builder: (context, totalItems) {
                                return Text(
                                  " ($totalItems)",
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            editProduct = !editProduct;
                          });
                        },
                        child: Container(
                          height: 40,
                          width: 40,
                          alignment: Alignment.center,
                          child: const Text(
                            "Sửa",
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          height: 40,
                          width: 40,
                          alignment: Alignment.center,
                          child: const Icon(BoxIcons.bx_chat,
                              color: Colors.brown, size: 30),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              height: 60,
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Checkbox(
                          fillColor:
                              WidgetStateProperty.resolveWith<Color>((states) {
                            if (states.contains(WidgetState.selected)) {
                              return Colors.brown;
                            }
                            return Colors.transparent;
                          }),
                          value: checkAllProduct,
                          onChanged: (newValue) {
                            setState(() {
                              checkAllProduct = newValue ?? false;
                              checkedShop = List.filled(
                                  checkedShop.length, newValue ?? false);
                              for (var shopId in listShopId) {
                                final shop = cart.getShop(shopId);
                                if (shop != null) {
                                  checkedProduct[shopId] = List.filled(
                                      shop.items.length, newValue ?? false);
                                }
                              }
                            });
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                          visualDensity: VisualDensity.compact,
                        ),
                        const Text("Tất cả",
                            style:
                                TextStyle(color: Colors.black, fontSize: 16)),
                      ],
                    ),
                  ),
                  editProduct
                      ? Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: 130,
                                height: 45,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 2, color: Colors.grey),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text("Lưu vào đã thích"),
                              ),
                            ],
                          ),
                        )
                      : Expanded(
                          child: GestureDetector(
                            onTap: () {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Tổng thanh toán ",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 13),
                                    ),
                                    Text(
                                      "đ${formatPrice(totalPrice)}",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Color.fromARGB(255, 151, 14, 4)),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                  editProduct
                      ? GestureDetector(
                          onTap: () async {
                            if (await _showConfirmDeleteProductDialog()) {
                              List<String> shopsToDelete = [];
                              Map<String, List<String>> productsToDelete = {};
                              Cart newCart = cart;
                              for (int i = 0; i < checkedShop.length; i++) {
                                if (checkedShop[i]) {
                                  shopsToDelete.add(listShopId[i]);
                                }
                                String shopId = listShopId[i];
                                if (checkedProduct[shopId] != null) {
                                  for (int j = 0;
                                      j < checkedProduct[shopId]!.length;
                                      j++) {
                                    if (checkedProduct[shopId]![j]) {
                                      productsToDelete.putIfAbsent(
                                          shopId, () => []);
                                      productsToDelete[shopId]!
                                          .add(listItemId[j]);
                                    }
                                  }
                                }
                              }

                              for (String shopId in shopsToDelete) {
                                final updatedShops =
                                    List<CartShop>.from(cart.shops);
                                updatedShops.removeWhere(
                                    (shop) => shop.shopId == shopId);
                                newCart = newCart.copyWith(shops: updatedShops);
                              }

                              for (String shopId in productsToDelete.keys) {
                                if (!shopsToDelete.contains(shopId)) {
                                  for (String itemId
                                      in productsToDelete[shopId]!) {
                                    final shop = newCart.getShop(shopId);
                                    if (shop != null &&
                                        shop.items.containsKey(itemId)) {
                                      final updatedItems =
                                          Map<String, CartItem>.from(
                                              shop.items);
                                      updatedItems.remove(itemId);

                                      final updatedShop =
                                          shop.copyWith(items: updatedItems);
                                      final updatedShops =
                                          List<CartShop>.from(newCart.shops);
                                      final existingShopIndex =
                                          updatedShops.indexWhere(
                                              (shop) => shop.shopId == shopId);
                                      if (existingShopIndex != -1) {
                                        if (updatedItems.isEmpty) {
                                          updatedShops
                                              .removeAt(existingShopIndex);
                                        } else {
                                          updatedShops[existingShopIndex] =
                                              updatedShop;
                                        }
                                      }
                                      newCart =
                                          newCart.copyWith(shops: updatedShops);
                                    }
                                  }
                                }
                              }

                              context
                                  .read<CartBloc>()
                                  .add(UpdateCartEvent(newCart));
                              setState(() {
                                cart = newCart;
                                listShopId = newCart.shops
                                    .map((shop) => shop.shopId)
                                    .toList();
                                checkedShop = List.generate(
                                    listShopId.length, (index) => false);
                                checkedProduct = {
                                  for (var shopId in listShopId)
                                    shopId: List.generate(
                                        newCart.getShop(shopId)?.items.length ??
                                            0,
                                        (index) => false)
                                };
                                checkAllProduct = false;
                                editProduct = false;
                              });
                            } else {
                              setState(() {
                                editProduct = !editProduct;
                              });
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            height: 45,
                            width: 60,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(width: 2, color: Colors.brown),
                            ),
                            child: const Text("Xóa",
                                style: TextStyle(color: Colors.brown)),
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            if (selectedItemsCount > 0) {
                              productCheckOut = {};
                              for (var shopId in checkedProduct.keys) {
                                if (checkedProduct[shopId] != null) {
                                  for (int i = 0;
                                      i < checkedProduct[shopId]!.length;
                                      i++) {
                                    if (checkedProduct[shopId]![i]) {
                                      productCheckOut.putIfAbsent(
                                          shopId, () => []);
                                      String itemId = '';
                                      int j = 0;
                                      for (var key
                                          in cart.getShop(shopId)!.items.keys) {
                                        if (i == j) {
                                          itemId = key;
                                        }
                                        j++;
                                      }
                                      productCheckOut[shopId]!.add(itemId);
                                    }
                                  }
                                }
                              }

                              Navigator.of(context).pushNamed(
                                  CheckOutScreen.routeName,
                                  arguments: productCheckOut);
                            } else {
                              _showAlertDialog();
                            }
                          },
                          child: Container(
                            height: 45,
                            width: 110,
                            decoration: BoxDecoration(
                                color: Colors.brown,
                                borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Mua hàng ",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.white)),
                                Text("($selectedItemsCount)",
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                  const SizedBox(width: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
