import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luanvan/blocs/auth/auth_bloc.dart';
import 'package:luanvan/blocs/auth/auth_state.dart';
import 'package:luanvan/blocs/user/user_bloc.dart';
import 'package:luanvan/blocs/user/user_event.dart';
import 'package:luanvan/blocs/user/user_state.dart';
import 'package:luanvan/models/user_info_model.dart';
import 'package:luanvan/services/storage_service.dart';
import 'package:luanvan/ui/user/change_info/change_email.dart';
import 'package:luanvan/ui/user/change_info/change_name.dart';
import 'package:luanvan/ui/user/change_info/change_phone.dart';

class ChangeInfomationUser extends StatefulWidget {
  const ChangeInfomationUser({super.key});
  static const String routeName = "change_infomation_user";

  @override
  State<ChangeInfomationUser> createState() => _ChangeInfomationUserState();
}

class _ChangeInfomationUserState extends State<ChangeInfomationUser> {
  final StorageService _storageService = StorageService();
  final ImagePicker _imagePicker = ImagePicker();
  Gender _selectedGender = Gender.unknown;
  String _selectedDate = '';
  final GlobalKey<PopupMenuButtonState<Gender>> _popupMenuKey =
      GlobalKey<PopupMenuButtonState<Gender>>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _genderController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _avatarUrlController = TextEditingController();
  bool _isInfoChange = false;

