import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:intl/intl.dart';
import 'package:luanvan/blocs/auth/auth_bloc.dart';
import 'package:luanvan/blocs/auth/auth_state.dart';
import 'package:luanvan/blocs/cart/cart_bloc.dart';
import 'package:luanvan/blocs/cart/cart_event.dart';
import 'package:luanvan/blocs/product/product_bloc.dart';
import 'package:luanvan/blocs/product/product_event.dart';
import 'package:luanvan/blocs/product/product_state.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/ui/widgets/alert_diablog.dart';

class AddToCartBottomSheet extends StatefulWidget {
  // final Product product;
  final String productId;
  final BuildContext parentContext;
  final String? optionId1;
  final String? optionId2;
  const AddToCartBottomSheet({
    Key? key,
    required this.productId,
    // required this.product,
    required this.parentContext,
    this.optionId1,
    this.optionId2,
  }) : super(key: key);

  @override
  _AddToCartBottomSheetState createState() => _AddToCartBottomSheetState();
}

class _AddToCartBottomSheetState extends State<AddToCartBottomSheet> {
  int _quantityAddToCart = 1;
  int selectedIndexVariant1 = -1;
  int selectedIndexVariant2 = -1;
  TextEditingController _quantityController = TextEditingController();
  final FocusNode _quantityAdd = FocusNode();
  double keyboardSize = 0;
  Product product = Product(
      id: '',
      name: '',
      quantitySold: 0,
      description: '',
      averageRating: 0,
      variants: [],
      shopId: '',
      shippingMethods: []);
  Future<void> _showAddToCartDialog() async {
    showAlertDialog(
      context,
      message: 'Thêm vào giỏ hàng thành công',
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        context
            .read<ProductBloc>()
            .add(FetchProductEventByProductId(widget.productId));
        await context.read<ProductBloc>().stream.firstWhere(
              (state) => state is ProductLoaded,
            );
        product =
            ((context.read<ProductBloc>().state) as ProductLoaded).product;
        if (widget.optionId1 != null) {
          selectedIndexVariant1 = product.variants[0].options.indexWhere(
            (element) => element.id == widget.optionId1,
          );
        }
        if (widget.optionId2 != null) {
          selectedIndexVariant2 = product.variants[1].options.indexWhere(
            (element) => element.id == widget.optionId2,
          );
        }
        _quantityController = TextEditingController(text: '1');
      },
    );
    _quantityAdd.addListener(
      () {
        if (_quantityAdd.hasFocus) {
          setState(() {
            keyboardSize = 225;
          });
        } else {
          setState(() {
            keyboardSize = 0;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  String formatPrice(double price) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return formatter.format(price.toInt());
  }

  int get maxStock {
    if (product.variants.isEmpty) {
      return product.quantity ?? 0;
    }

    if (product.variants.length == 1 && selectedIndexVariant1 != -1) {
      if (selectedIndexVariant1 >= product.optionInfos.length) {
        return product.quantity ?? 0;
      }
      return product.optionInfos[selectedIndexVariant1].stock;
    }

    if (product.variants.length > 1) {
      if (selectedIndexVariant1 != -1 && selectedIndexVariant2 != -1) {
        int optionInfoIndex =
            selectedIndexVariant1 * product.variants[1].options.length +
                selectedIndexVariant2;
        if (optionInfoIndex >= product.optionInfos.length) {
          return product.quantity ?? 0;
        }
        return product.optionInfos[optionInfoIndex].stock;
      } else if (selectedIndexVariant1 != -1) {
        // Khi đã chọn variant đầu tiên, lấy tổng số lượng kho của variant thứ 2
        int totalStock = 0;
        for (int i = 0; i < product.variants[1].options.length; i++) {
          int optionInfoIndex =
              selectedIndexVariant1 * product.variants[1].options.length + i;
          if (optionInfoIndex < product.optionInfos.length) {
            totalStock += product.optionInfos[optionInfoIndex].stock;
          }
        }
        return totalStock;
      }
    }

    return product.getTotalOptionStock();
  }

  void _updateQuantity(int newQuantity) {
    if (newQuantity > 0) {
      setState(() {
        _quantityAddToCart = newQuantity > maxStock ? maxStock : newQuantity;
        _quantityController.text = _quantityAddToCart.toString();
      });
    } else {
      setState(() {
        _quantityAddToCart = 1;
        _quantityController.text = '1';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(builder: (context, state) {
      if (state is ProductLoaded) {
        product = state.product;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with product image and price
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: product.imageUrl.isNotEmpty
                              ? Image.network(
                                  product.hasVariantImages &&
                                          selectedIndexVariant1 != -1 &&
                                          product
                                                  .variants[0]
                                                  .options[
                                                      selectedIndexVariant1]
                                                  .imageUrl !=
                                              null
                                      ? product
                                          .variants[0]
                                          .options[selectedIndexVariant1]
                                          .imageUrl!
                                      : product.imageUrl[0],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[200],
                                      child:
                                          const Icon(Icons.image_not_supported),
                                    );
                                  },
                                )
                              : Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image_not_supported),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getPriceText(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 151, 14, 4),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getStockText(),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Variants selection
                if (product.variants.isNotEmpty) ...[
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.variants[0].label,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(
                            product.variants[0].options.length,
                            (index) => _buildVariantOption(index, 0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (product.variants.length > 1) ...[
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.variants[1].label,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(
                              product.variants[1].options.length,
                              (index) => _buildVariantOption(index, 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],

                // Quantity selector
                SingleChildScrollView(
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.only(bottom: keyboardSize),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Số lượng",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          height: 36,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              _buildQuantityButton(
                                icon: Icons.remove,
                                onPressed: () {
                                  if (_quantityAddToCart > 1) {
                                    _updateQuantity(_quantityAddToCart - 1);
                                  }
                                },
                              ),
                              Container(
                                width: 50,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(color: Colors.grey[300]!),
                                    right: BorderSide(color: Colors.grey[300]!),
                                  ),
                                ),
                                child: TextField(
                                  focusNode: _quantityAdd,
                                  controller: _quantityController,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.only(bottom: 10),
                                  ),
                                  onChanged: (value) {
                                    int? quantity = int.tryParse(value);
                                    if (quantity != null) {
                                      _updateQuantity(quantity);
                                    }
                                  },
                                  onTapOutside: (event) {
                                    _quantityAdd.unfocus();
                                  },
                                ),
                              ),
                              _buildQuantityButton(
                                icon: Icons.add,
                                onPressed: () {
                                  if (_quantityAddToCart < maxStock) {
                                    _updateQuantity(_quantityAddToCart + 1);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Add to cart button
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: ElevatedButton(
                    onPressed: _isValidSelection()
                        ? () {
                            if (widget.parentContext.read<AuthBloc>().state
                                is AuthAuthenticated) {
                              String userId = (widget.parentContext
                                      .read<AuthBloc>()
                                      .state as AuthAuthenticated)
                                  .user
                                  .uid;
                              widget.parentContext
                                  .read<CartBloc>()
                                  .add(AddCartEvent(
                                    product.id,
                                    _quantityAddToCart,
                                    userId,
                                    product.shopId,
                                    selectedIndexVariant1 != -1
                                        ? product.variants[0].id
                                        : null,
                                    selectedIndexVariant1 != -1
                                        ? product.variants[0]
                                            .options[selectedIndexVariant1].id
                                        : null,
                                    product.variants.length > 1 &&
                                            selectedIndexVariant2 != -1
                                        ? product.variants[1].id
                                        : null,
                                    product.variants.length > 1 &&
                                            selectedIndexVariant2 != -1
                                        ? product.variants[1]
                                            .options[selectedIndexVariant2].id
                                        : null,
                                  ));
                            }
                            Navigator.pop(context);
                            _showAddToCartDialog();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text(
                      "Thêm vào giỏ hàng",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      return SizedBox.shrink();
    });
  }

  Widget _buildVariantOption(int index, int variantIndex) {
    final isSelected = variantIndex == 0
        ? index == selectedIndexVariant1
        : index == selectedIndexVariant2;

    // Kiểm tra xem option có bị tắt không
    bool isDisabled = false;
    if (variantIndex == 0) {
      if (product.variants.length == 1) {
        // Nếu chỉ có 1 variant, tắt option có stock = 0
        isDisabled = index < product.optionInfos.length &&
            product.optionInfos[index].stock == 0;
      } else {
        // Nếu có 2 variant, tắt option có tổng stock của tất cả option thứ 2 = 0
        bool hasStock = false;
        for (int i = 0; i < product.variants[1].options.length; i++) {
          int optionInfoIndex = index * product.variants[1].options.length + i;
          if (optionInfoIndex < product.optionInfos.length &&
              product.optionInfos[optionInfoIndex].stock > 0) {
            hasStock = true;
            break;
          }
        }
        isDisabled = !hasStock;
      }
    } else if (variantIndex == 1 && selectedIndexVariant1 != -1) {
      // Kiểm tra stock cho variant 2 khi đã chọn variant 1
      int optionInfoIndex =
          selectedIndexVariant1 * product.variants[1].options.length + index;
      if (optionInfoIndex < product.optionInfos.length) {
        isDisabled = product.optionInfos[optionInfoIndex].stock == 0;
      } else {
        isDisabled = true;
      }
    }

    return GestureDetector(
      onTap: isDisabled
          ? null
          : () {
              setState(() {
                if (variantIndex == 0) {
                  selectedIndexVariant1 = isSelected ? -1 : index;
                  selectedIndexVariant2 = -1;
                } else {
                  selectedIndexVariant2 = isSelected ? -1 : index;
                }
              });
            },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey[50] : Colors.grey[100],
          border: Border.all(
            color: isSelected
                ? Colors.brown
                : (isDisabled ? Colors.grey[200]! : Colors.grey[300]!),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (product.hasVariantImages && variantIndex == 0) ...[
              product.variants[variantIndex].options[index].imageUrl != null
                  ? Image.network(
                      product.variants[variantIndex].options[index].imageUrl!,
                      width: 24,
                      height: 24,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 24,
                          height: 24,
                          color: Colors.grey[200],
                          child:
                              const Icon(Icons.image_not_supported, size: 16),
                        );
                      },
                    )
                  : Container(
                      width: 24,
                      height: 24,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, size: 16),
                    ),
              const SizedBox(width: 8),
            ],
            Text(
              product.variants[variantIndex].options[index].name,
              style: TextStyle(
                color: isDisabled
                    ? Colors.grey[400]
                    : (isSelected ? Colors.brown : Colors.black),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        child: Icon(icon, size: 20),
      ),
    );
  }

  bool _isValidSelection() {
    if (product.variants.isEmpty) return true;
    if (product.variants.length == 1) return selectedIndexVariant1 != -1;
    return selectedIndexVariant1 != -1 && selectedIndexVariant2 != -1;
  }

  String _getPriceText() {
    if (product.variants.isEmpty) {
      return 'đ${formatPrice(product.price!)}';
    }

    if (product.variants.length == 1 && selectedIndexVariant1 != -1) {
      if (selectedIndexVariant1 >= product.optionInfos.length) {
        return 'đ${formatPrice(product.price!)}';
      }
      return 'đ${formatPrice(product.optionInfos[selectedIndexVariant1].price)}';
    }

    if (product.variants.length > 1) {
      if (selectedIndexVariant1 != -1 && selectedIndexVariant2 != -1) {
        int optionInfoIndex =
            selectedIndexVariant1 * product.variants[1].options.length +
                selectedIndexVariant2;
        if (optionInfoIndex >= product.optionInfos.length) {
          return 'đ${formatPrice(product.price!)}';
        }
        return 'đ${formatPrice(product.optionInfos[optionInfoIndex].price)}';
      } else if (selectedIndexVariant1 != -1) {
        // Khi đã chọn variant đầu tiên, hiển thị giá min-max của variant thứ 2
        List<double> prices = [];
        for (int i = 0; i < product.variants[1].options.length; i++) {
          int optionInfoIndex =
              selectedIndexVariant1 * product.variants[1].options.length + i;
          if (optionInfoIndex < product.optionInfos.length) {
            prices.add(product.optionInfos[optionInfoIndex].price);
          }
        }
        if (prices.isEmpty) {
          return 'đ${formatPrice(product.price!)}';
        }
        double minPrice = prices.reduce((a, b) => a < b ? a : b);
        double maxPrice = prices.reduce((a, b) => a > b ? a : b);
        if (minPrice == maxPrice) {
          return 'đ${formatPrice(minPrice)}';
        }
        return 'đ${formatPrice(minPrice)} - đ${formatPrice(maxPrice)}';
      }
    }

    double minPrice = product.getMinOptionPrice();
    double maxPrice = product.getMaxOptionPrice();

    if (minPrice == maxPrice) {
      return 'đ${formatPrice(minPrice)}';
    }
    return 'đ${formatPrice(minPrice)} - đ${formatPrice(maxPrice)}';
  }

  String _getStockText() {
    if (product.variants.isEmpty) {
      return 'Kho: ${product.quantity}';
    }

    if (product.variants.length == 1 && selectedIndexVariant1 != -1) {
      if (selectedIndexVariant1 >= product.optionInfos.length) {
        return 'Kho: ${product.quantity}';
      }
      return 'Kho: ${product.optionInfos[selectedIndexVariant1].stock}';
    }

    if (product.variants.length > 1) {
      if (selectedIndexVariant1 != -1 && selectedIndexVariant2 != -1) {
        int optionInfoIndex =
            selectedIndexVariant1 * product.variants[1].options.length +
                selectedIndexVariant2;
        if (optionInfoIndex >= product.optionInfos.length) {
          return 'Kho: ${product.quantity}';
        }
        return 'Kho: ${product.optionInfos[optionInfoIndex].stock}';
      } else if (selectedIndexVariant1 != -1) {
        // Khi đã chọn variant đầu tiên, hiển thị tổng số lượng kho của variant thứ 2
        int totalStock = 0;
        for (int i = 0; i < product.variants[1].options.length; i++) {
          int optionInfoIndex =
              selectedIndexVariant1 * product.variants[1].options.length + i;
          if (optionInfoIndex < product.optionInfos.length) {
            totalStock += product.optionInfos[optionInfoIndex].stock;
          }
        }
        return 'Kho: $totalStock';
      }
    }

    return 'Kho: ${product.getTotalOptionStock()}';
  }
}
