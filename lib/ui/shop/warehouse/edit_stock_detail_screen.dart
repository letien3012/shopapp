import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:luanvan/models/import_item.dart';
import 'package:luanvan/models/import_receipt.dart';
import 'package:luanvan/models/supplier.dart';
import 'package:luanvan/ui/shop/warehouse/add%20_import_receipt.dart';

class EditStockDetailScreen extends StatefulWidget {
  const EditStockDetailScreen({super.key});
  static const String routeName = "edit_stock_detail";

  @override
  State<EditStockDetailScreen> createState() => _EditStockDetailScreenState();
}

class _EditStockDetailScreenState extends State<EditStockDetailScreen> {
  List<ImportItem> selectedOptions = [];
  late List<TextEditingController> _priceOptionControllers;
  late List<TextEditingController> _stockOptionControllers;
  late List<FocusNode> _priceFocusNodes;
  late List<FocusNode> _stockFocusNodes;
  late List<String?> _priceOptionErrors;
  late List<String?> _stockOptionErrors;
  ImportReceipt importReceipt = ImportReceipt(
    id: '',
    code: '',
    supplier: Supplier(
        id: '', name: 'Chọn nhà cung cấp', address: '', phone: '', email: ''),
    status: ImportReceiptStatus.pending,
    createdAt: DateTime.now(),
    expectedImportDate: DateTime.now(),
    items: [],
  );
  double keyboardSize = 0;
  // Thêm controller cho BottomSheet
  final TextEditingController _batchPriceController = TextEditingController();
  final TextEditingController _batchStockController = TextEditingController();
  final FocusNode _batchPrice = FocusNode();
  final FocusNode _batchStock = FocusNode();
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      importReceipt =
          ModalRoute.of(context)!.settings.arguments as ImportReceipt;
      selectedOptions = importReceipt.items;
      setState(() {
        _initializeControllers();
      });
    });
    _batchPrice.addListener(
      () {
        if (_batchPrice.hasFocus) {
          setState(() {
            keyboardSize = 225;
            print(keyboardSize);
          });
        } else {
          setState(() {
            keyboardSize = 0;
            print(keyboardSize);
          });
        }
      },
    );
    _batchStock.addListener(
      () {
        if (_batchStock.hasFocus) {
          setState(() {
            keyboardSize = 225;
          });
        } else {
          setState(() {
            keyboardSize = 0;
          });
        }
      },
    );
  }

  void _initializeControllers() {
    _priceOptionControllers = List.generate(
      selectedOptions.length,
      (index) => TextEditingController(
        text: selectedOptions.length > index
            ? selectedOptions[index].price.toString()
            : '0',
      ),
    );
    _stockOptionControllers = List.generate(
      selectedOptions.length,
      (index) => TextEditingController(
        text: selectedOptions.length > index
            ? selectedOptions[index].adjustmentQuantities.toString()
            : '0',
      ),
    );
    _priceFocusNodes =
        List.generate(selectedOptions.length, (_) => FocusNode());
    _stockFocusNodes =
        List.generate(selectedOptions.length, (_) => FocusNode());
    _priceOptionErrors = List.generate(selectedOptions.length, (_) => null);
    _stockOptionErrors = List.generate(selectedOptions.length, (_) => null);
    _priceOptionErrors = List.generate(selectedOptions.length, (_) => null);
    _stockOptionErrors = List.generate(selectedOptions.length, (_) => null);
    for (int i = 0; i < selectedOptions.length; i++) {
      _priceFocusNodes[i].addListener(() => _handlePriceFocusChange(i));
      _stockFocusNodes[i].addListener(() => _handleStockFocusChange(i));
    }
  }

  @override
  void dispose() {
    for (var controller in _priceOptionControllers) {
      controller.dispose();
    }
    for (var controller in _stockOptionControllers) {
      controller.dispose();
    }
    for (var focusNode in _priceFocusNodes) {
      focusNode.dispose();
    }
    for (var focusNode in _stockFocusNodes) {
      focusNode.dispose();
    }
    _batchPriceController.dispose();
    _batchStockController.dispose();
    _batchPrice.dispose();
    _batchStock.dispose();
    super.dispose();
  }

  void _handlePriceFocusChange(int index) {
    if (!_priceFocusNodes[index].hasFocus) {
      final validatedPrice = _validatePrice(
          _priceOptionControllers[index].text, _priceOptionControllers[index]);
      setState(() {
        if (selectedOptions.length > index) {
          selectedOptions[index] =
              selectedOptions[index].copyWith(price: validatedPrice);
        }
      });
    } else {
      setState(() {
        keyboardSize = 225;
      });
    }
  }

  void _handleStockFocusChange(int index) {
    if (!_stockFocusNodes[index].hasFocus) {
      final validatedStock = _validateStock(
          _stockOptionControllers[index].text, _stockOptionControllers[index]);
      setState(() {
        if (selectedOptions.length > index) {
          selectedOptions[index] = selectedOptions[index]
              .copyWith(adjustmentQuantities: validatedStock);
        }
      });
    } else {
      setState(() {
        keyboardSize = 225;
      });
    }
  }

  void _handleTapOutside() {
    FocusScope.of(context).unfocus();
    setState(() {
      for (int i = 0; i < selectedOptions.length; i++) {
        final validatedPrice = _validatePrice(
            _priceOptionControllers[i].text, _priceOptionControllers[i]);
        final validatedStock = _validateStock(
            _stockOptionControllers[i].text, _stockOptionControllers[i]);
        if (selectedOptions.length > i) {
          selectedOptions[i] = selectedOptions[i].copyWith(
              price: validatedPrice, adjustmentQuantities: validatedStock);
        }
      }
      keyboardSize = 0;
    });
  }

  double _validatePrice(String value, TextEditingController controller) {
    if (value.isEmpty) {
      controller.text = '0';
      return 0;
    }
    String normalizedValue = value.replaceFirst(RegExp(r'^0+'), '');
    if (normalizedValue.isEmpty) normalizedValue = '0';
    try {
      final price = double.parse(normalizedValue);
      if (price < 0) {
        controller.text = '0';
        return 0;
      }
      controller.text = price.toString();
      return price;
    } catch (e) {
      controller.text = '0';
      return 0;
    }
  }

  int _validateStock(String value, TextEditingController controller) {
    if (value.isEmpty) {
      controller.text = '0';
      return 0;
    }
    String normalizedValue = value.replaceFirst(RegExp(r'^0+'), '');
    if (normalizedValue.isEmpty) normalizedValue = '0';
    try {
      final stock = int.parse(normalizedValue);
      if (stock < 0) {
        controller.text = '0';
        return 0;
      }
      controller.text = stock.toString();
      return stock;
    } catch (e) {
      controller.text = '0';
      return 0;
    }
  }

  bool _validateDataBeforeSave() {
    bool isValid = true;
    setState(() {
      _priceOptionErrors = List.generate(selectedOptions.length, (_) => null);
      _stockOptionErrors = List.generate(selectedOptions.length, (_) => null);

      for (int i = 0; i < selectedOptions.length; i++) {
        try {
          final price = double.parse(_priceOptionControllers[i].text.isEmpty
              ? '0'
              : _priceOptionControllers[i].text);
          if (price < 0) {
            _priceOptionErrors[i] = "Giá không được âm";
            isValid = false;
          }
          if (price == 0) {
            _priceOptionErrors[i] = "Giá không được bằng 0";
            isValid = false;
          }
        } catch (e) {
          _priceOptionErrors[i] = "Giá không hợp lệ";
          isValid = false;
        }
        try {
          final stock = int.parse(_stockOptionControllers[i].text.isEmpty
              ? '0'
              : _stockOptionControllers[i].text);
          if (stock < 0) {
            _stockOptionErrors[i] = "Số lượng không được âm";
            isValid = false;
          }
          if (stock == 0) {
            _stockOptionErrors[i] = "Số lượng không được bằng 0";
            isValid = false;
          }
        } catch (e) {
          _stockOptionErrors[i] = "Số lượng không hợp lệ";
          isValid = false;
        }
      }
    });
    return isValid;
  }

  Future<bool> _saveData() async {
    if (!_validateDataBeforeSave()) return false;

    try {
      for (int i = 0; i < selectedOptions.length; i++) {
        final price = _validatePrice(
            _priceOptionControllers[i].text, _priceOptionControllers[i]);
        final stock = _validateStock(
            _stockOptionControllers[i].text, _stockOptionControllers[i]);
        selectedOptions[i] = selectedOptions[i]
            .copyWith(price: price, adjustmentQuantities: stock);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã lưu thông tin thành công")),
      );
      Navigator.of(context).pushReplacementNamed(
        AddImportReceiptScreen.routeName,
        arguments: importReceipt,
      );

      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi lưu dữ liệu: $e")),
      );
      return false;
    }
  }

  // Hàm hiển thị BottomSheet để thay đổi hàng loạt
  void _showBatchUpdateBottomSheet() {
    _batchPriceController.clear();
    _batchStockController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: keyboardSize,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Thay đổi hàng loạt",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                focusNode: _batchPrice,
                controller: _batchPriceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: "Giá (VNĐ)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                focusNode: _batchStock,
                controller: _batchStockController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Kho hàng",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                      child: const Text("Hủy"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final batchPrice = _validatePrice(
                            _batchPriceController.text, _batchPriceController);
                        final batchStock = _validateStock(
                            _batchStockController.text, _batchStockController);

                        // Kiểm tra giá trị hợp lệ trước khi áp dụng
                        if (batchPrice <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Giá phải lớn hơn 0")),
                          );
                          return;
                        }

                        if (batchStock == 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Kho phải lớn hơn 0")),
                          );
                          return;
                        }

                        setState(() {
                          for (int i = 0; i < selectedOptions.length; i++) {
                            _priceOptionControllers[i].text =
                                batchPrice.toString();
                            _stockOptionControllers[i].text =
                                batchStock.toString();
                            if (selectedOptions.length > i) {
                              selectedOptions[i] = selectedOptions[i].copyWith(
                                  price: batchPrice,
                                  adjustmentQuantities: batchStock);
                            }
                          }
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                      ),
                      child: const Text(
                        "Áp dụng",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTapOutside,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(bottom: keyboardSize),
              child: Container(
                color: Colors.grey[200],
                padding: const EdgeInsets.only(top: 90, bottom: 80),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - 90 - 80,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 5,
                        color: Colors.grey[200],
                      ),
                      // Add products header
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                // Thêm nút "Thay đổi hàng loạt"
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Text(
                                                'Đặt đồng giá, số lượng hàng cho tất cả'),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      TextButton(
                                        onPressed: _showBatchUpdateBottomSheet,
                                        child: const Text(
                                          "Thay đổi hàng loạt",
                                          style: TextStyle(
                                            color: Colors.brown,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  itemCount: selectedOptions.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final option = selectedOptions[index];
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Colors.grey.shade200),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                height: 60,
                                                width: 60,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  color: Colors.grey[300],
                                                ),
                                                child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    child: Image.network(
                                                      option.imageUrl,
                                                      fit: BoxFit.cover,
                                                    )),
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
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      "Phân loại: ${option.optionName}",
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors
                                                            .grey.shade600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              const Expanded(
                                                  child: Text('Giá nhập')),
                                              const SizedBox(width: 10),
                                              const Expanded(
                                                  child: Text('Số lượng nhập')),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextField(
                                                  keyboardType:
                                                      const TextInputType
                                                          .numberWithOptions(
                                                          decimal: true),
                                                  maxLength: 10,
                                                  textAlign: TextAlign.start,
                                                  textAlignVertical:
                                                      TextAlignVertical.center,
                                                  decoration: InputDecoration(
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2),
                                                      borderSide: BorderSide(
                                                          width: 1,
                                                          color: Colors.grey),
                                                    ),
                                                    counterText: '',
                                                    contentPadding:
                                                        const EdgeInsets.only(
                                                            left: 10,
                                                            bottom: 15),
                                                    errorText:
                                                        _priceOptionErrors[
                                                            index],
                                                  ),
                                                  controller:
                                                      _priceOptionControllers[
                                                          index],
                                                  focusNode:
                                                      _priceFocusNodes[index],
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _priceOptionErrors[
                                                          index] = null;
                                                    });
                                                  },
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black),
                                                  maxLines: 1,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: TextField(
                                                  keyboardType:
                                                      TextInputType.number,
                                                  maxLength: 10,
                                                  textAlign: TextAlign.start,
                                                  textAlignVertical:
                                                      TextAlignVertical.center,
                                                  decoration: InputDecoration(
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2),
                                                      borderSide: BorderSide(
                                                          width: 1,
                                                          color: Colors.grey),
                                                    ),
                                                    counterText: '',
                                                    contentPadding:
                                                        const EdgeInsets.only(
                                                            bottom: 15,
                                                            left: 10),
                                                    errorText:
                                                        _stockOptionErrors[
                                                            index],
                                                  ),
                                                  controller:
                                                      _stockOptionControllers[
                                                          index],
                                                  focusNode:
                                                      _stockFocusNodes[index],
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _stockOptionErrors[
                                                          index] = null;
                                                    });
                                                  },
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black),
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
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
                decoration: const BoxDecoration(color: Colors.white),
                padding: const EdgeInsets.only(
                    top: 30, left: 10, right: 10, bottom: 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // GestureDetector(
                    //   onTap: () async {
                    //     if (await _saveData()) {
                    //       Navigator.of(context).pop();
                    //     }
                    //   },
                    //   child: Container(
                    //     height: 40,
                    //     width: 40,
                    //     alignment: Alignment.center,
                    //     margin: const EdgeInsets.only(bottom: 5),
                    //     child: const Icon(Icons.arrow_back,
                    //         color: Colors.black, size: 24),
                    //   ),
                    // ),
                    const SizedBox(width: 10),
                    const SizedBox(
                      height: 40,
                      child: Text(
                        "Thiết lập kho và giá bán",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveData,
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
      ),
    );
  }
}
