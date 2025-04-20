import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:luanvan/blocs/productorder/product_order_state.dart';
import 'package:luanvan/models/order_item.dart';
import 'package:luanvan/ui/home/detai_item_screen.dart';

class ProductOrderWidget extends StatefulWidget {
  final String shopId;
  final OrderItem item;
  final ProductOrderListLoaded productOrderState;

  const ProductOrderWidget({
    required this.shopId,
    required this.item,
    required this.productOrderState,
  });

  @override
  _ProductOrderWidgetState createState() => _ProductOrderWidgetState();
}

class _ProductOrderWidgetState extends State<ProductOrderWidget> {
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(DetaiItemScreen.routeName,
              arguments: widget.item.productId);
        },
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
                  widget.item.productImage,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.productName,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(widget.item.productVariation ?? '',
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
                      Text('đ${formatPrice(widget.item.price)}',
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
      ),
    );
  }
}
