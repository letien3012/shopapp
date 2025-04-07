import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:luanvan/blocs/product_in_cart/product_cart_state.dart';
import 'package:luanvan/models/cart_item.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/ui/widgets/add_to_cart.dart';
import 'package:luanvan/ui/widgets/change_cart_variant.dart';
import 'package:luanvan/ui/helper/icon_helper.dart';
import 'package:luanvan/ui/widgets/alert_diablog.dart';

class ProductItemWidget extends StatefulWidget {
  final String shopId;
  final String itemId;
  final CartItem item;
  final TextEditingController controller;
  final bool checked;
  final double maxSwipe;
  final ProductCartListLoaded productCartState;
  final Function(bool?) onCheckChanged;
  final Function(String, String) onDeleteProduct;
  final Function(String, String, int) onUpdateQuantity;
  final Future<bool> Function() onShowConfirmDelete;
  final Function(String, int, bool?)? onProductCheck;

  const ProductItemWidget({
    required this.shopId,
    required this.itemId,
    required this.item,
    required this.controller,
    required this.checked,
    required this.maxSwipe,
    required this.productCartState,
    required this.onCheckChanged,
    required this.onDeleteProduct,
    required this.onUpdateQuantity,
    required this.onShowConfirmDelete,
    this.onProductCheck,
  });

  @override
  _ProductItemWidgetState createState() => _ProductItemWidgetState();
}

class _ProductItemWidgetState extends State<ProductItemWidget> {
  double _dragExtent = 0;

