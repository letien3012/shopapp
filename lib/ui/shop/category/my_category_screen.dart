import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:luanvan/blocs/category/category_bloc.dart';
import 'package:luanvan/blocs/category/category_event.dart';
import 'package:luanvan/blocs/category/category_state.dart';
import 'package:luanvan/models/category.dart';
import 'package:luanvan/models/shop.dart';
import 'package:luanvan/ui/helper/icon_helper.dart';
import 'package:luanvan/ui/shop/category/add_category_screen.dart';
import 'package:luanvan/ui/shop/category/edit_category_screen.dart';
import 'package:luanvan/ui/shop/product_manager/details_product_shop_screen.dart';
import 'package:luanvan/ui/widgets/alert_diablog.dart';
import 'package:luanvan/ui/widgets/confirm_diablog.dart';

class MyCategoryScreen extends StatefulWidget {
  const MyCategoryScreen({super.key});
  static String routeName = "my_category";

  @override
  State<MyCategoryScreen> createState() => _MyCategoryScreenState();
}

class _MyCategoryScreenState extends State<MyCategoryScreen> {
  late Shop shop;
  String shopId = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryBloc>().add(FetchCategoriesEvent());
    });
  }

  Future<bool> _showConfirmLockUserDialog(String title) async {
    final confirmed = await ConfirmDialog(
      title: title,
      cancelText: "Không",
      confirmText: "Đồng ý",
    ).show(context);
    return confirmed;
  }

  Future<void> _showAlertDialog(String title) async {
    await showAlertDialog(
      context,
      message: title,
      iconPath: IconHelper.check,
      duration: Duration(seconds: 1),
    );
  }

  void _hideCategory(Category category) async {
    bool confirmed = false;
    if (category.isHidden) {
      confirmed = await _showConfirmLockUserDialog("Xác nhận hiện danh mục?");
    } else {
      confirmed = await _showConfirmLockUserDialog("Xác nhận ẩn danh mục?");
    }
    if (confirmed) {
      if (category.isHidden) {
        await _showAlertDialog("Đã hiện danh mục");
      } else {
        await _showAlertDialog("Đã ẩn danh mục");
      }
      context.read<CategoryBloc>().add(UpdateCategoryEvent(category: category));
    }
  }

  void _editCategory(Category category) {
    Navigator.of(context).pushNamed(
      EditCategoryScreen.routeName,
      arguments: category,
    );
  }

  void _deleteCategory(String categoryId) {
    context.read<CategoryBloc>().add(DeleteCategoryEvent(id: categoryId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, categoryState) {
          if (categoryState is CategoryLoading) {
            return _buildLoading();
          } else if (categoryState is CategoryLoaded) {
            return _buildShopContent(context, categoryState.categories);
          } else if (categoryState is CategoryError) {
            return _buildError(categoryState.message);
          }
          return _buildInitializing();
        },
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

  Widget _buildShopContent(BuildContext context, List<Category> categories) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height,
            minHeight: MediaQuery.of(context).size.height,
            minWidth: MediaQuery.of(context).size.width,
          ),
          padding: const EdgeInsets.only(top: 90, bottom: 60),
          child: _buildCategoryList(categories),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              Container(
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
                        margin: EdgeInsets.only(bottom: 5),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.brown,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 40,
                      child: Text(
                        "Quản lý danh mục",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(Icons.search, color: Colors.brown, size: 30),
                            const SizedBox(width: 10),
                            SvgPicture.asset(
                              IconHelper.chatIcon,
                              color: Colors.brown,
                              height: 30,
                              width: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 70,
            width: double.infinity,
            color: Colors.white,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(
                  AddCategoryScreen.routeName,
                  arguments: shopId,
                );
              },
              child: Container(
                margin: const EdgeInsets.all(10),
                height: 50,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.brown,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Thêm danh mục mới",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryList(List<Category> categories) {
    if (categories.isEmpty) {
      return Center(
        child: Text(
          "Không có danh mục",
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 90),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                      context, DetailsProductShopScreen.routeName,
                      arguments: category.id);
                },
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        category.imageUrl != null &&
                                category.imageUrl!.isNotEmpty
                            ? category.imageUrl!
                            : 'https://via.placeholder.com/80',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.network(
                          'https://via.placeholder.com/80',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            category.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildActionButton(
                      category.isHidden ? "Hiện" : "Ẩn",
                      Colors.white,
                      Colors.black,
                      category.isHidden
                          ? () =>
                              _hideCategory(category.copyWith(isHidden: false))
                          : () =>
                              _hideCategory(category.copyWith(isHidden: true))),
                  const SizedBox(width: 10),
                  _buildActionButton("Sửa", Colors.brown, Colors.white,
                      () => _editCategory(category)),
                  const SizedBox(width: 10),
                  _buildActionButton("Xóa", Colors.red[800]!, Colors.white,
                      () => _deleteCategory(category.id)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton(
      String label, Color bgColor, Color textColor, VoidCallback onTap) {
    return Material(
      color: bgColor,
      child: InkWell(
        splashColor: bgColor.withOpacity(0.2),
        highlightColor: bgColor.withOpacity(0.1),
        onTap: onTap,
        child: Container(
          height: 35,
          width: 80,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: textColor),
          ),
        ),
      ),
    );
  }
}
