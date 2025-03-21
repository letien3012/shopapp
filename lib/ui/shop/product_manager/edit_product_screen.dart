import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luanvan/blocs/auth/auth_bloc.dart';
import 'package:luanvan/blocs/auth/auth_state.dart';
import 'package:luanvan/blocs/product/product_bloc.dart';
import 'package:luanvan/blocs/product/product_event.dart';
import 'package:luanvan/blocs/shop/shop_bloc.dart';
import 'package:luanvan/blocs/shop/shop_event.dart';
import 'package:luanvan/blocs/shop/shop_state.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/models/product_option.dart';
import 'package:luanvan/models/product_variant.dart';
import 'package:luanvan/models/shop.dart';
import 'package:luanvan/models/user_info_model.dart';
import 'package:luanvan/services/storage_service.dart';
import 'package:luanvan/ui/helper/icon_helper.dart';
import 'package:luanvan/ui/shop/product_manager/add_category_screen.dart';
import 'package:luanvan/ui/shop/product_manager/delivery_cost_screen.dart';
import 'package:luanvan/ui/shop/product_manager/edit_variant_screen.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({super.key});
  static String routeName = 'edit_product';

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late List<ProductOption> productOption;
  late List<ProductVariant> productVariant;
  late Product product;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  List<XFile> _imageFiles = [];
  String _product_variant = "Thiết lập màu sắc kích thước";
  String _category = "Chọn ngành hàng";
  final TextEditingController _shipController = TextEditingController();

  @override
  void initState() {
    product = Product(
        id: '',
        name: '',
        quantitySold: 0,
        description: '',
        averageRating: 0,
        variants: [],
        shopId: '',
        isViolated: false,
        isHidden: false,
        hasVariantImages: false,
        shippingMethods: []);

    Future.microtask(() {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        context.read<ShopBloc>().add(FetchShopEvent(authState.user.uid));
      }

      product = args['product'] as Product;

      _nameController.text = product.name;
      _descriptionController.text = product.description;
      _category =
          product.category.isNotEmpty ? product.category : "Chọn ngành hàng";
      _imageFiles = product.imageUrl.map((url) => XFile(url)).toList();
      if (product.variants.isNotEmpty) {
        _product_variant = product.variants.map((v) => v.label).join(", ");
        _priceController.text =
            "${product.getMinOptionPrice()} - ${product.getMaxOptionPrice()}";
        _stockController.text = "${product.getMaxOptionStock()}";
      } else {
        _priceController.text = product.price.toString();
        _stockController.text = product.quantity.toString();
      }
      _shipController.text = 'Đã cài đặt';
    });

    super.initState();
  }

  void showImagePickMethod(BuildContext context) {
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
                    _imageFiles.add(pickedImage);
                    setState(() {});
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Thư viện hình ảnh'),
                onTap: () async {
                  final pickedImages =
                      await ImagePicker().pickMultiImage(limit: 10);
                  if (pickedImages.isNotEmpty) {
                    _imageFiles.addAll(pickedImages);
                    setState(() {});
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
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _shipController.dispose();
    super.dispose();
  }

  Future<void> _submitForm(String shopId) async {
    if (_imageFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Vui lòng thêm ít nhất 1 hình ảnh sản phẩm")),
      );
      return;
    }
    if (_category == "Chọn ngành hàng") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn ngành hàng của sản phẩm")),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      final StorageService _storageService = StorageService();
      product.name = _nameController.text;
      product.category = _category;
      product.description = _descriptionController.text;
      List<String> _listImageUrl = [];
      for (int i = 0; i < _imageFiles.length; i++) {
        if (!_imageFiles[i].path.startsWith('http')) {
          String? downloadUrl = await _storageService.uploadFile(
              File(_imageFiles[i].path), 'image', '', '');
          if (downloadUrl != null) {
            _listImageUrl.add(downloadUrl);
          }
        } else {
          _listImageUrl.add(_imageFiles[i].path);
        }
      }
      if (product.hasVariantImages) {
        for (int i = 0; i < product.variants[0].options.length; i++) {
          if (!product.variants[0].options[i].imageUrl!.startsWith('http')) {
            String? downloadUrl = await _storageService.uploadFile(
                File(product.variants[0].options[i].imageUrl!),
                'image',
                '',
                '');
            if (downloadUrl != null) {
              product.variants[0].options[i].imageUrl = downloadUrl;
            }
          }
        }
      } else {
        if (product.getTotalOptionsCount() > 0) {
          for (int i = 0; i < product.variants[0].options.length; i++) {
            product.variants[0].options[i].imageUrl = '';
          }
        }
      }
      if (product.getTotalOptionsCount() == 0) {
        product.quantity = int.parse(_stockController.text);
        product.price = double.parse(_priceController.text);
      }
      product.imageUrl = _listImageUrl;
      product.shopId = shopId;

      context.read<ProductBloc>().add(UpdateProductEvent(product));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: BlocBuilder<ShopBloc, ShopState>(
      builder: (context, shopState) {
        if (shopState is ShopLoading) {
          return _buildLoading();
        } else if (shopState is ShopLoaded) {
          return _buildShopContent(context, shopState.shop);
        } else if (shopState is ShopError) {
          return _buildError(shopState.message);
        }
        return _buildInitializing();
      },
    ));
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildError(String message) {
    return Center(child: Text('Error: $message'));
  }

  Widget _buildInitializing() {
    return const Center(child: Text('Đang khởi tạo'));
  }

  Widget _buildShopContent(BuildContext context, Shop shop) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Container(
            color: Colors.grey[100],
            padding:
                const EdgeInsets.only(top: 90, bottom: 80, left: 10, right: 10),
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
                              "Hình ảnh/Video sản phẩm ",
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
                        Text(
                          "(Vui lòng giữ và kéo thả ảnh bìa ở đầu)",
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        ReorderableGridView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _imageFiles.length + 1,
                          itemBuilder: (context, index) {
                            return index != _imageFiles.length
                                ? Stack(
                                    key: ValueKey(index),
                                    children: [
                                      Positioned.fill(
                                        child: _imageFiles[index]
                                                .path
                                                .startsWith('http')
                                            ? Image.network(
                                                _imageFiles[index].path,
                                                fit: BoxFit.cover,
                                              )
                                            : Image.file(
                                                File(_imageFiles[index].path),
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _imageFiles.removeAt(index);
                                            });
                                          },
                                          child: Icon(
                                            Icons.cancel,
                                            color: Colors.red[700],
                                            size: 15,
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                : GestureDetector(
                                    key: ValueKey(index),
                                    onTap: () {
                                      showImagePickMethod(context);
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                            width: 0.5,
                                            color: Colors.red,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Text(
                                        "Thêm ảnh",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  );
                          },
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 1,
                          ),
                          onReorder: (int oldIndex, int newIndex) {
                            if (oldIndex == _imageFiles.length ||
                                newIndex == _imageFiles.length) return;
                            setState(() {
                              final item = _imageFiles.removeAt(oldIndex);
                              _imageFiles.insert(newIndex, item);
                            });
                          },
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
                                  "Tên sản phẩm ",
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
                                  "${value.text.length}/120",
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
                          maxLength: 120,
                          decoration: const InputDecoration(
                            hintText: "Nhập tên sản phẩm",
                            border: InputBorder.none,
                            counterText: '',
                          ),
                          onChanged: (value) {
                            setState(() {
                              product.name = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Vui lòng nhập tên sản phẩm";
                            }
                            if (value.length < 10) {
                              return "Tên sản phẩm ít nhất 10 ký tự";
                            }
                            return null;
                          },
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
                                  "Mô tả sản phẩm ",
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
                              valueListenable: _descriptionController,
                              builder: (context, value, child) {
                                return Text(
                                  "${value.text.length}/3000",
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _descriptionController,
                          maxLength: 3000,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText: "Nhập mô tả sản phẩm",
                            border: InputBorder.none,
                            counterText: '',
                          ),
                          onChanged: (value) {
                            setState(() {
                              product.description = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Vui lòng nhập mô tả sản phẩm";
                            }
                            if (value.length < 100) {
                              return "Mô tả sản phẩm ít 100 ký tự";
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.pushNamed(
                          context, AddCategoryScreen.routeName,
                          arguments: _category) as String;
                      if (result.isNotEmpty) {
                        setState(() {
                          _category = result;
                        });
                      }
                    },
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text(
                                "Ngành hàng ",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                "*",
                                style: TextStyle(color: Colors.red),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                _category,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _category == "Chọn ngành hàng"
                                      ? Colors.grey
                                      : Colors.black,
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Icon(Icons.arrow_forward_ios,
                                  size: 16, color: Colors.grey),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () async {
                      final updatedProduct = await Navigator.pushNamed(
                        context,
                        EditVariantScreen.routeName,
                        arguments: product,
                      );
                      print(product.variants);
                      if (updatedProduct != null && updatedProduct is Product) {
                        setState(() {
                          product = updatedProduct;
                          if (product.variants.isNotEmpty) {
                            _product_variant = product.variants
                                .map((val) => val.label)
                                .join(", ");
                            _priceController.text =
                                "${product.getMinOptionPrice()} - ${product.getMaxOptionPrice()}";
                            _stockController.text =
                                "${product.getMaxOptionStock()}";
                          } else {
                            _product_variant = 'Thiết lập màu sắc kích thước';
                            _priceController.text = product.price.toString();
                            _stockController.text = product.quantity.toString();
                          }
                        });
                      }
                    },
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Phân loại hàng",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          Row(
                            children: [
                              Text(
                                _product_variant,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _product_variant ==
                                          "Thiết lập màu sắc kích thước"
                                      ? Colors.grey
                                      : Colors.black,
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Icon(Icons.arrow_forward_ios,
                                  size: 16, color: Colors.grey),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    color: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              IconHelper.pricetag,
                              height: 20,
                              width: 20,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            const Text(
                              "Giá ",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              "*",
                              style: TextStyle(color: Colors.red),
                            )
                          ],
                        ),
                        SizedBox(
                          width: 150,
                          child: TextFormField(
                            textAlign: TextAlign.end,
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            readOnly: product.variants.isNotEmpty,
                            decoration: const InputDecoration(
                              hintText: "Đặt",
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                            ),
                            onChanged: (value) {
                              if (product.variants.isNotEmpty) return;
                              setState(() {
                                if (_formKey.currentState!.validate()) {
                                  double price = double.tryParse(value) ?? 0;
                                  product.price = price;
                                }
                              });
                            },
                            validator: (value) {
                              if (product.variants.isNotEmpty) return null;
                              if (value == null || value.isEmpty) {
                                return "Vui lòng nhập giá";
                              }
                              if (double.tryParse(value) == null) {
                                return "Giá không hợp lệ";
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    color: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              IconHelper.cube,
                              height: 25,
                              width: 25,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            const Text(
                              "Kho hàng ",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              "*",
                              style: TextStyle(color: Colors.red),
                            )
                          ],
                        ),
                        SizedBox(
                          width: 150,
                          child: TextFormField(
                            textAlign: TextAlign.end,
                            controller: _stockController,
                            keyboardType: TextInputType.number,
                            readOnly: product.variants.isNotEmpty,
                            decoration: const InputDecoration(
                              hintText: "Đặt",
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                            ),
                            onChanged: (value) {
                              if (product.variants.isNotEmpty) return;
                              setState(() {
                                if (_formKey.currentState!.validate()) {
                                  int stock = int.tryParse(value) ?? 0;
                                  product.quantity = stock;
                                }
                              });
                            },
                            validator: (value) {
                              if (product.variants.isNotEmpty) return null;
                              if (value == null || value.isEmpty) {
                                return "Vui lòng nhập số lượng";
                              }
                              if (int.tryParse(value) == null) {
                                return "Số lượng không hợp lệ";
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Vận chuyển
                  GestureDetector(
                    onTap: () async {
                      final updatedProduct = await Navigator.pushNamed(
                        context,
                        DeliveryCostScreen.routeName,
                        arguments: {'product': product},
                      ) as Product;
                      setState(() {
                        product = updatedProduct as Product;
                        if (product.hasWeightVariant) {
                          _shipController.text = 'Đã cài đặt';
                        } else {
                          _shipController.text = 'Đã cài đặt';
                        }
                      });
                    },
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  IconHelper.truck,
                                  height: 25,
                                  width: 25,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                const Text(
                                  "Phí vận chuyển ",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  "*",
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 16),
                                ),
                                Expanded(
                                  child: TextFormField(
                                    readOnly: true,
                                    textAlign: TextAlign.end,
                                    controller: _shipController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      hintText: "Thiết lập",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: InputBorder.none,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Vui lòng chọn cân nặng";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _shipController.text.isEmpty
                              ? const SizedBox(
                                  width: 10,
                                )
                              : Container(),
                          _shipController.text.isEmpty
                              ? const Icon(Icons.arrow_forward_ios,
                                  size: 16, color: Colors.grey)
                              : Container(),
                        ],
                      ),
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
            padding:
                const EdgeInsets.only(top: 30, left: 10, right: 10, bottom: 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(bottom: 5),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const SizedBox(
                  height: 40,
                  child: Text(
                    "Chỉnh sửa sản phẩm",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
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
                    onPressed: () {
                      _submitForm(shop.shopId!);
                    },
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
    );
  }
}
