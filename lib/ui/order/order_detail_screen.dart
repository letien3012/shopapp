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
import 'package:luanvan/ui/chat/chat_detail_screen.dart';
import 'package:luanvan/ui/helper/icon_helper.dart';
import 'package:luanvan/ui/order/shop_order_detail.dart';

class OrderDetailScreen extends StatefulWidget {
  static const String routeName = 'order_detail_screen';

  const OrderDetailScreen({super.key});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool isShowMoreDetailOrderDate = false;
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
        title: Text('Thông tin đơn hàng'),
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
              ShopOrderDetail(order: order),
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
              if (order.status == OrderStatus.processing ||
                  order.status == OrderStatus.shipped ||
                  order.status == OrderStatus.returned)
                Container(
                  padding: const EdgeInsets.only(right: 16),
                  child: _buildShopContactButton(order),
                ),
              if (order.status == OrderStatus.delivered)
                Container(
                  padding: const EdgeInsets.only(right: 16),
                  child: _buildShopContactButton(order),
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
      margin: EdgeInsets.only(top: 10, left: 10, right: 10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
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
          if (order.status == OrderStatus.shipped ||
              order.status == OrderStatus.delivered ||
              order.status == OrderStatus.reviewed)
            Container(
              width: double.infinity,
              height: 60,
              padding: const EdgeInsets.all(10),
              color: Colors.white,
              alignment: Alignment.center,
              child: Row(children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('Thông tin vận chuyển'),
                    Text('${order.shipMethod.name}: ${order.shippingCode}'),
                  ],
                ),
              ]),
            ),
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  IconHelper.locaiton_pin,
                  height: 25,
                  width: 25,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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

  Widget _buildOrderInfoSection(Order order) {
    return Container(
      margin: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 20),
      padding: EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mã đơn hàng',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(order.trackingNumber ?? '',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Phương thức thanh toán',
              ),
              Text(
                getPaymentMethodName(order.paymentMethod.name),
              ),
            ],
          ),
          const SizedBox(height: 10),
          isShowMoreDetailOrderDate
              ? Container(
                  height: 1,
                  color: Colors.grey[300],
                )
              : SizedBox(),
          AnimatedContainer(
            curve: Curves.easeInOut,
            duration: const Duration(milliseconds: 300),
            height: isShowMoreDetailOrderDate
                ? (order.status == OrderStatus.delivered ||
                        order.status == OrderStatus.reviewed)
                    ? 125
                    : (order.status == OrderStatus.returned)
                        ? 145
                        : (order.statusHistory.isNotEmpty &&
                                order.statusHistory.any((element) =>
                                    element.status == OrderStatus.shipped)
                            ? 105
                            : (order.statusHistory.isNotEmpty &&
                                    order.statusHistory.any((element) =>
                                        element.status ==
                                        OrderStatus.processing)
                                ? 85
                                : (order.status == OrderStatus.cancelled)
                                    ? 105
                                    : 65))
                : 0,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ngày đặt hàng:'),
                      Text(formatDate(order.createdAt)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ngày giao hàng dự kiến:'),
                      Text(formatDate(
                          order.estimatedDeliveryDate ?? DateTime.now())),
                    ],
                  ),
                  if (order.statusHistory.isNotEmpty &&
                      order.statusHistory.any((element) =>
                          element.status == OrderStatus.processing))
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Thời gian người bán xác nhận:'),
                        Text(formatDate(order.statusHistory
                            .firstWhere((element) =>
                                element.status == OrderStatus.processing)
                            .timestamp)),
                      ],
                    ),
                  if (order.statusHistory.isNotEmpty &&
                      order.statusHistory.any(
                          (element) => element.status == OrderStatus.shipped))
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Thời gian người bán chuẩn bị hàng:'),
                        Text(formatDate(order.statusHistory
                            .firstWhere((element) =>
                                element.status == OrderStatus.shipped)
                            .timestamp)),
                      ],
                    ),
                  if (order.status == OrderStatus.delivered ||
                      order.status == OrderStatus.reviewed ||
                      order.status == OrderStatus.returned)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Giao hàng thành công:'),
                        Text(formatDate(
                            order.actualDeliveryDate ?? DateTime.now())),
                      ],
                    ),
                  if (order.status == OrderStatus.returned)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Lý do trả hàng:'),
                        Text(order.statusHistory
                                .firstWhere((element) =>
                                    element.status == OrderStatus.returned)
                                .note ??
                            'Không có lý do'),
                      ],
                    ),
                  if (order.status == OrderStatus.cancelled)
                    Column(children: [
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
                    ]),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                isShowMoreDetailOrderDate = !isShowMoreDetailOrderDate;
              });
            },
            child: Container(
              alignment: Alignment.center,
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(isShowMoreDetailOrderDate ? 'Rút gọn' : 'Xem chi tiết'),
                  Icon(
                      isShowMoreDetailOrderDate
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 20),
                ],
              ),
            ),
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
            'Muốn thay đổi sản phẩm trong đơn hàng',
            'Đổi ý, không muốn mua nữa',
            'Khác'
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
            ChatDetailScreen.routeName,
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
              'Liên hệ shop',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
