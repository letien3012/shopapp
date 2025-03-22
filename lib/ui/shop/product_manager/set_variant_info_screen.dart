import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luanvan/models/option_info.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/models/product_option.dart';
import 'package:luanvan/models/product_variant.dart';

class SetVariantInfoScreen extends StatefulWidget {
  const SetVariantInfoScreen({super.key});
  static const String routeName = "set_variant_info";

  @override
  State<SetVariantInfoScreen> createState() => _SetVariantInfoScreenState();
}

class _SetVariantInfoScreenState extends State<SetVariantInfoScreen> {
  late Product product;
  late List<TextEditingController> _priceOptionControllers;
  late List<TextEditingController> _stockOptionControllers;
  late List<FocusNode> _priceFocusNodes;
  late List<FocusNode> _stockFocusNodes;
  late List<String?> _priceOptionErrors;
  late List<String?> _stockOptionErrors;
  bool enableImageForVariant = false;
  int groupOptionCount = 0;

  // Thêm controller cho BottomSheet
  final TextEditingController _batchPriceController = TextEditingController();
  final TextEditingController _batchStockController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      product = ModalRoute.of(context)!.settings.arguments as Product;
      enableImageForVariant = product.hasVariantImages;
      if (product.variants.isNotEmpty) {
        groupOptionCount = product.variants.length == 2
            ? product.variants[0].options.length *
                product.variants[1].options.length
            : product.variants[0].options.length;
      } else {
        groupOptionCount = 0;
      }
      setState(() {
        _initializeControllers();
      });
    });
  }

  void _initializeControllers() {
    _priceOptionControllers = List.generate(
      groupOptionCount,
      (index) => TextEditingController(
        text: product.optionInfos.length > index
            ? product.optionInfos[index].price.toString()
            : '0',
      ),
    );
    _stockOptionControllers = List.generate(
      groupOptionCount,
      (index) => TextEditingController(
        text: product.optionInfos.length > index
            ? product.optionInfos[index].stock.toString()
            : '0',
      ),
    );
    _priceFocusNodes = List.generate(groupOptionCount, (_) => FocusNode());
    _stockFocusNodes = List.generate(groupOptionCount, (_) => FocusNode());
    _priceOptionErrors = List.generate(groupOptionCount, (_) => null);
    _stockOptionErrors = List.generate(groupOptionCount, (_) => null);

    for (int i = 0; i < groupOptionCount; i++) {
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
    super.dispose();
  }

  void _handlePriceFocusChange(int index) {
    if (!_priceFocusNodes[index].hasFocus) {
      final validatedPrice = _validatePrice(
          _priceOptionControllers[index].text, _priceOptionControllers[index]);
      setState(() {
        if (product.optionInfos.length > index) {
          product.optionInfos[index] =
              product.optionInfos[index].copyWith(price: validatedPrice);
        }
      });
    }
  }

  void _handleStockFocusChange(int index) {
    if (!_stockFocusNodes[index].hasFocus) {
      final validatedStock = _validateStock(
          _stockOptionControllers[index].text, _stockOptionControllers[index]);
      setState(() {
        if (product.optionInfos.length > index) {
          product.optionInfos[index] =
              product.optionInfos[index].copyWith(stock: validatedStock);
        }
      });
    }
  }

  void _handleTapOutside() {
    FocusScope.of(context).unfocus();
    setState(() {
      for (int i = 0; i < groupOptionCount; i++) {
        final validatedPrice = _validatePrice(
            _priceOptionControllers[i].text, _priceOptionControllers[i]);
        final validatedStock = _validateStock(
            _stockOptionControllers[i].text, _stockOptionControllers[i]);
        if (product.optionInfos.length > i) {
          product.optionInfos[i] = product.optionInfos[i]
              .copyWith(price: validatedPrice, stock: validatedStock);
        }
      }
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
      _priceOptionErrors = List.generate(groupOptionCount, (_) => null);
      _stockOptionErrors = List.generate(groupOptionCount, (_) => null);

      for (int i = 0; i < groupOptionCount; i++) {
        try {
          final price = double.parse(_priceOptionControllers[i].text);
          if (price <= 0) {
            _priceOptionErrors[i] = "Giá phải lớn hơn 0";
            isValid = false;
          }
        } catch (e) {
          _priceOptionErrors[i] = "Giá không hợp lệ";
          isValid = false;
        }
        try {
          final stock = int.parse(_stockOptionControllers[i].text);
          if (stock <= 0) {
            _stockOptionErrors[i] = "Kho phải lớn hơn 0";
            isValid = false;
          }
        } catch (e) {
          _stockOptionErrors[i] = "Kho không hợp lệ";
          isValid = false;
        }
      }
    });
    return isValid;
  }

  Future<bool> _saveData() async {
    if (!_validateDataBeforeSave()) return false;

    try {
      while (product.optionInfos.length < groupOptionCount) {
        product.optionInfos.add(OptionInfo(
            price: 0,
            stock: 0,
            weight: product.optionInfos.isNotEmpty
                ? product.optionInfos[0].weight
                : null));
      }

      for (int i = 0; i < groupOptionCount; i++) {
        final price = _validatePrice(
            _priceOptionControllers[i].text, _priceOptionControllers[i]);
        final stock = _validateStock(
            _stockOptionControllers[i].text, _stockOptionControllers[i]);
        product.optionInfos[i] =
            product.optionInfos[i].copyWith(price: price, stock: stock);
      }

      product = product.copyWith(hasVariantImages: enableImageForVariant);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã lưu thông tin thành công")),
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
            bottom: MediaQuery.of(context).viewInsets.bottom,
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
                controller: _batchStockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
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
                        Navigator.pop(context); // Đóng BottomSheet
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
                        // Áp dụng giá và kho hàng loạt
                        final batchPrice = _validatePrice(
                            _batchPriceController.text, _batchPriceController);
                        final batchStock = _validateStock(
                            _batchStockController.text, _batchStockController);

                        setState(() {
                          for (int i = 0; i < groupOptionCount; i++) {
                            _priceOptionControllers[i].text =
                                batchPrice.toString();
                            _stockOptionControllers[i].text =
                                batchStock.toString();
                            if (product.optionInfos.length > i) {
                              product.optionInfos[i] = product.optionInfos[i]
                                  .copyWith(
                                      price: batchPrice, stock: batchStock);
                            }
                          }
                        });
                        Navigator.pop(context); // Đóng BottomSheet
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
                      if (groupOptionCount == 0)
                        const Center(
                          child: Text(
                            "Không có phân loại nào để thiết lập",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      else
                        Column(
                          children: [
                            // Thêm nút "Thay đổi hàng loạt"
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text(
                                            'Đặt đồng giá, số lượng hàng cho tất cả phân loại'),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
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
                              itemCount: groupOptionCount,
                              itemBuilder: (BuildContext context, int index) {
                                String optionName = '';
                                int firstVariantIndex;
                                if (product.variants.length == 1) {
                                  optionName =
                                      product.variants[0].options[index].name;
                                  firstVariantIndex = index;
                                } else if (product.variants.length == 2) {
                                  int secondVariantOptionsLength =
                                      product.variants[1].options.length;
                                  int i = index % secondVariantOptionsLength;
                                  int j = index ~/ secondVariantOptionsLength;
                                  optionName =
                                      "${product.variants[0].options[j].name}  ${product.variants[1].options[i].name}";
                                  firstVariantIndex = j;
                                } else {
                                  return const SizedBox.shrink();
                                }

                                return Container(
                                  padding: const EdgeInsets.all(10),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  color: Colors.white,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          if (enableImageForVariant &&
                                              product.variants.isNotEmpty) ...[
                                            Container(
                                                height: 50,
                                                width: 40,
                                                color: Colors.grey[300],
                                                child: product
                                                        .variants[0]
                                                        .options[
                                                            firstVariantIndex]
                                                        .imageUrl!
                                                        .startsWith('http')
                                                    ? Image.network(
                                                        product
                                                            .variants[0]
                                                            .options[
                                                                firstVariantIndex]
                                                            .imageUrl!,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Image.file(
                                                        File(product
                                                            .variants[0]
                                                            .options[
                                                                firstVariantIndex]
                                                            .imageUrl!),
                                                        fit: BoxFit.cover,
                                                      )),
                                            const SizedBox(width: 10),
                                          ],
                                          Text(
                                            optionName,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const Expanded(child: Text('Giá')),
                                          const SizedBox(width: 10),
                                          const Expanded(
                                              child: Text('Kho hàng')),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              keyboardType: const TextInputType
                                                  .numberWithOptions(
                                                  decimal: true),
                                              maxLength: 10,
                                              textAlign: TextAlign.start,
                                              textAlignVertical:
                                                  TextAlignVertical.center,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                  borderSide: BorderSide(
                                                      width: 1,
                                                      color: Colors.grey),
                                                ),
                                                counterText: '',
                                                contentPadding:
                                                    const EdgeInsets.only(
                                                        left: 10, bottom: 15),
                                                errorText:
                                                    _priceOptionErrors[index],
                                              ),
                                              controller:
                                                  _priceOptionControllers[
                                                      index],
                                              focusNode:
                                                  _priceFocusNodes[index],
                                              onChanged: (value) {
                                                setState(() {
                                                  _priceOptionErrors[index] =
                                                      null;
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
                                                      BorderRadius.circular(2),
                                                  borderSide: BorderSide(
                                                      width: 1,
                                                      color: Colors.grey),
                                                ),
                                                counterText: '',
                                                contentPadding:
                                                    const EdgeInsets.only(
                                                        bottom: 15, left: 10),
                                                errorText:
                                                    _stockOptionErrors[index],
                                              ),
                                              controller:
                                                  _stockOptionControllers[
                                                      index],
                                              focusNode:
                                                  _stockFocusNodes[index],
                                              onChanged: (value) {
                                                setState(() {
                                                  _stockOptionErrors[index] =
                                                      null;
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
                    GestureDetector(
                      onTap: () async {
                        if (await _saveData()) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(bottom: 5),
                        child: const Icon(Icons.arrow_back,
                            color: Colors.black, size: 24),
                      ),
                    ),
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
                        onPressed: () async {
                          if (await _saveData()) {
                            Navigator.of(context).pop(product);
                          }
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
        ),
      ),
    );
  }
}
