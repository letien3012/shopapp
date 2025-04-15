import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:luanvan/blocs/alluser/all_user_bloc.dart';
import 'package:luanvan/blocs/alluser/all_user_event.dart';
import 'package:luanvan/blocs/alluser/all_user_state.dart';
import 'package:luanvan/blocs/auth/auth_bloc.dart';
import 'package:luanvan/blocs/auth/auth_state.dart';
import 'package:luanvan/blocs/order/order_bloc.dart';
import 'package:luanvan/blocs/order/order_event.dart';
import 'package:luanvan/blocs/order/order_state.dart';
import 'package:luanvan/models/order.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});
  static String routeName = "admin_home_screen";
  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int bannerCurrentPage = 0;

  int _selectedYear = DateTime.now().year;
  final List<int> _years =
      List.generate(5, (index) => DateTime.now().year - index);
  int? _selectedUserSection;
  int? _selectedOrderSection;

  // Dữ liệu mẫu cho biểu đồ doanh thu theo năm
  final Map<int, List<double>> _revenueData = {
    2024: [40, 50, 30, 60, 80, 70, 90, 65, 75, 85, 95, 100],
    2023: [35, 45, 25, 55, 75, 65, 85, 60, 70, 80, 90, 95],
    2022: [30, 40, 20, 50, 70, 60, 80, 55, 65, 75, 85, 90],
    2021: [25, 35, 15, 45, 65, 55, 75, 50, 60, 70, 80, 85],
    2020: [20, 30, 10, 40, 60, 50, 70, 45, 55, 65, 75, 80],
  };

  List<double> _getRevenueDataForYear(int year) {
    return _revenueData[year] ??
        _revenueData[DateTime.now().year] ??
        List.filled(12, 0.0);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AdminAuthenticated) {
        context.read<AllUserBloc>().add(FetchAllUserEvent());
        context
            .read<OrderBloc>()
            .add(FetchOrdersByShopId(authState.shop.shopId!));
      }
    });
  }

  String formatPrice(double price) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }

  Widget _buildPieChart({
    required String title,
    required List<PieChartSectionData> sections,
    required List<String> legends,
    required List<Color> colors,
    required int? selectedSection,
    required Function(int?) onSectionSelected,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: sections,
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        if (event is FlTapUpEvent &&
                            pieTouchResponse?.touchedSection != null) {
                          final sectionIndex = pieTouchResponse!
                              .touchedSection!.touchedSectionIndex;
                          onSectionSelected(sectionIndex);
                        } else if (event is FlTapUpEvent) {
                          onSectionSelected(null);
                        }
                      },
                    ),
                  ),
                ),
              ),
              if (selectedSection != null)
                Positioned(
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      '${sections[selectedSection].value.toInt()}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: List.generate(
              legends.length,
              (index) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[index],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(legends[index]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (BuildContext context, AuthState authState) {
          if (authState is AuthLoading) return _buildLoading();
          if (authState is AdminAuthenticated) {
            return BlocBuilder<AllUserBloc, AllUserState>(
              builder: (context, userState) {
                if (userState is AllUserLoaded) {
                  return BlocBuilder<OrderBloc, OrderState>(
                    builder: (context, orderState) {
                      return _buildHomeScreen(context, userState, orderState);
                    },
                  );
                }
                if (userState is AllUserError) {
                  return _buildError(userState.message);
                }
                if (userState is AllUserLoading) {
                  return _buildLoading();
                }
                return _buildInitializing();
              },
            );
          } else if (authState is AuthError) {
            return _buildError(authState.message);
          }
          if (authState is AuthLoading) {
            return _buildLoading();
          }
          return _buildInitializing();
        },
      ),
    );
  }

  // Trạng thái đang tải
  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  // Trạng thái lỗi
  Widget _buildError(String message) {
    return Center(child: Text('Error: $message'));
  }

  // Trạng thái khởi tạo
  Widget _buildInitializing() {
    return const Center(child: Text('Đang khởi tạo'));
  }

  Widget _buildHomeScreen(
      BuildContext context, AllUserState userState, OrderState orderState) {
    return Scaffold(
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              final authState = context.read<AuthBloc>().state;
              if (authState is AdminAuthenticated) {
                context.read<AllUserBloc>().add(FetchAllUserEvent());
                context
                    .read<OrderBloc>()
                    .add(FetchOrdersByShopId(authState.shop.shopId!));
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                padding: const EdgeInsets.only(bottom: 10),
                color: Colors.grey[200],
                constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height),
                child: Column(
                  children: [
                    const SizedBox(height: 90),
                    Container(
                      height: 10,
                      width: double.infinity,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 10),

                    // Bảng thống kê tổng quan
                    _buildStatisticsTable(userState, orderState),

                    // Biểu đồ thống kê người dùng
                    _buildUserPieChart(userState),

                    // Biểu đồ thống kê đơn hàng
                    _buildOrderPieChart(orderState),

                    // Biểu đồ thống kê doanh thu theo tháng
                    if (orderState is OrderLoaded)
                      _buildRevenueChart(orderState),
                  ],
                ),
              ),
            ),
          ),

          //Appbar
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              height: 90,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Colors.brown,
              ),
              padding: const EdgeInsets.only(
                  top: 30, left: 10, right: 10, bottom: 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Trang chủ',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsTable(AllUserState userState, OrderState orderState) {
    int totalUsers = 0;
    int totalOrders = 0;
    double totalRevenue = 0;

    if (userState is AllUserLoaded) {
      totalUsers = userState.users.length;
      if (orderState is OrderShopLoaded) {
        totalOrders = orderState.orders.length;
        totalRevenue =
            orderState.orders.fold(0, (sum, order) => sum + (order.totalPrice));
      }
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Tổng quan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatisticItem(
                    icon: Icons.people,
                    title: 'Tổng người dùng',
                    value: totalUsers.toString(),
                    color: Colors.blue,
                  ),
                  _buildStatisticItem(
                    icon: Icons.shopping_cart,
                    title: 'Tổng đơn hàng',
                    value: totalOrders.toString(),
                    color: Colors.green,
                  ),
                  _buildStatisticItem(
                    icon: Icons.attach_money,
                    title: 'Tổng doanh thu',
                    value: formatPrice(totalRevenue),
                    color: Colors.orange,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildUserPieChart(AllUserState userState) {
    if (userState is AllUserLoaded) {
      final newUsers = userState.users.where((user) {
        final now = DateTime.now();
        final userCreatedAt = user.createdAt.toDate();
        return now.difference(userCreatedAt).inDays <= 30;
      }).length;
      final oldUsers = userState.users.length - newUsers;

      final userSections = [
        PieChartSectionData(
          value: newUsers.toDouble(),
          title:
              '${((newUsers / userState.users.length) * 100).toStringAsFixed(0)}%',
          color: Colors.blue,
          radius: 50,
          titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        PieChartSectionData(
          value: oldUsers.toDouble(),
          title:
              '${((oldUsers / userState.users.length) * 100).toStringAsFixed(0)}%',
          color: Colors.orange,
          radius: 50,
          titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ];

      return _buildPieChart(
        title: 'Thống kê người dùng',
        sections: userSections,
        legends: const ['Người dùng mới', 'Người dùng cũ'],
        colors: const [Colors.blue, Colors.orange],
        selectedSection: _selectedUserSection,
        onSectionSelected: (index) {
          setState(() {
            _selectedUserSection = index;
          });
        },
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildOrderPieChart(OrderState orderState) {
    if (orderState is OrderShopLoaded) {
      final completedOrders = orderState.orders
          .where((order) =>
              order.status == OrderStatus.delivered ||
              order.status == OrderStatus.reviewed)
          .length;
      final processingOrders = orderState.orders
          .where((order) =>
              order.status == OrderStatus.processing ||
              order.status == OrderStatus.pending ||
              order.status == OrderStatus.shipped)
          .length;
      final cancelledOrders = orderState.orders
          .where((order) => order.status == OrderStatus.cancelled)
          .length;

      final orderSections = [
        PieChartSectionData(
          value: completedOrders.toDouble(),
          title:
              '${((completedOrders / orderState.orders.length) * 100).toStringAsFixed(0)}%',
          color: Colors.green,
          radius: 50,
          titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        PieChartSectionData(
          value: processingOrders.toDouble(),
          title:
              '${((processingOrders / orderState.orders.length) * 100).toStringAsFixed(0)}%',
          color: Colors.red,
          radius: 50,
          titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        PieChartSectionData(
          value: cancelledOrders.toDouble(),
          title:
              '${((cancelledOrders / orderState.orders.length) * 100).toStringAsFixed(0)}%',
          color: Colors.purple,
          radius: 50,
          titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ];

      return _buildPieChart(
        title: 'Thống kê đơn hàng',
        sections: orderSections,
        legends: const ['Hoàn thành', 'Đang xử lý', 'Đã hủy'],
        colors: const [Colors.green, Colors.red, Colors.purple],
        selectedSection: _selectedOrderSection,
        onSectionSelected: (index) {
          setState(() {
            _selectedOrderSection = index;
          });
        },
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildRevenueChart(OrderState orderState) {
    if (orderState is OrderShopLoaded) {
      // Lọc các đơn hàng đã hoàn thành (reviewed hoặc delivered)
      final completedOrders = orderState.orders
          .where((order) =>
              order.status == OrderStatus.reviewed ||
              order.status == OrderStatus.delivered)
          .toList();

      // Tính doanh thu theo tháng cho năm hiện tại
      final now = DateTime.now();
      final monthlyRevenue = List<double>.filled(12, 0.0);

      for (var order in completedOrders) {
        final orderDate = order.createdAt;
        if (orderDate.year == _selectedYear) {
          final month = orderDate.month - 1; // Chuyển từ 1-12 thành 0-11
          monthlyRevenue[month] += order.totalPrice;
        }
      }

      // Tìm giá trị lớn nhất để làm maxY cho biểu đồ
      final maxRevenue = monthlyRevenue.reduce((a, b) => a > b ? a : b);
      final maxY =
          (maxRevenue / 1000000).ceil() * 1000000.0; // Chuyển thành double

      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Doanh thu theo tháng',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<int>(
                    value: _selectedYear,
                    underline: const SizedBox(),
                    items: _years.map((year) {
                      return DropdownMenuItem<int>(
                        value: year,
                        child: Text(
                          'Năm $year',
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedYear = newValue;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.grey[800],
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          formatPrice(rod.toY),
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          const style = TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          );
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 0,
                            child: Text(formatPrice(value), style: style),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const style = TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          );
                          String text;
                          switch (value.toInt()) {
                            case 0:
                              text = 'T1';
                              break;
                            case 1:
                              text = 'T2';
                              break;
                            case 2:
                              text = 'T3';
                              break;
                            case 3:
                              text = 'T4';
                              break;
                            case 4:
                              text = 'T5';
                              break;
                            case 5:
                              text = 'T6';
                              break;
                            case 6:
                              text = 'T7';
                              break;
                            case 7:
                              text = 'T8';
                              break;
                            case 8:
                              text = 'T9';
                              break;
                            case 9:
                              text = 'T10';
                              break;
                            case 10:
                              text = 'T11';
                              break;
                            case 11:
                              text = 'T12';
                              break;
                            default:
                              text = '';
                              break;
                          }
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 4,
                            child: Text(text, style: style),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(12, (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: monthlyRevenue[index],
                          color: Colors.blue,
                          width: 20,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildStatisticItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
