import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:luanvan/blocs/cart/cart_bloc.dart';
import 'package:luanvan/blocs/cart/cart_state.dart';
import 'package:luanvan/blocs/list_shop/list_shop_bloc.dart';
import 'package:luanvan/blocs/list_shop/list_shop_state.dart';
import 'package:luanvan/blocs/product_in_cart/product_cart_bloc.dart';
import 'package:luanvan/blocs/product_in_cart/product_cart_state.dart';
import 'package:luanvan/models/cart.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/models/shipping_calculator.dart';
import 'package:luanvan/models/shipping_method.dart';
import 'package:luanvan/ui/checkout/choice_shipmethod_for_shop_screen.dart';
import 'package:luanvan/ui/checkout/product_checkout_screen.dart';

class ShopCheckoutItem extends StatefulWidget {
  final String shopId;
  final Cart cart;
  final List<String> listItemId;
  Map<String, List<String>> productCheckOut = {};
  ShippingMethod shipMethod;
  List<ShippingMethod> shipMethods = [];
  double totalWeight = 0.0;
  final Function(String, ShippingMethod) onShippingMethodChanged;

  ShopCheckoutItem({
    required this.shopId,
    required this.cart,
    required this.listItemId,
    required this.productCheckOut,
    required this.shipMethod,
    required this.shipMethods,
    required this.onShippingMethodChanged,
    required this.totalWeight,
  });

  @override
  State<ShopCheckoutItem> createState() => _ShopCheckoutItemState();
}

class _ShopCheckoutItemState extends State<ShopCheckoutItem> {
  late ShippingMethod _selectedShipMethod;

  @override
  void initState() {
    super.initState();
    _selectedShipMethod = widget.shipMethod;
  }

