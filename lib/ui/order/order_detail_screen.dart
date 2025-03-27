import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/order/order_bloc.dart';
import 'package:luanvan/blocs/order/order_event.dart';
import 'package:luanvan/blocs/order/order_state.dart';
import 'package:luanvan/models/cart_item.dart';
import 'package:luanvan/models/order.dart';
import 'package:intl/intl.dart';

class OrderDetailScreen extends StatefulWidget {
  static const String routeName = 'order_detail_screen';

  const OrderDetailScreen({super.key});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  String formatPrice(double price) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final order = ModalRoute.of(context)!.settings.arguments as Order;
    return Scaffold(
      appBar: AppBar(
        title: Text('Đơn hàng #${order.id.substring(0, 8)}'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildStatusSection(order),
            _buildOrderInfoSection(order),
            _buildProductListSection(order),
            _buildPaymentSection(order),
            _buildShippingSection(order),
            if (order.status == OrderStatus.pending) _buildCancelButton(order),
          ],
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
      padding: const EdgeInsets.all(16),
      color: statusColor.withOpacity(0.1),
      child: Column(
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            color: statusColor,
            size: 48,
          ),
          const SizedBox(height: 8),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfoSection(Order order) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          const Text(
            'Thông tin đơn hàng',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Mã đơn hàng', order.id),
          _buildInfoRow('Ngày đặt', formatDate(order.createdAt)),
          if (order.estimatedDeliveryDate != null)
            _buildInfoRow(
                'Dự kiến giao', formatDate(order.estimatedDeliveryDate!)),
        ],
      ),
    );
  }

  Widget _buildProductListSection(Order order) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          const Text(
            'Sản phẩm',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...order.item.map((item) => _buildProductItem(item)),
        ],
      ),
    );
  }

  Widget _buildProductItem(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'x${item.quantity}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mã sản phẩm: ${item.productId}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Số lượng: ${item.quantity}',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                if (item.variantId1 != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Biến thể 1: ${item.variantId1}',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                if (item.variantId2 != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Biến thể 2: ${item.variantId2}',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection(Order order) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          const Text(
            'Tổng quan thanh toán',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Tạm tính', 'đ${formatPrice(order.totalProductPrice)}'),
          _buildInfoRow(
              'Phí vận chuyển', 'đ${formatPrice(order.totalShipFee)}'),
          const Divider(height: 24),
          _buildInfoRow(
            'Tổng cộng',
            'đ${formatPrice(order.totalPrice)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildShippingSection(Order order) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          const Text(
            'Thông tin vận chuyển',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Địa chỉ nhận hàng', order.receiveAdress.addressLine),
          _buildInfoRow('Phương thức vận chuyển',
              order.paymentMethod.toString().split('.').last),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton(Order order) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () {
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
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text('Hủy đơn hàng'),
      ),
    );
  }
}
