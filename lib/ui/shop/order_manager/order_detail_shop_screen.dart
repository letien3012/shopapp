import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:luanvan/blocs/order/order_bloc.dart';
import 'package:luanvan/blocs/order/order_event.dart';
import 'package:luanvan/models/order.dart';
import 'package:intl/intl.dart';
import 'package:luanvan/ui/helper/icon_helper.dart';
import 'package:luanvan/ui/shop/order_manager/detail_product_and_shop.dart';

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
              if (order.status == OrderStatus.shipped ||
                  order.status == OrderStatus.returned ||
                  order.status == OrderStatus.cancelled)
                SizedBox(
                  child: Row(
                    children: [
                      _buildShopContactButton(order),
                      SizedBox(
                        width: 16,
                      )
                    ],
                  ),
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
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Hủy đơn hàng'),
              content: const Text('Bạn có chắc chắn muốn hủy đơn hàng này?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Không'),
                ),
                TextButton(
                  onPressed: () {
                    context.read<OrderBloc>().add(
                          CancelOrder(order.id),
                        );
                    Navigator.pop(context);
                  },
                  child: const Text('Có'),
                ),
              ],
            ),
          );
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
        onTap: () {},
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
}
