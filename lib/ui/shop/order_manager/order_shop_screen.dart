import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:luanvan/blocs/auth/auth_bloc.dart';
import 'package:luanvan/blocs/auth/auth_state.dart';
import 'package:luanvan/blocs/listuserordershop/list_user_order_bloc.dart';
import 'package:luanvan/blocs/listuserordershop/list_user_order_event.dart';
import 'package:luanvan/blocs/listuserordershop/list_user_order_state.dart';
import 'package:luanvan/blocs/order/order_bloc.dart';
import 'package:luanvan/blocs/order/order_event.dart';
import 'package:luanvan/blocs/order/order_state.dart';
import 'package:luanvan/blocs/productorder/product_order_bloc.dart';
import 'package:luanvan/blocs/productorder/product_order_event.dart';
import 'package:luanvan/blocs/productorder/product_order_state.dart';
import 'package:luanvan/blocs/shop/shop_bloc.dart';
import 'package:luanvan/blocs/shop/shop_state.dart';
import 'package:luanvan/models/order.dart';
import 'package:luanvan/ui/helper/icon_helper.dart';
import 'package:luanvan/ui/helper/image_helper.dart';
import 'package:luanvan/ui/shop/order_manager/user_order_item.dart';

class OrderShopScreen extends StatefulWidget {
  static const String routeName = 'order_shop_screen';

  const OrderShopScreen({
    super.key,
  });

  @override
  State<OrderShopScreen> createState() => _OrderShopScreenState();
}