  String formatPrice(double price) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }

  double calculateMaxWeight(List<Product> products) {
    double calculatedTotal = 0.0;
    final cartShop = widget.cart.getShop(widget.shopId);
    for (var itemId in widget.listItemId) {
      final item = cartShop!.items[itemId];
      if (item == null) continue;
      final product = products.firstWhere(
        (p) => p.id == item.productId,
      );

      if (product.id.isNotEmpty) {
        if (product.variants.isEmpty &&
            (product.shippingMethods.any(
              (element) => (element.isEnabled &&
                  element.name == _selectedShipMethod.name),
            ))) {
          calculatedTotal += product.weight! * item.quantity;
        } else if (product.variants.length == 1) {
          int i = product.variants[0].options
              .indexWhere((element) => element.id == item.optionId1);
          if (i == -1) i = 0;

          calculatedTotal += product.optionInfos[i].weight! * item.quantity;
        } else if (product.variants.length > 1) {
          int i = product.variants[0].options
              .indexWhere((opt) => opt.id == item.optionId1);
          int j = product.variants[1].options
              .indexWhere((opt) => opt.id == item.optionId2);
          if (i == -1) i = 0;
          if (j == -1) j = 0;
          calculatedTotal += product
                  .optionInfos[i * product.variants[1].options.length + j]
                  .weight! *
              item.quantity;
        }
      }
    }
    return calculatedTotal;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      buildWhen: (previous, current) {
        if (previous is CartLoaded && current is CartLoaded) {
          final prevShop = previous.cart.getShop(widget.shopId);
          final currShop = current.cart.getShop(widget.shopId);
          return prevShop != currShop;
        }
        return true;
      },
      builder: (context, cartState) {
        if (cartState is CartLoaded) {
          final cartShop = cartState.cart.getShop(widget.shopId);
          if (cartShop == null) return const SizedBox.shrink();

          final shopIndex =
              widget.cart.shops.indexWhere((s) => s.shopId == widget.shopId);
          if (shopIndex == -1) {
            return const SizedBox
                .shrink(); // Tránh lỗi nếu shopIndex không hợp lệ
          }

          return BlocBuilder<ListShopBloc, ListShopState>(
            builder: (context, listShopState) {
              if (listShopState is ListShopLoading) {
                return _buildShopSkeleton();
              } else if (listShopState is ListShopLoaded) {
                final shop = listShopState.shops.firstWhere(
                  (element) => element.shopId == widget.shopId,
                );
                if (shop == null) {
                  return const SizedBox.shrink();
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.only(
                      top: 10, left: 10, right: 10, bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                        child: Text(
                          shop.name,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 0.8,
                        color: Colors.grey[200],
                      ),
                      BlocBuilder<ProductCartBloc, ProductCartState>(
                        builder: (context, productCartState) {
                          if (productCartState is ProductCartListLoaded) {
                            if (cartShop.items.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            List<String> productIdChecked = [];
                            widget.listItemId.forEach(
                              (element) => productIdChecked
                                  .add(cartShop.items[element]!.productId),
                            );
                            List<Product> productChecked = [];
                            productCartState.products.forEach(
                              (element) {
                                if (productIdChecked.contains(element.id)) {
                                  productChecked.add(element);
                                }
                              },
                            );
                            double maxWeight =
                                calculateMaxWeight(productCartState.products);
                            DateTime now = DateTime.now();
                            int estimatedDays =
                                _selectedShipMethod.estimatedDeliveryDays;
                            DateTime estimatedDate =
                                now.add(Duration(days: estimatedDays));
                            double totalPriceShop = 0.0;
                            widget.listItemId.forEach((element) {
                              final item = widget.cart
                                  .getShop(widget.shopId)!
                                  .items[element];
                              final product = productChecked.firstWhere(
                                (p) => p.id == item!.productId,
                              );

                              if (product.id.isNotEmpty &&
                                  (product.shippingMethods.any(
                                    (element) => (element.isEnabled &&
                                        element.name ==
                                            _selectedShipMethod.name),
                                  ))) {
                                if (product.variants.isEmpty) {
                                  totalPriceShop +=
                                      product.price! * item!.quantity;
                                } else if (product.variants.length == 1) {
                                  int i = product.variants[0].options
                                      .indexWhere((element) =>
                                          element.id == item!.optionId1);
                                  if (i == -1) i = 0;
                                  totalPriceShop +=
                                      product.optionInfos[i].price *
                                          item!.quantity;
                                } else if (product.variants.length > 1) {
                                  int i = product.variants[0].options
                                      .indexWhere(
                                          (opt) => opt.id == item!.optionId1);
                                  int j = product.variants[1].options
                                      .indexWhere(
                                          (opt) => opt.id == item!.optionId2);
                                  if (i == -1) i = 0;
                                  if (j == -1) j = 0;
                                  totalPriceShop += (product
                                          .optionInfos[i *
                                                  product.variants[1].options
                                                      .length +
                                              j]
                                          .price *
                                      item!.quantity);
                                }
                              }
                            });

                            return Column(
                              children: [
                                ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: widget.listItemId.length,
                                  padding: const EdgeInsets.all(10),
                                  itemBuilder: (context, productIndex) {
                                    final itemId =
                                        widget.listItemId[productIndex];
                                    final item = cartShop.items[itemId]!;

                                    return ProductCheckoutWidget(
                                      shopId: widget.shopId,
                                      itemId: itemId,
                                      item: item,
                                      productCartState: productCartState,
                                      shipMethod: _selectedShipMethod,
                                    );
                                  },
                                ),
                                Container(
                                  width: double.infinity,
                                  height: 0.8,
                                  color: Colors.grey[200],
                                ),
                                Container(
                                  width: double.infinity,
                                  height: 0.8,
                                  color: Colors.grey[200],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text("Phương thức vận chuyển",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500)),
                                          GestureDetector(
                                            onTap: () async {
                                              final result =
                                                  await Navigator.pushNamed(
                                                      context,
                                                      ChoiceShipmethodForShopScreen
                                                          .routeName,
                                                      arguments: {
                                                    'shopId': widget.shopId,
                                                    'shipMethod':
                                                        widget.shipMethods,
                                                    'selectedMethod':
                                                        _selectedShipMethod,
                                                    'totalWeight':
                                                        widget.totalWeight
                                                  });
                                              if (result != null &&
                                                  result is ShippingMethod) {
                                                setState(() {
                                                  _selectedShipMethod =
                                                      result as ShippingMethod;
                                                });
                                                widget.onShippingMethodChanged(
                                                    widget.shopId,
                                                    _selectedShipMethod);
                                              }
                                            },
                                            child: const Row(
                                              children: [
                                                Text("Xem tất cả"),
                                                SizedBox(width: 5),
                                                Icon(Icons.arrow_forward_ios,
                                                    size: 14),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context,
                                              ChoiceShipmethodForShopScreen
                                                  .routeName,
                                              arguments: {
                                                'shopId': widget.shopId,
                                                'shipMethod':
                                                    widget.shipMethods,
                                                'selectedMethod':
                                                    _selectedShipMethod,
                                                'totalWeight':
                                                    widget.totalWeight
                                              });
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                              top: 10, bottom: 10),
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                              color: Colors.green[100]!
                                                  .withOpacity(0.5),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(_selectedShipMethod.name,
                                                      style: TextStyle(
                                                          fontSize: 13)),
                                                  Row(
                                                    children: [
                                                      Text(
                                                          "đ${ShippingCalculator.calculateShippingCost(methodName: _selectedShipMethod.name, weight: widget.totalWeight, includeDistanceFactor: false)}",
                                                          style: TextStyle(
                                                              fontSize: 13),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                  "Nhận hàng từ ${DateTime.now().day} tháng ${DateTime.now().month} - ${estimatedDate.day} tháng ${estimatedDate.month}",
                                                  style:
                                                      TextStyle(fontSize: 13),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  height: 0.8,
                                  color: Colors.grey[200],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  height: 40,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          "Tổng số tiền (${widget.listItemId.length} sản phẩm)",
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500)),
                                      Row(
                                        children: [
                                          Text(
                                              "đ${formatPrice(totalPriceShop + ShippingCalculator.calculateShippingCost(methodName: _selectedShipMethod.name, weight: maxWeight, includeDistanceFactor: false))}",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          } else if (productCartState is ProductCartError) {
                            return Text('Error: ${productCartState.message}');
                          }
                          return const Center(
                              child: CircularProgressIndicator());
                        },
                      ),
                    ],
                  ),
                );
              } else if (listShopState is ListShopError) {
                return Text('Error: ${listShopState.message}');
              }
              return _buildShopSkeleton();
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
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
}
