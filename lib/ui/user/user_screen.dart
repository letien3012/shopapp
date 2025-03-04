import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:luanvan/blocs/auth/auth_bloc.dart';
import 'package:luanvan/blocs/auth/auth_event.dart';
import 'package:luanvan/blocs/auth/auth_state.dart';
import 'package:luanvan/blocs/user/user_bloc.dart';
import 'package:luanvan/blocs/user/user_event.dart';
import 'package:luanvan/blocs/user/user_state.dart';
import 'package:luanvan/models/user_info_model.dart';
import 'package:luanvan/ui/checkout/location_screen.dart';
import 'package:luanvan/ui/helper/icon_helper.dart';
import 'package:luanvan/ui/user/change_account_info.dart';
import 'package:luanvan/ui/user/change_infomation_user.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});
  static const String routeName = "user_screen";

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
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
    return const Center(child: Text('Initializing...'));
  }

  // Chưa đăng nhập
  Widget _buildNotAuthenticated() {
    return const Center(child: Text("Chưa đăng nhập"));
  }

  // Nội dung chính của màn hình người dùng
  Widget _buildUserContent(BuildContext context, UserInfoModel user) {
    return SingleChildScrollView(
      child: Container(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        color: Colors.white,
        child: Column(
          children: [
            _buildHeader(context, user),
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
  Widget _buildHeader(BuildContext context, UserInfoModel user) {
    return Container(
      color: Colors.brown,
      padding: const EdgeInsets.only(top: 45, bottom: 10),
      child: Column(
        children: [
          _buildTopBar(),
          _buildUserProfile(context, user),
        ],
      ),
    );
  }

  // Thanh trên cùng với nút bán hàng và biểu tượng
  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          height: 30,
          width: 130,
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
              const Text(
                "Bắt đầu bán",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(width: 5),
              const Icon(Icons.arrow_forward_ios, size: 15),
            ],
          ),
        ),
        Row(
          children: [
            SizedBox(
              height: 40,
              width: 50,
              child: Stack(
                children: [
                  Container(
                      height: 40,
                      width: 40,
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        IconHelper.cartIcon,
                        height: 30,
                        width: 30,
                        color: Colors.white,
                      )),
                  Positioned(
                    left: 15,
                    top: 5,
                    child: Container(
                      height: 18,
                      width: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.red,
                        border: Border.all(width: 1.5, color: Colors.white),
                      ),
                      child: const Text(
                        "99+",
                        style: TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  ),
                ],
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
  Widget _buildUserProfile(BuildContext context, UserInfoModel user) {
    return SizedBox(
      height: 55,
      child: Row(
        children: [
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () =>
                Navigator.of(context).pushNamed(ChangeInfomationUser.routeName),
            child: SizedBox(
              height: 55,
              width: 70,
              child: Stack(
                children: [
                  ClipOval(
                    child: Image.network(
                      width: 55,
                      height: 55,
                      fit: BoxFit.cover,
                      user.avataUrl!,
                      errorBuilder: (context, error, stackTrace) => const Text(
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
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () =>
                Navigator.of(context).pushNamed(ChangeInfomationUser.routeName),
            child: SizedBox(
              height: 50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    user.name!,
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Row(
                    children: [
                      Text(
                        "4 người theo dõi",
                        style: TextStyle(fontSize: 13, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
                onTap: () {},
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
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOrderIcon(FontAwesome.wallet_solid, "Chờ xác nhận"),
              _buildOrderIcon(HeroIcons.inbox_stack, "Chờ lấy hàng"),
              _buildOrderIcon(FontAwesome.truck_solid, "Đang giao hàng"),
              _buildOrderIcon(Icons.stars_outlined, "Đánh giá"),
            ],
          ),
        ],
      ),
    );
  }

  // Biểu tượng đơn mua
  Widget _buildOrderIcon(IconData icon, String label) {
    return GestureDetector(
      child: Column(
        children: [
          Icon(icon, size: 35),
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
    return GestureDetector(
      onTap: routeName != null
          ? () => Navigator.of(context).pushNamed(routeName)
          : null,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        width: double.infinity,
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Colors.white,
          border:
              Border(bottom: BorderSide(width: 1, color: Colors.grey[200]!)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const Icon(Icons.arrow_forward_ios, size: 20),
          ],
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
          alignment: Alignment.centerLeft,
          color: Colors.white,
          child: GestureDetector(
            onTap: () {
              context.read<AuthBloc>().add(SignOutEvent());
            },
            child: Container(
              height: 50,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.brown,
                  border: Border.all(width: 1, color: Colors.black),
                  borderRadius: BorderRadius.circular(
                    10,
                  )),
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
      ],
    );
  }
}
