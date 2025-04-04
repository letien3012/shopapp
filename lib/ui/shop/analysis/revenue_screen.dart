import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:luanvan/blocs/order/order_bloc.dart';
import 'package:luanvan/blocs/order/order_event.dart';
import 'package:luanvan/blocs/order/order_state.dart';
import 'package:luanvan/models/order.dart';

class RevenueScreen extends StatefulWidget {
  const RevenueScreen({super.key});
  static const String routeName = 'revenue-screen';

  @override
  State<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends State<RevenueScreen> {
  @override
  void initState() {
    super.initState();
  }

  final formatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
    decimalDigits: 0,
  );

  double _calculateTotalRevenue(OrderState state) {
    if (state is OrderShopLoaded) {
      return state.orders
          .where((order) =>
              order.status == OrderStatus.delivered ||
              order.status == OrderStatus.reviewed)
          .fold(0, (sum, order) => sum + order.totalPrice);
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final shopId = ModalRoute.of(context)?.settings.arguments as String;
    context.read<OrderBloc>().add(FetchOrdersByShopId(shopId));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Tài chính',
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderShopLoaded) {
            final totalRevenue = _calculateTotalRevenue(state);
            return Container(
              color: Colors.grey[200],
              child: Column(
                children: [
                  _buildBalanceCard(totalRevenue),
                  // _buildRevenueItem(),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildBalanceCard(double totalRevenue) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng số dư',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              Text(
                '(Đã giao hoặc đã đánh giá)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            formatter.format(totalRevenue),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueItem() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      color: Colors.white,
      child: ListTile(
        leading: Icon(
          Icons.receipt_outlined,
          color: Colors.blue[700],
          size: 28,
        ),
        title: const Text(
          'Doanh Thu Đơn Hàng',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.black54,
        ),
        onTap: () {
          // Handle order revenue
        },
      ),
    );
  }
}
