import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:luanvan/blocs/auth/auth_bloc.dart';
import 'package:luanvan/blocs/auth/auth_state.dart';
import 'package:luanvan/blocs/cart/cart_bloc.dart';
import 'package:luanvan/blocs/cart/cart_event.dart';
import 'package:luanvan/models/product.dart';

class ChangeCartVariant extends StatefulWidget {
  final Product product;
  final BuildContext parentContext;
  final String itemId;
  final int quantity;
  final String? optionId1;
  final String? optionId2;
  const ChangeCartVariant({
    Key? key,
    required this.product,
    required this.parentContext,
    this.optionId1,
    this.optionId2,
    required this.itemId,
    required this.quantity,
  }) : super(key: key);

  @override
  _ChangeCartVariantState createState() => _ChangeCartVariantState();
}

class _ChangeCartVariantState extends State<ChangeCartVariant> {
  int _quantityAddToCart = 1;
  int selectedIndexVariant1 = -1;
  int selectedIndexVariant2 = -1;
  late TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    if (widget.quantity > 0) {
      _quantityAddToCart = widget.quantity;
    }
    if (widget.optionId1 != null) {
      selectedIndexVariant1 = widget.product.variants[0].options.indexWhere(
        (element) => element.id == widget.optionId1,
      );
    }
    if (widget.optionId2 != null) {
      selectedIndexVariant2 = widget.product.variants[1].options.indexWhere(
        (element) => element.id == widget.optionId2,
      );
    }
    _quantityController =
        TextEditingController(text: _quantityAddToCart.toString());
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
    if (widget.product.variants.isEmpty) {
      return widget.product.quantity ?? 0;
    }

    if (widget.product.variants.length == 1 && selectedIndexVariant1 != -1) {
      if (selectedIndexVariant1 >= widget.product.optionInfos.length) {
        return widget.product.quantity ?? 0;
      }
      return widget.product.optionInfos[selectedIndexVariant1].stock;
    }

    if (widget.product.variants.length > 1) {
      if (selectedIndexVariant1 != -1 && selectedIndexVariant2 != -1) {
        int optionInfoIndex =
            selectedIndexVariant1 * widget.product.variants[1].options.length +
                selectedIndexVariant2;
        if (optionInfoIndex >= widget.product.optionInfos.length) {
          return widget.product.quantity ?? 0;
        }
        return widget.product.optionInfos[optionInfoIndex].stock;
      } else if (selectedIndexVariant1 != -1) {
        // Khi đã chọn variant đầu tiên, lấy tổng số lượng kho của variant thứ 2
        int totalStock = 0;
        for (int i = 0; i < widget.product.variants[1].options.length; i++) {
          int optionInfoIndex = selectedIndexVariant1 *
                  widget.product.variants[1].options.length +
              i;
          if (optionInfoIndex < widget.product.optionInfos.length) {
            totalStock += widget.product.optionInfos[optionInfoIndex].stock;
          }
        }
        return totalStock;
      }
    }

    return widget.product.getTotalOptionStock();
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

