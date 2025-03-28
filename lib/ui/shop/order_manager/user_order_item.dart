import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:luanvan/blocs/listuserordershop/list_user_order_bloc.dart';
import 'package:luanvan/blocs/listuserordershop/list_user_order_state.dart';
import 'package:luanvan/blocs/productorder/product_order_bloc.dart';
import 'package:luanvan/blocs/productorder/product_order_state.dart';
import 'package:luanvan/models/order.dart';
import 'package:luanvan/ui/order/product_order_widget.dart';
import 'package:luanvan/ui/shop/order_manager/order_detail_shop_screen.dart';

class UserOrderItem extends StatefulWidget {
  Order order;
  UserOrderItem({
    required this.order,
  });

  @override
  State<UserOrderItem> createState() => _UserOrderItemState();
}

class _UserOrderItemState extends State<UserOrderItem> {
  bool _showAllProducts = false;

  @override
  void initState() {
    super.initState();
  }

  String _getOrderStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Chờ xác nhận';
      case OrderStatus.processing:
        return 'Chờ lấy hàng';
      case OrderStatus.shipped:
        return 'Chờ giao hàng';
      case OrderStatus.delivered:
        return 'Hoàn thành';
      case OrderStatus.cancelled:
        return 'Đã hủy';
      case OrderStatus.returned:
        return 'Trả hàng';
      default:
        return '';
    }
  }

  Color _getOrderStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.processing:
        return Colors.purple;
      case OrderStatus.shipped:
        return Colors.blue;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.returned:
        return Colors.grey;
      default:
        return Colors.grey;
    }
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
    return BlocBuilder<ListUserOrderBloc, ListUserOrderState>(
      builder: (context, listUserState) {
        if (listUserState is ListUserOrderLoading) {
          return _buildShopSkeleton();
        } else if (listUserState is ListUserOrderLoaded) {
          final user = listUserState.users.firstWhere(
            (element) => element.id == widget.order.userId,
          );

          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, OrderDetailShopScreen.routeName,
                  arguments: widget.order);
            },
            child: Container(
              margin: const EdgeInsets.only(
                top: 10,
              ),
              padding: const EdgeInsets.only(
                  top: 10, left: 10, right: 10, bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipOval(
                        child: Image.network(
                          user.avataUrl ?? '',
                          width: 25,
                          height: 25,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        user.name ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _getOrderStatusText(widget.order.status),
                        style: TextStyle(
                          color: _getOrderStatusColor(widget.order.status),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  BlocBuilder<ProductOrderBloc, ProductOrderState>(
                    builder: (context, productOrderState) {
                      if (productOrderState is ProductOrderListLoaded) {
                        int totalProduct = 0;
                        for (var element in widget.order.item) {
                          totalProduct += element.quantity;
                        }
                        return Column(
                          children: [
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: _showAllProducts
                                  ? widget.order.item.length
                                  : 1,
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
                            if (widget.order.item.length > 1)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _showAllProducts = !_showAllProducts;
                                  });
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _showAllProducts
                                            ? 'Thu gọn'
                                            : 'Xem thêm',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 13,
                                        ),
                                      ),
                                      Icon(
                                        _showAllProducts
                                            ? Icons.keyboard_arrow_up
                                            : Icons.keyboard_arrow_down,
                                        color: Colors.grey[600],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            SizedBox(
                              height: 40,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    "Tổng thanh toán: ",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    "đ${formatPrice(widget.order.totalPrice)}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Color.fromARGB(255, 151, 14, 4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 0.3,
                              color: Colors.grey[300],
                            ),
                            Container(
                              height: 60,
                              alignment: Alignment.centerRight,
                              child: Material(
                                color: Colors.brown,
                                child: InkWell(
                                  onTap: () {
                                    if (widget.order.status ==
                                        OrderStatus.pending) {
                                      // context.read<OrderBloc>().add(
                                      //       UpdateOrderStatusEvent(
                                      //         widget.order.orderId,
                                      //         OrderStatus.processing,
                                      //       ),
                                      //     );
                                    } else if (widget.order.status ==
                                        OrderStatus.processing) {
                                      // context.read<OrderBloc>().add(
                                      //       UpdateOrderStatusEvent(
                                      //         widget.order.orderId,
                                      //         OrderStatus.shipped,
                                      //       ),
                                      //     );
                                    } else if (widget.order.status ==
                                        OrderStatus.delivered) {
                                      // TODO: Implement contact buyer logic
                                    }
                                  },
                                  child: Container(
                                    height: 40,
                                    width: 120,
                                    alignment: Alignment.center,
                                    child: Text(
                                      widget.order.status == OrderStatus.pending
                                          ? 'Xác nhận'
                                          : widget.order.status ==
                                                  OrderStatus.processing
                                              ? 'Chuẩn bị hàng'
                                              : widget.order.status ==
                                                      OrderStatus.delivered
                                                  ? 'Liên hệ người mua'
                                                  : '',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: 0.3,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Mã đơn hàng',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  widget.order.trackingNumber ?? '',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
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
            ),
          );
        } else if (listUserState is ListUserOrderError) {
          return Text('Error: ${listUserState.message}');
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
