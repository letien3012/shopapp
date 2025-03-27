import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:luanvan/blocs/auth/auth_bloc.dart';
import 'package:luanvan/blocs/auth/auth_state.dart';
import 'package:luanvan/blocs/list_shop/list_shop_bloc.dart';
import 'package:luanvan/blocs/list_shop/list_shop_event.dart';
import 'package:luanvan/blocs/list_shop/list_shop_state.dart';
import 'package:luanvan/blocs/order/order_bloc.dart';
import 'package:luanvan/blocs/order/order_event.dart';
import 'package:luanvan/blocs/order/order_state.dart';
import 'package:luanvan/blocs/productorder/product_order_bloc.dart';
import 'package:luanvan/blocs/productorder/product_order_event.dart';
import 'package:luanvan/blocs/productorder/product_order_state.dart';
import 'package:luanvan/models/order.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/models/shop.dart';
import 'package:luanvan/ui/helper/icon_helper.dart';
import 'package:luanvan/ui/order/shop_order_item.dart';

class OrderScreen extends StatefulWidget {
  static const String routeName = 'order_screen';

  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  List<String> listShopId = [];
  List<String> listProductId = [];
  final List<String> _tabs = [
    'Chờ xác nhận',
    'Chờ lấy hàng',
    'Chờ giao hàng',
    'Đã giao',
    'Trả hàng',
    'Đã hủy',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _scrollController = ScrollController();
    _loadOrders();

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _scrollToSelectedTab();
      }
    });
  }

  void _scrollToSelectedTab() {
    final RenderBox tabBox = context.findRenderObject() as RenderBox;
    final double tabBarWidth = tabBox.size.width;
    final double selectedTabPosition =
        _tabController.index * (tabBarWidth / _tabs.length);
    final double offset = selectedTabPosition - (tabBarWidth / 3);

    _scrollController.animateTo(
      offset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _loadOrders() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<OrderBloc>().add(FetchOrdersByUserId(authState.user.uid));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Đơn đã mua',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          SvgPicture.asset(
            IconHelper.chatIcon,
            color: Colors.brown,
            height: 30,
            width: 30,
          ),
          const SizedBox(
            width: 10,
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              padding: EdgeInsets.zero,
              tabAlignment: TabAlignment.start,
              labelColor: const Color(0xFF8B4513),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF8B4513),
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              tabs: _tabs
                  .map((tab) => Tab(
                        text: tab,
                        height: 44,
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((tab) => _buildOrderList(tab)).toList(),
      ),
    );
  }

  Widget _buildOrderList(String status) {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        if (state is OrderLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is OrderError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Lỗi: ${state.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadOrders,
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        if (state is OrderLoaded) {
          List<Order> filteredOrders = state.orders;
          listShopId = filteredOrders.map((order) => order.shopId).toList();
          listProductId = filteredOrders
              .expand((order) => order.item)
              .map((item) => item.productId)
              .toList();
          context
              .read<ListShopBloc>()
              .add(FetchListShopEventByShopId(listShopId));
          context
              .read<ProductOrderBloc>()
              .add(FetchMultipleProductsOrderEvent(listProductId));
          filteredOrders = state.orders.where((order) {
            switch (status) {
              case 'Chờ xác nhận':
                return order.status == OrderStatus.pending;
              case 'Chờ lấy hàng':
                return order.status == OrderStatus.processing;
              case 'Chờ giao hàng':
                return order.status == OrderStatus.shipped;
              case 'Đã giao':
                return order.status == OrderStatus.delivered;
              case 'Trả hàng':
                return order.status == OrderStatus.returned;
              case 'Đã hủy':
                return order.status == OrderStatus.cancelled;
              default:
                return true;
            }
          }).toList();

          if (filteredOrders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(IconHelper.no_order,
                      width: 350, height: 350),
                  const SizedBox(height: 16),
                  const Text(
                    'Bạn chưa có đơn hàng nào cả',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // _buildRecommendedProducts(),
                ],
              ),
            );
          }

          return BlocBuilder<ListShopBloc, ListShopState>(
            builder: (BuildContext context, ListShopState listShopState) {
              if (listShopState is ListShopLoaded) {
                return BlocBuilder<ProductOrderBloc, ProductOrderState>(
                  builder: (BuildContext context, ProductOrderState state) {
                    if (state is ProductOrderListLoaded) {
                      return ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: filteredOrders.length,
                          itemBuilder: (context, index) {
                            if (index >= filteredOrders.length) {
                              return const SizedBox.shrink();
                            }
                            // final shop = listShop.firstWhere((shop) =>
                            //     shop.shopId == filteredOrders[index].shopId);
                            return ShopOrderItem(
                              order: filteredOrders[index],
                            );
                            // return _buildOrderCard(
                            //     filteredOrders[index], shop, state.products);
                          });
                    }
                    return const SizedBox();
                  },
                );
              }
              return const SizedBox();
            },
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildOrderCard(Order order, Shop shop, List<Product> products) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                      _getOrderStatusText(order.status),
                      style: TextStyle(
                        color: _getOrderStatusColor(order.status),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.item.first.productId,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          if (order.item.length > 1)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Xem thêm',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            'x${order.item.first.quantity}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Tổng số tiền (${order.item.length} sản phẩm): đ${_formatPrice(order.totalPrice)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (order.status == OrderStatus.delivered) ...[
                  OutlinedButton(
                    onPressed: () {
                      // TODO: Handle mua lại
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text(
                      'Mua lại',
                      style: TextStyle(
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Handle đánh giá
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[500],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text(
                      'Đánh giá',
                      style: TextStyle(
                        color: Colors.white,
                      ),
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

  Widget _buildRecommendedProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Có thể bạn cũng thích',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: 4,
          itemBuilder: (context, index) => _buildProductCard(),
        ),
      ],
    );
  }

  Widget _buildProductCard() {
    return Container(
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
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: SvgPicture.asset(
              IconHelper.no_order,
              width: 300,
              height: 250,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tên sản phẩm mẫu',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'đ99.000',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Đã bán 100',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
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
}
