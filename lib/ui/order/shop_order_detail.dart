import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:luanvan/blocs/list_shop/list_shop_bloc.dart';
import 'package:luanvan/blocs/list_shop/list_shop_state.dart';
import 'package:luanvan/blocs/productorder/product_order_bloc.dart';
import 'package:luanvan/blocs/productorder/product_order_state.dart';
import 'package:luanvan/models/order.dart';
import 'package:luanvan/ui/helper/icon_helper.dart';
import 'package:luanvan/ui/order/product_order_widget.dart';

class ShopOrderDetail extends StatefulWidget {
  Order order;
  ShopOrderDetail({
    required this.order,
  });

  @override
  State<ShopOrderDetail> createState() => _ShopOrderDetailState();
}

class _ShopOrderDetailState extends State<ShopOrderDetail> {
  bool isShowDetailPrice = false;
  @override
  void initState() {
    super.initState();
  }

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
    return BlocBuilder<ListShopBloc, ListShopState>(
      builder: (context, listShopState) {
        if (listShopState is ListShopLoading) {
          return _buildShopSkeleton();
        } else if (listShopState is ListShopLoaded) {
          final shop = listShopState.shops.firstWhere(
            (element) => element.shopId == widget.order.shopId,
          );

          return Container(
            margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
            padding:
                const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(IconHelper.store, width: 25, height: 25),
                    const SizedBox(width: 5),
                    Text(
                      shop.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                BlocBuilder<ProductOrderBloc, ProductOrderState>(
                  builder: (context, productOrderState) {
                    if (productOrderState is ProductOrderListLoaded) {
                      return Column(
                        children: [
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: widget.order.item.length,
                            padding: const EdgeInsets.only(
                                top: 10, left: 10, right: 10),
                            itemBuilder: (context, index) {
                              final item = widget.order.item[index];
                              return ProductOrderWidget(
                                shopId: widget.order.shopId,
                                item: item,
                                productOrderState: productOrderState,
                              );
                            },
                          ),
                          (isShowDetailPrice)
                              ? AnimatedContainer(
                                  duration: const Duration(seconds: 1),
                                  curve: Curves.easeInOut,
                                  height: isShowDetailPrice ? 50 : 0,
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Tổng tiền hàng'),
                                          Text(
                                              'đ${formatPrice(widget.order.totalProductPrice)}'),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Phí vận chuyển'),
                                          Text(
                                              'đ${formatPrice(widget.order.totalShipFee)}'),
                                        ],
                                      ),
                                    ],
                                  ))
                              : const SizedBox(),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isShowDetailPrice = !isShowDetailPrice;
                              });
                            },
                            child: SizedBox(
                              height: 40,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    "Thành tiền: đ${formatPrice(widget.order.totalPrice)}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Icon(
                                    isShowDetailPrice
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    } else if (productOrderState is ProductOrderError) {
                      return Text('Error: ${productOrderState.message}');
                    }
                    return const Center(child: CircularProgressIndicator());
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
          Container(
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
          ),
        ],
      ),
    );
  }
}
