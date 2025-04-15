import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/listproductbloc/listproduct_bloc.dart';
import 'package:luanvan/blocs/listproductbloc/listproduct_event.dart';
import 'package:luanvan/blocs/listproductbloc/listproduct_state.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/models/product_option.dart';
import 'package:luanvan/models/import_item.dart';
import 'package:luanvan/models/import_receipt.dart';
import 'package:luanvan/models/supplier.dart';
import 'package:luanvan/ui/helper/icon_helper.dart';
import 'package:luanvan/ui/shop/warehouse/import_receipt_manager/import_receipt_manager_screen.dart';
import 'package:luanvan/ui/widgets/alert_diablog.dart';
import 'package:luanvan/ui/shop/warehouse/edit_stock_detail_screen.dart';

class MyWarehouseScreen extends StatefulWidget {
  const MyWarehouseScreen({super.key});
  static String routeName = "my_warehouse";

  @override
  State<MyWarehouseScreen> createState() => _MyWarehouseScreenState();
}

class _MyWarehouseScreenState extends State<MyWarehouseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String shopId = '';
  bool _isSelectionMode = false;
  Set<ImportItem> _selectedOptions = {};
  List<ImportItem> allImportItems = [];
  List<ImportItem> lowStockImportItems = [];
  List<ImportItem> outOfStockImportItems = [];
  Future<void> _showAlertDialog() async {
    await showAlertDialog(
      context,
      message: "Bạn chưa chọn sản phẩm nào để tạo phiếu nhập hàng",
      iconPath: IconHelper.warning,
      duration: Duration(seconds: 1),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      shopId = ModalRoute.of(context)!.settings.arguments as String;
      context
          .read<ListProductBloc>()
          .add(FetchListProductEventByShopId(shopId));
    });

    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ListProductBloc, ListProductState>(
        builder: (context, productState) {
          if (productState is ListProductLoading) {
            return _buildLoading();
          } else if (productState is ListProductLoaded) {
            allImportItems = [];
            lowStockImportItems = [];
            outOfStockImportItems = [];
            return _buildShopContent(context, productState.listProduct);
          } else if (productState is ListProductError) {
            return _buildError(productState.message);
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

  Widget _buildShopContent(BuildContext context, List<Product> listProduct) {
    // Filter products based on search query
    final filteredProducts = _searchQuery.isEmpty
        ? listProduct
        : listProduct
            .where(
                (product) => product.name.toLowerCase().contains(_searchQuery))
            .toList();

    for (var product in filteredProducts) {
      if (product.isDeleted || product.isHidden) continue;
      if (product.variants.isEmpty) {
        if (product.quantity! > 5) {
          allImportItems.add(ImportItem(
              productId: product.id,
              productName: product.name,
              imageUrl: product.imageUrl.isNotEmpty ? product.imageUrl[0] : '',
              optionName: 'Mặc định',
              quantity: product.quantity!,
              price: 0,
              adjustmentQuantities: 0));
        }
        if (product.quantity! <= 5 && product.quantity! > 0) {
          lowStockImportItems.add(ImportItem(
              productId: product.id,
              productName: product.name,
              imageUrl: product.imageUrl.isNotEmpty ? product.imageUrl[0] : '',
              optionName: 'Mặc định',
              quantity: product.quantity!,
              price: 0,
              adjustmentQuantities: 0));
        }
        if (product.quantity! == 0) {
          outOfStockImportItems.add(ImportItem(
              productId: product.id,
              productName: product.name,
              imageUrl: product.imageUrl.isNotEmpty ? product.imageUrl[0] : '',
              optionName: 'Mặc định',
              quantity: 0,
              price: 0,
              adjustmentQuantities: 0));
        }
      } else {
        for (var optionInfo in product.optionInfos) {
          String optionName = '';
          String? optionId1 = optionInfo.optionId1;
          String? optionId2 = optionInfo.optionId2;
          String imageUrl = '';
          if (product.variants.length == 1) {
            final option = product.variants[0].options.firstWhere(
              (opt) => opt.id == optionInfo.optionId1,
              orElse: () => ProductOption(id: '', name: ''),
            );
            if (product.hasVariantImages) {
              imageUrl = option.imageUrl ?? '';
            } else {
              imageUrl = product.imageUrl[0];
            }
            optionName = option.name;
          } else if (product.variants.length == 2) {
            final option1 = product.variants[0].options.firstWhere(
              (opt) => opt.id == optionInfo.optionId1,
              orElse: () => ProductOption(id: '', name: ''),
            );
            final option2 = product.variants[1].options.firstWhere(
              (opt) => opt.id == optionInfo.optionId2,
              orElse: () => ProductOption(id: '', name: ''),
            );
            if (product.hasVariantImages) {
              imageUrl = option1.imageUrl ?? '';
            } else {
              imageUrl = product.imageUrl[0];
            }
            optionName = "${option1.name} - ${option2.name}";
          }

          if (optionInfo.stock > 5) {
            allImportItems.add(ImportItem(
                productId: product.id,
                productName: product.name,
                imageUrl: imageUrl,
                optionName: optionName,
                quantity: optionInfo.stock,
                price: 0,
                optionId1: optionId1,
                optionId2: optionId2,
                adjustmentQuantities: 0));
          } else {
            if (optionInfo.stock > 0) {
              lowStockImportItems.add(ImportItem(
                  productId: product.id,
                  productName: product.name,
                  imageUrl: imageUrl,
                  optionName: optionName,
                  quantity: optionInfo.stock,
                  price: 0,
                  optionId1: optionId1,
                  optionId2: optionId2,
                  adjustmentQuantities: 0));
            } else {
              outOfStockImportItems.add(
                ImportItem(
                    productId: product.id,
                    productName: product.name,
                    imageUrl: imageUrl,
                    optionName: optionName,
                    quantity: 0,
                    price: 0,
                    optionId1: optionId1,
                    optionId2: optionId2,
                    adjustmentQuantities: 0),
              );
            }
          }
        }
      }
    }

    return Column(
      children: [
        // Header
        Container(
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
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  height: 40,
                  width: 40,
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(bottom: 5),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.brown,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 40,
                child: Text(
                  "Kho hàng của tôi",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isSelectionMode = !_isSelectionMode;
                      if (!_isSelectionMode) {
                        _selectedOptions.clear();
                      }
                    });
                  },
                  child: SizedBox(
                    height: 40,
                    child: Text(
                      _isSelectionMode ? "Hủy" : "Chọn",
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Search bar
        Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Container(
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.search, color: Colors.grey, size: 20),
                ),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Tìm sản phẩm',
                      hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minWidth: 32),
                    icon: Icon(Icons.clear, color: Colors.grey, size: 20),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                      });
                    },
                  ),
              ],
            ),
          ),
        ),
        // TabBar
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.brown,
            labelStyle: TextStyle(fontSize: 13),
            tabs: [
              Tab(text: 'Tất cả (${allImportItems.length})'),
              Tab(text: 'Sắp hết hàng (${lowStockImportItems.length})'),
              Tab(text: 'Đã hết hàng (${outOfStockImportItems.length})'),
            ],
          ),
        ),
        // TabBarView
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOptionList(allImportItems),
              lowStockImportItems.isEmpty
                  ? _buildEmptyTab("Không có sản phẩm sắp hết hàng")
                  : _buildOptionList(lowStockImportItems),
              outOfStockImportItems.isEmpty
                  ? _buildEmptyTab("Không có sản phẩm đã hết hàng")
                  : _buildOptionList(outOfStockImportItems),
            ],
          ),
        ),
        // Bottom buttons
        _buildBottomButtons(allImportItems),
      ],
    );
  }

  Widget _buildOptionList(List<ImportItem> options) {
    return Container(
      color: Colors.white,
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height,
      ),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 90),
        itemCount: options.length,
        itemBuilder: (context, index) {
          final option = options[index];
          final productId = option.productId;
          final optionName = option.optionName;
          final stock = option.quantity;
          final optionId1 = option.optionId1;
          final optionId2 = option.optionId2;

          return Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: GestureDetector(
              onTap: () {
                if (_isSelectionMode) {
                  setState(() {
                    bool isSelected = _selectedOptions.any((selectedOption) =>
                        selectedOption.productId == productId &&
                        selectedOption.optionId1 == optionId1 &&
                        selectedOption.optionId2 == optionId2);

                    if (isSelected) {
                      _selectedOptions.removeWhere((selectedOption) =>
                          selectedOption.productId == productId &&
                          selectedOption.optionId1 == optionId1 &&
                          selectedOption.optionId2 == optionId2);
                    } else {
                      _selectedOptions.add(option);
                    }
                  });
                }
              },
              child: Row(
                children: [
                  if (_isSelectionMode)
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _selectedOptions.any((selectedOption) =>
                              selectedOption.productId == productId &&
                              selectedOption.optionId1 == optionId1 &&
                              selectedOption.optionId2 == optionId2),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedOptions.add(option);
                              } else {
                                _selectedOptions.removeWhere((selectedOption) =>
                                    selectedOption.productId == productId &&
                                    selectedOption.optionId1 == optionId1 &&
                                    selectedOption.optionId2 == optionId2);
                              }
                            });
                          },
                          activeColor: Colors.brown,
                        ),
                      ),
                    ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      option.imageUrl.isNotEmpty
                          ? option.imageUrl
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
                          option.productName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Phân loại: $optionName",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Kho: $stock",
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                stock <= 5 ? Colors.red : Colors.grey.shade600,
                            fontWeight: stock <= 5
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyTab(String message) {
    return Container(
      color: Colors.white,
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height,
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
      ),
    );
  }

  Widget _buildBottomButtons(List<ImportItem> options) {
    return Container(
      height: 70,
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_isSelectionMode && _selectedOptions.isNotEmpty) {
                  // Create import items from selected options

                  // Create import receipt
                  final importReceipt = ImportReceipt(
                    id: '',
                    supplier: Supplier(
                        id: '',
                        name: 'Chọn nhà cung cấp',
                        address: '',
                        phone: '',
                        email: ''),
                    code: '',
                    status: ImportReceiptStatus.pending,
                    createdAt: DateTime.now(),
                    expectedImportDate: DateTime.now(),
                    items: _selectedOptions.toList(),
                  );

                  Navigator.of(context)
                      .pushNamed(
                    EditStockDetailScreen.routeName,
                    arguments: importReceipt,
                  )
                      .then((result) {
                    // if (result != null) {
                    //   Navigator.of(context).pushNamed(
                    //     AddImportReceiptScreen.routeName,
                    //     arguments: {
                    //       'products': selectedProductsList,
                    //       'selectedOptions': _selectedOptions.toList(),
                    //       'importReceipt': importReceipt,
                    //     },
                    //   );
                    // }
                  });
                } else {
                  _showAlertDialog();
                }
              },
              child: Container(
                margin: const EdgeInsets.all(10),
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: Text(
                  "Tạo phiếu nhập hàng",
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(
                  ImportReceiptManagerScreen.routeName,
                  arguments: shopId,
                );
              },
              child: Container(
                margin: const EdgeInsets.all(10),
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: Text(
                  "Quản lý nhập hàng và điều chỉnh tồn kho",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
