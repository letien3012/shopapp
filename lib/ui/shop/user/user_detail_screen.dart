import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/auth/auth_bloc.dart';
import 'package:luanvan/blocs/auth/auth_state.dart';
import 'package:luanvan/blocs/user/user_bloc.dart';
import 'package:luanvan/blocs/user/user_event.dart';
import 'package:luanvan/blocs/user/user_state.dart';
import 'package:luanvan/models/user_info_model.dart';

class UserDetailScreen extends StatefulWidget {
  const UserDetailScreen({super.key});
  static const String routeName = "user_detail_screen";

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  Gender _selectedGender = Gender.unknown;
  String _selectedDate = '';
  bool _showPhone = false; // Thêm biến để kiểm soát hiển thị số điện thoại
  bool _showEmail = false; // Thêm biến để kiểm soát hiển thị email
  TextEditingController _nameController = TextEditingController();
  TextEditingController _genderController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _avatarUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userId = ModalRoute.of(context)?.settings.arguments as String;
    context.read<UserBloc>().add(FetchUserEvent(userId));
    return Scaffold(
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, userState) {
          if (userState is UserLoading) {
            return _buildLoading();
          } else if (userState is UserLoaded) {
            userState.user.gender != Gender.unknown
                ? _selectedGender = userState.user.gender!
                : null;

            userState.user.date != null
                ? _selectedDate = userState.user.date!
                : null;
            _avatarUrlController.text.isEmpty
                ? _avatarUrlController.text = userState.user.avataUrl!
                : null;

            (_nameController.text.isEmpty && userState.user.name!.isNotEmpty)
                ? _nameController.text = userState.user.name!
                : null;

            _dateController.text = _selectedDate;
            _genderController.text = _selectedGender.name;
            return _buildContent(context, userState);
          } else if (userState is UserError) {
            return _buildError(userState.message);
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
    return const Center(child: Text('Initializing...'));
  }

  // Nội dung chính
  Widget _buildContent(BuildContext context, UserLoaded userState) {
    return Stack(
      children: [
        _buildBody(context, userState),
        _buildAppBar(context, userState.user),
      ],
    );
  }

  // Phần body với thông tin người dùng
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
            _buildAvatarSection(userState),
            _buildSpacer(2),
            _buildName("Tên", _nameController.text, userState.user),
            _buildGenderItem(context, "Giới tính", userState.user),
            _buildSpacer(10),
            _buildDateItem(context, "Ngày sinh", userState.user),
            _buildPhoneItem(
                "Số điện thoại",
                _maskPhoneNumber(userState.user.phone ?? ""),
                userState.user.phone ?? ""),
            _buildSpacer(10),
            _buildEmailItem("Email", _maskEmail(userState.user.email ?? ""),
                userState.user.email ?? ""),
          ],
        ),
      ),
    );
  }

  // Phần ảnh đại diện
  Widget _buildAvatarSection(UserLoaded userState) {
    return Container(
      height: 200,
      width: double.infinity,
      alignment: Alignment.center,
      color: Colors.brown[500],
      child: ClipOval(
        child: _avatarUrlController.text.startsWith('http')
            ? Image.network(
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                _avatarUrlController.text,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.person, size: 70),
              )
            : Image.file(
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                File(_avatarUrlController.text),
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.person, size: 70),
              ),
      ),
    );
  }

  // Khoảng cách
  Widget _buildSpacer(double height) {
    return SizedBox(height: height);
  }

  Widget _buildName(String title, String value, UserInfoModel user) {
    return Material(
      color: Colors.white,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        width: double.infinity,
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(width: 0.2, color: Colors.grey)),
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
                Text(
                  value.isEmpty ? "Chưa cập nhật" : value,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: value.isNotEmpty ? Colors.black : Colors.grey,
                  ),
                ),
                const SizedBox(width: 5),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Mục giới tính với PopupMenuButton
  Widget _buildGenderItem(
      BuildContext context, String title, UserInfoModel user) {
    return Material(
      color: Colors.white,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        width: double.infinity,
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(width: 0.1, color: Colors.grey)),
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
                Text(
                  _selectedGender != Gender.unknown
                      ? _selectedGender == Gender.male
                          ? "Nam"
                          : _selectedGender == Gender.female
                              ? "Nữ"
                              : "Khác"
                      : "Chưa cập nhật",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: _selectedGender != Gender.unknown
                        ? Colors.black
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Mục ngày sinh với DatePicker
  Widget _buildDateItem(
      BuildContext context, String title, UserInfoModel user) {
    return Material(
      color: Colors.white,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        width: double.infinity,
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(width: 0.1, color: Colors.grey)),
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
                Text(_selectedDate != '' ? _selectedDate : "Chưa cập nhật",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color:
                          _selectedDate.isNotEmpty ? Colors.black : Colors.grey,
                    )),
                const SizedBox(width: 5),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneItem(
      String title, String maskedValue, String originalValue) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () {
          if (originalValue.isNotEmpty) {
            setState(() {
              _showPhone = !_showPhone;
            });
          }
        },
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          width: double.infinity,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(width: 0.2, color: Colors.grey)),
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
                  Text(
                    originalValue.isNotEmpty
                        ? (_showPhone ? originalValue : maskedValue)
                        : "Chưa cập nhật",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color:
                          originalValue.isNotEmpty ? Colors.black : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 5),
                  if (originalValue.isNotEmpty)
                    Icon(
                        _showPhone
                            ? Icons.visibility_off
                            : Icons.remove_red_eye,
                        size: 20,
                        color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailItem(
      String title, String maskedValue, String originalValue) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () {
          if (originalValue.isNotEmpty) {
            setState(() {
              _showEmail = !_showEmail;
            });
          }
        },
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          width: double.infinity,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(width: 0.2, color: Colors.grey)),
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
                  Text(
                    originalValue.isNotEmpty
                        ? (_showEmail ? originalValue : maskedValue)
                        : "Chưa cập nhật",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color:
                          originalValue.isNotEmpty ? Colors.black : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 5),
                  if (originalValue.isNotEmpty)
                    Icon(
                        _showEmail
                            ? Icons.visibility_off
                            : Icons.remove_red_eye,
                        size: 20,
                        color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // AppBar
  Widget _buildAppBar(BuildContext context, UserInfoModel user) {
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
                "Thông tin người dùng",
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
      return "Chưa cập nhật";
    }
    final originalPhone = phone; // Lưu số điện thoại gốc
    return '********${originalPhone.substring(originalPhone.length - 2)}';
  }

  // Hàm ẩn email
  String _maskEmail(String email) {
    if (email.isEmpty || !email.contains('@')) {
      return "Chưa cập nhật";
    }
    return '${email[0]}****${email[email.indexOf('@') - 1]}@gmail.com';
  }
}
