import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/cart/cart_bloc.dart';
import 'package:luanvan/blocs/cart/cart_state.dart';
import 'package:luanvan/blocs/list_shop/list_shop_bloc.dart';
import 'package:luanvan/blocs/list_shop/list_shop_state.dart';
import 'package:luanvan/blocs/product_in_cart/product_cart_bloc.dart';
import 'package:luanvan/blocs/product_in_cart/product_cart_state.dart';
import 'package:luanvan/models/cart.dart';
import 'package:luanvan/models/cart_item.dart';
import 'package:luanvan/models/shop.dart';
import 'package:luanvan/ui/cart/product_item.dart';

class ShopItemWidget extends StatefulWidget {
  final String shopId;
  final Cart cart;
  final List<bool> checkedShop;
  final Function(List<bool>) onCheckedShopChanged;
  final Map<String, List<bool>> checkedProduct;
  final Function(Map<String, List<bool>>) onCheckedProductChanged;
  final Map<String, TextEditingController> quantityControllers;
  final double maxSwipe;
  final Function(String, String) onDeleteProduct;
  final Function(String) onDeleteShop;
  final Function(String, String, int) onUpdateQuantity;
  final Future<bool> Function() onShowConfirmDelete;
  final List<String>? availableItems;
  final Function(String, int, bool?)? onProductCheck;

  const ShopItemWidget({
    Key? key,
    required this.shopId,
    required this.cart,
    required this.checkedShop,
    required this.onCheckedShopChanged,
    required this.checkedProduct,
    required this.onCheckedProductChanged,
    required this.quantityControllers,
    required this.maxSwipe,
    required this.onDeleteProduct,
    required this.onDeleteShop,
    required this.onUpdateQuantity,
    required this.onShowConfirmDelete,
    this.availableItems,
    this.onProductCheck,
  }) : super(key: key);

  @override
  State<ShopItemWidget> createState() => _ShopItemWidgetState();
}

class _ShopItemWidgetState extends State<ShopItemWidget> {
  late int shopIndex;

  @override
  void initState() {
    super.initState();
    shopIndex =
        widget.cart.shops.indexWhere((shop) => shop.shopId == widget.shopId);
  }

  void _updateCheckedShop(List<bool> newCheckedShop) {
    final shop = widget.cart.getShop(widget.shopId);
    if (shop != null) {
      final productState = context.read<ProductCartBloc>().state;
      if (productState is ProductCartListLoaded) {
        List<bool> productChecks = [];
        shop.items.forEach((itemId, item) {
          final product =
              productState.products.firstWhere((p) => p.id == item.productId);
          bool isOutOfStock = _isProductOutOfStock(product, item);
          productChecks.add(isOutOfStock ? false : newCheckedShop[shopIndex]);
        });
        widget.checkedProduct[widget.shopId] = productChecks;
        widget.onCheckedProductChanged(widget.checkedProduct);
      }
    }
    widget.onCheckedShopChanged(newCheckedShop);
  }

  bool _isProductOutOfStock(dynamic product, CartItem item) {
    if (product.variants.isEmpty) {
      return (product.quantity ?? 0) == 0;
    } else if (product.variants.length == 1) {
      if (item.optionId1 != null) {
        int optionIndex = product.variants[0].options
            .indexWhere((opt) => opt.id == item.optionId1);
        if (optionIndex != -1 && optionIndex < product.optionInfos.length) {
          return product.optionInfos[optionIndex].stock == 0;
        }
      }
    } else if (product.variants.length > 1) {
      if (item.optionId1 != null && item.optionId2 != null) {
        int option1Index = product.variants[0].options
            .indexWhere((opt) => opt.id == item.optionId1);
        int option2Index = product.variants[1].options
            .indexWhere((opt) => opt.id == item.optionId2);
        if (option1Index != -1 && option2Index != -1) {
          int optionInfoIndex =
              (option1Index * product.variants[1].options.length + option2Index)
                  .toInt();
          if (optionInfoIndex < product.optionInfos.length) {
            return product.optionInfos[optionInfoIndex].stock == 0;
          }
        }
      }
    }
    return true;
  }

  void _updateCheckedProduct(Map<String, List<bool>> newCheckedProduct) {
    widget.onCheckedProductChanged(newCheckedProduct);
  }

