import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/cart/cart_bloc.dart';
import 'package:luanvan/blocs/cart/cart_state.dart';
import 'package:luanvan/blocs/list_shop/list_shop_bloc.dart';
import 'package:luanvan/blocs/list_shop/list_shop_state.dart';
import 'package:luanvan/blocs/product_in_cart/product_cart_bloc.dart';
import 'package:luanvan/blocs/product_in_cart/product_cart_state.dart';
import 'package:luanvan/models/cart.dart';
import 'package:luanvan/ui/cart/product_item.dart';

class ShopItemWidget extends StatelessWidget {
  final String shopId;
  final Cart cart;
  final List<bool> checkedShop;
  final Map<String, List<bool>> checkedProduct;
  final Map<String, TextEditingController> quantityControllers;
  final double maxSwipe;
  final Function(List<bool>) onCheckedShopChanged;
  final Function(Map<String, List<bool>>) onCheckedProductChanged;
  final Function(String, String) onDeleteProduct;
  final Function(String) onDeleteShop;
  final Function(String, String, int) onUpdateQuantity;
  final Future<bool> Function() onShowConfirmDelete;

  const ShopItemWidget({
    required this.shopId,
    required this.cart,
    required this.checkedShop,
    required this.checkedProduct,
    required this.quantityControllers,
    required this.maxSwipe,
    required this.onDeleteProduct,
    required this.onDeleteShop,
    required this.onUpdateQuantity,
    required this.onShowConfirmDelete,
    required this.onCheckedShopChanged,
    required this.onCheckedProductChanged,
  });

  void _updateCheckedShop(List<bool> newCheckedShop) {
    onCheckedShopChanged(newCheckedShop);
  }

  void _updateCheckedProduct(Map<String, List<bool>> newCheckedProduct) {
    onCheckedProductChanged(newCheckedProduct);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      buildWhen: (previous, current) {
        if (previous is CartLoaded && current is CartLoaded) {
          final prevShop = previous.cart.getShop(shopId);
          final currShop = current.cart.getShop(shopId);
          return prevShop != currShop;
        }
        return true;
      },
      builder: (context, cartState) {
        if (cartState is CartLoaded) {
          final cartShop = cartState.cart.getShop(shopId);
          if (cartShop == null) return const SizedBox.shrink();

          final shopIndex = cart.shops.indexWhere((s) => s.shopId == shopId);
          if (shopIndex == -1 || shopIndex >= checkedShop.length) {
            return const SizedBox
                .shrink(); // Tránh lỗi nếu shopIndex không hợp lệ
          }

          return BlocBuilder<ListShopBloc, ListShopState>(
            builder: (context, listShopState) {
              if (listShopState is ListShopLoading) {
                return _buildShopSkeleton();
              } else if (listShopState is ListShopLoaded) {
                final shop = listShopState.shops.firstWhere(
                  (element) => element.shopId == shopId,
                );
                if (shop == null) {
                  return const SizedBox
                      .shrink(); // Không hiển thị nếu shop không tồn tại
                }

                // Đảm bảo checkedProduct[shopId] được khởi tạo đúng
                final checkedItems = checkedProduct[shopId] ??
                    List.generate(cartShop.items.length, (index) => false);

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.only(
                      top: 10, left: 10, right: 10, bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            fillColor: WidgetStateProperty.resolveWith<Color>(
                                (states) {
                              if (states.contains(WidgetState.selected)) {
                                return Colors.brown;
                              }
                              return Colors.transparent;
                            }),
                            value: checkedShop[shopIndex],
                            onChanged: (bool? newValue) {
                              final newCheckedShop =
                                  List<bool>.from(checkedShop);
                              newCheckedShop[shopIndex] = newValue ?? false;
                              _updateCheckedShop(newCheckedShop);
                              final newCheckedProduct =
                                  Map<String, List<bool>>.from(checkedProduct);
                              newCheckedProduct[shopId] = List.filled(
                                  cartShop.items.length, newValue ?? false);
                              _updateCheckedProduct(newCheckedProduct);
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    shop.name,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(Icons.keyboard_arrow_right_outlined,
                                    color: Colors.grey[500]),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => onDeleteShop(shopId),
                            child: const Text(
                              "Sửa",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                      BlocBuilder<ProductCartBloc, ProductCartState>(
                        builder: (context, productCartState) {
                          if (productCartState is ProductCartListLoaded) {
                            if (cartShop.items.isEmpty) {
                              return const SizedBox
                                  .shrink(); // Không hiển thị nếu không có sản phẩm
                            }
                            return ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: cartShop.items.length,
                              padding: EdgeInsets.zero,
                              itemBuilder: (context, productIndex) {
                                final itemId =
                                    cartShop.items.keys.elementAt(productIndex);
                                final item = cartShop.items[itemId]!;
                                final controllerKey = '${shopId}_${itemId}';
                                final controller =
                                    quantityControllers[controllerKey] ??
                                        TextEditingController(
                                            text: item.quantity.toString());

                                return ProductItemWidget(
                                  shopId: shopId,
                                  itemId: itemId,
                                  item: item,
                                  controller: controller,
                                  checked: checkedItems[productIndex],
                                  maxSwipe: maxSwipe,
                                  productCartState: productCartState,
                                  onCheckChanged: (newValue) {
                                    final newCheckedProduct =
                                        Map<String, List<bool>>.from(
                                            checkedProduct);
                                    newCheckedProduct[shopId] ??= List.generate(
                                        cartShop.items.length,
                                        (index) => false);
                                    newCheckedProduct[shopId]![productIndex] =
                                        newValue ?? false;
                                    _updateCheckedProduct(newCheckedProduct);
                                    final allChecked =
                                        newCheckedProduct[shopId]!
                                            .every((checked) => checked);
                                    final newCheckedShop =
                                        List<bool>.from(checkedShop);
                                    newCheckedShop[shopIndex] = allChecked;
                                    _updateCheckedShop(newCheckedShop);
                                  },
                                  onDeleteProduct: onDeleteProduct,
                                  onUpdateQuantity: onUpdateQuantity,
                                  onShowConfirmDelete: onShowConfirmDelete,
                                );
                              },
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
    // Giữ nguyên hàm _buildShopSkeleton như mã gốc
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
