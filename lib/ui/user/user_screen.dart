import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:luanvan/blocs/auth/auth_bloc.dart';
import 'package:luanvan/blocs/auth/auth_event.dart';
import 'package:luanvan/blocs/auth/auth_state.dart';
import 'package:luanvan/blocs/cart/cart_bloc.dart';
import 'package:luanvan/blocs/cart/cart_state.dart';
import 'package:luanvan/blocs/user/user_bloc.dart';
import 'package:luanvan/blocs/user/user_event.dart';
import 'package:luanvan/blocs/user/user_state.dart';
import 'package:luanvan/models/user_info_model.dart';
import 'package:luanvan/ui/cart/cart_screen.dart';
import 'package:luanvan/ui/checkout/location_screen.dart';
import 'package:luanvan/ui/helper/icon_helper.dart';
import 'package:luanvan/ui/login/signin_screen.dart';
import 'package:luanvan/ui/login/singup_screen.dart';
import 'package:luanvan/ui/order/order_screen.dart';
import 'package:luanvan/ui/shop/shop_manager/my_shop_screen.dart';
import 'package:luanvan/ui/shop/sign_shop/start_shop.dart';
import 'package:luanvan/ui/user/change_account_info.dart';
import 'package:luanvan/ui/user/change_infomation_user.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});
  static const String routeName = "user_screen";

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
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

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<UserBloc>().add(FetchUserEvent(authState.user.uid));
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthAuthenticated) {
            return BlocBuilder<UserBloc, UserState>(
              builder: (context, userState) {
                if (userState is UserLoading) {
                  return _buildLoading();
                } else if (userState is UserLoaded) {
                  return _buildUserContent(context, userState.user);
                } else if (userState is UserError) {
                  return _buildError(userState.message);
                }
                return _buildInitializing();
              },
            );
          }
          return _buildNotAuthenticated();
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

  // Chưa đăng nhập
  Widget _buildNotAuthenticated() {
    return SingleChildScrollView(
      child: Container(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        color: Colors.white,
        child: Column(
          children: [
            _buildHeader(context, null, isAuthen: false),
            _buildOrderSection(),
            _buildDivider(),
            _buildSettingsSection(context),
          ],
        ),
      ),
    );
  }

  // Nội dung chính của màn hình người dùng
  Widget _buildUserContent(BuildContext context, UserInfoModel user) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Container(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        color: Colors.white,
        child: Column(
          children: [
            _buildHeader(context, user, isAuthen: true),
            _buildOrderSection(),
            _buildDivider(),
            _buildSettingsSection(context),
            _buildDivider(),
            _buildLogoutSection(),
          ],
        ),
      ),
    );
  }

  // Phần header với thông tin người dùng
  Widget _buildHeader(BuildContext context, UserInfoModel? user,
      {required bool isAuthen}) {
    return Container(
      color: Colors.brown,
      padding: const EdgeInsets.only(top: 45, bottom: 10),
      child: Column(
        children: [
          _buildTopBar(isAuthen, user),
          _buildUserProfile(context, user, isAuthen: isAuthen),
        ],
      ),
    );
  }

  // Thanh trên cùng với nút bán hàng và biểu tượng
  Widget _buildTopBar(bool isAuthen, UserInfoModel? user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        isAuthen
            ? ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                child: Material(
                  color: Colors.white,
                  child: InkWell(
                    onTap: () {
                      user.role == 1
                          ? Navigator.of(context).pushNamed(
                              MyShopScreen.routeName,
                              arguments: user)
                          : Navigator.of(context)
                              .pushNamed(StartShop.routeName);
                    },
                    splashColor: Colors.transparent.withOpacity(0.2),
                    highlightColor: Colors.transparent.withOpacity(0.1),
                    child: SizedBox(
                      height: 30,
                      width: 140,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            IconHelper.store,
                            height: 25,
                            width: 25,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            user!.role == 1 ? "Shop của tôi" : "Bắt đầu bán",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(width: 5),
                          const Icon(Icons.arrow_forward_ios, size: 15),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : SizedBox(),
        Row(
          children: [
            InkWell(
              onTap: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
              child: SizedBox(
                height: 40,
                width: 60,
                child: Stack(
                  children: [
                    ClipOval(
                      child: Container(
                          color: Colors.transparent,
                          height: 40,
                          width: 40,
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            IconHelper.cartIcon,
                            height: 30,
                            width: 30,
                            color: Colors.white,
                          )),
                    ),
                    (context.read<AuthBloc>().state is AuthAuthenticated)
                        ? BlocSelector<CartBloc, CartState, String>(
                            builder: (BuildContext context, cartItem) {
                              if (cartItem != '0') {
                                return Positioned(
                                  right: 15,
                                  top: 5,
                                  child: Container(
                                    height: 20,
                                    width: 30,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          width: 1.5, color: Colors.white),
                                    ),
                                    child: Text(
                                      '$cartItem',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                );
                              } else {
                                return Container();
                              }
                            },
                            selector: (state) {
                              if (state is CartLoaded) {
                                return state.cart.totalItems.toString();
                              }
                              return '';
                            },
                          )
                        : Container()
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            SvgPicture.asset(
              IconHelper.chatIcon,
              color: Colors.white,
              height: 30,
              width: 30,
            ),
            // const Icon(BoxIcons.bx_chat, color: Colors.white, size: 30),
            const SizedBox(width: 10),
          ],
        ),
      ],
    );
  }

  // Thông tin người dùng (ảnh đại diện và tên)
  Widget _buildUserProfile(BuildContext context, UserInfoModel? user,
      {required bool isAuthen}) {
    return SizedBox(
      height: 55,
      child: Row(
        mainAxisAlignment: !isAuthen
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.start,
        children: [
          isAuthen
              ? GestureDetector(
                  onTap: () => Navigator.of(context)
                      .pushNamed(ChangeInfomationUser.routeName),
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      SizedBox(
                          height: 55,
                          width: 70,
                          child: Stack(
                            children: [
                              ClipOval(
                                child: Image.network(
                                  width: 55,
                                  height: 55,
                                  fit: BoxFit.cover,
                                  user!.avataUrl!,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Text(
                                    "lỗi",
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 35,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black45,
                                    shape: BoxShape.circle,
                                  ),
                                  height: 25,
                                  width: 25,
                                  child: const Icon(
                                    FontAwesome.pen_solid,
                                    size: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            ],
                          )),
                    ],
                  ),
                )
              : Container(
                  margin: EdgeInsets.only(left: 10),
                  height: 55,
                  width: 55,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Center(
                    child: SizedBox(
                      height: 40,
                      width: 40,
                      child: SvgPicture.asset(
                        IconHelper.user,
                        color: Colors.brown,
                      ),
                    ),
                  ),
                ),
          isAuthen
              ? GestureDetector(
                  onTap: () => Navigator.of(context)
                      .pushNamed(ChangeInfomationUser.routeName),
                  child: SizedBox(
                    height: 50,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          user!.userName!.replaceFirst("(changed)", ''),
                          style: const TextStyle(
                              fontSize: 18, color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            Text(
                              "4 người theo dõi",
                              style:
                                  TextStyle(fontSize: 13, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              : SizedBox(),
          isAuthen
              ? SizedBox()
              : Row(
                  children: [
                    Material(
                      color: Colors.white,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(SigninScreen.routeName);
                        },
                        splashColor: Colors.transparent.withOpacity(0.2),
                        highlightColor: Colors.transparent.withOpacity(0.1),
                        child: Container(
                          height: 30,
                          width: 80,
                          alignment: Alignment.center,
                          child: Text(
                            "Đăng nhập",
                            style: TextStyle(
                              color: Colors.brown,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(SingupScreen.routeName);
                        },
                        splashColor: Colors.transparent.withOpacity(0.2),
                        highlightColor: Colors.transparent.withOpacity(0.1),
                        child: Container(
                          height: 30,
                          width: 80,
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.white),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Đăng ký",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    )
                  ],
                )
        ],
      ),
    );
  }

  // Phần đơn mua
  Widget _buildOrderSection() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Đơn mua", style: TextStyle(fontSize: 14)),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(OrderScreen.routeName);
                },
                child: const Row(
                  children: [
                    Text("Xem tất cả"),
                    SizedBox(width: 5),
                    Icon(Icons.arrow_forward_ios, size: 14),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOrderIcon(IconHelper.wallet, "Chờ xác nhận"),
              _buildOrderIcon(IconHelper.package_box, "Chờ lấy hàng"),
              _buildOrderIcon(IconHelper.truck, "Đang giao hàng"),
              _buildOrderIcon(IconHelper.star_circle, "Đánh giá"),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Biểu tượng đơn mua
  Widget _buildOrderIcon(String icon, String label) {
    return GestureDetector(
      child: Column(
        children: [
          SvgPicture.asset(icon, height: 35, width: 35),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  // Dòng phân cách
  Widget _buildDivider() {
    return Container(
      height: 5,
      width: double.infinity,
      color: Colors.grey[200],
    );
  }

  // Phần cài đặt
  Widget _buildSettingsSection(BuildContext context) {
    return Column(
      children: [
        _buildSettingItem(
          "Tài khoản và bảo mật",
          ChangeAccountInfo.routeName,
          context,
        ),
        _buildSettingItem(
          "Địa chỉ",
          LocationScreen.routeName,
          context,
        ),
        _buildSettingItem("Tiêu chuẩn cộng đồng", null, context),
        _buildSettingItem("Sản phẩm đã thích", null, context),
        _buildSettingItem("Yêu cầu xóa tài khoản", null, context),
      ],
    );
  }

  // Mục cài đặt
  Widget _buildSettingItem(
      String title, String? routeName, BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        splashColor: Colors.grey.withOpacity(0.3),
        highlightColor: Colors.grey.withOpacity(0.1),
        onTap: routeName != null
            ? () => Navigator.of(context).pushNamed(routeName)
            : null,
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          width: double.infinity,
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            border:
                Border(bottom: BorderSide(width: 1, color: Colors.grey[200]!)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const Icon(Icons.arrow_forward_ios, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Phần đăng xuất
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
}