class _OrderShopScreenState extends State<OrderShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  List<String> listUserId = [];
  List<String> listProductId = [];
  String? selectedShipMethodPending;
  String? selectedShipMethodProcessing;
  String? selectedShipMethodShipping;
  String? selectedShipMethodDelivered;
  String? selectedShipMethodReturned;
  String? selectedShipMethodCancelled;
  String selectedStatus = 'all';
  String selectedSort = 'newest';
  bool isShippingMethodExpanded = false;
  final List<String> _tabs = [
    'Chờ xác nhận',
    'Chờ lấy hàng',
    'Chờ giao hàng',
    'Đã giao',
    'Trả hàng',
    'Đã hủy',
  ];
  int initialTab = 0;
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

    // Set initial tab after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments;
      initialTab = args as int;
      if (initialTab != null) {
        _tabController.animateTo(initialTab);
      }
    });
  }

  @override
  void didUpdateWidget(OrderShopScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _tabController.animateTo(initialTab);
  }

  void _scrollToSelectedTab() {
    if (!_scrollController.hasClients) return;

    final RenderBox tabBox = context.findRenderObject() as RenderBox;
    final double tabBarWidth = tabBox.size.width;
    final double selectedTabPosition =
        _tabController.index * (tabBarWidth / _tabs.length);
    final double offset = selectedTabPosition - (tabBarWidth / 4);

    _scrollController.animateTo(
      offset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _loadOrders() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final shopState = context.read<ShopBloc>().state;
      if (shopState is ShopLoaded) {
        context
            .read<OrderBloc>()
            .add(FetchOrdersByShopId(shopState.shop.shopId!));
      }
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
          'Đơn hàng',
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
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
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
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((tab) => _buildOrderList(tab)).toList(),
      ),
    );
  }

  Widget _buildOrderList(String status) {
    return Column(
      children: [
        _buildFilterByTab(status),
        Expanded(
          child: BlocBuilder<OrderBloc, OrderState>(
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

              if (state is OrderShopLoaded) {
                List<Order> filteredOrders = state.orders;
                listUserId =
                    filteredOrders.map((order) => order.userId).toList();
                listProductId = filteredOrders
                    .expand((order) => order.item)
                    .map((item) => item.productId)
                    .toList();
                context
                    .read<ListUserOrderBloc>()
                    .add(FetchListUserOrderEventByUserId(listUserId));
                context
                    .read<ProductOrderBloc>()
                    .add(FetchMultipleProductsOrderEvent(listProductId));
                filteredOrders = state.orders.where((order) {
                  bool matchesStatus = false;
                  switch (status) {
                    case 'Chờ xác nhận':
                      matchesStatus = order.status == OrderStatus.pending;
                      break;
                    case 'Chờ lấy hàng':
                      matchesStatus = order.status == OrderStatus.processing;
                      break;
                    case 'Chờ giao hàng':
                      matchesStatus = order.status == OrderStatus.shipped;
                      break;
                    case 'Đã giao':
                      matchesStatus = order.status == OrderStatus.delivered;
                      break;
                    case 'Trả hàng':
                      matchesStatus = order.status == OrderStatus.returned;
                      break;
                    case 'Đã hủy':
                      matchesStatus = order.status == OrderStatus.cancelled;
                      break;
                    default:
                      matchesStatus = true;
                  }

                  final selectedMethod = _getSelectedShipMethodForTab(status);
                  bool matchesShipMethod = selectedMethod == null ||
                      order.shipMethod?.name == selectedMethod;

                  return matchesStatus && matchesShipMethod;
                }).toList();

                // Sắp xếp đơn hàng theo ngày
                if (status == 'Chờ lấy hàng') {
                  filteredOrders.sort((a, b) {
                    if (selectedSort == 'newest') {
                      return b.createdAt.compareTo(a.createdAt);
                    } else {
                      return a.createdAt.compareTo(b.createdAt);
                    }
                  });
                }

                if (filteredOrders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          ImageHelper.no_order,
                          width: 300,
                          height: 300,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Bạn chưa có đơn hàng nào cả',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  );
                }

                return BlocBuilder<ListUserOrderBloc, ListUserOrderState>(
                  builder:
                      (BuildContext context, ListUserOrderState listUserState) {
                    if (listUserState is ListUserOrderLoaded) {
                      return BlocBuilder<ProductOrderBloc, ProductOrderState>(
                        builder:
                            (BuildContext context, ProductOrderState state) {
                          if (state is ProductOrderListLoaded) {
                            return ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: filteredOrders.length,
                                itemBuilder: (context, index) {
                                  if (index >= filteredOrders.length) {
                                    return const SizedBox.shrink();
                                  }
                                  return UserOrderItem(
                                    order: filteredOrders[index],
                                  );
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
          ),
        ),
      ],
    );
  }

  Widget _buildFilterByTab(String status) {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        if (state is OrderShopLoaded) {
          final filteredOrders = state.orders.where((order) {
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

          final shippingMethods = filteredOrders
              .map((order) => order.shipMethod)
              .where((method) => method != null)
              .toSet()
              .toList();

          final selectedMethod = _getSelectedShipMethodForTab(status);

          if (status == 'Chờ lấy hàng') {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  selectedStatus = 'all';
                                });
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: selectedStatus == 'all'
                                          ? const Color(0xFF8B4513)
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Tất cả',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: selectedStatus == 'all'
                                        ? const Color(0xFF8B4513)
                                        : Colors.grey[600],
                                    fontWeight: selectedStatus == 'all'
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  selectedStatus = 'pending';
                                });
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: selectedStatus == 'pending'
                                          ? const Color(0xFF8B4513)
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Chưa xử lý',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: selectedStatus == 'pending'
                                        ? const Color(0xFF8B4513)
                                        : Colors.grey[600],
                                    fontWeight: selectedStatus == 'pending'
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  selectedStatus = 'processed';
                                });
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: selectedStatus == 'processed'
                                          ? const Color(0xFF8B4513)
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Đã xử lý',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: selectedStatus == 'processed'
                                        ? const Color(0xFF8B4513)
                                        : Colors.grey[600],
                                    fontWeight: selectedStatus == 'processed'
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Sắp xếp theo thời gian',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Đơn vị vận chuyển',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedSort,
                                  isExpanded: true,
                                  dropdownColor: Colors.white,
                                  icon: const Icon(Icons.keyboard_arrow_down),
                                  items: [
                                    DropdownMenuItem(
                                      value: 'newest',
                                      child: Text('Mới nhất',
                                          style: TextStyle(
                                            color: selectedSort == 'newest'
                                                ? Colors.black
                                                : Colors.grey[600],
                                          )),
                                    ),
                                    DropdownMenuItem(
                                      value: 'oldest',
                                      child: Text('Cũ nhất',
                                          style: TextStyle(
                                            color: selectedSort == 'oldest'
                                                ? Colors.black
                                                : Colors.grey[600],
                                          )),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      selectedSort = value!;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedMethod,
                                  isExpanded: true,
                                  dropdownColor: Colors.white,
                                  hint: Text(
                                    'Đơn vị vận chuyển',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  items: [
                                    DropdownMenuItem<String>(
                                      value: null,
                                      child: Text(
                                        'Tất cả',
                                        style: TextStyle(
                                          color: selectedMethod == null
                                              ? Colors.black
                                              : Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                    ...shippingMethods.map(
                                        (method) => DropdownMenuItem<String>(
                                              value: method.name,
                                              child: Text(
                                                method.name,
                                                style: TextStyle(
                                                  color: selectedMethod ==
                                                          method.name
                                                      ? Colors.black
                                                      : Colors.grey[600],
                                                ),
                                              ),
                                            )),
                                  ],
                                  onChanged: (value) {
                                    _updateSelectedShipMethod(status, value);
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Đơn vị vận chuyển',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedMethod,
                            isExpanded: true,
                            dropdownColor: Colors.white,
                            hint: Text(
                              'Đơn vị vận chuyển',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            items: [
                              DropdownMenuItem<String>(
                                value: null,
                                child: Text(
                                  'Tất cả',
                                  style: TextStyle(
                                    color: selectedMethod == null
                                        ? Colors.black
                                        : Colors.grey[600],
                                  ),
                                ),
                              ),
                              ...shippingMethods
                                  .map((method) => DropdownMenuItem<String>(
                                        value: method.name,
                                        child: Text(
                                          method.name,
                                          style: TextStyle(
                                            color: selectedMethod == method.name
                                                ? Colors.black
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      )),
                            ],
                            onChanged: (value) {
                              _updateSelectedShipMethod(status, value);
                            },
                          ),
                        ),
                      ),
                    ),
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

  String? _getSelectedShipMethodForTab(String status) {
    switch (status) {
      case 'Chờ xác nhận':
        return selectedShipMethodPending;
      case 'Chờ lấy hàng':
        return selectedShipMethodProcessing;
      case 'Chờ giao hàng':
        return selectedShipMethodShipping;
      case 'Đã giao':
        return selectedShipMethodDelivered;
      case 'Trả hàng':
        return selectedShipMethodReturned;
      case 'Đã hủy':
        return selectedShipMethodCancelled;
      default:
        return null;
    }
  }

  void _updateSelectedShipMethod(String status, String? value) {
    setState(() {
      switch (status) {
        case 'Chờ xác nhận':
          selectedShipMethodPending = value;
          break;
        case 'Chờ lấy hàng':
          selectedShipMethodProcessing = value;
          break;
        case 'Chờ giao hàng':
          selectedShipMethodShipping = value;
          break;
        case 'Đã giao':
          selectedShipMethodDelivered = value;
          break;
        case 'Trả hàng':
          selectedShipMethodReturned = value;
          break;
        case 'Đã hủy':
          selectedShipMethodCancelled = value;
          break;
      }
    });
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
          // Image.asset(
          //   ImageHelper.no_order,
          //   width: 300,
          //   height: 250,
          // ),
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
