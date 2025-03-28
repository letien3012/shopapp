import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:luanvan/blocs/productorder/product_order_state.dart';
import 'package:luanvan/models/cart_item.dart';

class ProductOrderShopItem extends StatefulWidget {
  final String shopId;
  final CartItem item;
  final ProductOrderListLoaded productOrderState;

  const ProductOrderShopItem({
    required this.shopId,
    required this.item,
    required this.productOrderState,
  });

  @override
  _ProductOrderShopItemState createState() => _ProductOrderShopItemState();
}

class _ProductOrderShopItemState extends State<ProductOrderShopItem> {
  String formatPrice(double price) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.productOrderState.products
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
                                (option) => option.id == widget.item.optionId1)]
                            .imageUrl ??
                        product.imageUrl[0])
                    : product.imageUrl[0],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name.isNotEmpty ? product.name : 'Sản phẩm không tên',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('đ${formatPrice(double.parse(productPrice))}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        )),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
