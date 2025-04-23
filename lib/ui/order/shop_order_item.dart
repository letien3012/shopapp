import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:luanvan/blocs/auth/auth_bloc.dart';
import 'package:luanvan/blocs/auth/auth_state.dart';
import 'package:luanvan/blocs/list_shop/list_shop_bloc.dart';
import 'package:luanvan/blocs/list_shop/list_shop_state.dart';
import 'package:luanvan/blocs/order/order_bloc.dart';
import 'package:luanvan/blocs/order/order_event.dart';
import 'package:luanvan/blocs/order/order_state.dart';
import 'package:luanvan/blocs/productorder/product_order_bloc.dart';
import 'package:luanvan/blocs/productorder/product_order_state.dart';
import 'package:luanvan/blocs/user/user_bloc.dart';
import 'package:luanvan/blocs/user/user_state.dart';
import 'package:luanvan/models/order.dart';
import 'package:luanvan/models/order_history.dart';
import 'package:luanvan/models/shop.dart';
import 'package:luanvan/ui/helper/icon_helper.dart';
import 'package:luanvan/ui/item/add_review_screen.dart';
import 'package:luanvan/ui/order/order_detail_screen.dart';
import 'package:luanvan/ui/order/product_order_widget.dart';
import 'package:luanvan/ui/widgets/confirm_diablog.dart';

class ShopOrderItem extends StatefulWidget {
  Order order;
  final Function() refreshOrder;
  ShopOrderItem({
    required this.order,
    required this.refreshOrder,
  });

  @override
  State<ShopOrderItem> createState() => _ShopOrderItemState();
}

class _ShopOrderItemState extends State<ShopOrderItem> {
  bool _showAllProducts = false;
  String? _selectedReason;
  final List<String> _returnReasons = [
    'Sản phẩm bị lỗi/hỏng',
    'Sản phẩm không đúng mô tả',
    'Nhận sai sản phẩm',
    'Không vừa ý với sản phẩm',
    'Lý do khác'
  ];

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

