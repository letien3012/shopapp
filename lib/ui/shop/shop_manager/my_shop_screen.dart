import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:luanvan/blocs/auth/auth_bloc.dart';
import 'package:luanvan/blocs/auth/auth_event.dart';
import 'package:luanvan/blocs/comment/comment_bloc.dart';
import 'package:luanvan/blocs/comment/comment_event.dart';
import 'package:luanvan/blocs/comment/comment_state.dart';
import 'package:luanvan/blocs/order/order_bloc.dart';
import 'package:luanvan/blocs/order/order_event.dart';
import 'package:luanvan/blocs/order/order_state.dart';
import 'package:luanvan/blocs/shop/shop_bloc.dart';
import 'package:luanvan/blocs/shop/shop_event.dart';
import 'package:luanvan/blocs/shop/shop_state.dart';
import 'package:luanvan/models/order.dart';
import 'package:luanvan/models/shop.dart';
import 'package:luanvan/models/user_info_model.dart';
import 'package:luanvan/ui/helper/icon_helper.dart';
import 'package:luanvan/ui/home/shop_dashboard.dart';
import 'package:luanvan/ui/login/signin_screen.dart';
import 'package:luanvan/ui/shop/baner/my_banner_screen.dart';
import 'package:luanvan/ui/shop/category/my_category_screen.dart';
import 'package:luanvan/ui/shop/chat/shop_chat_screen.dart';
import 'package:luanvan/ui/shop/comment/shop_review_screen.dart';
import 'package:luanvan/ui/shop/order_manager/order_shop_screen.dart';
import 'package:luanvan/ui/shop/product_manager/my_product_screen.dart';
import 'package:luanvan/ui/shop/product_manager/ship_manager_screen.dart';
import 'package:luanvan/ui/shop/analysis/revenue_screen.dart';
import 'package:luanvan/ui/shop/analysis/sales_analysis_screen.dart';
import 'package:luanvan/ui/shop/shop_manager/setting_shop_screen.dart';
import 'package:luanvan/ui/shop/user/my_user_screen.dart';

class MyShopScreen extends StatefulWidget {
  const MyShopScreen({super.key});
  static String routeName = "my_shop_screen";
  @override
  State<MyShopScreen> createState() => _MyShopScreenState();
}

class _MyShopScreenState extends State<MyShopScreen> {
  String formatNumber(int number) {
    if (number >= 1000000000) {
      double result = number / 1000000000;
      return '${result.toStringAsFixed(1)}B';
    }
    if (number >= 1000000) {
      double result = number / 1000000;
      return '${result.toStringAsFixed(1)}M';
    }
    if (number >= 1000) {
      double result = number / 1000;
      return '${result.toStringAsFixed(1)}k';
    }
    return number.toString();
  }

