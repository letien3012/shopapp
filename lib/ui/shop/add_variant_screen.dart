import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/models/product_option.dart';
import 'package:luanvan/models/product_variant.dart';
import 'package:luanvan/ui/helper/icon_helper.dart';

class AddVariantScreen extends StatefulWidget {
  const AddVariantScreen({super.key});
  static const String routeName = "add_variant";

  @override
  State<AddVariantScreen> createState() => _AddVariantScreenState();
}

class _AddVariantScreenState extends State<AddVariantScreen> {
  List<ProductVariant> _variants = [];
  List<List<ProductOption>> _options = [];
  late List<List<TextEditingController>> _labelOptionControllers;
  late List<List<TextEditingController>> _priceOptionControllers;
  late List<List<TextEditingController>> _stockOptionControllers;
  late List<List<FocusNode>> _labelFocusNodes;
  late List<List<FocusNode>> _priceFocusNodes;
  late List<List<FocusNode>> _stockFocusNodes;
  bool enableImageForVariant = false;

  final List<TextEditingController> _valueControllers = [
    TextEditingController(),
    TextEditingController()
  ];
  List<TextEditingController> _labelControllers = [];
  List<XFile> _imageFiles =
      []; // Danh sách hình ảnh tổng quát cho variant đầu tiên

