import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luanvan/blocs/shop/shop_bloc.dart';
import 'package:luanvan/blocs/shop/shop_event.dart';
import 'package:luanvan/blocs/shop/shop_state.dart';
import 'package:luanvan/models/shop.dart';
import 'package:luanvan/services/storage_service.dart';

class ChangeShopInfoScreen extends StatefulWidget {
  const ChangeShopInfoScreen({super.key});
  static String routeName = 'change_shop_info';
  @override
  State<ChangeShopInfoScreen> createState() => _ChangeShopInfoScreenState();
}

class _ChangeShopInfoScreenState extends State<ChangeShopInfoScreen> {
  final StorageService _storageService = StorageService();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _avatarUrlController = TextEditingController();
  TextEditingController _backgroundUrlController = TextEditingController();
  bool _isInfoChange = false;
  final _formKey = GlobalKey<FormState>();
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

  Future<void> _uploadBackground(String userId, XFile image) async {
    try {
      File imageFile = File(image.path);
      String? downloadUrl = await _storageService.uploadFile(
          imageFile, 'image', 'background', userId);
      if (downloadUrl != null) {
        _backgroundUrlController.text = downloadUrl;
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

  void showImagePickMethod(
      BuildContext context, TextEditingController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: EdgeInsets.symmetric(vertical: 10),
          contentPadding: EdgeInsets.symmetric(vertical: 10),
          title: Stack(
            children: [
              Center(
                child: Text(
                  'Thao tác',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ListTile(
                title: Text('Chụp ảnh'),
                onTap: () async {
                  final pickedImage =
                      await ImagePicker().pickImage(source: ImageSource.camera);
                  if (pickedImage != null) {
                    controller.text = pickedImage.path;
                    setState(() {
                      _isInfoChange = true;
                    });
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Thư viện hình ảnh'),
                onTap: () async {
                  final pickedImage = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (pickedImage != null) {
                    controller.text = pickedImage.path;
                    setState(() {
                      _isInfoChange = true;
                    });
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        );
      },
    );
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
            Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildSpacer(10),
                    _buildNameShop(),
                    _buildSpacer(10),
                    _buildDescriptionShop()
                  ],
                ))
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
              image: shop.backgroundImageUrl != null
                  ? DecorationImage(
                      image: _backgroundUrlController.text.startsWith('http')
                          ? NetworkImage(
                              _backgroundUrlController.text,
                            )
                          : FileImage(
                              File(_backgroundUrlController.text),
                            ),
                      fit: BoxFit.fitWidth)
                  : null,
            ),
            child: GestureDetector(
              onTap: () async {
                showImagePickMethod(context, _avatarUrlController);
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
                onTap: () {
                  showImagePickMethod(context, _backgroundUrlController);
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
                if (_isInfoChange && _formKey.currentState!.validate()) {
                  if (!_avatarUrlController.text.startsWith('http')) {
                    await _uploadAvatar(
                        shop.shopId!, XFile(_avatarUrlController.text));
                  }
                  if (!_backgroundUrlController.text.startsWith('http')) {
                    await _uploadBackground(
                        shop.shopId!, XFile(_backgroundUrlController.text));
                  }
                  final updateShop = shop.copyWith(
                    avatarUrl: _avatarUrlController.text,
                    backgroundImageUrl: _backgroundUrlController.text,
                    name: _nameController.text,
                    description: _descriptionController.text,
                  );
                  context.read<ShopBloc>().add(UpdateShopEvent(updateShop));
                  Navigator.of(context).pop();
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
}
