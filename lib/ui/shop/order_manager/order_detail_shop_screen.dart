import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:luanvan/blocs/chat/chat_bloc.dart';
import 'package:luanvan/blocs/chat/chat_event.dart';
import 'package:luanvan/blocs/order/order_bloc.dart';
import 'package:luanvan/blocs/order/order_event.dart';
import 'package:luanvan/blocs/order/order_state.dart';
import 'package:luanvan/models/order.dart';
import 'package:intl/intl.dart';

import 'package:luanvan/ui/helper/icon_helper.dart';
import 'package:luanvan/ui/shop/chat/shop_chat_detail_screen.dart';
import 'package:luanvan/ui/shop/order_manager/detail_product_and_shop.dart';
import 'package:luanvan/ui/shop/order_manager/packing_slip_screen.dart';

class OrderDetailShopScreen extends StatefulWidget {
  static const String routeName = 'order_detail_shop_screen';

  const OrderDetailShopScreen({super.key});

  @override
  State<OrderDetailShopScreen> createState() => _OrderDetailShopScreenState();
}

class _OrderDetailShopScreenState extends State<OrderDetailShopScreen> {
  String formatPrice(double price) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }

  String formatDate(DateTime date) {
    return DateFormat('dd-MM-yyyy HH:mm').format(date);
  }

  String getPaymentMethodName(String paymentMethod) {
    switch (paymentMethod.toLowerCase()) {
      case 'cod':
        return 'Thanh toán khi nhận hàng';
      case 'bank':
        return 'Chuyển khoản ngân hàng';
      case 'momo':
        return 'Ví MoMo';
      case 'vnpay':
        return 'VNPay';
      case 'zalopay':
        return 'ZaloPay';
      case 'shopee':
        return 'Ví ShopeePay';
      default:
        return paymentMethod;
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = ModalRoute.of(context)!.settings.arguments as Order;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Chi tiết đơn hàng'),
      ),
      body: Container(
        color: Colors.grey[200],
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildStatusSection(order),
              _buildPaymentInfo(order),
              _buildPaymentMethod(order),
              if (order.status == OrderStatus.shipped ||
                  order.status == OrderStatus.delivered ||
                  order.status == OrderStatus.reviewed)
                Container(
                  margin: EdgeInsets.only(top: 10),
                  width: double.infinity,
                  height: 70,
                  padding: const EdgeInsets.all(10),
                  color: Colors.white,
                  alignment: Alignment.center,
                  child: Row(children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('Thông tin vận chuyển',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            )),
                        Text('${order.shipMethod.name}: ${order.shippingCode}'),
                      ],
                    ),
                  ]),
                ),
              DetailProductAndShop(order: order),
              _buildOrderInfoSection(order),
              if (order.status == OrderStatus.pending)
                SizedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: _buildCancelButton(order)),
                      Expanded(child: _buildShopContactButton(order)),
                      SizedBox(width: 16),
                    ],
                  ),
                ),
              if (order.status == OrderStatus.returned ||
                  order.status == OrderStatus.cancelled ||
                  order.status == OrderStatus.processing)
                Container(
                  padding: const EdgeInsets.only(right: 16),
                  child: _buildShopContactButton(order),
                ),
              if (order.status == OrderStatus.shipped)
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(right: 16),
                      child: _buildShopContactButton(order),
                    ),
                    Container(
                      padding: const EdgeInsets.only(right: 16),
                      child: _buildPrintOrderBillButton(order),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusSection(Order order) {
    Color statusColor;
    String statusText;

    switch (order.status) {
      case OrderStatus.pending:
        statusColor = Colors.orange;
        statusText = 'Chờ xác nhận';
        break;
      case OrderStatus.shipped:
        statusColor = Colors.blue;
        statusText = 'Đang giao';
        break;
      case OrderStatus.delivered:
        statusColor = Colors.green;
        statusText = 'Đã giao';
        break;
      case OrderStatus.cancelled:
        statusColor = Colors.red;
        statusText = 'Đã hủy';
        break;
      case OrderStatus.processing:
        statusColor = Colors.purple;
        statusText = 'Đang xử lý';
        break;
      case OrderStatus.returned:
        statusColor = Colors.grey;
        statusText = 'Đã trả hàng';
        break;
      case OrderStatus.reviewed:
        statusColor = Colors.green;
        statusText = 'Đã đánh giá';
        break;
    }

    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 40,
            color: statusColor,
            alignment: Alignment.center,
            child: Text(
              'Đơn hàng $statusText',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(IconHelper.locaiton_pin,
                    height: 25, width: 25, color: Colors.green[700]),
                const SizedBox(width: 5),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'Địa chỉ nhận hàng',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Text(
                            order.receiveAdress.receiverName,
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            ' ( ${order.receiveAdress.receiverPhone} )',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                      Text(
                        '${order.receiveAdress.addressLine}, ${order.receiveAdress.ward}, ${order.receiveAdress.district}, ${order.receiveAdress.city}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
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

  Widget _buildPaymentInfo(Order order) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(
        top: 10,
      ),
      child: Column(
        children: [
          Row(
            children: [
              SvgPicture.asset(IconHelper.dollar,
                  height: 25, width: 25, color: Colors.green[700]),
              const SizedBox(
                width: 10,
              ),
              Text(
                'Thông tin thanh toán',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const SizedBox(width: 35),
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tổng tiền sản phẩm'),
                        Text('đ${formatPrice(order.totalProductPrice)}'),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Phí vận chuyển'),
                        Text('đ${formatPrice(order.totalShipFee)}'),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tổng đơn hàng'),
                        Text('đ${formatPrice(order.totalPrice)}'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(Order order) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Phương thức thanh toán',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 5),
          Text(getPaymentMethodName(order.paymentMethod.name)),
        ],
      ),
    );
  }

  Widget _buildOrderInfoSection(Order order) {
    return Container(
      margin: EdgeInsets.only(
        top: 10,
      ),
      padding: EdgeInsets.all(10),
      width: double.infinity,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mã đơn hàng',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  )),
              Text(order.trackingNumber ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  )),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 1,
            color: Colors.grey[300],
          ),
          Column(
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Thời gian đặt hàng:'),
                  Text(formatDate(order.createdAt)),
                ],
              ),
              (order.statusHistory.length > 0 &&
                      order.status == OrderStatus.cancelled)
                  ? Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Thời gian hủy đơn hàng:'),
                            Text(formatDate(order.statusHistory
                                .firstWhere((element) =>
                                    element.status == OrderStatus.cancelled)
                                .timestamp)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Lý do hủy đơn:'),
                            Text(order.statusHistory
                                    .firstWhere((element) =>
                                        element.status == OrderStatus.cancelled)
                                    .note ??
                                'Không có lý do'),
                          ],
                        ),
                      ],
                    )
                  : SizedBox.shrink(),
              (order.statusHistory.length > 0 &&
                      order.status != OrderStatus.cancelled)
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Thời gian xác nhận:'),
                        Text(formatDate(order.statusHistory.first.timestamp)),
                      ],
                    )
                  : SizedBox.shrink(),
              (order.statusHistory.length > 1)
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Thời gian người bán chuẩn bị hàng:'),
                        Text(formatDate(order.statusHistory[1].timestamp)),
                      ],
                    )
                  : SizedBox.shrink(),
              if (order.status == OrderStatus.delivered ||
                  order.status == OrderStatus.reviewed)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Giao hàng thành công:'),
                    Text(
                        formatDate(order.actualDeliveryDate ?? DateTime.now())),
                  ],
                ),
              const SizedBox(height: 5),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton(Order order) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 16),
      child: GestureDetector(
        onTap: () async {
          String? selectedReason;
          final reasons = [
            'Sản phẩm hết hàng',
            'Không liên lạc được với khách hàng',
            'Lý do khác'
          ];

          final result = await showModalBottomSheet<Map<String, String>>(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => StatefulBuilder(
              builder: (context, setState) => Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Lý do hủy đơn',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Vui lòng chọn lý do hủy đơn:',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ...reasons.map((reason) => RadioListTile<String>(
                          title: Text(reason),
                          value: reason,
                          groupValue: selectedReason,
                          onChanged: (value) {
                            setState(() {
                              selectedReason = value;
                            });
                          },
                        )),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: selectedReason == null
                            ? null
                            : () {
                                Navigator.pop(
                                    context, {'reason': selectedReason!});
                              },
                        child: const Text(
                          'Xác nhận',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );

          if (result != null) {
            context
                .read<OrderBloc>()
                .add(CancelOrder(order.id, note: result['reason']));
            await context
                .read<OrderBloc>()
                .stream
                .firstWhere((element) => element is OrderDetailLoaded);
            Navigator.pop(context, 'cancel');
          }
        },
        child: Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.brown),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              'Hủy đơn hàng',
              style: TextStyle(color: Colors.brown),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShopContactButton(Order order) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 16),
      child: GestureDetector(
        onTap: () {
          context.read<ChatBloc>().add(StartChatEvent(
                order.userId,
                order.shopId,
              ));
          final tempChatRoomId = '${order.userId}-${order.shopId}';
          Navigator.pushNamed(
            context,
            ShopChatDetailScreen.routeName,
            arguments: tempChatRoomId,
          );
        },
        child: Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.brown,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              'Liên hệ người mua',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrintOrderBillButton(Order order) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 16),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            PackingSlipScreen.routeName,
            arguments: order,
          );
        },
        child: Container(
          width: double.infinity,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.brown),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.print),
              const SizedBox(width: 10),
              Text(
                'In phiếu giao hàng',
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
