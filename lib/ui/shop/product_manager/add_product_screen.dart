import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luanvan/blocs/category/category_bloc.dart';
import 'package:luanvan/blocs/category/category_event.dart';
import 'package:luanvan/blocs/listproductbloc/listproduct_bloc.dart';
import 'package:luanvan/blocs/listproductbloc/listproduct_event.dart';
import 'package:luanvan/blocs/listproductbloc/listproduct_state.dart';
import 'package:luanvan/blocs/product/product_bloc.dart';
import 'package:luanvan/blocs/product/product_event.dart';
import 'package:luanvan/blocs/product/product_state.dart';
import 'package:luanvan/blocs/shop/shop_bloc.dart';
import 'package:luanvan/blocs/shop/shop_event.dart';
import 'package:luanvan/blocs/shop/shop_state.dart';
import 'package:luanvan/blocs/category/category_state.dart';
import 'package:luanvan/models/category.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/models/shipping_method.dart';
import 'package:luanvan/models/shop.dart';
import 'package:luanvan/services/image_feature_service.dart';
import 'package:luanvan/services/storage_service.dart';
import 'package:luanvan/ui/helper/icon_helper.dart';
import 'package:luanvan/ui/shop/product_manager/add_product_category_screen.dart';
import 'package:luanvan/ui/shop/product_manager/add_variant_screen.dart';
import 'package:luanvan/ui/shop/product_manager/delivery_cost_screen.dart';
import 'package:luanvan/ui/widgets/alert_diablog.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});
  static String routeName = 'add_product';

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  String shopId = '';
  late Product product;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _shipController = TextEditingController();
  List<XFile> _imageFiles = [];
  String _productVariant = "Thiết lập màu sắc kích thước";
  String _category = "Chọn danh mục";
  bool _isAddingProduct = false;

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
      isHidden: false,
      isDeleted: false,
      hasVariantImages: false,
      hasWeightVariant: false,
      shippingMethods: [],
      optionInfos: [],
    );
    product.shippingMethods.addAll(ShippingMethod.defaultMethods);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<CategoryBloc>().add(FetchCategoriesEvent());
    });
    super.initState();
  }

  Future<void> _showAddSuccessDialog() async {
    await showAlertDialog(
      context,
      message: "Thêm sản phẩm thành công",
      iconPath: IconHelper.check,
      duration: Duration(seconds: 1),
    );
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
    if (_category == "Chọn danh mục") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn danh mục của sản phẩm")),
      );
      return;
    }
    if (!(product.shippingMethods[0].isEnabled ||
        product.shippingMethods[1].isEnabled ||
        product.shippingMethods[2].isEnabled)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Vui lòng kích hoạt ít nhất 1 phương thức vận chuyển cho sản phẩm")),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isAddingProduct = true;
      });

      final StorageService _storageService = StorageService();
      product.name = _nameController.text;
      product.category = _category;
      product.description = _descriptionController.text;
      List<String> _listImageUrl = [];
      List<String> _listImageUrlFeature = [];
      List<String> _listImageFeature = [];
      for (int i = 0; i < _imageFiles.length; i++) {
        _listImageFeature.add(_imageFiles[i].path);
        String? downloadUrl = await _storageService.uploadFile(
            File(_imageFiles[i].path), 'image', '', '');
        if (downloadUrl != null) {
          _listImageUrl.add(downloadUrl);
          _listImageUrlFeature.add(downloadUrl);
        }
      }

      product.imageUrl = _listImageUrl;
      if (product.hasVariantImages) {
        for (int i = 0; i < product.variants[0].options.length; i++) {
          _listImageFeature.add(product.variants[0].options[i].imageUrl!);
          String? downloadUrl = await _storageService.uploadFile(
              File(product.variants[0].options[i].imageUrl!), 'image', '', '');
          if (downloadUrl != null) {
            product.variants[0].options[i].imageUrl = downloadUrl;

            _listImageUrlFeature.add(downloadUrl);
          }
        }
      }
      if (product.getTotalOptionsCount() == 0) {
        double price = double.parse(_priceController.text);
        int stock = int.parse(_stockController.text);
        product.price = price;
        product.quantity = stock;
      }

      product.shopId = shopId;
      print(product.imageUrl.length);
      context.read<ProductBloc>().add(AddProductEvent(product));
      await context
          .read<ProductBloc>()
          .stream
          .firstWhere((state) => state is ProductCreated);
      final productId =
          (context.read<ProductBloc>().state as ProductCreated).productId;
      await ImageFeatureService().uploadImageFeature(
          _listImageFeature, productId, _listImageUrlFeature);

      context
          .read<ListProductBloc>()
          .add(FetchListProductEventByShopId(shopId));
      await context
          .read<ListProductBloc>()
          .stream
          .firstWhere((state) => state is ListProductLoaded);
      await _showAddSuccessDialog();
      setState(() {
        _isAddingProduct = false;
      });

      Future.delayed(Duration(milliseconds: 100), () {
        Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    shopId = ModalRoute.of(context)!.settings.arguments as String;
    context.read<ShopBloc>().add(FetchShopEventByShopId(shopId));
    context.read<CategoryBloc>().add(FetchCategoriesEvent());

    return Scaffold(
      body: Stack(
        children: [
          BlocBuilder<ShopBloc, ShopState>(
            builder: (context, shopState) {
              if (shopState is ShopLoading) {
                return _buildLoading();
              } else if (shopState is ShopLoaded) {
                return BlocBuilder<CategoryBloc, CategoryState>(
                  builder: (context, categoryState) {
                    if (categoryState is CategoryLoading) {
                      return _buildLoading();
                    } else if (categoryState is CategoryLoaded) {
                      return _buildShopContent(
                          context, shopState.shop, categoryState.categories);
                    } else if (categoryState is CategoryError) {
                      return _buildError(categoryState.message);
                    }
                    return _buildInitializing();
                  },
                );
              } else if (shopState is ShopError) {
                return _buildError(shopState.message);
              }
              return _buildInitializing();
            },
          ),
          if (_isAddingProduct)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.brown),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Đang thêm sản phẩm...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildError(String message) {
    return Center(child: Text('Error: $message'));
  }

  Widget _buildInitializing() {
    return const Center(child: Text('Đang khởi tạo'));
  }

  Widget _buildShopContent(
      BuildContext context, Shop shop, List<Category> categories) {
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
                                        child: Image.file(
                                          File(
                                            _imageFiles[index].path,
                                          ),
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
                  // Mô tả sản phẩm
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Vui lòng nhập mô tả sản phẩm";
                            }
                            if (value.length < 100) {
                              return "Mô tả sản phẩm ít nhất 100 ký tự";
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Ngành hàng
                  GestureDetector(
                    onTap: () {
                      if (_nameController.text.isEmpty ||
                          _descriptionController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Vui lòng nhập tên và mô tả sản phẩm trước khi chọn danh mục'),
                          ),
                        );
                        return;
                      }
                      Navigator.pushNamed(
                        context,
                        AddProductCategoryScreen.routeName,
                        arguments: {
                          'selectedCategory': _category,
                          'product': Product(
                            id: '',
                            shopId: '',
                            name: _nameController.text,
                            description: _descriptionController.text,
                            quantitySold: 0,
                            averageRating: 0,
                            variants: [],
                            shippingMethods: [],
                          ),
                        },
                      ).then((value) {
                        if (value != null) {
                          setState(() {
                            final category = value as Category;
                            _category = category.id;
                          });
                        }
                      });
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
                                "Danh mục ",
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
                                _category == "Chọn danh mục"
                                    ? _category
                                    : categories
                                        .firstWhere((element) =>
                                            element.id == _category)
                                        .name,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _category == "Chọn danh mục"
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
                  // Phân loại hàng
                  GestureDetector(
                    onTap: () async {
                      final updatedProduct = await Navigator.pushNamed(
                        context,
                        AddVariantScreen.routeName,
                        arguments: product,
                      );

                      if (updatedProduct != null && updatedProduct is Product) {
                        setState(() {
                          product = updatedProduct;
                          if (product.variants.isNotEmpty) {
                            _productVariant = product.variants
                                .map((val) => val.label)
                                .join(', ');
                          } else {
                            _productVariant = 'Thiết lập màu sắc kích thước';
                          }
                          if (product.variants.isEmpty) {
                            // Nếu không có phân loại, để người dùng nhập giá và kho
                            _priceController.text =
                                product.price?.toString() ?? '';
                            _stockController.text =
                                product.quantity?.toString() ?? '';
                          } else {
                            // Nếu có phân loại, hiển thị giá và kho từ optionInfos
                            if (product.getMinOptionPrice() !=
                                product.getMaxOptionPrice()) {
                              _priceController.text =
                                  "${product.getMinOptionPrice()} - ${product.getMaxOptionPrice()}";
                            } else {
                              _priceController.text =
                                  "${product.getMinOptionPrice()}";
                            }
                            _stockController.text =
                                "${product.getTotalOptionStock()}";
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
                                _productVariant,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _productVariant ==
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
                  // Giá
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
                            readOnly: product.variants.isNotEmpty,
                            textAlign: TextAlign.end,
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: "Đặt",
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                            ),
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
                  // Kho hàng
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
                            readOnly: product.variants.isNotEmpty,
                            textAlign: TextAlign.end,
                            controller: _stockController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: "Đặt",
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                            ),
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
                        product = updatedProduct;
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
                                        return "Vui lòng thiết lập phí vận chuyển";
                                      }
                                      // Kiểm tra cân nặng
                                      if (!product.hasWeightVariant &&
                                          product.weight == null) {
                                        return "Vui lòng thiết lập cân nặng";
                                      }
                                      // Kiểm tra phương thức vận chuyển
                                      if (!(product
                                              .shippingMethods[0].isEnabled ||
                                          product
                                              .shippingMethods[1].isEnabled ||
                                          product
                                              .shippingMethods[2].isEnabled)) {
                                        return "Vui lòng bật ít nhất 1 phương thức vận chuyển";
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
        // AppBar
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
                // Icon trở về
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
                      color: Colors.brown,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const SizedBox(
                  height: 40,
                  child: Text(
                    "Thêm sản phẩm",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Bottom Appbar
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
