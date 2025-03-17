import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luanvan/blocs/auth/auth_bloc.dart';
import 'package:luanvan/blocs/auth/auth_state.dart';
import 'package:luanvan/blocs/shop/shop_bloc.dart';
import 'package:luanvan/blocs/shop/shop_state.dart';
import 'package:luanvan/blocs/user/user_bloc.dart';
import 'package:luanvan/blocs/user/user_event.dart';
import 'package:luanvan/blocs/user/user_state.dart';
import 'package:luanvan/models/shop.dart';
import 'package:luanvan/models/user_info_model.dart';
import 'package:luanvan/services/storage_service.dart';
import 'package:luanvan/ui/user/change_info/change_name.dart';

class ChangeShopInfoScreen extends StatefulWidget {
  const ChangeShopInfoScreen({super.key});
  static String routeName = 'change_shop_info';
  @override
  State<ChangeShopInfoScreen> createState() => _ChangeShopInfoScreenState();
}

class _ChangeShopInfoScreenState extends State<ChangeShopInfoScreen> {
  final StorageService _storageService = StorageService();
  final ImagePicker _imagePicker = ImagePicker();
  Gender _selectedGender = Gender.unknown;
  String _selectedDate = '';
  final GlobalKey<PopupMenuButtonState<Gender>> _popupMenuKey =
      GlobalKey<PopupMenuButtonState<Gender>>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _avatarUrlController = TextEditingController();
  TextEditingController _backgroundUrlController = TextEditingController();
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
    final shopState = context.read<ShopBloc>().state;
    if (shopState is ShopLoaded) {
      _avatarUrlController.text = shopState.shop.avatarUrl!;
      if (shopState.shop.backgroundImageUrl != null) {
        _backgroundUrlController.text = shopState.shop.backgroundImageUrl!;
      }
      _nameController.text = shopState.shop.name;
      if (shopState.shop.description != null) {
        _descriptionController.text = shopState.shop.description!;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: BlocBuilder<ShopBloc, ShopState>(
      builder: (context, shopState) {
        if (shopState is ShopLoading) {
          return _buildLoading();
        } else if (shopState is ShopLoaded) {
          return _buildContent(context, shopState.shop);
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
    return const Center(child: Text('Initializing...'));
  }

  // Chưa đăng nhập
  Widget _buildNotAuthenticated() {
    return const Center(child: Text("Chưa đăng nhập"));
  }

  // Nội dung chính
  Widget _buildContent(BuildContext context, Shop shop) {
    return Stack(
      children: [
        _buildBody(context, shop),
        _buildAppBar(context, shop),
      ],
    );
  }

  // Phần body với thông tin người dùng
  Widget _buildBody(BuildContext context, Shop shop) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.only(top: 80),
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        color: Colors.grey[200],
        child: Column(
          children: [
            _buildAvatarSection(shop),
            _buildSpacer(10),
            _buildNameShop(),
            _buildSpacer(10),
            _buildDescriptionShop()

            // _buildSpacer(10),
            // _buildDateItem(context, "Ngày sinh", userState.user),
            // _buildPhoneItem(
            //     "Số điện thoại", _maskPhoneNumber(userState.user.phone ?? "")),
            // _buildSpacer(10),
            // _buildEmailItem("Email", _maskEmail(userState.user.email ?? "")),
          ],
        ),
      ),
    );
  }

  // Phần ảnh đại diện
  Widget _buildAvatarSection(Shop shop) {
    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey[300],
            ),
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
          ),
          Align(
              alignment: Alignment.bottomCenter,
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
                child: Container(
                    color: Colors.black54,
                    height: 30,
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.center,
                    child: Text(
                      "Chạm để thay đổi ảnh bìa",
                      style: TextStyle(color: Colors.white),
                    )),
              ))
        ],
      ),
    );
  }

  // Khoảng cách
  Widget _buildSpacer(double height) {
    return SizedBox(height: height);
  }

  Widget _buildNameShop() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "Tên shop ",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _nameController,
                builder: (context, value, child) {
                  return Text(
                    "${value.text.length}/30",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _nameController,
            maxLength: 30,
            decoration: const InputDecoration(
                hintText: "Nhập tên shop",
                border: InputBorder.none,
                counterText: '',
                contentPadding: EdgeInsets.zero),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Vui lòng nhập tên Shop";
              }
              if (value.length < 10) {
                return "Tến Shop ít nhất 10 ký tự";
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // Mục giới tính với PopupMenuButton
  Widget _buildDescriptionShop() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Mô tả Shop ",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _descriptionController,
                builder: (context, value, child) {
                  return Text(
                    "${value.text.length}/500",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _descriptionController,
            maxLength: 500,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: "Nhập mô tả Shop",
              border: InputBorder.none,
              counterText: '',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Vui lòng nhập mô tả Shop";
              }

              return null;
            },
          ),
        ],
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

  Widget _buildPhoneItem(String title, String value) {
    return Material(
      color: Colors.white,
      child: InkWell(
        splashColor: Colors.grey.withOpacity(0.3),
        highlightColor: Colors.grey.withOpacity(0.1),
        onTap: () {
          Navigator.of(context).pushNamed(ChangeName.routeName);
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

  Widget _buildEmailItem(String title, String value) {
    return Material(
      color: Colors.white,
      child: InkWell(
        splashColor: Colors.grey.withOpacity(0.3),
        highlightColor: Colors.grey.withOpacity(0.1),
        onTap: () {
          Navigator.of(context).pushNamed(ChangeName.routeName);
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
  Widget _buildAppBar(BuildContext context, Shop shop) {
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
                "Sửa hồ sơ Shop",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ),
            GestureDetector(
              onTap: () async {
                if (_isInfoChange) {
                  if (!_avatarUrlController.text.startsWith('http')) {
                    await _uploadAvatar(
                        shop.shopId!, XFile(_avatarUrlController.text));
                  }

                  // context
                  //     .read<UserBloc>()
                  //     .add(UpdateBasicInfoUserEvent(userUpdate));
                  // Navigator.of(context).pop();
                }
              },
              child: Container(
                height: 40,
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  "Lưu",
                  style: TextStyle(
                      color: _isInfoChange ? Colors.brown : Colors.grey),
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