  Future<bool> _showLogoutConfirmationDialog() async {
    return await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              actionsPadding: EdgeInsets.zero,
              titlePadding: EdgeInsets.symmetric(horizontal: 10, vertical: 25),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
              title: const Text("Bạn có chắc muốn đăng xuất"),
              titleTextStyle: TextStyle(fontSize: 14, color: Colors.black),
              actions: [
                Row(
                  children: [
                    Expanded(
                        child: Container(
                      alignment: Alignment.center,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border(
                            top: BorderSide(width: 0.3, color: Colors.grey),
                            right: BorderSide(width: 0.3, color: Colors.grey)),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop(false);
                        },
                        child: Text(
                          "Hủy",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    )),
                    Expanded(
                        child: Container(
                      alignment: Alignment.center,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(width: 0.3, color: Colors.grey),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop(true);
                        },
                        child: Text(
                          "Đăng xuất",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.brown,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )),
                  ],
                )
              ],
            );
          },
        ) ??
        false;
  }

  bool isFastEnabled = false;
  bool isEconomyEnabled = false;
  bool isExpress = false;
  UserInfoModel user = UserInfoModel(id: '', role: 0);
  @override
  void initState() {
    Future.microtask(() {
      user = ModalRoute.of(context)!.settings.arguments as UserInfoModel;
      context.read<ShopBloc>().add(FetchShopEvent(user.id));
      final shopState = context.read<ShopBloc>().state;
      if (shopState is ShopLoaded) {
        context
            .read<OrderBloc>()
            .add(FetchOrdersByShopId(shopState.shop.shopId!));
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: BlocBuilder<ShopBloc, ShopState>(
      builder: (context, shopState) {
        if (shopState is ShopLoading) {
          return _buildLoading();
        } else if (shopState is ShopLoaded) {
          context
              .read<CommentBloc>()
              .add(LoadCommentsShopIdEvent(shopState.shop.shopId!));
          return _buildShopContent(context, shopState.shop, user);
        } else if (shopState is ShopError) {
          return _buildError(shopState.message);
        }
        return _buildInitializing();
      },
    ));
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

  Widget _buildLogoutSection() {
    return Column(
      children: [
        Container(
          height: 70,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.centerLeft,
          color: Colors.white,
          child: Material(
            color: Colors.brown,
            child: InkWell(
              splashColor: Colors.transparent.withOpacity(0.2),
              highlightColor: Colors.transparent.withOpacity(0.1),
              onTap: () async {
                if (await _showLogoutConfirmationDialog()) {
                  context.read<AuthBloc>().add(SignOutEvent());
                  Navigator.of(context).pushNamed(SigninScreen.routeName);
                }
              },
              child: Container(
                height: 50,
                width: double.infinity,
                alignment: Alignment.center,
                child: const Text(
                  "Đăng xuất",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShopContent(
      BuildContext context, Shop shop, UserInfoModel user) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height + 60,
              minHeight: MediaQuery.of(context).size.height,
              minWidth: MediaQuery.of(context).size.width,
            ),
            padding: const EdgeInsets.only(top: 90, bottom: 60),
            child: Column(
              children: [
                Container(
                  height: 5,
                  color: Colors.grey[200],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  color: Colors.white,
                  child: Row(
                    children: [
                      ClipOval(
                        child: Image.network(
                          shop.avatarUrl!,
                          height: 60,
                          width: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Container(
                          height: 60,
                          alignment: Alignment.topLeft,
                          child: Text(
                            shop.name,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, ShopDashboard.routeName,
                              arguments: shop.shopId);
                        },
                        child: Container(
                          height: 30,
                          width: 90,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              border: Border.all(
                            width: 1,
                            color: Colors.brown,
                          )),
                          child: Text(
                            "Xem shop",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.brown,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 5,
                  color: Colors.grey[200],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Đơn hàng"),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                              context, OrderShopScreen.routeName,
                              arguments: 0);
                        },
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("Xem lịch sử đơn hàng"),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 15,
                              )
                            ]),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15, bottom: 20),
                  child: BlocBuilder<OrderBloc, OrderState>(
                    builder: (context, state) {
                      int processingCount = 0;
                      int cancelledCount = 0;
                      int returnedCount = 0;

                      if (state is OrderShopLoaded) {
                        for (var order in state.orders) {
                          if (order.shopId == shop.shopId) {
                            switch (order.status) {
                              case OrderStatus.pending:
                                processingCount++;
                                break;
                              case OrderStatus.cancelled:
                                cancelledCount++;
                                break;
                              case OrderStatus.returned:
                                returnedCount++;
                                break;
                              default:
                                break;
                            }
                          }
                        }
                      }

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildOrderCountItem("Chờ xác nhận", processingCount,
                              OrderStatus.pending),
                          _buildOrderCountItem(
                              "Đơn huỷ", cancelledCount, OrderStatus.cancelled),
                          _buildOrderCountItem("Trả hàng hoàn tiền",
                              returnedCount, OrderStatus.returned),
                          BlocSelector<CommentBloc, CommentState, int>(
                            selector: (state) {
                              if (state is CommentShopLoaded) {
                                return state.comments.length;
                              }
                              return 0;
                            },
                            builder: (context, feedbackCount) {
                              if (feedbackCount > 0) {
                                return _buildOrderCountItem("Phản hôi đánh giá",
                                    feedbackCount, OrderStatus.reviewed);
                              }
                              return _buildOrderCountItem(
                                  "Phản hôi đánh giá", 0, OrderStatus.reviewed);
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Container(
                  height: 5,
                  color: Colors.grey[200],
                ),
                Material(
                  color: Colors.white,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        MyUserScreen.routeName,
                      );
                    },
                    splashColor: Colors.transparent.withOpacity(0.2),
                    highlightColor: Colors.transparent.withOpacity(0.1),
                    child: Container(
                      height: 60,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                        width: 0.2,
                        color: Colors.grey,
                      ))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                IconHelper.userlist,
                                color: Colors.yellow[800],
                                height: 30,
                                width: 30,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                "Quản lý người dùng",
                                style: TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 15,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Material(
                  color: Colors.white,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed(MyProductScreen.routeName,
                          arguments: shop.shopId);
                    },
                    splashColor: Colors.transparent.withOpacity(0.2),
                    highlightColor: Colors.transparent.withOpacity(0.1),
                    child: Container(
                      height: 60,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                        width: 0.2,
                        color: Colors.grey,
                      ))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                IconHelper.box,
                                color: Colors.yellow[800],
                                height: 30,
                                width: 30,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                "Sản phẩm của tôi",
                                style: TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 15,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Material(
                  color: Colors.white,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed(RevenueScreen.routeName,
                          arguments: shop.shopId);
                    },
                    splashColor: Colors.transparent.withOpacity(0.2),
                    highlightColor: Colors.transparent.withOpacity(0.1),
                    child: Container(
                      height: 60,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                        width: 0.2,
                        color: Colors.grey,
                      ))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                IconHelper.wallet,
                                color: Colors.orange[700],
                                height: 30,
                                width: 30,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                "Doanh thu",
                                style: TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 15,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Material(
                  color: Colors.white,
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        ShipManagerScreen.routeName,
                        arguments: shop,
                      );
                    },
                    splashColor: Colors.transparent.withOpacity(0.2),
                    highlightColor: Colors.transparent.withOpacity(0.1),
                    child: Container(
                      height: 60,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                        width: 0.2,
                        color: Colors.grey,
                      ))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                IconHelper.truck,
                                color: Colors.blue[700],
                                height: 30,
                                width: 30,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                "Cài đặt vận chuyển",
                                style: TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 15,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Material(
                  color: Colors.white,
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        SalesAnalysisScreen.routeName,
                      );
                    },
                    splashColor: Colors.transparent.withOpacity(0.2),
                    highlightColor: Colors.transparent.withOpacity(0.1),
                    child: Container(
                      height: 60,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                        width: 0.2,
                        color: Colors.grey,
                      ))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                IconHelper.chart,
                                color: Colors.green[800],
                                height: 30,
                                width: 30,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                "Phân tích bán hàng",
                                style: TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 15,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Material(
                  color: Colors.white,
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        MyCategoryScreen.routeName,
                        arguments: shop.shopId,
                      );
                    },
                    splashColor: Colors.transparent.withOpacity(0.2),
                    highlightColor: Colors.transparent.withOpacity(0.1),
                    child: Container(
                      height: 60,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                        width: 0.2,
                        color: Colors.grey,
                      ))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                IconHelper.category,
                                color: Colors.brown[800],
                                height: 30,
                                width: 30,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                "Quản lý danh mục",
                                style: TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 15,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Material(
                  color: Colors.white,
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        SalesAnalysisScreen.routeName,
                      );
                    },
                    splashColor: Colors.transparent.withOpacity(0.2),
                    highlightColor: Colors.transparent.withOpacity(0.1),
                    child: Container(
                      height: 60,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                        width: 0.2,
                        color: Colors.grey,
                      ))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                IconHelper.warehouse,
                                color: Colors.pink[800],
                                height: 30,
                                width: 30,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                "Quản lý nhập hàng",
                                style: TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 15,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Material(
                  color: Colors.white,
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        MyBannerScreen.routeName,
                      );
                    },
                    splashColor: Colors.transparent.withOpacity(0.2),
                    highlightColor: Colors.transparent.withOpacity(0.1),
                    child: Container(
                      height: 60,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                        width: 0.2,
                        color: Colors.grey,
                      ))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                IconHelper.banner,
                                color: Colors.purple[800],
                                height: 10,
                                width: 10,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                "Quản lý banner",
                                style: TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 15,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                _buildLogoutSection(),
                Expanded(
                    child: Container(
                  color: Colors.grey[200],
                ))
              ],
            ),
          ),
        ),
        // AppBar
        Align(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              Container(
                height: 90,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                padding: const EdgeInsets.only(
                    top: 30, left: 10, right: 10, bottom: 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 40,
                      child: Text(
                        "Shop của tôi",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  SettingShopScreen.routeName,
                                  arguments: shop.shopId,
                                );
                              },
                              child: Icon(
                                HeroIcons.cog_8_tooth,
                                color: Colors.brown,
                                size: 30,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  ShopChatScreen.routeName,
                                );
                              },
                              child: SvgPicture.asset(
                                IconHelper.chatIcon,
                                color: Colors.brown,
                                height: 30,
                                width: 30,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCountItem(String label, int count, OrderStatus status) {
    return InkWell(
      onTap: () {
        if (status == OrderStatus.reviewed) {
          Navigator.pushNamed(
            context,
            ShopReviewScreen.routeName,
          );
        } else {
          int index = 0;
          switch (status) {
            case OrderStatus.pending:
              index = 0; // Chờ xác nhận
              break;
            case OrderStatus.processing:
              index = 1; // Chờ lấy hàng
              break;
            case OrderStatus.shipped:
              index = 2; // Chờ giao hàng
              break;
            case OrderStatus.delivered:
              index = 3; // Đã giao
              break;
            case OrderStatus.returned:
              index = 4; // Trả hàng
              break;
            case OrderStatus.cancelled:
              index = 5; // Đã hủy
              break;
            case OrderStatus.reviewed:
          }
          Navigator.pushNamed(
            context,
            OrderShopScreen.routeName,
            arguments: index,
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Text(
              formatNumber(count),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B4513),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
