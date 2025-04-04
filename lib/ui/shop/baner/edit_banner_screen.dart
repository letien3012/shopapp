import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luanvan/blocs/banner/banner_bloc.dart';
import 'package:luanvan/blocs/banner/banner_event.dart';
import 'package:luanvan/blocs/category/category_bloc.dart';
import 'package:luanvan/blocs/category/category_event.dart';
import 'package:luanvan/services/storage_service.dart';
import 'package:luanvan/models/banner.dart' as model;

class EditBannerScreen extends StatefulWidget {
  const EditBannerScreen({super.key});
  static String routeName = 'edit_banner';

  @override
  State<EditBannerScreen> createState() => _EditBannerScreenState();
}

class _EditBannerScreenState extends State<EditBannerScreen> {
  final _formKey = GlobalKey<FormState>();
  XFile? _categoryImage;
  String? _currentImageUrl;
  model.Banner? currentBanner;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showImagePickMethod(BuildContext context) {
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
                    setState(() {
                      _categoryImage = pickedImage;
                      _currentImageUrl = null;
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
                    setState(() {
                      _categoryImage = pickedImage;
                      _currentImageUrl = null;
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

  Future<void> _submitForm(String bannerId) async {
    if (_categoryImage == null && _currentImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng thêm hình ảnh banner")),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      String? imageUrl = _currentImageUrl;
      // Chỉ upload ảnh mới nếu người dùng đã chọn ảnh mới
      if (_categoryImage != null) {
        final StorageService storageService = StorageService();
        imageUrl = await storageService.uploadFile(
            File(_categoryImage!.path), 'image', '', '');
        if (imageUrl == null) {
          context.read<BannerBloc>().add(UpdateBannerEvent(
              banner: currentBanner!.copyWith(imageUrl: imageUrl)));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Lỗi khi tải lên hình ảnh")),
          );
          return;
        }
      }

      context.read<BannerBloc>().add(UpdateBannerEvent(
          banner: currentBanner!.copyWith(imageUrl: imageUrl, id: bannerId)));
      Navigator.of(context).pop();
    }
  }

  Widget _buildImageWidget() {
    if (_categoryImage != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(_categoryImage!.path),
              width: MediaQuery.of(context).size.width * 0.9,
              height: 300,
              fit: BoxFit.fitWidth,
            ),
          ),
          _buildRemoveImageButton(),
        ],
      );
    } else if (_currentImageUrl != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              _currentImageUrl!,
              width: MediaQuery.of(context).size.width * 0.9,
              height: 300,
              fit: BoxFit.fitWidth,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.error_outline,
                size: 30,
                color: Colors.red,
              ),
            ),
          ),
          _buildRemoveImageButton(),
        ],
      );
    } else {
      return Center(
        child: Icon(
          Icons.add_photo_alternate_outlined,
          size: 30,
          color: Colors.grey,
        ),
      );
    }
  }

  Widget _buildRemoveImageButton() {
    return Positioned(
      right: 0,
      top: 0,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _categoryImage = null;
            _currentImageUrl = null;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.close,
            size: 20,
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    currentBanner = ModalRoute.of(context)!.settings.arguments as model.Banner;
    _currentImageUrl = currentBanner?.imageUrl;
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              color: Colors.grey[100],
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              padding: const EdgeInsets.only(
                  top: 90, bottom: 80, left: 10, right: 10),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(16),
                      margin: EdgeInsets.only(top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                "Hình ảnh banner",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                "*",
                                style: TextStyle(color: Colors.red),
                              ),
                              Spacer(),
                              Text("Tỉ lệ hình ảnh 1:1")
                            ],
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () => _showImagePickMethod(context),
                            child: Container(
                              height: 300,
                              width: MediaQuery.of(context).size.width * 0.9,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: _buildImageWidget(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
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
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      height: 40,
                      width: 40,
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(bottom: 5),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.brown,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const SizedBox(
                    height: 40,
                    child: Text(
                      "Chỉnh sửa banner",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 70,
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _submitForm(currentBanner!.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Lưu",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
