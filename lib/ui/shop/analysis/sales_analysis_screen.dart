import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:luanvan/blocs/order/order_bloc.dart';
import 'package:luanvan/blocs/order/order_event.dart';
import 'package:luanvan/blocs/order/order_state.dart';
import 'package:luanvan/blocs/productorder/product_order_bloc.dart';
import 'package:luanvan/blocs/productorder/product_order_event.dart';
import 'package:luanvan/blocs/productorder/product_order_state.dart';
import 'package:luanvan/blocs/shop/shop_bloc.dart';
import 'package:luanvan/blocs/shop/shop_state.dart';
import 'package:luanvan/models/order.dart';

class SalesAnalysisScreen extends StatefulWidget {
  const SalesAnalysisScreen({super.key});
  static const String routeName = '/sales-analysis-screen';

  @override
  State<SalesAnalysisScreen> createState() => _SalesAnalysisScreenState();
}

class _SalesAnalysisScreenState extends State<SalesAnalysisScreen> {
  List<String> listProductId = [];
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shopState = context.read<ShopBloc>().state;
      if (shopState is ShopLoaded) {
        final shop = shopState.shop;
        if (shop != null) {
          context.read<OrderBloc>().add(FetchOrdersByShopId(shop.shopId!));
        }
      }
    });
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

  final List<FlSpot> chartData = [
    const FlSpot(1, 7),
    const FlSpot(3, 28),
    const FlSpot(5, 14),
    const FlSpot(7, 28),
    const FlSpot(9, 21),
    const FlSpot(11, 0),
    const FlSpot(13, 14),
    const FlSpot(15, 28),
    const FlSpot(17, 3),
    const FlSpot(19, 0),
    const FlSpot(21, 7),
    const FlSpot(23, 3),
    const FlSpot(25, 0),
  ];

  OrderStatus? selectedOrderStatus;

  // Thêm biến để lưu khoảng thời gian
  DateTimeRange selectedDateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  // Thêm getter để format hiển thị khoảng thời gian
  String get timeRangeLabel {
    final int days = selectedDateRange.duration.inDays;
    final DateTime now = DateTime.now();
    final vietnameseDateFormat = DateFormat('d MMM', 'vi_VN');

    bool isEndingNow = selectedDateRange.end.difference(now).inDays.abs() <= 1;

    if (isEndingNow) {
      if (days <= 7) return 'Trong 7 ngày qua';
      if (days <= 30) return 'Trong 30 ngày qua';
      if (days <= 60) return 'Trong 2 tháng qua';
      if (days <= 90) return 'Trong 3 tháng qua';
      if (days <= 365) return 'Trong năm qua';
    }

    return '${vietnameseDateFormat.format(selectedDateRange.start)} - ${vietnameseDateFormat.format(selectedDateRange.end)}';
  }

  // Thêm method chọn khoảng thời gian định sẵn
  void _selectPredefinedRange(String range) {
    final now = DateTime.now();
    DateTime start;

    switch (range) {
      case '7 ngày':
        start = now.subtract(const Duration(days: 7));
        break;
      case '30 ngày':
        start = now.subtract(const Duration(days: 30));
        break;
      case '2 tháng':
        start = now.subtract(const Duration(days: 60));
        break;
      case '3 tháng':
        start = now.subtract(const Duration(days: 90));
        break;
      case '1 năm':
        start = now.subtract(const Duration(days: 365));
        break;
      default:
        return;
    }

    setState(() {
      selectedDateRange = DateTimeRange(start: start, end: now);
    });
    Navigator.pop(context);
  }

  // Thêm hàm lọc đơn hàng chung
  List<Order> _getFilteredOrders(List<Order> orders) {
    return orders.where((order) {
      // Lọc theo thời gian
      bool isInDateRange = order.createdAt.isAfter(selectedDateRange.start) &&
          order.createdAt
              .isBefore(selectedDateRange.end.add(const Duration(days: 1)));

      // Lọc theo trạng thái
      bool matchesStatus =
          selectedOrderStatus == null || order.status == selectedOrderStatus;

      return isInDateRange && matchesStatus;
    }).toList();
  }

  // Thêm method để tính toán tỉ lệ thay đổi
  Map<String, double> _calculateChangeRates(List<Order> currentOrders) {
    final previousStart = selectedDateRange.start.subtract(
      Duration(days: selectedDateRange.duration.inDays),
    );
    final previousEnd = selectedDateRange.start;

    // Lấy đơn hàng của khoảng thời gian trước đó
    final previousOrders = currentOrders.where((order) {
      return order.createdAt.isAfter(previousStart) &&
          order.createdAt.isBefore(previousEnd) &&
          (selectedOrderStatus == null || order.status == selectedOrderStatus);
    }).toList();

    // Tính toán các chỉ số cho khoảng thời gian hiện tại
    final currentOrderCount = currentOrders.length;
    final currentRevenue =
        currentOrders.fold(0.0, (sum, order) => sum + order.totalPrice);
    final currentAverage =
        currentOrderCount > 0 ? currentRevenue / currentOrderCount : 0;

    // Tính toán các chỉ số cho khoảng thời gian trước đó
    final previousOrderCount = previousOrders.length;
    final previousRevenue =
        previousOrders.fold(0.0, (sum, order) => sum + order.totalPrice);
    final previousAverage =
        previousOrderCount > 0 ? previousRevenue / previousOrderCount : 0;

    // Tính tỉ lệ thay đổi
    final orderChange = previousOrderCount > 0
        ? ((currentOrderCount - previousOrderCount) / previousOrderCount * 100)
        : 0.0;
    final revenueChange = previousRevenue > 0
        ? ((currentRevenue - previousRevenue) / previousRevenue * 100)
        : 0.0;
    final averageChange = previousAverage > 0
        ? ((currentAverage - previousAverage) / previousAverage * 100)
        : 0.0;

    return {
      'orderChange': orderChange,
      'revenueChange': revenueChange,
      'averageChange': averageChange,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Phân Tích Bán Hàng',
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderShopLoaded) {
            List<Order> filteredOrders = state.orders;
            listProductId = filteredOrders
                .expand((order) => order.item)
                .map((item) => item.productId)
                .toList();
            context
                .read<ProductOrderBloc>()
                .add(FetchMultipleProductsOrderEvent(listProductId));
            return BlocBuilder<ProductOrderBloc, ProductOrderState>(
              builder: (context, productState) {
                if (productState is ProductOrderListLoaded) {
                  return Container(
                    color: Colors.white,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFilters(),
                          _buildTimeInfo(),
                          _buildImportantMetrics(),
                          _buildOrderChart(),
                          _buildProductRanking(),
                        ],
                      ),
                    ),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildFilterButton(
              'Loại Đơn Hàng',
              selectedOrderStatus != null
                  ? _getOrderStatusText(selectedOrderStatus!)
                  : 'Tất cả đơn hàng',
              onTap: _showOrderStatusFilter,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildFilterButton(
              'Khoảng Thời Gian',
              timeRangeLabel,
              onTap: _showDateRangePicker,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo() {
    final vietnameseDateFormat = DateFormat('d MMM', 'vi_VN');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              Text(
                'Chỉ số quan trọng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.info_outline, size: 16),
            ],
          ),
          Text(
            '${vietnameseDateFormat.format(selectedDateRange.start)} - ${vietnameseDateFormat.format(selectedDateRange.end)}',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String title, String value, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showOrderStatusFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Tất cả đơn hàng'),
            selected: selectedOrderStatus == null,
            onTap: () => _updateOrderStatus(null),
          ),
          ...OrderStatus.values.map((status) => ListTile(
                title: Text(_getOrderStatusText(status)),
                selected: selectedOrderStatus == status,
                onTap: () => _updateOrderStatus(status),
              )),
        ],
      ),
    );
  }

  void _updateOrderStatus(OrderStatus? status) {
    setState(() {
      selectedOrderStatus = status;
    });
    Navigator.pop(context);
    // TODO: Implement your filter logic here based on selected status
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
        return 'Đã giao';
      case OrderStatus.reviewed:
        return 'Đã đánh giá';
      case OrderStatus.returned:
        return 'Trả hàng';
      case OrderStatus.cancelled:
        return 'Đã hủy';
      default:
        return 'Tất cả đơn hàng';
    }
  }

  Widget _buildImportantMetrics() {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        if (state is OrderShopLoaded) {
          final filteredOrders = _getFilteredOrders(state.orders);
          final totalRevenue =
              filteredOrders.fold(0.0, (sum, order) => sum + order.totalPrice);
          final averageOrderValue = filteredOrders.isEmpty
              ? 0.0
              : totalRevenue / filteredOrders.length;

          // Tính toán tỉ lệ thay đổi
          final changes = _calculateChangeRates(filteredOrders);

          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        'Đơn hàng',
                        filteredOrders.length.toString(),
                        '${changes['orderChange']!.toStringAsFixed(1)}%',
                        changes['orderChange']! >= 0
                            ? Colors.green
                            : Colors.red,
                        changes['orderChange']! < 0,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        'Doanh số(đ)',
                        totalRevenue.toString(),
                        '${changes['revenueChange']!.toStringAsFixed(1)}%',
                        changes['revenueChange']! >= 0
                            ? Colors.green
                            : Colors.red,
                        changes['revenueChange']! < 0,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        'Doanh số trên mỗi đơn hàng(đ)',
                        averageOrderValue.toString(),
                        '${changes['averageChange']!.toStringAsFixed(1)}%',
                        changes['averageChange']! >= 0
                            ? Colors.green
                            : Colors.red,
                        changes['averageChange']! < 0,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String percentage,
    Color color,
    bool isDown,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            (title == 'Doanh số(đ)' || title == 'Doanh số trên mỗi đơn hàng(đ)')
                ? formatPrice(double.parse(value))
                : value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              Icon(
                isDown ? Icons.arrow_downward : Icons.arrow_upward,
                size: 12,
                color: color,
              ),
              Text(
                percentage,
                style: TextStyle(fontSize: 12, color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderChart() {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        if (state is OrderShopLoaded) {
          final filteredOrders = _getFilteredOrders(state.orders);

          // Tạo map để đếm số đơn hàng theo ngày
          final ordersByDate = <DateTime, int>{};

          // Khởi tạo tất cả các ngày trong khoảng với giá trị 0
          for (var d = selectedDateRange.start;
              d.isBefore(selectedDateRange.end.add(const Duration(days: 1)));
              d = d.add(const Duration(days: 1))) {
            ordersByDate[DateTime(d.year, d.month, d.day)] = 0;
          }

          // Đếm số đơn hàng cho mỗi ngày
          for (var order in filteredOrders) {
            final orderDate = DateTime(
              order.createdAt.year,
              order.createdAt.month,
              order.createdAt.day,
            );
            ordersByDate[orderDate] = (ordersByDate[orderDate] ?? 0) + 1;
          }

          // Chuyển đổi dữ liệu sang định dạng FlSpot
          final spots = ordersByDate.entries.map((entry) {
            final days =
                entry.key.difference(selectedDateRange.start).inDays.toDouble();
            return FlSpot(days, entry.value.toDouble());
          }).toList();

          // Sắp xếp spots theo thời gian
          spots.sort((a, b) => a.x.compareTo(b.x));

          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Biểu đồ đơn hàng ${timeRangeLabel}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.info_outline, size: 16),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 1,
                      ),
                      titlesData: FlTitlesData(
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            reservedSize: 30,
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: spots.length > 30 ? 5 : 1,
                            getTitlesWidget: (value, meta) {
                              final date = selectedDateRange.start.add(
                                Duration(days: value.toInt()),
                              );
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  '${date.day}/${date.month}',
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: Colors.red,
                          barWidth: 2,
                          dotData: FlDotData(
                            show: spots.length < 30,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 3,
                                color: Colors.red,
                                strokeWidth: 1,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.red.withOpacity(0.1),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        enabled: true,
                        touchTooltipData: LineTouchTooltipData(
                          tooltipBgColor: Colors.white,
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              final date = selectedDateRange.start.add(
                                Duration(days: spot.x.toInt()),
                              );
                              return LineTooltipItem(
                                '${date.day}/${date.month}\n${spot.y.toInt()} đơn',
                                const TextStyle(color: Colors.black),
                              );
                            }).toList();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildProductRanking() {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        if (state is OrderShopLoaded) {
          final filteredOrders = _getFilteredOrders(state.orders);
          final productStats = <String, Map<String, dynamic>>{};

          for (var order in filteredOrders) {
            for (var item in order.item) {
              if (!productStats.containsKey(item.productId)) {
                productStats[item.productId] = {
                  'quantity': 0,
                  'revenue': 0.0,
                };
              }
              productStats[item.productId]!['quantity'] += item.quantity;
              productStats[item.productId]!['revenue'] += item.quantity;
            }
          }

          final sortedProducts = productStats.entries.toList()
            ..sort((a, b) => (b.value['revenue'] as double)
                .compareTo(a.value['revenue'] as double));

          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Text(
                          'Sản phẩm bán chạy nhất',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.info_outline, size: 16),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Hiển thị top 3 sản phẩm
                ...sortedProducts.take(3).map((entry) {
                  final index = sortedProducts.indexOf(entry);
                  return BlocBuilder<ProductOrderBloc, ProductOrderState>(
                    builder: (context, productState) {
                      if (productState is ProductOrderListLoaded) {
                        final product = productState.products.firstWhere(
                          (p) => p.id == entry.key,
                        );
                        if (product != null) {
                          return _buildProductItem(
                            rank: index + 1,
                            image: product.imageUrl.isNotEmpty
                                ? product.imageUrl[0]
                                : '',
                            name: product.name,
                            quantity: entry.value['quantity'] as int,
                            revenue: entry.value['revenue'] as double,
                          );
                        }
                      }
                      return const SizedBox.shrink();
                    },
                  );
                }).toList(),
              ],
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildProductItem({
    required int rank,
    required String image,
    required String name,
    required int quantity,
    required double revenue,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            alignment: Alignment.center,
            child: Text(
              '$rank',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
              image: image.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(image),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Đã bán: $quantity',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Doanh thu: ${formatPrice(revenue)}đ',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Thêm method hiển thị bottom sheet chọn thời gian
  Future<void> _showDateRangePicker() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('7 ngày qua'),
              onTap: () => _selectPredefinedRange('7 ngày'),
            ),
            ListTile(
              title: const Text('30 ngày qua'),
              onTap: () => _selectPredefinedRange('30 ngày'),
            ),
            ListTile(
              title: const Text('2 tháng qua'),
              onTap: () => _selectPredefinedRange('2 tháng'),
            ),
            ListTile(
              title: const Text('3 tháng qua'),
              onTap: () => _selectPredefinedRange('3 tháng'),
            ),
            ListTile(
              title: const Text('1 năm qua'),
              onTap: () => _selectPredefinedRange('1 năm'),
            ),
            ListTile(
              title: const Text('Tùy chỉnh...'),
              onTap: () async {
                Navigator.pop(context);
                final DateTimeRange? picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDateRange: selectedDateRange,
                  saveText: 'Chọn',
                  cancelText: 'Hủy',
                  confirmText: 'Xác nhận',
                  locale: const Locale('vi', 'VN'),
                  builder: (BuildContext context, Widget? child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        appBarTheme: const AppBarTheme(
                          backgroundColor: Colors.red,
                          iconTheme: IconThemeData(color: Colors.white),
                          titleTextStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );

                if (picked != null && picked != selectedDateRange) {
                  setState(() {
                    selectedDateRange = picked;
                  });
                  // TODO: Implement your filter logic here based on selected date range
                }
              },
            ),
          ],
        );
      },
    );
  }
}
