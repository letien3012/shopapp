import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:luanvan/blocs/product_in_cart/product_cart_state.dart';
import 'package:luanvan/models/cart_item.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/models/shipping_method.dart';
import 'package:luanvan/ui/widgets/add_to_cart.dart';

class ProductCheckoutWidget extends StatefulWidget {
  final String shopId;
  final String itemId;
  final CartItem item;
  final ShippingMethod shipMethod;
  final ProductCartListLoaded productCartState;

  const ProductCheckoutWidget({
    required this.shopId,
    required this.itemId,
    required this.item,
    required this.productCartState,
    required this.shipMethod,
  });

  @override
  _ProductItemWidgetState createState() => _ProductItemWidgetState();
}

class _ProductItemWidgetState extends State<ProductCheckoutWidget> {
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
      builder: (context) => AddToCartBottomSheet(
        product: product,
        parentContext: context,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Opacity(
        opacity: (!product.shippingMethods.any(
          (element) =>
              (element.isEnabled && element.name == widget.shipMethod.name),
        ))
            ? 0.5
            : 1,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey, width: 0.6)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  (product.hasVariantImages && product.variants.isNotEmpty)
                      ? (product
                              .variants[0]
                              .options[product.variants[0].options.indexWhere(
                                  (option) =>
                                      option.id == widget.item.optionId1)]
                              .imageUrl ??
                          product.imageUrl[0])
                      : product.imageUrl[0],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Stack(
                children: [
                  (!product.shippingMethods.any(
                    (element) => (element.isEnabled &&
                        element.name == widget.shipMethod.name),
                  ))
                      ? Positioned.fill(
                          top: 25,
                          child: Text(
                            'Lựa chọn vận chuyển không hỗ trợ',
                            style: TextStyle(color: Colors.red),
                          ))
                      : SizedBox.shrink(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name.isNotEmpty
                            ? product.name
                            : 'Sản phẩm không tên',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Text(
                              (widget.item.variantId1 != null)
                                  ? product.variants
                                      .firstWhere((variant) =>
                                          variant.id == widget.item.variantId1)
                                      .options
                                      .firstWhere((option) =>
                                          option.id == widget.item.optionId1)
                                      .name
                                  : '',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w300),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          Text(
                              (widget.item.variantId2 != null)
                                  ? ', ${product.variants.firstWhere((variant) => variant.id == widget.item.variantId2).options.firstWhere((option) => option.id == widget.item.optionId2).name}'
                                  : '',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w300),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('đ${formatPrice(double.parse(productPrice))}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              )),
                          SizedBox(
                            height: 20,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("X", style: TextStyle(fontSize: 12)),
                                Text(widget.item.quantity.toString(),
                                    style: TextStyle(fontSize: 15)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
