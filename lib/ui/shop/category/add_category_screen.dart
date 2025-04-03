import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luanvan/blocs/category/category_bloc.dart';
import 'package:luanvan/blocs/category/category_event.dart';
import 'package:luanvan/models/category.dart';
import 'package:luanvan/services/storage_service.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});
  static String routeName = 'add_category';

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  XFile? _categoryImage;

  @override
  void dispose() {
    _nameController.dispose();
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

  Future<void> _submitForm(String shopId) async {
    if (_categoryImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng thêm hình ảnh danh mục")),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final StorageService storageService = StorageService();
      String categoryName = _nameController.text;
      String? imageUrl = await storageService.uploadFile(
          File(_categoryImage!.path), 'image', '', '');
      Category category = Category(
        id: '',
        name: categoryName,
        imageUrl: imageUrl,
        isHidden: false,
      );
      if (imageUrl != null) {
        context.read<CategoryBloc>().add(AddCategoryEvent(
              category: category,
            ));
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final shopId = ModalRoute.of(context)!.settings.arguments as String;
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
                                "Hình ảnh danh mục",
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
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: _categoryImage != null
                                  ? Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.file(
                                            File(_categoryImage!.path),
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _categoryImage = null;
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
                                        ),
                                      ],
                                    )
                                  : Center(
                                      child: Icon(
                                        Icons.add_photo_alternate_outlined,
                                        size: 30,
                                        color: Colors.grey,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    "Tên danh mục",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    "*",
                                    style: TextStyle(color: Colors.red),
                                  )
                                ],
                              ),
                              const Spacer(),
                              ValueListenableBuilder<TextEditingValue>(
                                valueListenable: _nameController,
                                builder: (context, value, child) {
                                  return Text(
                                    "${value.text.length}/10",
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _nameController,
                            maxLength: 100,
                            decoration: const InputDecoration(
                              hintText: "Nhập tên danh mục",
                              border: InputBorder.none,
                              counterText: '',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Vui lòng nhập tên danh mục";
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
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
                      "Thêm danh mục",
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
                      onPressed: () => _submitForm(shopId),
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