  // Biến lưu trữ lỗi
  List<String?> _labelErrors = [];
  late List<List<String?>> _labelOptionErrors;
  late List<List<String?>> _priceOptionErrors;
  late List<List<String?>> _stockOptionErrors;
  late Product product;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      product = ModalRoute.of(context)!.settings.arguments as Product;
      setState(() {
        _variants.addAll(product.variants);
        _labelControllers = product.variants
            .map((val) => TextEditingController(text: val.label))
            .toList();
        _options = product.variants
            .map((variant) => List<ProductOption>.from(variant.options))
            .toList();
        _labelErrors =
            List<String?>.filled(_variants.length, null, growable: true);
        enableImageForVariant = product.hasVariantImages;

        // Đồng bộ _imageFiles với options của variant đầu tiên
        if (enableImageForVariant && _options.isNotEmpty) {
          _imageFiles = _options[0].map((option) {
            return option.imageUrl != null && option.imageUrl!.isNotEmpty
                ? XFile(option.imageUrl!)
                : XFile(''); // Placeholder nếu không có hình ảnh
          }).toList();
        } else {
          _imageFiles = [];
        }

        _initializeVariantsAndControllers();
      });
    });
  }

  void _initializeVariantsAndControllers() {
    _labelOptionControllers = _options
        .map((optionList) => optionList
            .map((option) => TextEditingController(text: option.name))
            .toList())
        .toList();
    _priceOptionControllers = _options
        .map((optionList) => optionList
            .map((option) =>
                TextEditingController(text: option.price.toString()))
            .toList())
        .toList();
    _stockOptionControllers = _options
        .map((optionList) => optionList
            .map((option) =>
                TextEditingController(text: option.stock.toString()))
            .toList())
        .toList();

    _labelFocusNodes = _options
        .map((optionList) => optionList.map((_) => FocusNode()).toList())
        .toList();
    _priceFocusNodes = _options
        .map((optionList) => optionList.map((_) => FocusNode()).toList())
        .toList();
    _stockFocusNodes = _options
        .map((optionList) => optionList.map((_) => FocusNode()).toList())
        .toList();

    _labelOptionErrors = _options
        .map((optionList) =>
            List<String?>.filled(optionList.length, null, growable: true))
        .toList();
    _priceOptionErrors = _options
        .map((optionList) =>
            List<String?>.filled(optionList.length, null, growable: true))
        .toList();
    _stockOptionErrors = _options
        .map((optionList) =>
            List<String?>.filled(optionList.length, null, growable: true))
        .toList();

    for (int i = 0; i < _labelFocusNodes.length; i++) {
      for (var focusNode in _labelFocusNodes[i]) {
        focusNode.addListener(_handleFocusChange);
      }
      for (var focusNode in _priceFocusNodes[i]) {
        focusNode.addListener(() => _handlePriceFocusChange(i));
      }
      for (var focusNode in _stockFocusNodes[i]) {
        focusNode.addListener(() => _handleStockFocusChange(i));
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _valueControllers) controller.dispose();
    for (var controller in _labelControllers) controller.dispose();
    for (var controllers in _labelOptionControllers) {
      for (var controller in controllers) controller.dispose();
    }
    for (var controllers in _priceOptionControllers) {
      for (var controller in controllers) controller.dispose();
    }
    for (var controllers in _stockOptionControllers) {
      for (var controller in controllers) controller.dispose();
    }
    for (var focusNodes in _labelFocusNodes) {
      for (var focusNode in focusNodes) focusNode.dispose();
    }
    for (var focusNodes in _priceFocusNodes) {
      for (var focusNode in focusNodes) focusNode.dispose();
    }
    for (var focusNodes in _stockFocusNodes) {
      for (var focusNode in focusNodes) focusNode.dispose();
    }
    super.dispose();
  }

  void _addValue(int variantIndex) {
    setState(() {
      if (_valueControllers[variantIndex].text.isNotEmpty) {
        _options[variantIndex].add(ProductOption(
            price: 0, stock: 0, name: _valueControllers[variantIndex].text));
        _labelOptionControllers[variantIndex].add(
            TextEditingController(text: _valueControllers[variantIndex].text));
        _priceOptionControllers[variantIndex]
            .add(TextEditingController(text: '0'));
        _stockOptionControllers[variantIndex]
            .add(TextEditingController(text: '0'));
        _labelFocusNodes[variantIndex]
            .add(FocusNode()..addListener(_handleFocusChange));
        _priceFocusNodes[variantIndex].add(FocusNode()
          ..addListener(() => _handlePriceFocusChange(variantIndex)));
        _stockFocusNodes[variantIndex].add(FocusNode()
          ..addListener(() => _handleStockFocusChange(variantIndex)));
        _labelOptionErrors[variantIndex].add(null);
        _priceOptionErrors[variantIndex].add(null);
        _stockOptionErrors[variantIndex].add(null);
        if (variantIndex == 0 && enableImageForVariant)
          _imageFiles.add(XFile(''));
        _valueControllers[variantIndex].clear();
      } else {
        _options[variantIndex].add(ProductOption(price: 0, stock: 0, name: ''));
        _labelOptionControllers[variantIndex]
            .add(TextEditingController(text: ''));
        _priceOptionControllers[variantIndex]
            .add(TextEditingController(text: '0'));
        _stockOptionControllers[variantIndex]
            .add(TextEditingController(text: '0'));
        final newFocusNode = FocusNode()..addListener(_handleFocusChange);
        _labelFocusNodes[variantIndex].add(newFocusNode);
        _priceFocusNodes[variantIndex].add(FocusNode()
          ..addListener(() => _handlePriceFocusChange(variantIndex)));
        _stockFocusNodes[variantIndex].add(FocusNode()
          ..addListener(() => _handleStockFocusChange(variantIndex)));
        _labelOptionErrors[variantIndex].add(null);
        _priceOptionErrors[variantIndex].add(null);
        _stockOptionErrors[variantIndex].add(null);
        if (variantIndex == 0 && enableImageForVariant)
          _imageFiles.add(XFile(''));
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FocusScope.of(context).requestFocus(newFocusNode);
        });
      }
      _variants[variantIndex] =
          _variants[variantIndex].copyWith(options: _options[variantIndex]);
    });
  }

  void _removeVariant(int variantIndex) {
    setState(() {
      _variants.removeAt(variantIndex);
      _options.removeAt(variantIndex);
      _labelOptionControllers.removeAt(variantIndex);
      _priceOptionControllers.removeAt(variantIndex);
      _stockOptionControllers.removeAt(variantIndex);
      _labelFocusNodes.removeAt(variantIndex);
      _priceFocusNodes.removeAt(variantIndex);
      _stockFocusNodes.removeAt(variantIndex);
      _labelOptionErrors.removeAt(variantIndex);
      _priceOptionErrors.removeAt(variantIndex);
      _stockOptionErrors.removeAt(variantIndex);
      _labelControllers.removeAt(variantIndex);
      _labelErrors.removeAt(variantIndex);

      if (_variants.isNotEmpty && variantIndex == 0) {
        _options[0] = List.from(_options[1]);
        _labelOptionControllers[0] = _options[0]
            .map((option) => TextEditingController(text: option.name))
            .toList();
        _priceOptionControllers[0] = _options[0]
            .map((option) =>
                TextEditingController(text: option.price.toString()))
            .toList();
        _stockOptionControllers[0] = _options[0]
            .map((option) =>
                TextEditingController(text: option.stock.toString()))
            .toList();
        _labelFocusNodes[0] = _options[0]
            .map((_) => FocusNode()..addListener(_handleFocusChange))
            .toList();
        _priceFocusNodes[0] = _options[0]
            .map((_) =>
                FocusNode()..addListener(() => _handlePriceFocusChange(0)))
            .toList();
        _stockFocusNodes[0] = _options[0]
            .map((_) =>
                FocusNode()..addListener(() => _handleStockFocusChange(0)))
            .toList();
        _labelOptionErrors[0] =
            List<String?>.generate(_options[0].length, (_) => null);
        _priceOptionErrors[0] =
            List<String?>.generate(_options[0].length, (_) => null);
        _stockOptionErrors[0] =
            List<String?>.generate(_options[0].length, (_) => null);
        _imageFiles = _options[0].map((option) {
          return option.imageUrl != null && option.imageUrl!.isNotEmpty
              ? XFile(option.imageUrl!)
              : XFile('');
        }).toList();
        _labelControllers[0].text = _labelControllers[1].text;
        _labelErrors[0] = _labelErrors[1];

        _options.removeAt(1);
        _labelOptionControllers.removeAt(1);
        _priceOptionControllers.removeAt(1);
        _stockOptionControllers.removeAt(1);
        _labelFocusNodes.removeAt(1);
        _priceFocusNodes.removeAt(1);
        _stockFocusNodes.removeAt(1);
        _labelOptionErrors.removeAt(1);
        _priceOptionErrors.removeAt(1);
        _stockOptionErrors.removeAt(1);
        _labelControllers.removeAt(1);
        _labelErrors.removeAt(1);
      }
    });
  }

  void _addNewVariant() {
    setState(() {
      _variants.add(ProductVariant(label: "Phân loại mới", options: []));
      _options.add([]);
      _labelOptionControllers.add([]);
      _priceOptionControllers.add([]);
      _stockOptionControllers.add([]);
      _labelFocusNodes.add([]);
      _priceFocusNodes.add([]);
      _stockFocusNodes.add([]);
      _labelOptionErrors.add([]);
      _priceOptionErrors.add([]);
      _stockOptionErrors.add([]);
      _labelControllers.add(TextEditingController(text: "Phân loại mới"));
      _labelErrors.add(null);
      _addValue(_variants.length - 1); // Thêm ít nhất 1 ProductOption
    });
  }

  void _handleFocusChange() {
    setState(() {
      for (int i = 0; i < _variants.length; i++) {
        for (int j = 0; j < _labelFocusNodes[i].length; j++) {
          if (!_labelFocusNodes[i][j].hasFocus &&
              _labelOptionControllers[i][j].text.isEmpty &&
              _options[i].length > 1) {
            _options[i].removeAt(j);
            _labelOptionControllers[i].removeAt(j);
            _priceOptionControllers[i].removeAt(j);
            _stockOptionControllers[i].removeAt(j);
            _labelFocusNodes[i].removeAt(j);
            _priceFocusNodes[i].removeAt(j);
            _stockFocusNodes[i].removeAt(j);
            _labelOptionErrors[i].removeAt(j);
            _priceOptionErrors[i].removeAt(j);
            _stockOptionErrors[i].removeAt(j);
            if (i == 0 && enableImageForVariant) _imageFiles.removeAt(j);
            _variants[i] = _variants[i].copyWith(options: _options[i]);
            break;
          }
        }
      }
    });
  }

  void _handlePriceFocusChange(int variantIndex) {
    setState(() {
      for (int i = 0; i < _priceFocusNodes[variantIndex].length; i++) {
        if (!_priceFocusNodes[variantIndex][i].hasFocus) {
          final validatedPrice = _validatePrice(
              _priceOptionControllers[variantIndex][i].text,
              _priceOptionControllers[variantIndex][i]);
          _options[variantIndex][i] =
              _options[variantIndex][i].copyWith(price: validatedPrice);
          _variants[variantIndex] =
              _variants[variantIndex].copyWith(options: _options[variantIndex]);
        }
      }
    });
  }

  void _handleStockFocusChange(int variantIndex) {
    setState(() {
      for (int i = 0; i < _stockFocusNodes[variantIndex].length; i++) {
        if (!_stockFocusNodes[variantIndex][i].hasFocus) {
          final validatedStock = _validateStock(
              _stockOptionControllers[variantIndex][i].text,
              _stockOptionControllers[variantIndex][i]);
          // Đồng bộ giá trị stock vào _options
          _options[variantIndex][i] =
              _options[variantIndex][i].copyWith(stock: validatedStock);
          // Cập nhật _variants với _options mới
          _variants[variantIndex] =
              _variants[variantIndex].copyWith(options: _options[variantIndex]);
        }
      }
    });
  }

  void _handleTapOutside() {
    FocusScope.of(context).unfocus();
    setState(() {
      for (int i = 0; i < _variants.length; i++) {
        if (_options[i].isNotEmpty &&
            _labelOptionControllers[i].last.text.isEmpty &&
            _options[i].length > 1) {
          _options[i].removeLast();
          _labelOptionControllers[i].removeLast();
          _priceOptionControllers[i].removeLast();
          _stockOptionControllers[i].removeLast();
          _labelFocusNodes[i].removeLast();
          _priceFocusNodes[i].removeLast();
          _stockFocusNodes[i].removeLast();
          _labelOptionErrors[i].removeLast();
          _priceOptionErrors[i].removeLast();
          _stockOptionErrors[i].removeLast();
          if (i == 0 && enableImageForVariant) _imageFiles.removeLast();
          _variants[i] = _variants[i].copyWith(options: _options[i]);
        }
        for (int j = 0; j < _options[i].length; j++) {
          final validatedPrice = _validatePrice(
              _priceOptionControllers[i][j].text,
              _priceOptionControllers[i][j]);
          final validatedStock = _validateStock(
              _stockOptionControllers[i][j].text,
              _stockOptionControllers[i][j]);
          _options[i][j] = _options[i][j]
              .copyWith(price: validatedPrice, stock: validatedStock);
          _variants[i] = _variants[i].copyWith(options: _options[i]);
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
      _labelErrors = List.filled(_variants.length, null, growable: true);
      _labelOptionErrors = _options
          .map((opts) => List<String?>.generate(opts.length, (_) => null))
          .toList();
      _priceOptionErrors = _options
          .map((opts) => List<String?>.generate(opts.length, (_) => null))
          .toList();
      _stockOptionErrors = _options
          .map((opts) => List<String?>.generate(opts.length, (_) => null))
          .toList();

      for (int i = 0; i < _variants.length; i++) {
        if (_options[i].isEmpty) {
          _labelErrors[i] = "Phân loại phải có ít nhất một tùy chọn";
          isValid = false;
          continue;
        }
        if (_labelControllers[i].text.isEmpty) {
          _labelErrors[i] = "Tên phân loại không được để trống";
          isValid = false;
        }
        for (int j = 0; j < _options[i].length; j++) {
          if (_labelOptionControllers[i][j].text.isEmpty) {
            _labelOptionErrors[i][j] = "Tên nhãn không được để trống";
            isValid = false;
          }
          try {
            final price = double.parse(_priceOptionControllers[i][j].text);
            if (price <= 0) {
              _priceOptionErrors[i][j] = "Giá phải lớn hơn 0";
              isValid = false;
            }
          } catch (e) {
            _priceOptionErrors[i][j] = "Giá không hợp lệ";
            isValid = false;
          }
          try {
            final stock = int.parse(_stockOptionControllers[i][j].text);
            if (stock <= 0) {
              _stockOptionErrors[i][j] = "Kho phải lớn hơn 0";
              isValid = false;
            }
          } catch (e) {
            _stockOptionErrors[i][j] = "Kho không hợp lệ";
            isValid = false;
          }
          if (i == 0 &&
              enableImageForVariant &&
              (j >= _imageFiles.length || _imageFiles[j].path.isEmpty)) {
            _labelOptionErrors[i][j] = "Hình ảnh cho nhãn này chưa được thêm";
            isValid = false;
          }
        }
      }
    });
    return isValid;
  }

  void showImagePickMethod(BuildContext context, int optionIndex) {
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
                      while (_imageFiles.length <= optionIndex) {
                        _imageFiles.add(XFile('')); // Đảm bảo đủ phần tử
                      }
                      _imageFiles[optionIndex] = pickedImage;
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
                      while (_imageFiles.length <= optionIndex) {
                        _imageFiles.add(XFile('')); // Đảm bảo đủ phần tử
                      }
                      _imageFiles[optionIndex] = pickedImage;
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

  void _saveData() async {
    if (!_validateDataBeforeSave()) return;

    try {
      // Đồng bộ tất cả dữ liệu từ controllers vào _options và _variants trước khi lưu
      for (int i = 0; i < _variants.length; i++) {
        for (int j = 0; j < _options[i].length; j++) {
          final name = _labelOptionControllers[i][j].text;
          final price = _validatePrice(_priceOptionControllers[i][j].text,
              _priceOptionControllers[i][j]);
          final stock = _validateStock(_stockOptionControllers[i][j].text,
              _stockOptionControllers[i][j]);

          // Cập nhật _options với dữ liệu từ controllers
          _options[i][j] = _options[i][j].copyWith(
            name: name,
            price: price,
            stock: stock,
            imageUrl: i == 0 &&
                    enableImageForVariant &&
                    j < _imageFiles.length &&
                    _imageFiles[j].path.isNotEmpty
                ? _imageFiles[j].path
                : null,
          );
        }

        _variants[i] = _variants[i].copyWith(
          label: _labelControllers[i].text,
          options: _options[i],
        );
      }

      product.variants.clear();
      product.variants.addAll(_variants);
      product = product.copyWith(hasVariantImages: enableImageForVariant);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã lưu phân loại thành công")),
      );
      Navigator.of(context).pop(product);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi lưu dữ liệu: $e")),
      );
    }
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
                      ..._variants.asMap().entries.map((entry) {
                        int index = entry.key;
                        return Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () => _removeVariant(index),
                                    child: SvgPicture.asset(
                                      IconHelper.minus,
                                      height: 25,
                                      width: 25,
                                      color: Colors.red[500],
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: TextField(
                                      controller: _labelControllers[index],
                                      maxLength: 30,
                                      decoration: InputDecoration(
                                        hintText: "Nhập tên phân loại",
                                        counterText: '',
                                        border: InputBorder.none,
                                        errorText: _labelErrors[index],
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          _variants[index] = _variants[index]
                                              .copyWith(label: value);
                                          _labelErrors[index] = null;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                      child: Text("Tên nhãn",
                                          textAlign: TextAlign.center)),
                                  Expanded(
                                      child: Text("Giá",
                                          textAlign: TextAlign.center)),
                                  Expanded(
                                      child: Text("Kho",
                                          textAlign: TextAlign.center)),
                                ],
                              ),
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: [
                                  ...(_options.isNotEmpty &&
                                              index < _options.length
                                          ? _options[index].asMap().entries
                                          : <MapEntry<int, ProductOption>>[])
                                      .map((entry) {
                                    int optIndex = entry.key;
                                    ProductOption value = entry.value;
                                    return Stack(
                                      children: [
                                        Container(
                                          constraints: const BoxConstraints(
                                              minHeight: 70),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: Colors.grey, width: 0.6),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: TextField(
                                                  maxLength: 30,
                                                  textAlign: TextAlign.center,
                                                  textAlignVertical:
                                                      TextAlignVertical.center,
                                                  decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    counterText: '',
                                                    contentPadding:
                                                        EdgeInsets.only(
                                                            bottom: 15),
                                                    errorText:
                                                        _labelOptionErrors[
                                                            index][optIndex],
                                                  ),
                                                  controller:
                                                      _labelOptionControllers[
                                                          index][optIndex],
                                                  focusNode:
                                                      _labelFocusNodes[index]
                                                          [optIndex],
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _options[index]
                                                              [optIndex] =
                                                          _options[index]
                                                                  [optIndex]
                                                              .copyWith(
                                                                  name: value);
                                                      _variants[
                                                          index] = _variants[
                                                              index]
                                                          .copyWith(
                                                              options: _options[
                                                                  index]);
                                                      _labelOptionErrors[index]
                                                          [optIndex] = null;
                                                    });
                                                  },
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black),
                                                  maxLines: 1,
                                                ),
                                              ),
                                              Expanded(
                                                child: TextField(
                                                  keyboardType:
                                                      const TextInputType
                                                          .numberWithOptions(
                                                          decimal: true),
                                                  maxLength: 30,
                                                  textAlign: TextAlign.center,
                                                  textAlignVertical:
                                                      TextAlignVertical.center,
                                                  decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    counterText: '',
                                                    contentPadding:
                                                        EdgeInsets.only(
                                                            bottom: 15),
                                                    errorText:
                                                        _priceOptionErrors[
                                                            index][optIndex],
                                                  ),
                                                  controller:
                                                      _priceOptionControllers[
                                                          index][optIndex],
                                                  focusNode:
                                                      _priceFocusNodes[index]
                                                          [optIndex],
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _priceOptionErrors[index]
                                                          [optIndex] = null;
                                                    });
                                                  },
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black),
                                                  maxLines: 1,
                                                ),
                                              ),
                                              Expanded(
                                                child: TextField(
                                                  keyboardType:
                                                      TextInputType.number,
                                                  maxLength: 30,
                                                  textAlign: TextAlign.center,
                                                  textAlignVertical:
                                                      TextAlignVertical.center,
                                                  decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    counterText: '',
                                                    contentPadding:
                                                        EdgeInsets.only(
                                                            bottom: 15),
                                                    errorText:
                                                        _stockOptionErrors[
                                                            index][optIndex],
                                                  ),
                                                  controller:
                                                      _stockOptionControllers[
                                                          index][optIndex],
                                                  focusNode:
                                                      _stockFocusNodes[index]
                                                          [optIndex],
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _stockOptionErrors[index]
                                                          [optIndex] = null;
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
                                        ),
                                        if (_options[index].length > 1)
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _options[index]
                                                      .removeAt(optIndex);
                                                  _labelOptionControllers[index]
                                                      .removeAt(optIndex);
                                                  _priceOptionControllers[index]
                                                      .removeAt(optIndex);
                                                  _stockOptionControllers[index]
                                                      .removeAt(optIndex);
                                                  _labelFocusNodes[index]
                                                      .removeAt(optIndex);
                                                  _priceFocusNodes[index]
                                                      .removeAt(optIndex);
                                                  _stockFocusNodes[index]
                                                      .removeAt(optIndex);
                                                  _labelOptionErrors[index]
                                                      .removeAt(optIndex);
                                                  _priceOptionErrors[index]
                                                      .removeAt(optIndex);
                                                  _stockOptionErrors[index]
                                                      .removeAt(optIndex);
                                                  if (index == 0 &&
                                                      enableImageForVariant)
                                                    _imageFiles
                                                        .removeAt(optIndex);
                                                  _variants[index] =
                                                      _variants[index].copyWith(
                                                          options:
                                                              _options[index]);
                                                });
                                              },
                                              child: Icon(Icons.cancel,
                                                  color: Colors.yellow[800],
                                                  size: 15),
                                            ),
                                          ),
                                      ],
                                    );
                                  }).toList(),
                                  GestureDetector(
                                    onTap: () => _addValue(index),
                                    child: Container(
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 0.5, color: Colors.red),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text("Thêm",
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                  ),
                                ],
                              ),
                              if (index == 0) ...[
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        "Thêm hình ảnh cho phân loại ${_labelControllers[index].text}\nKhi bật tính năng này, tất cả hình ảnh phải được tải lên",
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    CupertinoSwitch(
                                      value: enableImageForVariant,
                                      onChanged: (value) {
                                        setState(() {
                                          enableImageForVariant = value;
                                          product.hasVariantImages = value;
                                          if (!value) {
                                            _imageFiles.clear();
                                          } else if (_options.isNotEmpty) {
                                            _imageFiles =
                                                _options[0].map((option) {
                                              return option.imageUrl != null &&
                                                      option
                                                          .imageUrl!.isNotEmpty
                                                  ? XFile(option.imageUrl!)
                                                  : XFile('');
                                            }).toList();
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                if (enableImageForVariant) ...[
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _options[index]
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      int optIndex = entry.key;
                                      ProductOption value = entry.value;
                                      return GestureDetector(
                                        onTap: () => showImagePickMethod(
                                            context, optIndex),
                                        child: Container(
                                          height: 70,
                                          width: 70,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 0.5, color: Colors.red),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            image: optIndex <
                                                        _imageFiles.length &&
                                                    _imageFiles[optIndex]
                                                        .path
                                                        .isNotEmpty
                                                ? DecorationImage(
                                                    image: FileImage(File(
                                                        _imageFiles[optIndex]
                                                            .path)),
                                                    fit: BoxFit.cover,
                                                  )
                                                : null,
                                          ),
                                          child:
                                              optIndex >= _imageFiles.length ||
                                                      _imageFiles[optIndex]
                                                          .path
                                                          .isEmpty
                                                  ? Text(value.name,
                                                      style: const TextStyle(
                                                          color: Colors.red))
                                                  : null,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 10),
                      if (_variants.length < 2) ...[
                        Container(
                          width: double.infinity,
                          height: 50,
                          color: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: GestureDetector(
                            onTap: _addNewVariant,
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  IconHelper.plus,
                                  height: 30,
                                  width: 30,
                                  color: Colors.brown,
                                ),
                                const SizedBox(width: 10),
                                const Text("Thêm phân loại hàng"),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
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
                      onTap: () => Navigator.of(context).pop(),
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
                        "Thiết lập phân loại",
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