  bool _hasVariantChanged() {
    if (widget.optionId1 == null && selectedIndexVariant1 == -1) return false;
    if (widget.optionId1 != null && selectedIndexVariant1 != -1) {
      if (widget.product.variants[0].options[selectedIndexVariant1].id !=
          widget.optionId1) {
        return true;
      }
    } else if (widget.optionId1 != null || selectedIndexVariant1 != -1) {
      return true;
    }

    if (widget.product.variants.length > 1) {
      if (widget.optionId2 == null && selectedIndexVariant2 == -1) return false;
      if (widget.optionId2 != null && selectedIndexVariant2 != -1) {
        if (widget.product.variants[1].options[selectedIndexVariant2].id !=
            widget.optionId2) {
          return true;
        }
      } else if (widget.optionId2 != null || selectedIndexVariant2 != -1) {
        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
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
                    child: widget.product.imageUrl.isNotEmpty
                        ? Image.network(
                            widget.product.hasVariantImages &&
                                    selectedIndexVariant1 != -1 &&
                                    widget
                                            .product
                                            .variants[0]
                                            .options[selectedIndexVariant1]
                                            .imageUrl !=
                                        null
                                ? widget.product.variants[0]
                                    .options[selectedIndexVariant1].imageUrl!
                                : widget.product.imageUrl[0],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.image_not_supported),
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
          if (widget.product.variants.isNotEmpty) ...[
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
                    widget.product.variants[0].label,
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
                      widget.product.variants[0].options.length,
                      (index) => _buildVariantOption(index, 0),
                    ),
                  ),
                ],
              ),
            ),
            if (widget.product.variants.length > 1) ...[
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
                      widget.product.variants[1].label,
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
                        widget.product.variants[1].options.length,
                        (index) => _buildVariantOption(index, 1),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],

          // Quantity selector
          Container(
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

          // Add to cart button
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: ElevatedButton(
              onPressed: _isValidSelection() && _hasVariantChanged()
                  ? () {
                      if (widget.parentContext.read<AuthBloc>().state
                          is AuthAuthenticated) {
                        String userId = (widget.parentContext
                                .read<AuthBloc>()
                                .state as AuthAuthenticated)
                            .user
                            .uid;
                        print('itemId: ${widget.itemId}');
                        widget.parentContext
                            .read<CartBloc>()
                            .add(UpdateProductVariantEvent(
                              widget.product.id,
                              widget.product.shopId,
                              userId,
                              widget.itemId,
                              _quantityAddToCart,
                              variant1Id: selectedIndexVariant1 != -1
                                  ? widget.product.variants[0].id
                                  : null,
                              option1Id: selectedIndexVariant1 != -1
                                  ? widget.product.variants[0]
                                      .options[selectedIndexVariant1].id
                                  : null,
                              variant2Id: widget.product.variants.length > 1 &&
                                      selectedIndexVariant2 != -1
                                  ? widget.product.variants[1].id
                                  : null,
                              option2Id: widget.product.variants.length > 1 &&
                                      selectedIndexVariant2 != -1
                                  ? widget.product.variants[1]
                                      .options[selectedIndexVariant2].id
                                  : null,
                            ));
                      }
                      Navigator.pop(context);
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
                "Xác nhận",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariantOption(int index, int variantIndex) {
    final isSelected = variantIndex == 0
        ? index == selectedIndexVariant1
        : index == selectedIndexVariant2;
    return GestureDetector(
      onTap: () {
        setState(() {
          if (variantIndex == 0) {
            selectedIndexVariant1 = isSelected ? -1 : index;
          } else {
            selectedIndexVariant2 = isSelected ? -1 : index;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border.all(
            color: isSelected ? Colors.brown : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.product.hasVariantImages && variantIndex == 0) ...[
              widget.product.variants[variantIndex].options[index].imageUrl !=
                      null
                  ? Image.network(
                      widget.product.variants[variantIndex].options[index]
                          .imageUrl!,
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
              widget.product.variants[variantIndex].options[index].name,
              style: TextStyle(
                color: isSelected ? Colors.brown : Colors.black,
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
    if (widget.product.variants.isEmpty) return true;
    if (widget.product.variants.length == 1) return selectedIndexVariant1 != -1;
    return selectedIndexVariant1 != -1 && selectedIndexVariant2 != -1;
  }

  String _getPriceText() {
    if (widget.product.variants.isEmpty) {
      return 'đ${formatPrice(widget.product.price!)}';
    }

    if (widget.product.variants.length == 1 && selectedIndexVariant1 != -1) {
      if (selectedIndexVariant1 >= widget.product.optionInfos.length) {
        return 'đ${formatPrice(widget.product.price!)}';
      }
      return 'đ${formatPrice(widget.product.optionInfos[selectedIndexVariant1].price)}';
    }

    if (widget.product.variants.length > 1) {
      if (selectedIndexVariant1 != -1 && selectedIndexVariant2 != -1) {
        int optionInfoIndex =
            selectedIndexVariant1 * widget.product.variants[1].options.length +
                selectedIndexVariant2;
        if (optionInfoIndex >= widget.product.optionInfos.length) {
          return 'đ${formatPrice(widget.product.price!)}';
        }
        return 'đ${formatPrice(widget.product.optionInfos[optionInfoIndex].price)}';
      } else if (selectedIndexVariant1 != -1) {
        // Khi đã chọn variant đầu tiên, hiển thị giá min-max của variant thứ 2
        List<double> prices = [];
        for (int i = 0; i < widget.product.variants[1].options.length; i++) {
          int optionInfoIndex = selectedIndexVariant1 *
                  widget.product.variants[1].options.length +
              i;
          if (optionInfoIndex < widget.product.optionInfos.length) {
            prices.add(widget.product.optionInfos[optionInfoIndex].price);
          }
        }
        if (prices.isEmpty) {
          return 'đ${formatPrice(widget.product.price!)}';
        }
        double minPrice = prices.reduce((a, b) => a < b ? a : b);
        double maxPrice = prices.reduce((a, b) => a > b ? a : b);
        if (minPrice == maxPrice) {
          return 'đ${formatPrice(minPrice)}';
        }
        return 'đ${formatPrice(minPrice)} - đ${formatPrice(maxPrice)}';
      }
    }

    double minPrice = widget.product.getMinOptionPrice();
    double maxPrice = widget.product.getMaxOptionPrice();

    if (minPrice == maxPrice) {
      return 'đ${formatPrice(minPrice)}';
    }
    return 'đ${formatPrice(minPrice)} - đ${formatPrice(maxPrice)}';
  }

  String _getStockText() {
    if (widget.product.variants.isEmpty) {
      return 'Kho: ${widget.product.quantity}';
    }

    if (widget.product.variants.length == 1 && selectedIndexVariant1 != -1) {
      if (selectedIndexVariant1 >= widget.product.optionInfos.length) {
        return 'Kho: ${widget.product.quantity}';
      }
      return 'Kho: ${widget.product.optionInfos[selectedIndexVariant1].stock}';
    }

    if (widget.product.variants.length > 1) {
      if (selectedIndexVariant1 != -1 && selectedIndexVariant2 != -1) {
        int optionInfoIndex =
            selectedIndexVariant1 * widget.product.variants[1].options.length +
                selectedIndexVariant2;
        if (optionInfoIndex >= widget.product.optionInfos.length) {
          return 'Kho: ${widget.product.quantity}';
        }
        return 'Kho: ${widget.product.optionInfos[optionInfoIndex].stock}';
      } else if (selectedIndexVariant1 != -1) {
        // Khi đã chọn variant đầu tiên, hiển thị tổng số lượng kho của variant thứ 2
        int totalStock = 0;
        for (int i = 0; i < widget.product.variants[1].options.length; i++) {
          int optionInfoIndex = selectedIndexVariant1 *
                  widget.product.variants[1].options.length +
              i;
          if (optionInfoIndex < widget.product.optionInfos.length) {
            totalStock += widget.product.optionInfos[optionInfoIndex].stock;
          }
        }
        return 'Kho: $totalStock';
      }
    }

    return 'Kho: ${widget.product.getTotalOptionStock()}';
  }
}