  Future<void> _uploadAvatar(String userId, XFile image) async {
    try {
      File imageFile = File(image.path);
      String? downloadUrl = await _storageService.uploadFile(
          imageFile, 'image', 'avatar', userId);
      if (downloadUrl != null) {
        _avatarUrlController.text = downloadUrl;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tải ảnh lên thành công')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải ảnh: $e')),
      );
    }
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
                  userState.user.gender != Gender.unknown
                      ? _selectedGender = userState.user.gender!
                      : null;

                  userState.user.date != null && _selectedDate.isEmpty
                      ? _selectedDate = userState.user.date!
                      : null;
                  _avatarUrlController.text.isEmpty
                      ? _avatarUrlController.text = userState.user.avataUrl!
                      : null;

                  (_nameController.text.isEmpty &&
                          userState.user.name!.isNotEmpty)
                      ? _nameController.text = userState.user.name!
                      : null;

                  _genderController.text = _selectedGender.name;
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
                () => Navigator.of(context).pushNamed(
                      ChangePhone.routeName,
                      arguments: userState.user.phone,
                    )),
            _buildSpacer(10),
            _buildEmailItem(
              "Email",
              _maskEmail(userState.user.email ?? ""),
              () {},
              // () => Navigator.of(context).pushNamed(
              //   ChangeEmail.routeName,
              //   arguments: userState.user.email,
              // ),
            ),
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
      child: GestureDetector(
        onTap: () async {
          final XFile? image =
              await _imagePicker.pickImage(source: ImageSource.gallery);
          if (image != null) {
            setState(() {
              _avatarUrlController.text = image.path;
              _isInfoChange = true;
            });
          }
        },
        child: Stack(
          children: [
            ClipOval(
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
                      )),
            Positioned(
              bottom: 0,
              child: Container(
                width: 70,
                height: 30,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(35),
                  ),
                ),
                alignment: Alignment.center,
                child: const Text(
                  "Sửa",
                  style: TextStyle(fontSize: 13, color: Colors.white),
                ),
              ),
            ),
          ],
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
      child: InkWell(
        splashColor: Colors.grey.withOpacity(0.3),
        highlightColor: Colors.grey.withOpacity(0.1),
        onTap: () async {
          final newName = await Navigator.pushNamed(
            context,
            ChangeName.routeName,
            arguments: value,
          );

          if (newName != null) {
            setState(() {
              _nameController.text = newName as String;
              if (_nameController.text != user.name) {
                setState(() {
                  _isInfoChange = true;
                });
              }
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
                    value.isEmpty ? "Thiết lập ngay" : value,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: value.isNotEmpty ? Colors.black : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Mục giới tính với PopupMenuButton
  Widget _buildGenderItem(
      BuildContext context, String title, UserInfoModel user) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () {
          _popupMenuKey.currentState?.showButtonMenu();
        },
        splashColor: Colors.grey.withOpacity(0.3),
        highlightColor: Colors.grey.withOpacity(0.1),
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
                        : "Thiết lập ngay",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: _selectedGender != Gender.unknown
                          ? Colors.black
                          : Colors.grey,
                    ),
                  ),
                  PopupMenuButton<Gender>(
                    key: _popupMenuKey,
                    color: Colors.white,
                    menuPadding: EdgeInsets.zero,
                    padding: EdgeInsets.zero,
                    shape: OutlineInputBorder(
                        borderSide: BorderSide(
                      width: 0.5,
                      color: Colors.grey,
                    )),
                    onSelected: (Gender value) {
                      setState(() {
                        _selectedGender = value;
                        _genderController.text = value.name;
                        if (_genderController.text != user.gender!.name) {
                          setState(() {
                            _isInfoChange = true;
                          });
                        }
                      });
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<Gender>>[
                      PopupMenuItem<Gender>(
                        height: 50,
                        value: Gender.male,
                        child: Text('Nam'),
                      ),
                      const PopupMenuItem<Gender>(
                        height: 50,
                        value: Gender.female,
                        child: Text('Nữ'),
                      ),
                      const PopupMenuItem<Gender>(
                        height: 50,
                        value: Gender.other,
                        child: Text('Khác'),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.only(left: 5),
                      height: 50,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Mục ngày sinh với DatePicker
  Widget _buildDateItem(
      BuildContext context, String title, UserInfoModel user) {
    return Material(
      color: Colors.white,
      child: InkWell(
        splashColor: Colors.grey.withOpacity(0.3),
        highlightColor: Colors.grey.withOpacity(0.1),
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            helpText: 'Chọn ngày sinh',
            cancelText: 'Hủy',
            confirmText: 'Xác nhận',
            locale: Locale('vi'),
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
            builder: (context, child) {
              return Theme(
                data: ThemeData.light().copyWith(
                  primaryColor: Colors.brown, // Màu chính
                  hintColor: Colors.brown, // Màu gợi ý
                  colorScheme: const ColorScheme.light(
                    primary: Colors.brown, // Màu tiêu đề & nút chọn
                    onPrimary: Colors.white, // Màu chữ của tiêu đề & nút chọn
                    onSurface: Colors.black, // Màu chữ trên bề mặt
                  ),
                  dialogBackgroundColor: Colors.white, // Màu nền
                ),
                child: child!,
              );
            },
          );
          if (pickedDate != null) {
            setState(() {
              _selectedDate =
                  "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
              _dateController.text = _selectedDate;

              if (_dateController.text != user.date) {
                setState(() {
                  _isInfoChange = true;
                });
              }
            });
          }
        },
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
                  Text(_selectedDate != '' ? _selectedDate : "Thiết lập ngay",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: _selectedDate.isNotEmpty
                            ? Colors.black
                            : Colors.grey,
                      )),
                  const SizedBox(width: 5),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneItem(String title, String value, VoidCallback? onTap) {
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
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: value == "Thiết lập ngay"
                          ? Colors.grey
                          : Colors.black,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailItem(String title, String value, VoidCallback? onTap) {
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
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: value == "Thiết lập ngay"
                          ? Colors.grey
                          : Colors.black,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Icon(Icons.arrow_forward_ios, size: 16),
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
                "Sửa hồ sơ",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ),
            GestureDetector(
              onTap: () async {
                if (_isInfoChange) {
                  if (!_avatarUrlController.text.startsWith('http')) {
                    await _uploadAvatar(
                        user.id, XFile(_avatarUrlController.text));
                  }
                  UserInfoModel userUpdate = UserInfoModel(
                    id: user.id,
                    name: _nameController.text,
                    email: user.email,
                    phone: user.phone,
                    avataUrl: _avatarUrlController.text,
                    gender: Gender.values.firstWhere(
                      (g) =>
                          g.toString().split('.').last ==
                          _genderController.text,
                      orElse: () => Gender.unknown,
                    ),
                    date: _dateController.text,
                    userName: user.userName,
                    role: user.role,
                  );

                  context
                      .read<UserBloc>()
                      .add(UpdateBasicInfoUserEvent(userUpdate));
                  Navigator.of(context).pop();
                }
              },
              child: Container(
                height: 40,
                width: 40,
                alignment: Alignment.center,
                child: Icon(
                  HeroIcons.check,
                  color: _isInfoChange ? Colors.brown : Colors.grey,
                ),
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