  String formatPrice(double price) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }

  void showAddToCart(BuildContext context, Product product,
      {String? optionId1, String? optionId2}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      builder: (context) => ChangeCartVariant(
        product: product,
        parentContext: context,
        quantity: widget.item.quantity,
        itemId: widget.itemId,
        optionId1: optionId1,
        optionId2: optionId2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.productCartState.products
        .firstWhere((element) => element.id == widget.item.productId);
    String productPrice = '';
    if (product.variants.isEmpty) {
      productPrice = product.price.toString();
    } else if (product.variants.length > 1) {
      int i = product.variants[0].options
          .indexWhere((element) => element.id == widget.item.optionId1);
      int j = product.variants[1].options
          .indexWhere((element) => element.id == widget.item.optionId2);
      if (i == -1) i = 0;
      if (j == -1) j = 0;
      productPrice = product
          .optionInfos[i * product.variants[1].options.length + j].price
          .toString();
    }

    return Stack(
      children: [
        Positioned.fill(
          child: Align(
            alignment: Alignment.centerRight,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              alignment: Alignment.center,
              height: 130,
              width: _dragExtent,
              color: Colors.brown,
              child: GestureDetector(
                onTap: () async {
                  if (await widget.onShowConfirmDelete()) {
                    widget.onDeleteProduct(widget.shopId, widget.itemId);
                  } else {
                    setState(() {
                      _dragExtent = 0;
                    });
                  }
                },
                child: const Text(
                  "Xóa",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
        GestureDetector(
          onHorizontalDragUpdate: (details) {
            setState(() {
              if (details.primaryDelta! < 0) {
                _dragExtent = max(0,
                    min(_dragExtent - details.primaryDelta!, widget.maxSwipe));
              }
              if (details.primaryDelta! > 0) {
                _dragExtent = (_dragExtent - details.primaryDelta!)
                    .clamp(0, widget.maxSwipe);
              }
            });
          },
          onHorizontalDragEnd: (details) {
            setState(() {
              _dragExtent =
                  (_dragExtent > widget.maxSwipe / 2) ? widget.maxSwipe : 0;
            });
          },
          child: AnimatedContainer(
            transform: Matrix4.translationValues(-_dragExtent, 0, 0),
            padding: const EdgeInsets.only(bottom: 20),
            duration: const Duration(milliseconds: 300),
            curve: Curves.linear,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    _isOutOfStock(product) || product.isDeleted
                        ? const SizedBox()
                        : Checkbox(
                            fillColor: WidgetStateProperty.resolveWith<Color>(
                                (states) {
                              if (states.contains(WidgetState.selected)) {
                                return Colors.brown;
                              }
                              return Colors.transparent;
                            }),
                            value: widget.checked,
                            onChanged: (bool? newValue) {
                              if (widget.onProductCheck != null) {
                                widget.onProductCheck!(
                                    widget.shopId, 0, newValue);
                              } else {
                                widget.onCheckChanged(newValue);
                              }
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                          ),
                    Opacity(
                      opacity: _isOutOfStock(product) || product.isDeleted
                          ? 0.5
                          : 1.0,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey, width: 0.6)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                            (product.hasVariantImages &&
                                    product.variants.isNotEmpty)
                                ? (product
                                        .variants[0]
                                        .options[product.variants[0].options
                                            .indexWhere((option) =>
                                                option.id ==
                                                widget.item.optionId1)]
                                        .imageUrl ??
                                    product.imageUrl[0])
                                : product.imageUrl[0],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name.isNotEmpty
                            ? product.name
                            : 'Sản phẩm không tên',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      (product.optionInfos.length > 1)
                          ? IntrinsicWidth(
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                height: 30,
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(5)),
                                alignment: Alignment.center,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        (widget.item.variantId1 != null)
                                            ? product.variants
                                                .firstWhere((variant) =>
                                                    variant.id ==
                                                    widget.item.variantId1)
                                                .options
                                                .firstWhere((option) =>
                                                    option.id ==
                                                    widget.item.optionId1)
                                                .name
                                            : '',
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        if (product.variants.isEmpty ||
                                            (product.variants.length == 2 &&
                                                product.variants.every(
                                                    (variant) =>
                                                        variant
                                                            .options.length <=
                                                        1)) ||
                                            (product.variants.length == 1 &&
                                                product.variants[0].options
                                                        .length <=
                                                    1)) {
                                          // context.read<CartBloc>().add(
                                          //     AddCartEvent(
                                          //         product.id,
                                          //         _quantityAddToCart,
                                          //         userId,
                                          //         product.shopId,
                                          //         null,
                                          //         null,
                                          //         null,
                                          //         null));
                                        } else {
                                          if (product.variants.length > 1) {
                                            showAddToCart(context, product,
                                                optionId1:
                                                    widget.item.optionId1,
                                                optionId2:
                                                    widget.item.optionId2);
                                          } else {
                                            showAddToCart(context, product,
                                                optionId1:
                                                    widget.item.optionId1);
                                          }
                                        }
                                      },
                                      child: Row(
                                        children: [
                                          Text(
                                            (widget.item.variantId2 != null)
                                                ? ', ${product.variants.firstWhere((variant) => variant.id == widget.item.variantId2).options.firstWhere((option) => option.id == widget.item.optionId2).name}'
                                                : '',
                                            style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          const Icon(Icons
                                              .keyboard_arrow_down_outlined),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : SizedBox(height: 30),
                      const SizedBox(height: 5),
                      _buildStockStatus(product),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'đ${formatPrice(double.parse(productPrice))}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 151, 14, 4),
                            ),
                          ),
                          if (!_isOutOfStock(product) || !product.isDeleted)
                            Container(
                              height: 20,
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey, width: 1)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      final newQuantity = int.tryParse(
                                              widget.controller.text) ??
                                          1;
                                      if (newQuantity > 1) {
                                        widget.onUpdateQuantity(widget.shopId,
                                            widget.itemId, newQuantity - 1);
                                        widget.controller.text =
                                            (newQuantity - 1).toString();
                                      } else {
                                        if (await widget
                                            .onShowConfirmDelete()) {
                                          widget.onDeleteProduct(
                                              widget.shopId, widget.itemId);
                                        }
                                      }
                                    },
                                    child: Container(
                                      height: double.infinity,
                                      width: 19,
                                      alignment: Alignment.center,
                                      decoration: const BoxDecoration(
                                          border: Border(
                                              right: BorderSide(
                                                  color: Colors.grey,
                                                  width: 1))),
                                      child: Icon(FontAwesomeIcons.minus,
                                          color: Colors.grey[700], size: 13),
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    height: 20,
                                    width: 30,
                                    child: TextField(
                                      controller: widget.controller,
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding:
                                              EdgeInsets.only(bottom: 13)),
                                      style: TextStyle(
                                          fontSize: 13,
                                          textBaseline:
                                              TextBaseline.alphabetic),
                                      onSubmitted: (value) {
                                        final newQuantity =
                                            int.tryParse(value) ?? 1;
                                        if (newQuantity > 0) {
                                          widget.onUpdateQuantity(widget.shopId,
                                              widget.itemId, newQuantity);
                                        } else {
                                          widget.controller.text = '1';
                                          widget.onUpdateQuantity(
                                              widget.shopId, widget.itemId, 1);
                                        }
                                      },
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      final newQuantity = int.tryParse(
                                              widget.controller.text) ??
                                          1;
                                      widget.onUpdateQuantity(widget.shopId,
                                          widget.itemId, newQuantity + 1);
                                      widget.controller.text =
                                          (newQuantity + 1).toString();
                                    },
                                    child: Container(
                                      height: double.infinity,
                                      width: 19,
                                      alignment: Alignment.center,
                                      decoration: const BoxDecoration(
                                          border: Border(
                                              left: BorderSide(
                                                  color: Colors.grey,
                                                  width: 1))),
                                      child: Icon(FontAwesomeIcons.plus,
                                          color: Colors.grey[700], size: 13),
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
  }

  bool _isOutOfStock(Product product) {
    int currentStock = 0;
    if (product.variants.isEmpty) {
      currentStock = product.quantity ?? 0;
    } else if (product.variants.length == 1) {
      if (widget.item.optionId1 != null) {
        int optionIndex = product.variants[0].options
            .indexWhere((opt) => opt.id == widget.item.optionId1);
        if (optionIndex != -1 && optionIndex < product.optionInfos.length) {
          currentStock = product.optionInfos[optionIndex].stock;
        }
      }
    } else if (product.variants.length > 1) {
      if (widget.item.optionId1 != null && widget.item.optionId2 != null) {
        int option1Index = product.variants[0].options
            .indexWhere((opt) => opt.id == widget.item.optionId1);
        int option2Index = product.variants[1].options
            .indexWhere((opt) => opt.id == widget.item.optionId2);
        if (option1Index != -1 && option2Index != -1) {
          int optionInfoIndex =
              (option1Index * product.variants[1].options.length + option2Index)
                  .toInt();
          if (optionInfoIndex < product.optionInfos.length) {
            currentStock = product.optionInfos[optionInfoIndex].stock;
          }
        }
      }
    }
    return currentStock == 0;
  }

  Widget _buildStockStatus(Product product) {
    if (_isOutOfStock(product) || product.isDeleted) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Loại hàng đã chọn không còn",
            style: TextStyle(
              color: Colors.red,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 5),
          GestureDetector(
            onTap: () {
              if (product.variants.isEmpty || product.optionInfos.length <= 1) {
                // TODO: Navigate to similar products
              } else {
                if (product.variants.length > 1) {
                  showAddToCart(context, product,
                      optionId1: widget.item.optionId1,
                      optionId2: widget.item.optionId2);
                } else {
                  showAddToCart(context, product,
                      optionId1: widget.item.optionId1);
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red[300]!),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(
                product.variants.isEmpty || product.optionInfos.length <= 1
                    ? "Tìm sản phẩm tương tự"
                    : "Đổi loại khác",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.red[300],
                ),
              ),
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}