  Shop? _findShop(List<Shop> shops) {
    try {
      return shops.firstWhere(
        (element) => element.shopId == widget.order.shopId,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> _showReturnDialog() async {
    _selectedReason = null;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Chọn lý do trả hàng'),
              content: Container(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _returnReasons.map((reason) {
                    return RadioListTile<String>(
                      title: Text(reason),
                      value: reason,
                      groupValue: _selectedReason,
                      onChanged: (value) {
                        setState(() {
                          _selectedReason = value;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Hủy'),
                ),
                TextButton(
                  onPressed: _selectedReason == null
                      ? null
                      : () async {
                          context.read<OrderBloc>().add(
                                UpdateOrderStatus(
                                  widget.order.id,
                                  OrderStatus.returned,
                                  note: _selectedReason,
                                ),
                              );
                          try {
                            await for (final state
                                in context.read<OrderBloc>().stream) {
                              if (state is OrderDetailLoaded) {
                                final userState =
                                    context.read<UserBloc>().state;
                                if (userState is UserLoaded) {
                                  context.read<OrderBloc>().add(
                                      FetchOrdersByUserId(userState.user.id));
                                }

                                // Show success message
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Yêu cầu trả hàng thành công'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                                break;
                              } else if (state is OrderError) {
                                // Show error message
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Lỗi trả hàng: ${state.message}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                                break;
                              }
                            }
                          } catch (e) {
                            // Show error message
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Lỗi xác nhận đơn hàng: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } finally {
                            // Hide loading indicator
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          }
                        },
                  child:
                      Text('Xác nhận', style: TextStyle(color: Colors.white)),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.brown,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showConfirmShipSuccessOrderDialog() async {
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          actionsPadding: EdgeInsets.zero,
          titlePadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          title: const Text(
            "Nhấn đã nhận được hàng đồng nghĩa với việc bạn không hài lòng và không thể trả hàng sau khi xác nhận?",
            style: TextStyle(fontSize: 14, color: Colors.black),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(width: 0.2, color: Colors.grey),
                        right: BorderSide(width: 0.2, color: Colors.grey),
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(false),
                      child: const Text(
                        "Hủy",
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(width: 0.2, color: Colors.grey),
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () async {
                        context.read<OrderBloc>().add(
                              UpdateOrderStatus(
                                widget.order.id,
                                OrderStatus.delivered,
                                note: "Người mua xác nhận nhận hàng thành công",
                              ),
                            );
                        try {
                          await for (final state
                              in context.read<OrderBloc>().stream) {
                            if (state is OrderDetailLoaded) {
                              final userState = context.read<UserBloc>().state;
                              if (userState is UserLoaded) {
                                context.read<OrderBloc>().add(
                                    FetchOrdersByUserId(userState.user.id));
                              }

                              // Show success message
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Xác nhận giao hàng thành công'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                              break;
                            } else if (state is OrderError) {
                              // Show error message
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Lỗi trả hàng: ${state.message}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                              break;
                            }
                          }
                        } catch (e) {
                          // Show error message
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Lỗi xác nhận đơn hàng: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } finally {
                          // Hide loading indicator
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        }
                      },
                      child: const Text(
                        "Xác nhận",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.brown,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  OrderStatusHistory? deliveredEntry;
  @override
  Widget build(BuildContext context) {
    deliveredEntry = widget.order.statusHistory
        .where(
          (element) => element.status == OrderStatus.delivered,
        )
        .firstOrNull;

    final canConfirmReceived = widget.order.status == OrderStatus.delivered &&
        !widget.order.statusHistory.any(
          (element) =>
              element.note == 'Người mua xác nhận nhận hàng thành công',
        ) &&
        deliveredEntry != null &&
        DateTime.now().difference(deliveredEntry!.timestamp).inDays < 7;
    final hasConfirmed = widget.order.statusHistory.any(
      (element) => element.note == 'Người mua xác nhận nhận hàng thành công',
    );

    final canReviewOrder = widget.order.status == OrderStatus.delivered &&
        (hasConfirmed ||
            (deliveredEntry != null &&
                DateTime.now().difference(deliveredEntry!.timestamp).inDays >=
                    7));
    return BlocBuilder<ListShopBloc, ListShopState>(
      builder: (context, listShopState) {
        if (listShopState is ListShopLoading) {
          return _buildShopSkeleton();
        } else if (listShopState is ListShopLoaded) {
          final shop = _findShop(listShopState.shops);
          if (shop == null) {
            return const SizedBox.shrink();
          }

          return GestureDetector(
            onTap: () async {
              final result = await Navigator.pushNamed(
                  context, OrderDetailScreen.routeName,
                  arguments: widget.order);
              if (result == 'cancel') {
                widget.refreshOrder();
              }
            },
            child: Container(
              margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
              padding: const EdgeInsets.only(
                  top: 10, left: 10, right: 10, bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
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
                      Text(
                        _getOrderStatusText(widget.order.status),
                        style: TextStyle(
                          color: _getOrderStatusColor(widget.order.status),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
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
                                    "Tổng số tiền ($totalProduct sản phẩm): đ${formatPrice(widget.order.totalPrice)}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            canConfirmReceived
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        height: 60,
                                        alignment: Alignment.center,
                                        child: Material(
                                          color: Colors.white,
                                          child: InkWell(
                                            onTap:
                                                _showConfirmShipSuccessOrderDialog,
                                            child: Container(
                                              height: 40,
                                              width: 120,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.brown,
                                                ),
                                              ),
                                              child: Text(
                                                'Đã nhận được hàng',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.brown,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Container(
                                        height: 60,
                                        alignment: Alignment.centerRight,
                                        child: Material(
                                          color: Colors.brown,
                                          child: InkWell(
                                            onTap: _showReturnDialog,
                                            child: Container(
                                              height: 40,
                                              width: 120,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.brown,
                                                ),
                                              ),
                                              child: Text(
                                                'Trả hàng',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : SizedBox.shrink(),
                            canReviewOrder
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      // Container(
                                      //   height: 60,
                                      //   alignment: Alignment.centerRight,
                                      //   child: Material(
                                      //     color: Colors.brown,
                                      //     child: InkWell(
                                      //       onTap: _showReturnDialog,
                                      //       child: Container(
                                      //         height: 40,
                                      //         width: 120,
                                      //         alignment: Alignment.center,
                                      //         decoration: BoxDecoration(
                                      //           border: Border.all(
                                      //             color: Colors.brown,
                                      //           ),
                                      //         ),
                                      //         child: Text(
                                      //           'Trả hàng',
                                      //           style: TextStyle(
                                      //             color: Colors.white,
                                      //           ),
                                      //         ),
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Container(
                                        height: 60,
                                        alignment: Alignment.centerRight,
                                        child: Material(
                                          color: Colors.white,
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.pushNamed(context,
                                                  AddReviewScreen.routeName,
                                                  arguments: widget.order);
                                            },
                                            child: Container(
                                              height: 40,
                                              width: 120,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.brown,
                                                ),
                                              ),
                                              child: Text(
                                                'Đánh giá',
                                                style: TextStyle(
                                                  color: Colors.brown,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : SizedBox.shrink(),
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
