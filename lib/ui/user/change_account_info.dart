import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/auth/auth_bloc.dart';
import 'package:luanvan/blocs/auth/auth_state.dart';
import 'package:luanvan/blocs/user/user_bloc.dart';
import 'package:luanvan/blocs/user/user_state.dart';
import 'package:luanvan/ui/user/change_infomation_user.dart';

class ChangeAccountInfo extends StatefulWidget {
  const ChangeAccountInfo({super.key});
  static const String routeName = "change_account_info";

  @override
  State<ChangeAccountInfo> createState() => _ChangeAccountInfoState();
}

class _ChangeAccountInfoState extends State<ChangeAccountInfo> {
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
                  return _buildContent(context, userState);
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

  // Nội dung chính
  Widget _buildContent(BuildContext context, UserLoaded userState) {
    return Stack(
      children: [
        _buildBody(context, userState),
        _buildAppBar(context),
      ],
    );
  }

  // Phần body với danh sách thông tin tài khoản
  Widget _buildBody(BuildContext context, UserLoaded userState) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.only(top: 80),
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        color: Colors.grey[200],
        child: Column(
          children: [
            _buildSectionHeader("Account"),
            _buildAccountItem(
              "Hồ sơ của tôi",
              onTap: () => Navigator.of(context)
                  .pushNamed(ChangeInfomationUser.routeName),
            ),
            _buildAccountItem(
              "Tên người dùng",
              trailingText: userState.user.userName ?? "Chưa có tên người dùng",
            ),
            _buildAccountItem(
              "Điện thoại",
              trailingText: _maskPhoneNumber(userState.user.phone ?? ""),
              showArrow: true,
            ),
            _buildAccountItem(
              "Email",
              trailingText: _maskEmail(userState.user.email ?? ""),
              showArrow: true,
            ),
            _buildAccountItem("Đổi mật khẩu", showArrow: true),
            _buildAccountItem("Xác thực bằng vân tay", showArrow: true),
          ],
        ),
      ),
    );
  }

  // Tiêu đề phần
  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.only(left: 10),
      height: 40,
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontSize: 13),
      ),
    );
  }

  // Mục thông tin tài khoản
  Widget _buildAccountItem(
    String title, {
    String? trailingText,
    VoidCallback? onTap,
    bool showArrow = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(width: 0.2, color: Colors.grey),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Row(
              children: [
                if (trailingText != null)
                  Text(
                    trailingText,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                if (showArrow) ...[
                  const SizedBox(width: 5),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // AppBar
  Widget _buildAppBar(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: AnimatedContainer(
        height: 80,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(color: Colors.white),
        padding:
            const EdgeInsets.only(top: 30, left: 10, right: 10, bottom: 10),
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                height: 40,
                width: 40,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.brown,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                "Tài khoản & bảo mật",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hàm ẩn số điện thoại
  String _maskPhoneNumber(String phone) {
    if (phone.isEmpty || phone.length < 2) {
      return "Không có số điện thoại";
    }
    return '********${phone.substring(phone.length - 2)}';
  }

  // Hàm ẩn email
  String _maskEmail(String email) {
    if (email.isEmpty || !email.contains('@')) {
      return "Không có email";
    }
    return '${email[0]}****${email[email.indexOf('@') - 1]}@gmail.com';
  }
}
