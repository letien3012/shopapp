import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/auth/auth_bloc.dart';
import 'package:luanvan/blocs/auth/auth_state.dart';
import 'package:luanvan/blocs/user/user_bloc.dart';
import 'package:luanvan/blocs/user/user_state.dart';
import 'package:luanvan/ui/user/change_info/change_email.dart';
import 'package:luanvan/ui/user/change_info/change_password.dart';
import 'package:luanvan/ui/user/change_info/change_phone.dart';
import 'package:luanvan/ui/user/change_info/change_username.dart';
import 'package:luanvan/ui/user/change_infomation_user.dart';

class ChangeAccountInfo extends StatefulWidget {
  const ChangeAccountInfo({super.key});
  static const String routeName = "change_account_info";

  @override
  State<ChangeAccountInfo> createState() => _ChangeAccountInfoState();
}

class _ChangeAccountInfoState extends State<ChangeAccountInfo> {
  TextEditingController _userNameController = TextEditingController();
  Future<bool> _showUserNameChangeConfirmationDialog() async {
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
              title: const Text(
                  "Bạn chỉ có thể thay đổi tên đăng nhập một lần. Hãy chắc chắn trước khi chọn tên mới"),
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
                          "Tiếp theo",
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
                  _userNameController.text.isEmpty
                      ? _userNameController.text = userState.user.userName!
                      : null;
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
            _buildUserNameItem(
              "Tên người dùng",
              userName: _userNameController.text,
              showArrow: _userNameController.text.startsWith("(changed)")
                  ? false
                  : true,
            ),
            _buildAccountItem(
              "Điện thoại",
              trailingText: _maskPhoneNumber(userState.user.phone ?? ""),
              showArrow: true,
              onTap: () => Navigator.of(context).pushNamed(
                ChangePhone.routeName,
                arguments: userState.user.phone,
              ),
            ),
            _buildAccountItem(
              "Email",
              trailingText: _maskEmail(userState.user.email ?? ""),
              showArrow: true,
              onTap: () {
                // Navigator.of(context).pushNamed(
                //   ChangeEmail.routeName,
                //   arguments: userState.user.email,
                // );
              },
            ),
            _buildAccountItem(
              "Đổi mật khẩu",
              showArrow: true,
              onTap: () => Navigator.of(context).pushNamed(
                ChangePassword.routeName,
              ),
            ),
            // _buildAccountItem("Xác thực bằng vân tay", showArrow: true),
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

  Widget _buildUserNameItem(
    String title, {
    String? userName,
    bool showArrow = false,
  }) {
    return Material(
      color: Colors.white,
      child: InkWell(
        splashColor: Colors.grey.withOpacity(0.3),
        highlightColor: Colors.grey.withOpacity(0.1),
        onTap: () async {
          if (showArrow) {
            if (await _showUserNameChangeConfirmationDialog()) {
              final newName = await Navigator.pushNamed(
                context,
                ChangeUsername.routeName,
                arguments: userName,
              );

              if (newName != null) {
                setState(() {
                  _userNameController.text = newName as String;
                });
              }
            }
          }
        },
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          width: double.infinity,
          decoration: const BoxDecoration(
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
                  if (userName != null)
                    Text(
                      userName.replaceFirst('(changed)', ''),
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: userName == "Thiết lập ngay"
                            ? Colors.grey
                            : Colors.black,
                      ),
                    ),
                  if (showArrow) ...[
                    const SizedBox(width: 5),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ] else ...[
                    const SizedBox(width: 20),
                  ]
                ],
              ),
            ],
          ),
        ),
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
    return Material(
      color: Colors.white,
      child: InkWell(
        splashColor: Colors.grey.withOpacity(0.3),
        highlightColor: Colors.grey.withOpacity(0.1),
        onTap: onTap,
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          width: double.infinity,
          decoration: const BoxDecoration(
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
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: trailingText == "Thiết lập ngay"
                            ? Colors.grey
                            : Colors.black,
                      ),
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
      return "Thiết lập ngay";
    }
    return '********${phone.substring(phone.length - 2)}';
  }

  // Hàm ẩn email
  String _maskEmail(String email) {
    if (email.isEmpty || !email.contains('@')) {
      return "Thiết lập ngay";
    }
    return '${email[0]}****${email[email.indexOf('@') - 1]}@gmail.com';
  }
}
