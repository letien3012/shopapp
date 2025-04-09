import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:luanvan/blocs/import_receipt/import_receipt_bloc.dart';
import 'package:luanvan/blocs/import_receipt/import_receipt_event.dart';
import 'package:luanvan/blocs/import_receipt/import_receipt_state.dart';
import 'package:luanvan/blocs/listproductbloc/listproduct_bloc.dart';
import 'package:luanvan/blocs/listproductbloc/listproduct_event.dart';
import 'package:luanvan/blocs/shop/shop_bloc.dart';
import 'package:luanvan/blocs/shop/shop_state.dart';
import 'package:luanvan/models/import_receipt.dart';
import 'package:luanvan/models/supplier.dart';
import 'package:luanvan/ui/helper/icon_helper.dart';
import 'package:luanvan/ui/shop/warehouse/add_import_receipt_supplier.dart';
import 'package:luanvan/ui/shop/warehouse/edit_stock_detail_screen.dart';
import 'package:luanvan/ui/widgets/alert_diablog.dart';

class AddImportReceiptScreen extends StatefulWidget {
  static String routeName = 'add_import_receipt';

  @override
  State<AddImportReceiptScreen> createState() => _AddImportReceiptScreenState();
}

class _AddImportReceiptScreenState extends State<AddImportReceiptScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _supplierController = TextEditingController();
  final TextEditingController _expectedImportDateController =
      TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  ImportReceipt importReceipts = ImportReceipt(
    id: '',
    supplier: Supplier(
        id: '', name: 'Chọn nhà cung cấp', address: '', phone: '', email: ''),
    status: ImportReceiptStatus.pending,
    code: '',
    createdAt: DateTime.now(),
    expectedImportDate: DateTime.now(),
    items: [],
  );
  @override
  void dispose() {
    _supplierController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _showAddSuccessDialog() async {
    await showAlertDialog(
      context,
      message: "Thêm phiếu nhập thành công",
      iconPath: IconHelper.check,
      duration: Duration(seconds: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the arguments passed from the warehouse screen
    importReceipts =
        ModalRoute.of(context)!.settings.arguments as ImportReceipt;
    _supplierController.text = importReceipts.supplier.name;
    _expectedImportDateController.text =
        '${importReceipts.expectedImportDate.day}/${importReceipts.expectedImportDate.month}/${importReceipts.expectedImportDate.year}';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Điều chỉnh tồn kho'),
      ),
      body: Container(
        color: Colors.white,
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
          minWidth: MediaQuery.of(context).size.width,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Divider(height: 1),
                GestureDetector(
                  onTap: () async {
                    final result = await Navigator.pushNamed(
                        context, AddImportReceiptSupplierScreen.routeName,
                        arguments: {
                          'selectedSupplier': importReceipts.supplier.id,
                        });
                    if (result != null) {
                      setState(() {
                        importReceipts.supplier = result as Supplier;
                        _supplierController.text = importReceipts.supplier.name;
                      });
                    }
                  },
                  child: Row(children: [
                    const SizedBox(width: 10),
                    Row(
                      children: [
                        const Text(
                          'Nhà cung cấp',
                          style: TextStyle(fontSize: 16),
                        ),
                        const Text(
                          ' *',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                    Expanded(
                      child: TextFormField(
                        textAlign: TextAlign.end,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                        ),
                        controller: _supplierController,
                        readOnly: true,
                        style: TextStyle(
                          color: _supplierController.text == 'Chọn nhà cung cấp'
                              ? Colors.grey
                              : Colors.black,
                          fontSize: 16,
                        ),
                        validator: (value) {
                          if (value == 'Chọn nhà cung cấp') {
                            return 'Vui lòng chọn nhà cung cấp';
                          }
                          return null;
                        },
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ]),
                ),
                const Divider(height: 1),

                GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: importReceipts.expectedImportDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        importReceipts.expectedImportDate = date;
                        _expectedImportDateController.text =
                            '${date.day}/${date.month}/${date.year}';
                      });
                    }
                  },
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      Row(
                        children: [
                          const Text(
                            'Ngày nhập dự kiến',
                            style: TextStyle(fontSize: 16),
                          ),
                          const Text(
                            ' *',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _expectedImportDateController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                          ),
                          textAlign: TextAlign.end,
                          readOnly: true,
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: importReceipts.expectedImportDate,
                              firstDate: DateTime.now(),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              setState(() {
                                importReceipts.expectedImportDate = date;
                                _expectedImportDateController.text =
                                    '${date.day}/${date.month}/${date.year}';
                              });
                            }
                          },
                          style: TextStyle(
                            color: _expectedImportDateController.text.isEmpty
                                ? Colors.grey
                                : Colors.black,
                            fontSize: 16,
                          ),
                          validator: (value) {
                            if (value == '') {
                              return 'Vui lòng chọn ngày nhập dự kiến';
                            }
                            return null;
                          },
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
                Container(
                  height: 0.5,
                  color: Colors.grey,
                ),
                // Ghi chú
                Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            'Ghi chú',
                            style: TextStyle(fontSize: 16),
                          ),
                          const Spacer(),
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _noteController,
                            builder: (context, value, child) {
                              return Text(
                                "${value.text.length}/50",
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.grey),
                              );
                            },
                          ),
                        ],
                      ),
                      TextField(
                        controller: _noteController,
                        maxLength: 50,
                        decoration: const InputDecoration(
                          hintText: 'Thêm ghi chú',
                          border: InputBorder.none,
                          counterText: '',
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 0.5,
                  color: Colors.grey,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                            context, EditStockDetailScreen.routeName,
                            arguments: importReceipts);
                      },
                      child: Text(
                        'Sửa',
                        style: TextStyle(
                            color: Colors.brown,
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    )
                  ],
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: importReceipts.items.length,
                  itemBuilder: (context, index) {
                    final option = importReceipts.items[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(color: Colors.grey),
                        ),
                      ),
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              final result = Navigator.pushNamed(
                                  context, EditStockDetailScreen.routeName,
                                  arguments: importReceipts);
                              if (result != null) {
                                setState(() {
                                  importReceipts = result as ImportReceipt;
                                });
                              }
                            },
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    option.imageUrl,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        option.productName,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Phân loại: ${option.optionName}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      importReceipts.items.removeAt(index);
                                    });
                                  },
                                  child: Icon(
                                    FontAwesomeIcons.trash,
                                    size: 16,
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            color: Colors.grey.shade200,
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Số lượng hiện tại:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${option.quantity}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Số lượng điều chỉnh dự kiến:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${option.adjustmentQuantities}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Số lượng hàng có sẵn (sau điều chỉnh):',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${option.quantity + option.adjustmentQuantities!}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    if (_formKey.currentState!.validate()) {
                      context.read<ImportReceiptBloc>().add(
                            CreateImportReceipt(importReceipts.copyWith(
                              status: ImportReceiptStatus.completed,
                            )),
                          );
                      await context.read<ImportReceiptBloc>().stream.firstWhere(
                        (state) {
                          if (state is ImportReceiptCreated) {
                            final shopState = context.read<ShopBloc>().state;
                            if (shopState is ShopLoaded) {
                              _showAddSuccessDialog();
                              context.read<ListProductBloc>().add(
                                  FetchListProductEventByShopId(
                                      shopState.shop.shopId!));

                              Future.delayed(Duration(seconds: 1), () {
                                Navigator.of(context).pop();
                              });
                            }
                          }
                          return false;
                        },
                      );
                    }
                  },
                  child: Container(
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.brown),
                    ),
                    child: const Text('Hoàn thành nhanh'),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    if (_formKey.currentState!.validate()) {
                      context.read<ImportReceiptBloc>().add(
                            CreateImportReceipt(importReceipts),
                          );
                      await context.read<ImportReceiptBloc>().stream.firstWhere(
                        (state) {
                          if (state is ImportReceiptCreated) {
                            final shopState = context.read<ShopBloc>().state;
                            if (shopState is ShopLoaded) {
                              _showAddSuccessDialog();
                              context.read<ListProductBloc>().add(
                                  FetchListProductEventByShopId(
                                      shopState.shop.shopId!));

                              Future.delayed(Duration(seconds: 1), () {
                                Navigator.of(context).pop();
                              });
                            }
                          }
                          return false;
                        },
                      );
                    }
                  },
                  child: Container(
                    height: 40,
                    color: Colors.brown,
                    alignment: Alignment.center,
                    child: const Text(
                      'Xác nhận',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