  @override
  Widget build(BuildContext context) {
    final shop = widget.cart.getShop(widget.shopId);
    if (shop == null) return const SizedBox.shrink();

    // Filter items based on availableItems parameter
    final items = widget.availableItems != null
        ? Map.fromEntries(shop.items.entries
            .where((entry) => widget.availableItems!.contains(entry.key)))
        : shop.items;

    if (items.isEmpty) return const SizedBox.shrink();

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

          return BlocBuilder<ListShopBloc, ListShopState>(
            builder: (context, listShopState) {
              if (listShopState is ListShopLoading) {
                return _buildShopSkeleton();
              } else if (listShopState is ListShopLoaded) {
                Shop? shop;
                try {
                  shop = listShopState.shops.firstWhere(
                    (element) => element.shopId == widget.shopId,
                  );
                } catch (e) {
                  return const SizedBox
                      .shrink(); // Don't display if shop doesn't exist
                }
                if (shop == null) {
                  return const SizedBox
                      .shrink(); // Don't display if shop doesn't exist
                }

                // Đảm bảo checkedProduct[shopId] được khởi tạo đúng
                final checkedItems = widget.checkedProduct[widget.shopId] ??
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
                            value: widget.checkedShop[shopIndex],
                            onChanged: (bool? newValue) {
                              final newCheckedShop =
                                  List<bool>.from(widget.checkedShop);
                              newCheckedShop[shopIndex] = newValue ?? false;

                              // Cập nhật trạng thái checkbox của shop
                              _updateCheckedShop(newCheckedShop);

                              // Cập nhật trạng thái checkbox của từng sản phẩm
                              final newCheckedProduct =
                                  Map<String, List<bool>>.from(
                                      widget.checkedProduct);
                              List<bool> productChecks = [];

                              // Kiểm tra từng sản phẩm trong shop
                              final productState =
                                  context.read<ProductCartBloc>().state;
                              if (productState is ProductCartListLoaded) {
                                cartShop.items.forEach((itemId, item) {
                                  final product = productState.products
                                      .firstWhere(
                                          (p) => p.id == item.productId);
                                  bool isOutOfStock =
                                      _isProductOutOfStock(product, item);
                                  productChecks.add(
                                      isOutOfStock || product.isDeleted
                                          ? false
                                          : (newValue ?? false));
                                });

                                newCheckedProduct[widget.shopId] =
                                    productChecks;
                                _updateCheckedProduct(newCheckedProduct);
                              }
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
                        ],
                      ),
                      BlocBuilder<ProductCartBloc, ProductCartState>(
                        builder: (context, productCartState) {
                          if (productCartState is ProductCartListLoaded) {
                            if (cartShop.items.isEmpty) {
                              return const SizedBox
                                  .shrink(); // Không hiển thị nếu không có sản phẩm
                            }
                            final sortedEntries = items.entries.toList()
                              ..sort((a, b) => b.value.updatedAt
                                  .compareTo(a.value.updatedAt));
                            cartShop.items = Map<String, CartItem>.fromEntries(
                                sortedEntries);
                            return ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: cartShop.items.length,
                              padding: EdgeInsets.zero,
                              itemBuilder: (context, productIndex) {
                                final itemId =
                                    cartShop.items.keys.elementAt(productIndex);
                                final item = cartShop.items[itemId]!;

                                final controllerKey =
                                    '${widget.shopId}_${itemId}';
                                final controller =
                                    widget.quantityControllers[controllerKey] ??
                                        TextEditingController(
                                          text: item.quantity.toString(),
                                        );

                                return ProductItemWidget(
                                  shopId: widget.shopId,
                                  itemId: itemId,
                                  item: item,
                                  controller: controller,
                                  checked: checkedItems[productIndex],
                                  maxSwipe: widget.maxSwipe,
                                  productCartState: productCartState,
                                  onCheckChanged: (newValue) {
                                    final product = productCartState.products
                                        .firstWhere(
                                            (p) => p.id == item.productId);
                                    bool isOutOfStock =
                                        _isProductOutOfStock(product, item);
                                    // Nếu sản phẩm hết hàng, không cho phép chọn
                                    if (isOutOfStock || product.isDeleted) {
                                      newValue = false;
                                    }

                                    final newCheckedProduct =
                                        Map<String, List<bool>>.from(
                                            widget.checkedProduct);
                                    newCheckedProduct[widget.shopId] ??=
                                        List.generate(cartShop.items.length,
                                            (index) => false);
                                    newCheckedProduct[widget.shopId]![
                                        productIndex] = newValue ?? false;

                                    // Cập nhật trạng thái checkbox của sản phẩm
                                    _updateCheckedProduct(newCheckedProduct);

                                    // Kiểm tra xem tất cả sản phẩm còn hàng có được chọn không
                                    bool allInStockChecked = true;
                                    cartShop.items.forEach((itemId, item) {
                                      final product = productCartState.products
                                          .firstWhere(
                                              (p) => p.id == item.productId);
                                      bool isOutOfStock =
                                          _isProductOutOfStock(product, item);
                                      if (!isOutOfStock) {
                                        int index = cartShop.items.keys
                                            .toList()
                                            .indexOf(itemId);
                                        if (!(newCheckedProduct[widget.shopId]
                                                ?[index] ??
                                            false)) {
                                          allInStockChecked = false;
                                        }
                                      }
                                    });

                                    // Cập nhật trạng thái checkbox của shop
                                    final newCheckedShop =
                                        List<bool>.from(widget.checkedShop);
                                    newCheckedShop[shopIndex] =
                                        allInStockChecked;
                                    _updateCheckedShop(newCheckedShop);
                                  },
                                  onDeleteProduct: widget.onDeleteProduct,
                                  onUpdateQuantity: widget.onUpdateQuantity,
                                  onShowConfirmDelete:
                                      widget.onShowConfirmDelete,
                                  onProductCheck: widget.onProductCheck != null
                                      ? (shopId, _, value) =>
                                          widget.onProductCheck!(
                                              shopId, productIndex, value)
                                      : null,
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
