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
import 'package:luanvan/blocs/product/product_bloc.dart';
import 'package:luanvan/blocs/product/product_event.dart';
import 'package:luanvan/blocs/product/product_state.dart';
import 'package:luanvan/blocs/shop/shop_bloc.dart';
import 'package:luanvan/blocs/shop/shop_event.dart';
import 'package:luanvan/blocs/shop/shop_state.dart';
import 'package:luanvan/models/cart.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/models/shop.dart';
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
  List<Shop> listShop = [];
  List<Product> listProduct = [];
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        context.read<CartBloc>().add(FetchCartEventUserId(authState.user.uid));
      }
    });
  }

  @override
  void dispose() {
    quantityControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _updateQuantity(String shopId, String productId, int newQuantity) {
    if (newQuantity > 0) {
      context.read<CartBloc>().add(UpdateCartEvent(
            productId,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
          builder: (BuildContext context, AuthState authState) {
        if (authState is AuthLoading) return _buildLoading();
        if (authState is AuthAuthenticated) {
          return BlocBuilder<CartBloc, CartState>(
            builder: (context, cartState) {
              if (cartState is CartLoading) return _buildLoading();
              if (cartState is CartLoaded) {
                // Update lists when cart changes
                listShopId =
                    cartState.cart.shops.map((shop) => shop.shopId).toList();
                listProductId = cartState.cart.shops
                    .expand((shop) => shop.items.keys)
                    .toList();

                // Initialize quantity controllers if needed
                for (var shop in cartState.cart.shops) {
                  for (var item in shop.items.entries) {
                    final key = '${shop.shopId}_${item.key}';
                    if (!quantityControllers.containsKey(key)) {
                      quantityControllers[key] = TextEditingController(
                        text: item.value.quantity.toString(),
                      );
                    }
                  }
                }

                // Update checkedShop and checkedProduct sizes
                if (checkedShop.length != listShopId.length) {
                  checkedShop =
                      List.generate(listShopId.length, (index) => false);
                }
                for (var shopId in listShopId) {
                  final shop = cartState.cart.getShop(shopId);
                  if (shop != null) {
                    if (!checkedProduct.containsKey(shopId) ||
                        checkedProduct[shopId]!.length != shop.items.length) {
                      checkedProduct[shopId] = List.generate(
                        shop.items.length,
                        (index) => false,
                      );
                    }
                  }
                }

                // Initialize listProduct if empty
                if (listProduct.isEmpty) {
                  listProduct = cartState.cart.shops
                      .expand(
                          (shop) => shop.items.entries.map((entry) => Product(
                                id: entry.key,
                                name: '',
                                description: '',
                                price: 0,
                                imageUrl: [],
                                shopId: shop.shopId,
                                quantitySold: 0,
                                averageRating: 0,
                                variants: [],
                                shippingMethods: [],
                              )))
                      .toList();
                }

                return BlocBuilder<ProductBloc, ProductState>(
                  buildWhen: (previous, current) {
                    // Chỉ rebuild khi product được load và có trong listProductId
                    if (current is ProductLoaded) {
                      return listProductId.contains(current.product.id);
                    }
                    return false;
                  },
                  builder: (context, productState) {
                    if (productState is ProductLoaded) {
                      // Update listProduct when product data is loaded
                      final index = listProduct
                          .indexWhere((p) => p.id == productState.product.id);
                      if (index != -1) {
                        listProduct[index] = productState.product;
                      } else {
                        listProduct.add(productState.product);
                      }
                    }
                    return _buildCartScreen(context, cartState.cart);
                  },
                );
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
      }),
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
                  // Danh sách các shop trong giỏ hàng
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
                        context
                            .read<ShopBloc>()
                            .add(FetchShopEventByShopId(shopId));
                        final cartShop = cart.getShop(shopId);
                        if (cartShop == null) return const SizedBox.shrink();
                        return BlocBuilder<ShopBloc, ShopState>(
                            builder: (context, shopState) {
                          if (shopState is ShopError) {
                            return _buildError(shopState.message);
                          }
                          if (shopState is ShopLoaded) {
                            final shop = shopState.shop;
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
                                              newValue ?? false,
                                            );
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
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            )),
                                            Icon(
                                              Icons
                                                  .keyboard_arrow_right_outlined,
                                              color: Colors.grey[500],
                                            ),
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
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),

                                  // Hiển thị danh sách sản phẩm của 1 shop trong giỏ hàng
                                  ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: cartShop.items.length,
                                    padding: EdgeInsets.zero,
                                    itemBuilder: (context, productIndex) {
                                      final productId = cartShop.items.keys
                                          .elementAt(productIndex);
                                      final item = cartShop.items[productId]!;
                                      context.read<ProductBloc>().add(
                                          FetchProductEventByProductId(
                                              productId));

                                      final controllerKey =
                                          '${shopId}_${productId}';
                                      final controller =
                                          quantityControllers[controllerKey]!;

                                      return BlocBuilder<ProductBloc,
                                              ProductState>(
                                          builder: (BuildContext context,
                                              ProductState productState) {
                                        final product =
                                            (productState is ProductLoaded)
                                                ? productState.product
                                                : null;

                                        return Stack(
                                          children: [
                                            Positioned.fill(
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: AnimatedContainer(
                                                  duration: const Duration(
                                                      milliseconds: 300),
                                                  alignment: Alignment.center,
                                                  height: 130,
                                                  width: _dragExtent,
                                                  color: Colors.brown,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      _deleteProduct(
                                                          shopId, productId);
                                                    },
                                                    child: const Text(
                                                      "Xóa",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onHorizontalDragUpdate:
                                                  (details) {
                                                setState(() {
                                                  if (details.primaryDelta! <
                                                      0) {
                                                    _dragExtent = max(
                                                        0,
                                                        min(
                                                            _dragExtent -
                                                                details
                                                                    .primaryDelta!,
                                                            _maxSwipe));
                                                  }
                                                  if (details.primaryDelta! >
                                                      0) {
                                                    _dragExtent = (_dragExtent -
                                                            details
                                                                .primaryDelta!)
                                                        .clamp(0, _maxSwipe);
                                                  }
                                                });
                                              },
                                              onHorizontalDragEnd: (details) {
                                                setState(() {
                                                  _dragExtent = (_dragExtent >
                                                          _maxSwipe / 2)
                                                      ? _maxSwipe
                                                      : 0;
                                                });
                                              },
                                              child: AnimatedContainer(
                                                transform:
                                                    Matrix4.translationValues(
                                                        -_dragExtent, 0, 0),
                                                padding: const EdgeInsets.only(
                                                    bottom: 20),
                                                duration: const Duration(
                                                    milliseconds: 300),
                                                curve: Curves.linear,
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Checkbox(
                                                          fillColor:
                                                              WidgetStateProperty
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
                                                          onChanged:
                                                              (bool? newValue) {
                                                            setState(() {
                                                              checkedProduct[
                                                                          shopId]![
                                                                      productIndex] =
                                                                  newValue ??
                                                                      false;
                                                              // Update shop checkbox based on all products
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
                                                                  width: 0.6)),
                                                          child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              child:
                                                                  Image.network(
                                                                width: 110,
                                                                height: 110,
                                                                fit: BoxFit
                                                                    .cover,
                                                                (product!.hasVariantImages &&
                                                                        product
                                                                            .variants
                                                                            .isNotEmpty)
                                                                    ? product
                                                                            .variants[
                                                                                0]
                                                                            .options[product.variants[0].options.indexWhere((option) =>
                                                                                option.id ==
                                                                                item
                                                                                    .optionId1)]
                                                                            .imageUrl ??
                                                                        product.imageUrl[
                                                                            0]
                                                                    : product
                                                                        .imageUrl[0],
                                                              )
                                                              // : Container(
                                                              //     width:
                                                              //         110,
                                                              //     height:
                                                              //         110,
                                                              //     color:
                                                              //         Colors.grey[300],
                                                              //     child:
                                                              //         const Icon(
                                                              //       Icons.image_not_supported,
                                                              //       color:
                                                              //           Colors.grey,
                                                              //     ),
                                                              //   );

                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            product.name
                                                                    .isNotEmpty
                                                                ? product.name
                                                                : 'Sản phẩm không tên',
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                          const SizedBox(
                                                              height: 5),
                                                          IntrinsicWidth(
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          5),
                                                              height: 30,
                                                              decoration: BoxDecoration(
                                                                  color: Colors
                                                                          .grey[
                                                                      200],
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5)),
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: Text(
                                                                      item.variantId1 ??
                                                                          '',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          color: Colors
                                                                              .black,
                                                                          fontWeight:
                                                                              FontWeight.w500),
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    ', ${item.optionId1 ?? ''}',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.w500),
                                                                  ),
                                                                  Icon(Icons
                                                                      .keyboard_arrow_down_outlined)
                                                                ],
                                                              ),
                                                            ),
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
                                                                    size: 17,
                                                                  ),
                                                                  Text(
                                                                    "${product.price}",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color: Colors
                                                                            .red),
                                                                  ),
                                                                ],
                                                              ),
                                                              Container(
                                                                height: 20,
                                                                width: 60,
                                                                decoration: BoxDecoration(
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .grey,
                                                                        width:
                                                                            1)),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          final newQuantity =
                                                                              int.tryParse(controller.text) ?? 1;
                                                                          if (newQuantity >
                                                                              1) {
                                                                            _updateQuantity(
                                                                                shopId,
                                                                                productId,
                                                                                newQuantity - 1);
                                                                            controller.text =
                                                                                (newQuantity - 1).toString();
                                                                          }
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              double.infinity,
                                                                          decoration:
                                                                              const BoxDecoration(border: Border(right: BorderSide(color: Colors.grey, width: 1))),
                                                                          child:
                                                                              Icon(
                                                                            FontAwesomeIcons.minus,
                                                                            color:
                                                                                Colors.grey[700],
                                                                            size:
                                                                                13,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              )
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          }
                          return _buildShopSkeleton();
                        });
                      }),
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
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                padding: const EdgeInsets.only(
                    top: 30, left: 10, right: 10, bottom: 10),
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeInOut,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        child: GestureDetector(
                      onTap: () {},
                      child: SizedBox(
                        height: 40,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Giỏ hàng",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              " (${cart.totalItems})",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            )
                          ],
                        ),
                      ),
                    )),
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
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
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
                    )
                  ],
                ),
              )),

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
                                final shop =
                                    context.read<CartBloc>().state is CartLoaded
                                        ? (context.read<CartBloc>().state
                                                as CartLoaded)
                                            .cart
                                            .getShop(shopId)
                                        : null;
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
                        )
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
                                  border: Border.all(
                                    width: 2,
                                    color: Colors.grey,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text("Lưu vào đã thích"),
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
                                const SizedBox(
                                  width: 10,
                                ),
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
                                            color: Colors.red,
                                          ),
                                          // maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                  editProduct
                      ? Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          height: 45,
                          width: 60,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(width: 2, color: Colors.brown),
                          ),
                          child: const Text(
                            "Xóa",
                            style: TextStyle(
                              color: Colors.brown,
                            ),
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
                                )
                              ],
                            ),
                          ),
                        ),
                  const SizedBox(
                    width: 10,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
