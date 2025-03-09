import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
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
  List<ProductOption> _optionsVariant1 = [];
  List<ProductOption> _optionsVariant2 = [];
  late List<TextEditingController> _labelOptionControllers1;
  late List<TextEditingController> _priceOptionControllers1;
  late List<TextEditingController> _stockOptionControllers1;
  late List<TextEditingController> _labelOptionControllers2;
  late List<TextEditingController> _priceOptionControllers2;
  late List<TextEditingController> _stockOptionControllers2;
  late List<FocusNode> _labelFocusNodes1;
  late List<FocusNode> _priceFocusNodes1;
  late List<FocusNode> _stockFocusNodes1;
  late List<FocusNode> _labelFocusNodes2;
  late List<FocusNode> _priceFocusNodes2;
  late List<FocusNode> _stockFocusNodes2;
  List<String> variantValues1 = ["Trắng", "Đen"];
  List<String> variantValues2 = ["S", "M", "L"];
  String variantLabel1 = "Màu sắc";
  String variantLabel2 = "Kích cỡ";
  bool enableImageForVariant = false;

  final TextEditingController _valueController1 = TextEditingController();
  final TextEditingController _valueController2 = TextEditingController();
  final TextEditingController _labelController1 =
      TextEditingController(text: "Màu sắc");
  final TextEditingController _labelController2 =
      TextEditingController(text: "Kích cỡ");

  // Biến lưu trữ lỗi cho từng TextField
  String? _labelError1;
  String? _labelError2;
  List<String?> _labelOptionErrors1 = [];
  List<String?> _priceOptionErrors1 = [];
  List<String?> _stockOptionErrors1 = [];
  List<String?> _labelOptionErrors2 = [];
  List<String?> _priceOptionErrors2 = [];
  List<String?> _stockOptionErrors2 = [];

  @override
  void initState() {
    super.initState();
    _initializeVariantsAndControllers();
  }

  void _initializeVariantsAndControllers() {
    for (int i = 0; i < variantValues1.length; i++) {
      _optionsVariant1
          .add(ProductOption(price: 0, stock: 0, name: variantValues1[i]));
    }
    for (int i = 0; i < variantValues2.length; i++) {
      _optionsVariant2
          .add(ProductOption(price: 0, stock: 0, name: variantValues2[i]));
    }
    _variants.add(ProductVariant(
        label: _labelController1.text, options: _optionsVariant1));
    _variants.add(ProductVariant(
        label: _labelController2.text, options: _optionsVariant2));
    _labelOptionControllers1 = _optionsVariant1
        .map((option) => TextEditingController(text: option.name))
        .toList();
    _priceOptionControllers1 = _optionsVariant1
        .map((option) => TextEditingController(text: option.price.toString()))
        .toList();
    _stockOptionControllers1 = _optionsVariant1
        .map((option) => TextEditingController(text: option.stock.toString()))
        .toList();
    _labelOptionControllers2 = _optionsVariant2
        .map((option) => TextEditingController(text: option.name))
        .toList();
    _priceOptionControllers2 = _optionsVariant2
        .map((option) => TextEditingController(text: option.price.toString()))
        .toList();
    _stockOptionControllers2 = _optionsVariant2
        .map((option) => TextEditingController(text: option.stock.toString()))
        .toList();

    _labelFocusNodes1 = _optionsVariant1.map((_) => FocusNode()).toList();
    _priceFocusNodes1 = _optionsVariant1.map((_) => FocusNode()).toList();
    _stockFocusNodes1 = _optionsVariant1.map((_) => FocusNode()).toList();
    _labelFocusNodes2 = _optionsVariant2.map((_) => FocusNode()).toList();
    _priceFocusNodes2 = _optionsVariant2.map((_) => FocusNode()).toList();
    _stockFocusNodes2 = _optionsVariant2.map((_) => FocusNode()).toList();

    // Khởi tạo danh sách lỗi động
    _labelOptionErrors1 =
        List<String?>.generate(_optionsVariant1.length, (_) => null);
    _priceOptionErrors1 =
        List<String?>.generate(_optionsVariant1.length, (_) => null);
    _stockOptionErrors1 =
        List<String?>.generate(_optionsVariant1.length, (_) => null);
    _labelOptionErrors2 =
        List<String?>.generate(_optionsVariant2.length, (_) => null);
    _priceOptionErrors2 =
        List<String?>.generate(_optionsVariant2.length, (_) => null);
    _stockOptionErrors2 =
        List<String?>.generate(_optionsVariant2.length, (_) => null);

    for (var focusNode in _labelFocusNodes1) {
      focusNode.addListener(_handleFocusChange);
    }
    for (var focusNode in _labelFocusNodes2) {
      focusNode.addListener(_handleFocusChange);
    }
    for (var focusNode in _priceFocusNodes1) {
      focusNode.addListener(_handlePriceFocusChange1);
    }
    for (var focusNode in _priceFocusNodes2) {
      focusNode.addListener(_handlePriceFocusChange2);
    }
    for (var focusNode in _stockFocusNodes1) {
      focusNode.addListener(_handleStockFocusChange1);
    }
    for (var focusNode in _stockFocusNodes2) {
      focusNode.addListener(_handleStockFocusChange2);
    }
  }

  @override
  void dispose() {
    _valueController1.dispose();
    _valueController2.dispose();
    _labelController1.dispose();
    _labelController2.dispose();
    for (var controller in _labelOptionControllers1) controller.dispose();
    for (var controller in _priceOptionControllers1) controller.dispose();
    for (var controller in _stockOptionControllers1) controller.dispose();
    for (var controller in _labelOptionControllers2) controller.dispose();
    for (var controller in _priceOptionControllers2) controller.dispose();
    for (var controller in _stockOptionControllers2) controller.dispose();
    for (var focusNode in _labelFocusNodes1) focusNode.dispose();
    for (var focusNode in _priceFocusNodes1) focusNode.dispose();
    for (var focusNode in _stockFocusNodes1) focusNode.dispose();
    for (var focusNode in _labelFocusNodes2) focusNode.dispose();
    for (var focusNode in _priceFocusNodes2) focusNode.dispose();
    for (var focusNode in _stockFocusNodes2) focusNode.dispose();
    super.dispose();
  }

  void _addValue1() {
    setState(() {
      if (_valueController1.text.isNotEmpty) {
        variantValues1.add(_valueController1.text);
        _optionsVariant1.add(
            ProductOption(price: 0, stock: 0, name: _valueController1.text));
        _labelOptionControllers1
            .add(TextEditingController(text: _valueController1.text));
        _priceOptionControllers1.add(TextEditingController(text: '0'));
        _stockOptionControllers1.add(TextEditingController(text: '0'));
        _labelFocusNodes1.add(FocusNode()..addListener(_handleFocusChange));
        _priceFocusNodes1
            .add(FocusNode()..addListener(_handlePriceFocusChange1));
        _stockFocusNodes1
            .add(FocusNode()..addListener(_handleStockFocusChange1));
        _labelOptionErrors1.add(null);
        _priceOptionErrors1.add(null);
        _stockOptionErrors1.add(null);
        _valueController1.clear();
      } else {
        _optionsVariant1.add(ProductOption(price: 0, stock: 0, name: ''));
        _labelOptionControllers1.add(TextEditingController(text: ''));
        _priceOptionControllers1.add(TextEditingController(text: '0'));
        _stockOptionControllers1.add(TextEditingController(text: '0'));
        final newFocusNode = FocusNode()..addListener(_handleFocusChange);
        _labelFocusNodes1.add(newFocusNode);
        _priceFocusNodes1
            .add(FocusNode()..addListener(_handlePriceFocusChange1));
        _stockFocusNodes1
            .add(FocusNode()..addListener(_handleStockFocusChange1));
        _labelOptionErrors1.add(null);
        _priceOptionErrors1.add(null);
        _stockOptionErrors1.add(null);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FocusScope.of(context).requestFocus(newFocusNode);
        });
      }
      _variants[0] = _variants[0].copyWith(options: _optionsVariant1);
    });
  }

  void _addValue2() {
    setState(() {
      if (_valueController2.text.isNotEmpty) {
        variantValues2.add(_valueController2.text);
        _optionsVariant2.add(
            ProductOption(price: 0, stock: 0, name: _valueController2.text));
        _labelOptionControllers2
            .add(TextEditingController(text: _valueController2.text));
        _priceOptionControllers2.add(TextEditingController(text: '0'));
        _stockOptionControllers2.add(TextEditingController(text: '0'));
        _labelFocusNodes2.add(FocusNode()..addListener(_handleFocusChange));
        _priceFocusNodes2
            .add(FocusNode()..addListener(_handlePriceFocusChange2));
        _stockFocusNodes2
            .add(FocusNode()..addListener(_handleStockFocusChange2));
        _labelOptionErrors2.add(null);
        _priceOptionErrors2.add(null);
        _stockOptionErrors2.add(null);
        _valueController2.clear();
      } else {
        _optionsVariant2.add(ProductOption(price: 0, stock: 0, name: ''));
        _labelOptionControllers2.add(TextEditingController(text: ''));
        _priceOptionControllers2.add(TextEditingController(text: '0'));
        _stockOptionControllers2.add(TextEditingController(text: '0'));
        final newFocusNode = FocusNode()..addListener(_handleFocusChange);
        _labelFocusNodes2.add(newFocusNode);
        _priceFocusNodes2
            .add(FocusNode()..addListener(_handlePriceFocusChange2));
        _stockFocusNodes2
            .add(FocusNode()..addListener(_handleStockFocusChange2));
        _labelOptionErrors2.add(null);
        _priceOptionErrors2.add(null);
        _stockOptionErrors2.add(null);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FocusScope.of(context).requestFocus(newFocusNode);
        });
      }
      if (_variants.length > 1)
        _variants[1] = _variants[1].copyWith(options: _optionsVariant2);
    });
  }

  void _removeVariant1() {
    setState(() {
      _variants.removeAt(0);
      variantLabel1 = "";
      variantValues1.clear();
      _optionsVariant1.clear();
      _labelOptionControllers1.clear();
      _priceOptionControllers1.clear();
      _stockOptionControllers1.clear();
      _labelFocusNodes1.clear();
      _priceFocusNodes1.clear();
      _stockFocusNodes1.clear();
      _labelOptionErrors1.clear();
      _priceOptionErrors1.clear();
      _stockOptionErrors1.clear();
      _labelController1.clear();
      _labelError1 = null;

      if (_variants.isNotEmpty) {
        variantLabel1 = variantLabel2;
        _optionsVariant1 = List.from(_optionsVariant2);
        _labelOptionControllers1 = _optionsVariant1
            .map((option) => TextEditingController(text: option.name))
            .toList();
        _priceOptionControllers1 = _optionsVariant1
            .map((option) =>
                TextEditingController(text: option.price.toString()))
            .toList();
        _stockOptionControllers1 = _optionsVariant1
            .map((option) =>
                TextEditingController(text: option.stock.toString()))
            .toList();
        _labelFocusNodes1 = _optionsVariant1
            .map((_) => FocusNode()..addListener(_handleFocusChange))
            .toList();
        _priceFocusNodes1 = _optionsVariant1
            .map((_) => FocusNode()..addListener(_handlePriceFocusChange1))
            .toList();
        _stockFocusNodes1 = _optionsVariant1
            .map((_) => FocusNode()..addListener(_handleStockFocusChange1))
            .toList();
        _labelOptionErrors1 =
            List<String?>.generate(_optionsVariant1.length, (_) => null);
        _priceOptionErrors1 =
            List<String?>.generate(_optionsVariant1.length, (_) => null);
        _stockOptionErrors1 =
            List<String?>.generate(_optionsVariant1.length, (_) => null);
        _labelController1.text = variantLabel2;
        _labelError1 = _labelError2;

        variantLabel2 = "";
        _optionsVariant2.clear();
        _labelOptionControllers2.clear();
        _priceOptionControllers2.clear();
        _stockOptionControllers2.clear();
        _labelFocusNodes2.clear();
        _priceFocusNodes2.clear();
        _stockFocusNodes2.clear();
        _labelOptionErrors2.clear();
        _priceOptionErrors2.clear();
        _stockOptionErrors2.clear();
        _labelController2.clear();
        _labelError2 = null;
      }
    });
  }

  void _removeVariant2() {
    setState(() {
      if (_variants.length > 1) {
        _variants.removeAt(1);
        variantLabel2 = "";
        variantValues2.clear();
        _optionsVariant2.clear();
        _labelOptionControllers2.clear();
        _priceOptionControllers2.clear();
        _stockOptionControllers2.clear();
        _labelFocusNodes2.clear();
        _priceFocusNodes2.clear();
        _stockFocusNodes2.clear();
        _labelOptionErrors2.clear();
        _priceOptionErrors2.clear();
        _stockOptionErrors2.clear();
        _labelController2.clear();
        _labelError2 = null;
      }
    });
  }

  void _addNewVariant() {
    setState(() {
      _variants.add(ProductVariant(label: "Phân loại mới", options: []));
      variantLabel2 = "Phân loại mới";
      variantValues2 = [];
      _optionsVariant2 = [];
      _labelOptionControllers2 = [];
      _priceOptionControllers2 = [];
      _stockOptionControllers2 = [];
      _labelFocusNodes2 = [];
      _priceFocusNodes2 = [];
      _stockFocusNodes2 = [];
      _labelOptionErrors2 = [];
      _priceOptionErrors2 = [];
      _stockOptionErrors2 = [];
      if (_variants.isEmpty) _labelController1.text = "Phân loại mới";
      _labelController2.text = "Phân loại mới";
      _addValue2();
    });
  }

  void _handleFocusChange() {
    setState(() {
      for (int i = 0; i < _labelFocusNodes1.length; i++) {
        if (!_labelFocusNodes1[i].hasFocus &&
            _labelOptionControllers1[i].text.isEmpty) {
          _optionsVariant1.removeAt(i);
          _labelOptionControllers1.removeAt(i);
          _priceOptionControllers1.removeAt(i);
          _stockOptionControllers1.removeAt(i);
          _labelFocusNodes1.removeAt(i);
          _priceFocusNodes1.removeAt(i);
          _stockFocusNodes1.removeAt(i);
          _labelOptionErrors1.removeAt(i);
          _priceOptionErrors1.removeAt(i);
          _stockOptionErrors1.removeAt(i);
          _variants[0] = _variants[0].copyWith(options: _optionsVariant1);
          break;
        }
      }
      for (int i = 0; i < _labelFocusNodes2.length; i++) {
        if (!_labelFocusNodes2[i].hasFocus &&
            _labelOptionControllers2[i].text.isEmpty) {
          _optionsVariant2.removeAt(i);
          _labelOptionControllers2.removeAt(i);
          _priceOptionControllers2.removeAt(i);
          _stockOptionControllers2.removeAt(i);
          _labelFocusNodes2.removeAt(i);
          _priceFocusNodes2.removeAt(i);
          _stockFocusNodes2.removeAt(i);
          _labelOptionErrors2.removeAt(i);
          _priceOptionErrors2.removeAt(i);
          _stockOptionErrors2.removeAt(i);
          if (_variants.length > 1)
            _variants[1] = _variants[1].copyWith(options: _optionsVariant2);
          break;
        }
      }
    });
  }

  void _handlePriceFocusChange1() {
    setState(() {
      for (int i = 0; i < _priceFocusNodes1.length; i++) {
        if (!_priceFocusNodes1[i].hasFocus) {
          final validatedPrice = _validatePrice(
              _priceOptionControllers1[i].text, _priceOptionControllers1[i]);
          _optionsVariant1[i] =
              _optionsVariant1[i].copyWith(price: validatedPrice);
          _variants[0] = _variants[0].copyWith(options: _optionsVariant1);
        }
      }
    });
  }

  void _handlePriceFocusChange2() {
    setState(() {
      for (int i = 0; i < _priceFocusNodes2.length; i++) {
        if (!_priceFocusNodes2[i].hasFocus) {
          final validatedPrice = _validatePrice(
              _priceOptionControllers2[i].text, _priceOptionControllers2[i]);
          _optionsVariant2[i] =
              _optionsVariant2[i].copyWith(price: validatedPrice);
          if (_variants.length > 1)
            _variants[1] = _variants[1].copyWith(options: _optionsVariant2);
        }
      }
    });
  }

  void _handleStockFocusChange1() {
    setState(() {
      for (int i = 0; i < _stockFocusNodes1.length; i++) {
        if (!_stockFocusNodes1[i].hasFocus) {
          final validatedStock = _validateStock(
              _stockOptionControllers1[i].text, _stockOptionControllers1[i]);
          _optionsVariant1[i] =
              _optionsVariant1[i].copyWith(stock: validatedStock);
          _variants[0] = _variants[0].copyWith(options: _optionsVariant1);
        }
      }
    });
  }

  void _handleStockFocusChange2() {
    setState(() {
      for (int i = 0; i < _stockFocusNodes2.length; i++) {
        if (!_stockFocusNodes2[i].hasFocus) {
          final validatedStock = _validateStock(
              _stockOptionControllers2[i].text, _stockOptionControllers2[i]);
          _optionsVariant2[i] =
              _optionsVariant2[i].copyWith(stock: validatedStock);
          if (_variants.length > 1)
            _variants[1] = _variants[1].copyWith(options: _optionsVariant2);
        }
      }
    });
  }

  void _handleTapOutside() {
    FocusScope.of(context).unfocus();
    setState(() {
      if (_optionsVariant1.isNotEmpty &&
          _labelOptionControllers1.last.text.isEmpty) {
        _optionsVariant1.removeLast();
        _labelOptionControllers1.removeLast();
        _priceOptionControllers1.removeLast();
        _stockOptionControllers1.removeLast();
        _labelFocusNodes1.removeLast();
        _priceFocusNodes1.removeLast();
        _stockFocusNodes1.removeLast();
        _labelOptionErrors1.removeLast();
        _priceOptionErrors1.removeLast();
        _stockOptionErrors1.removeLast();
        _variants[0] = _variants[0].copyWith(options: _optionsVariant1);
      }
      if (_optionsVariant2.isNotEmpty &&
          _labelOptionControllers2.last.text.isEmpty) {
        _optionsVariant2.removeLast();
        _labelOptionControllers2.removeLast();
        _priceOptionControllers2.removeLast();
        _stockOptionControllers2.removeLast();
        _labelFocusNodes2.removeLast();
        _priceFocusNodes2.removeLast();
        _stockFocusNodes2.removeLast();
        _labelOptionErrors2.removeLast();
        _priceOptionErrors2.removeLast();
        _stockOptionErrors2.removeLast();
        if (_variants.length > 1)
          _variants[1] = _variants[1].copyWith(options: _optionsVariant2);
      }

      for (int i = 0; i < _optionsVariant1.length; i++) {
        final validatedPrice = _validatePrice(
            _priceOptionControllers1[i].text, _priceOptionControllers1[i]);
        final validatedStock = _validateStock(
            _stockOptionControllers1[i].text, _stockOptionControllers1[i]);
        _optionsVariant1[i] = _optionsVariant1[i]
            .copyWith(price: validatedPrice, stock: validatedStock);
        _variants[0] = _variants[0].copyWith(options: _optionsVariant1);
      }
      for (int i = 0; i < _optionsVariant2.length; i++) {
        final validatedPrice = _validatePrice(
            _priceOptionControllers2[i].text, _priceOptionControllers2[i]);
        final validatedStock = _validateStock(
            _stockOptionControllers2[i].text, _stockOptionControllers2[i]);
        _optionsVariant2[i] = _optionsVariant2[i]
            .copyWith(price: validatedPrice, stock: validatedStock);
        if (_variants.length > 1)
          _variants[1] = _variants[1].copyWith(options: _optionsVariant2);
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
      // Reset lỗi cũ
      _labelError1 = null;
      _labelError2 = null;
      _labelOptionErrors1 =
          List<String?>.generate(_labelOptionControllers1.length, (_) => null);
      _priceOptionErrors1 =
          List<String?>.generate(_priceOptionControllers1.length, (_) => null);
      _stockOptionErrors1 =
          List<String?>.generate(_stockOptionControllers1.length, (_) => null);
      _labelOptionErrors2 =
          List<String?>.generate(_labelOptionControllers2.length, (_) => null);
      _priceOptionErrors2 =
          List<String?>.generate(_priceOptionControllers2.length, (_) => null);
      _stockOptionErrors2 =
          List<String?>.generate(_stockOptionControllers2.length, (_) => null);

      if (_variants.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vui lòng thêm ít nhất một phân loại")),
        );
        return;
      }

      if (variantLabel1.isEmpty) {
        _labelError1 = "Tên phân loại không được để trống";
        isValid = false;
      }
      for (int i = 0; i < _optionsVariant1.length; i++) {
        if (_labelOptionControllers1[i].text.isEmpty) {
          _labelOptionErrors1[i] = "Tên nhãn không được để trống";
          isValid = false;
        }
        try {
          final price = double.parse(_priceOptionControllers1[i].text);
          if (price <= 0) {
            _priceOptionErrors1[i] = "Giá phải lớn hơn 0";
            isValid = false;
          }
        } catch (e) {
          _priceOptionErrors1[i] = "Giá không hợp lệ";
          isValid = false;
        }
        try {
          final stock = int.parse(_stockOptionControllers1[i].text);
          if (stock <= 0) {
            _stockOptionErrors1[i] = "Kho phải lớn hơn 0";
            isValid = false;
          }
        } catch (e) {
          _stockOptionErrors1[i] = "Kho không hợp lệ";
          isValid = false;
        }
      }

      if (_variants.length > 1) {
        if (variantLabel2.isEmpty) {
          _labelError2 = "Tên phân loại không được để trống";
          isValid = false;
        }
        for (int i = 0; i < _optionsVariant2.length; i++) {
          if (_labelOptionControllers2[i].text.isEmpty) {
            _labelOptionErrors2[i] = "Tên nhãn không được để trống";
            isValid = false;
          }
          try {
            final price = double.parse(_priceOptionControllers2[i].text);
            if (price <= 0) {
              _priceOptionErrors2[i] = "Giá phải lớn hơn 0";
              isValid = false;
            }
          } catch (e) {
            _priceOptionErrors2[i] = "Giá không hợp lệ";
            isValid = false;
          }
          try {
            final stock = int.parse(_stockOptionControllers2[i].text);
            if (stock <= 0) {
              _stockOptionErrors2[i] = "Kho phải lớn hơn 0";
              isValid = false;
            }
          } catch (e) {
            _stockOptionErrors2[i] = "Kho không hợp lệ";
            isValid = false;
          }
        }
      }
    });
    return isValid;
  }

  void _saveData() async {
    if (!_validateDataBeforeSave()) return;

    final firestore = FirebaseFirestore.instance;
    try {
      await firestore.collection('variants').add({
        'variants': _variants.map((v) => v.toJson()).toList(),
        'enableImageForVariant': enableImageForVariant,
        'timestamp': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã lưu phân loại thành công")),
      );
      Navigator.of(context).pop();
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
                      if (_variants.isNotEmpty) ...[
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: _removeVariant1,
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
                                      controller: _labelController1,
                                      maxLength: 30,
                                      decoration: InputDecoration(
                                        hintText: "",
                                        counterText: '',
                                        border: InputBorder.none,
                                        errorText: _labelError1,
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          variantLabel1 = value;
                                          _variants[0] = _variants[0]
                                              .copyWith(label: value);
                                          _labelError1 = null;
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
                                  ..._optionsVariant1
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    int index = entry.key;
                                    return Stack(
                                      children: [
                                        Container(
                                          constraints: const BoxConstraints(
                                              minWidth: 70),
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
                                                        _labelOptionErrors1[
                                                            index],
                                                  ),
                                                  controller:
                                                      _labelOptionControllers1[
                                                          index],
                                                  focusNode:
                                                      _labelFocusNodes1[index],
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _optionsVariant1[index] =
                                                          _optionsVariant1[
                                                                  index]
                                                              .copyWith(
                                                                  name: value);
                                                      _variants[0] =
                                                          _variants[0].copyWith(
                                                              options:
                                                                  _optionsVariant1);
                                                      _labelOptionErrors1[
                                                          index] = null;
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
                                                        _priceOptionErrors1[
                                                            index],
                                                  ),
                                                  controller:
                                                      _priceOptionControllers1[
                                                          index],
                                                  focusNode:
                                                      _priceFocusNodes1[index],
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _priceOptionErrors1[
                                                          index] = null;
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
                                                        _stockOptionErrors1[
                                                            index],
                                                  ),
                                                  controller:
                                                      _stockOptionControllers1[
                                                          index],
                                                  focusNode:
                                                      _stockFocusNodes1[index],
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _stockOptionErrors1[
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
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _optionsVariant1
                                                    .removeAt(index);
                                                _labelOptionControllers1
                                                    .removeAt(index);
                                                _priceOptionControllers1
                                                    .removeAt(index);
                                                _stockOptionControllers1
                                                    .removeAt(index);
                                                _labelFocusNodes1
                                                    .removeAt(index);
                                                _priceFocusNodes1
                                                    .removeAt(index);
                                                _stockFocusNodes1
                                                    .removeAt(index);
                                                _labelOptionErrors1
                                                    .removeAt(index);
                                                _priceOptionErrors1
                                                    .removeAt(index);
                                                _stockOptionErrors1
                                                    .removeAt(index);
                                                _variants[0] = _variants[0]
                                                    .copyWith(
                                                        options:
                                                            _optionsVariant1);
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
                                    onTap: _addValue1,
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
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      "Thêm hình ảnh cho phân loại $variantLabel1\nKhi bật tính năng này, tất cả hình ảnh phải được tải lên",
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  CupertinoSwitch(
                                    value: enableImageForVariant,
                                    onChanged: (value) {
                                      setState(() {
                                        enableImageForVariant = value;
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
                                  children: _optionsVariant1.map((value) {
                                    return GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                        height: 70,
                                        width: 70,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 0.5, color: Colors.red),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(value.name,
                                            style: const TextStyle(
                                                color: Colors.red)),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      if (_variants.length > 1) ...[
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: _removeVariant2,
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
                                      controller: _labelController2,
                                      maxLength: 30,
                                      decoration: InputDecoration(
                                        hintText: "Nhập tên phân loại",
                                        counterText: '',
                                        border: InputBorder.none,
                                        errorText: _labelError2,
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          variantLabel2 = value;
                                          _variants[1] = _variants[1]
                                              .copyWith(label: value);
                                          _labelError2 = null;
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
                                  ..._optionsVariant2
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    int index = entry.key;
                                    return Stack(
                                      children: [
                                        Container(
                                          constraints: const BoxConstraints(
                                              minWidth: 70),
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
                                                        _labelOptionErrors2[
                                                            index],
                                                  ),
                                                  controller:
                                                      _labelOptionControllers2[
                                                          index],
                                                  focusNode:
                                                      _labelFocusNodes2[index],
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _optionsVariant2[index] =
                                                          _optionsVariant2[
                                                                  index]
                                                              .copyWith(
                                                                  name: value);
                                                      _variants[1] =
                                                          _variants[1].copyWith(
                                                              options:
                                                                  _optionsVariant2);
                                                      _labelOptionErrors2[
                                                          index] = null;
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
                                                        _priceOptionErrors2[
                                                            index],
                                                  ),
                                                  controller:
                                                      _priceOptionControllers2[
                                                          index],
                                                  focusNode:
                                                      _priceFocusNodes2[index],
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _priceOptionErrors2[
                                                          index] = null;
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
                                                        _stockOptionErrors2[
                                                            index],
                                                  ),
                                                  controller:
                                                      _stockOptionControllers2[
                                                          index],
                                                  focusNode:
                                                      _stockFocusNodes2[index],
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _stockOptionErrors2[
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
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _optionsVariant2
                                                    .removeAt(index);
                                                _labelOptionControllers2
                                                    .removeAt(index);
                                                _priceOptionControllers2
                                                    .removeAt(index);
                                                _stockOptionControllers2
                                                    .removeAt(index);
                                                _labelFocusNodes2
                                                    .removeAt(index);
                                                _priceFocusNodes2
                                                    .removeAt(index);
                                                _stockFocusNodes2
                                                    .removeAt(index);
                                                _labelOptionErrors2
                                                    .removeAt(index);
                                                _priceOptionErrors2
                                                    .removeAt(index);
                                                _stockOptionErrors2
                                                    .removeAt(index);
                                                _variants[1] = _variants[1]
                                                    .copyWith(
                                                        options:
                                                            _optionsVariant2);
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
                                    onTap: _addValue2,
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
                            ],
                          ),
                        ),
                      ],
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
