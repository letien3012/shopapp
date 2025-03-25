import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:luanvan/blocs/auth/auth_bloc.dart';
import 'package:luanvan/blocs/auth/auth_state.dart';
import 'package:luanvan/blocs/cart/cart_bloc.dart';
import 'package:luanvan/blocs/cart/cart_event.dart';
import 'package:luanvan/blocs/cart/cart_state.dart';
import 'package:luanvan/blocs/list_shop/list_shop_bloc.dart';
import 'package:luanvan/blocs/list_shop/list_shop_event.dart';
import 'package:luanvan/blocs/list_shop/list_shop_state.dart';
import 'package:luanvan/blocs/product_in_cart/product_cart_bloc.dart';
import 'package:luanvan/blocs/product_in_cart/product_cart_event.dart';
import 'package:luanvan/blocs/product_in_cart/product_cart_state.dart';
import 'package:luanvan/models/cart.dart';
import 'package:luanvan/services/shop_service.dart';
import 'package:luanvan/ui/checkout/check_out_screen.dart';

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
  bool checkAllProduct = false;
  bool editProduct = false;
  Map<String, TextEditingController> quantityControllers = {};

  double _dragExtent = 0;
  final double _maxSwipe = 80;

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
        cartState.cart.shops.forEach(
          (element) {},
        );
        listProductId = cartState.cart.shops
            .expand((shop) => shop.items.values)
            .map(
              (item) => item.productId,
            )
            .toList();
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

        // Khởi tạo quantity controllers
        for (var shop in cartState.cart.shops) {
          for (var item in shop.items.entries) {
            // print(item.value.quantity);
            final key = '${shop.shopId}_${item.key}';
            if (!quantityControllers.containsKey(key)) {
              quantityControllers[key] = TextEditingController(
                text: item.value.quantity.toString(),
              );
            }
          }
        }

        // Khởi tạo checkedShop và checkedProduct
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

  void _updateQuantity(String shopId, String itemId, int newQuantity) {
    final userId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.uid;
    if (newQuantity > 0) {
      context.read<CartBloc>().add(UpdateQuantityEvent(
            userId,
            itemId,
            newQuantity,
            shopId,
          ));
    }
  }

  void _deleteProduct(String shopId, String productId) {
    context.read<CartBloc>().add(DeleteCartProductEvent(
          productId,
          shopId,
        ));
  }

  void _deleteShop(String shopId) {
    context.read<CartBloc>().add(DeleteCartShopEvent(
          shopId,
        ));
  }

  double _calculateFontSize(String text) {
    int length = text.length;
    if (length <= 1) return 13;
    if (length == 2) return 12;
    if (length == 3) return 10;
    return 8; // Giới hạn nhỏ nhất
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthLoading) return _buildLoading();
          if (authState is AuthAuthenticated) {
            return BlocBuilder<CartBloc, CartState>(
              buildWhen: (previous, current) {
                return previous is CartLoading && current is CartLoaded;
              },
              builder: (context, cartState) {
                if (cartState is CartLoading) return _buildLoading();
                if (cartState is CartLoaded) {
                  // listShopId =
                  //     cartState.cart.shops.map((shop) => shop.shopId).toList();
                  // listProductId = cartState.cart.shops
                  //     .expand((shop) => shop.items.keys)
                  //     .toList();
                  // if (listProductId.isNotEmpty) {
                  //   context
                  //       .read<ProductBloc>()
                  //       .add(FetchMultipleProductsEvent(listProductId));
                  // }

                  // // Khởi tạo quantity controllers
                  // for (var shop in cartState.cart.shops) {
                  //   for (var item in shop.items.entries) {
                  //     print(item.value.quantity);
                  //     final key = '${shop.shopId}_${item.key}';
                  //     if (!quantityControllers.containsKey(key)) {
                  //       quantityControllers[key] = TextEditingController(
                  //         text: item.value.quantity.toString(),
                  //       );
                  //     }
                  //   }
                  // }

                  // // Khởi tạo checkedShop và checkedProduct
                  // if (checkedShop.length != listShopId.length) {
                  //   checkedShop =
                  //       List.generate(listShopId.length, (index) => false);
                  // }
                  // for (var shopId in listShopId) {
                  //   final shop = cartState.cart.getShop(shopId);
                  //   if (shop != null) {
                  //     if (!checkedProduct.containsKey(shopId) ||
                  //         checkedProduct[shopId]!.length != shop.items.length) {
                  //       checkedProduct[shopId] =
                  //           List.generate(shop.items.length, (index) => false);
                  //     }
                  //   }
                  // }
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

  // Skeleton cho shop khi chưa tải xong
  Widget _buildShopSkeleton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 150,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Spacer(),
              Container(
                width: 40,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 2,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 150,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            width: 100,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 80,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              Container(
                                width: 60,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCartScreen(BuildContext context, Cart cart) {
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
                      final cartShop = cart.getShop(shopId);
                      if (cartShop == null) return const SizedBox.shrink();
                      return BlocBuilder<ListShopBloc, ListShopState>(
                        builder: (context, listShopState) {
                          if (listShopState is ListShopError) {
                            return _buildError(listShopState.message);
                          }
                          if (listShopState is ListShopLoaded) {
                            final shop = listShopState.shops.firstWhere(
                              (element) => element.shopId == shopId,
                            );

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.only(
                                  top: 10, left: 10, right: 10, bottom: 20),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Checkbox(
                                        fillColor: WidgetStateProperty
                                            .resolveWith<Color>((states) {
                                          if (states
                                              .contains(WidgetState.selected)) {
                                            return Colors.brown;
                                          }
                                          return Colors.transparent;
                                        }),
                                        value: checkedShop[index],
                                        onChanged: (bool? newValue) {
                                          setState(() {
                                            checkedShop[index] =
                                                newValue ?? false;
                                            checkedProduct[shopId] =
                                                List.filled(
                                                    cartShop.items.length,
                                                    newValue ?? false);
                                          });
                                        },
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                      ),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                shop.name,
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Icon(
                                                Icons
                                                    .keyboard_arrow_right_outlined,
                                                color: Colors.grey[500]),
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          _deleteShop(shopId);
                                        },
                                        child: const Text(
                                          "Sửa",
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                                  BlocBuilder<ProductCartBloc,
                                      ProductCartState>(
                                    builder: (context, productCartState) {
                                      if (productCartState
                                          is ProductCartLoading) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      } else if (productCartState
                                          is ProductCartListLoaded) {
                                        return ListView.builder(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: cartShop.items.length,
                                          padding: EdgeInsets.zero,
                                          itemBuilder: (context, productIndex) {
                                            final itemId = cartShop.items.keys
                                                .elementAt(productIndex);
                                            final productId = cartShop
                                                .items[itemId]!.productId;
                                            final item =
                                                cartShop.items[itemId]!;
                                            final controllerKey =
                                                '${shopId}_${itemId}';
                                            final controller =
                                                quantityControllers[
                                                    controllerKey]!;
                                            final product = productCartState
                                                .products
                                                .firstWhere(
                                              (element) =>
                                                  element.id == productId,
                                            );
                                            String productPrice = '';
                                            if (product.variants.isEmpty) {
                                              productPrice =
                                                  product.price.toString();
                                            } else {
                                              if (product.variants.length > 1) {
                                                int i = product
                                                    .variants[0].options
                                                    .indexWhere(
                                                  (element) =>
                                                      element.id ==
                                                      item.optionId1,
                                                );
                                                int j = product
                                                    .variants[1].options
                                                    .indexWhere(
                                                        (element) =>
                                                            element.id ==
                                                            item.optionId2,
                                                        0);
                                                if (i == -1) {
                                                  i = 0;
                                                }
                                                if (j == -1) {
                                                  j = 0;
                                                }
                                                productPrice = product
                                                    .optionInfos[i + j].price
                                                    .toString();
                                              }
                                            }
                                            //??
                                            // Product(
                                            //   id: productId,
                                            //   name: 'Loading...',
                                            //   description: '',
                                            //   price: 0,
                                            //   imageUrl: [],
                                            //   shopId: shopId,
                                            //   quantitySold: 0,
                                            //   averageRating: 0,
                                            //   variants: [],
                                            //   shippingMethods: [],
                                            // );
                                            return Stack(
                                              children: [
                                                Positioned.fill(
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: AnimatedContainer(
                                                      duration: const Duration(
                                                          milliseconds: 300),
                                                      alignment:
                                                          Alignment.center,
                                                      height: 130,
                                                      width: _dragExtent,
                                                      color: Colors.brown,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          _deleteProduct(shopId,
                                                              productId);
                                                        },
                                                        child: const Text(
                                                          "Xóa",
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onHorizontalDragUpdate:
                                                      (details) {
                                                    setState(() {
                                                      if (details
                                                              .primaryDelta! <
                                                          0) {
                                                        _dragExtent = max(
                                                            0,
                                                            min(
                                                                _dragExtent -
                                                                    details
                                                                        .primaryDelta!,
                                                                _maxSwipe));
                                                      }
                                                      if (details
                                                              .primaryDelta! >
                                                          0) {
                                                        _dragExtent = (_dragExtent -
                                                                details
                                                                    .primaryDelta!)
                                                            .clamp(
                                                                0, _maxSwipe);
                                                      }
                                                    });
                                                  },
                                                  onHorizontalDragEnd:
                                                      (details) {
                                                    setState(() {
                                                      _dragExtent =
                                                          (_dragExtent >
                                                                  _maxSwipe / 2)
                                                              ? _maxSwipe
                                                              : 0;
                                                    });
                                                  },
                                                  child: AnimatedContainer(
                                                    transform: Matrix4
                                                        .translationValues(
                                                            -_dragExtent, 0, 0),
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 20),
                                                    duration: const Duration(
                                                        milliseconds: 300),
                                                    curve: Curves.linear,
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Checkbox(
                                                              fillColor: WidgetStateProperty
                                                                  .resolveWith<
                                                                          Color>(
                                                                      (states) {
                                                                if (states.contains(
                                                                    WidgetState
                                                                        .selected)) {
                                                                  return Colors
                                                                      .brown;
                                                                }
                                                                return Colors
                                                                    .transparent;
                                                              }),
                                                              value: checkedProduct[
                                                                      shopId]![
                                                                  productIndex],
                                                              onChanged: (bool?
                                                                  newValue) {
                                                                setState(() {
                                                                  checkedProduct[
                                                                              shopId]![
                                                                          productIndex] =
                                                                      newValue ??
                                                                          false;
                                                                  checkedShop[
                                                                      index] = checkedProduct[
                                                                          shopId]!
                                                                      .every((checked) =>
                                                                          checked);
                                                                });
                                                              },
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              4)),
                                                            ),
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .grey,
                                                                      width:
                                                                          0.6)),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                child: Image
                                                                    .network(
                                                                  width: 110,
                                                                  height: 110,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  (product.hasVariantImages &&
                                                                          product
                                                                              .variants
                                                                              .isNotEmpty)
                                                                      ? (product.variants[0].options[product.variants[0].options.indexWhere((option) => option.id == item.optionId1)].imageUrl ??
                                                                          product.imageUrl[
                                                                              0])
                                                                      : product
                                                                          .imageUrl[0],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                            width: 10),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                product.name
                                                                        .isNotEmpty
                                                                    ? product
                                                                        .name
                                                                    : 'Sản phẩm không tên',
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              (product.optionInfos
                                                                          .length >
                                                                      1)
                                                                  ? IntrinsicWidth(
                                                                      child:
                                                                          Container(
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            horizontal:
                                                                                5),
                                                                        height:
                                                                            30,
                                                                        decoration: BoxDecoration(
                                                                            color:
                                                                                Colors.grey[200],
                                                                            borderRadius: BorderRadius.circular(5)),
                                                                        alignment:
                                                                            Alignment.center,
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Expanded(
                                                                              child: Text(
                                                                                (item.variantId1 != null)
                                                                                    ? product.variants
                                                                                        .firstWhere(
                                                                                          (variant) => variant.id == item.variantId1,
                                                                                        )
                                                                                        .options
                                                                                        .firstWhere((option) => option.id == item.optionId1)
                                                                                        .name
                                                                                    : '',
                                                                                style: const TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.w500),
                                                                                maxLines: 1,
                                                                                overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                            ),
                                                                            Text(
                                                                              (item.variantId2 != null)
                                                                                  ? ', ${product.variants.firstWhere(
                                                                                        (variant) => variant.id == item.variantId2,
                                                                                      ).options.firstWhere((option) => option.id == item.optionId2).name}'
                                                                                  : '',
                                                                              style: const TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.w500),
                                                                            ),
                                                                            const Icon(Icons.keyboard_arrow_down_outlined),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : SizedBox(
                                                                      height:
                                                                          30,
                                                                    ),
                                                              const SizedBox(
                                                                  height: 30),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      const Icon(
                                                                        FontAwesomeIcons
                                                                            .dongSign,
                                                                        color: Colors
                                                                            .red,
                                                                        size:
                                                                            17,
                                                                      ),
                                                                      Text(
                                                                        productPrice,
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            color: Colors.red),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Container(
                                                                    height: 20,
                                                                    decoration: BoxDecoration(
                                                                        border: Border.all(
                                                                            color:
                                                                                Colors.grey,
                                                                            width: 1)),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            final newQuantity =
                                                                                int.tryParse(controller.text) ?? 1;

                                                                            if (newQuantity >
                                                                                1) {
                                                                              _updateQuantity(shopId, productId, newQuantity - 1);
                                                                              controller.text = (newQuantity - 1).toString();
                                                                            }
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            height:
                                                                                double.infinity,
                                                                            width:
                                                                                19,
                                                                            alignment:
                                                                                Alignment.center,
                                                                            decoration:
                                                                                const BoxDecoration(border: Border(right: BorderSide(color: Colors.grey, width: 1))),
                                                                            child:
                                                                                Icon(
                                                                              FontAwesomeIcons.minus,
                                                                              color: Colors.grey[700],
                                                                              size: 13,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          alignment:
                                                                              Alignment.center,
                                                                          height:
                                                                              20,
                                                                          width:
                                                                              30,
                                                                          child:
                                                                              TextField(
                                                                            controller:
                                                                                controller,
                                                                            textAlignVertical:
                                                                                TextAlignVertical.center,
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            keyboardType:
                                                                                TextInputType.number,
                                                                            decoration:
                                                                                const InputDecoration(
                                                                              border: InputBorder.none,
                                                                              contentPadding: EdgeInsets.only(bottom: 13),
                                                                            ),
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 13,
                                                                              textBaseline: TextBaseline.alphabetic,
                                                                            ),
                                                                            onSubmitted:
                                                                                (value) {
                                                                              final newQuantity = int.tryParse(value) ?? 1;
                                                                              if (newQuantity > 0) {
                                                                                _updateQuantity(shopId, productId, newQuantity);
                                                                              } else {
                                                                                controller.text = '1';
                                                                                _updateQuantity(shopId, productId, 1);
                                                                              }
                                                                            },
                                                                          ),
                                                                        ),
                                                                        GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            final newQuantity =
                                                                                int.tryParse(controller.text) ?? 1;

                                                                            _updateQuantity(
                                                                                shopId,
                                                                                itemId,
                                                                                newQuantity + 1);
                                                                            controller.text =
                                                                                (newQuantity + 1).toString();
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            height:
                                                                                double.infinity,
                                                                            width:
                                                                                19,
                                                                            alignment:
                                                                                Alignment.center,
                                                                            decoration:
                                                                                const BoxDecoration(border: Border(left: BorderSide(color: Colors.grey, width: 1))),
                                                                            child:
                                                                                Icon(
                                                                              FontAwesomeIcons.plus,
                                                                              color: Colors.grey[700],
                                                                              size: 13,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      } else if (productCartState
                                          is ProductCartError) {
                                        return Text(
                                            'Error: ${productCartState.message}');
                                      }
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    },
                                  ),
                                ],
                              ),
                            );
                          }
                          return _buildShopSkeleton();
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // AppBar
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
                            Text(
                              " (${cart.totalItems})",
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
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
                          child: const Icon(
                            BoxIcons.bx_chat,
                            color: Colors.brown,
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Bottom AppBar
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
                        const Text(
                          "Tất cả",
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
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
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Tổng thanh toán ",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 13),
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          FontAwesomeIcons.dongSign,
                                          color: Colors.red,
                                          size: 15,
                                        ),
                                        Text(
                                          "500.000",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                  editProduct
                      ? Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          height: 45,
                          width: 60,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(width: 2, color: Colors.brown),
                          ),
                          child: const Text(
                            "Xóa",
                            style: TextStyle(color: Colors.brown),
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed(CheckOutScreen.routeName);
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
                                Text(
                                  "Mua hàng ",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.white),
                                ),
                                Text(
                                  "(0)",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.white),
                                ),
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
