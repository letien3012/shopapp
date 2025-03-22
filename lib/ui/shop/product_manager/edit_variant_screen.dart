import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luanvan/models/option_info.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/models/product_option.dart';
import 'package:luanvan/models/product_variant.dart';
import 'package:luanvan/ui/helper/icon_helper.dart';
import 'package:luanvan/ui/shop/product_manager/set_variant_info_screen.dart';

class EditVariantScreen extends StatefulWidget {
  const EditVariantScreen({super.key});
  static const String routeName = "add_variant";

  @override
  State<EditVariantScreen> createState() => _EditVariantScreenState();
}

class _EditVariantScreenState extends State<EditVariantScreen> {
  List<ProductVariant> _variants = [];
  List<List<ProductOption>> _options = [];
  late List<List<TextEditingController>> _labelOptionControllers;
  late List<List<FocusNode>> _labelFocusNodes;
  bool enableImageForVariant = false;

  final List<TextEditingController> _valueControllers = [
    TextEditingController(),
    TextEditingController()
  ];
  List<TextEditingController> _labelControllers = [];
  List<String> _imageUrls = [];

  // Biến lưu trữ lỗi
  List<String?> _labelErrors = [];
  late List<List<String?>> _labelOptionErrors;
  late Product product;
  List<bool> isEditVariant = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      product = ModalRoute.of(context)!.settings.arguments as Product;
      setState(() {
        _variants = product.variants.isNotEmpty
            ? product.variants.map((variant) => variant.copyWith()).toList()
            : [];
        _labelControllers = _variants
            .map((val) => TextEditingController(text: val.label))
            .toList();
        _options = _variants
            .map((variant) => List<ProductOption>.from(variant.options))
            .toList();
        _labelErrors =
            List<String?>.filled(_variants.length, null, growable: true);
        enableImageForVariant = product.hasVariantImages;

        isEditVariant =
            List<bool>.filled(_variants.length, false, growable: true);

        if (enableImageForVariant && _options.isNotEmpty) {
          _imageUrls = _options[0].map((option) {
            return option.imageUrl ?? '';
          }).toList();
        } else {
          _imageUrls = [];
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

    _labelFocusNodes = _options
        .map((optionList) => optionList.map((_) => FocusNode()).toList())
        .toList();

    _labelOptionErrors = _options
        .map((optionList) =>
            List<String?>.filled(optionList.length, null, growable: true))
        .toList();

    for (int i = 0; i < _labelFocusNodes.length; i++) {
      for (var focusNode in _labelFocusNodes[i]) {
        focusNode.addListener(_handleFocusChange);
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

    for (var focusNodes in _labelFocusNodes) {
      for (var focusNode in focusNodes) focusNode.dispose();
    }

    super.dispose();
  }

  void _addValue(int variantIndex) {
    setState(() {
      if (_valueControllers[variantIndex].text.isNotEmpty) {
        _options[variantIndex]
            .add(ProductOption(name: _valueControllers[variantIndex].text));
        _labelOptionControllers[variantIndex].add(
            TextEditingController(text: _valueControllers[variantIndex].text));
        _labelFocusNodes[variantIndex]
            .add(FocusNode()..addListener(_handleFocusChange));
        _labelOptionErrors[variantIndex].add(null);

        if (variantIndex == 0 && enableImageForVariant) _imageUrls.add('');
        _valueControllers[variantIndex].clear();
      } else {
        _options[variantIndex].add(ProductOption(name: ''));
        _labelOptionControllers[variantIndex]
            .add(TextEditingController(text: ''));
        final newFocusNode = FocusNode()..addListener(_handleFocusChange);
        _labelFocusNodes[variantIndex].add(newFocusNode);
        _labelOptionErrors[variantIndex].add(null);

        if (variantIndex == 0 && enableImageForVariant) _imageUrls.add('');
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
      _labelFocusNodes.removeAt(variantIndex);
      _labelOptionErrors.removeAt(variantIndex);
      _labelControllers.removeAt(variantIndex);
      _labelErrors.removeAt(variantIndex);

      if (_variants.isNotEmpty && variantIndex == 0) {
        _options[0] = List.from(_options[1]);
        _labelOptionControllers[0] = _options[0]
            .map((option) => TextEditingController(text: option.name))
            .toList();
        _labelFocusNodes[0] = _options[0]
            .map((_) => FocusNode()..addListener(_handleFocusChange))
            .toList();
        _labelOptionErrors[0] =
            List<String?>.generate(_options[0].length, (_) => null);
        _imageUrls =
            _options[0].map((option) => option.imageUrl ?? '').toList();
        _labelControllers[0].text = _labelControllers[1].text;
        _labelErrors[0] = _labelErrors[1];

        _options.removeAt(1);
        _labelOptionControllers.removeAt(1);
        _labelFocusNodes.removeAt(1);
        _labelOptionErrors.removeAt(1);
        _labelControllers.removeAt(1);
        _labelErrors.removeAt(1);
      }

      isEditVariant.removeAt(variantIndex);
      if (variantIndex == 0 && _variants.isNotEmpty) {
        isEditVariant[0] = false;
      }
    });
  }

  void _addNewVariant() {
    if (_variants.length >= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Chỉ được phép có tối đa 2 phân loại")),
      );
      return;
    }
    setState(() {
      _variants.add(ProductVariant(label: "Phân loại mới", options: []));
      _options.add([]);
      _labelOptionControllers.add([]);
      _labelFocusNodes.add([]);
      _labelOptionErrors.add([]);
      _labelControllers.add(TextEditingController(text: "Phân loại mới"));
      _labelErrors.add(null);
      isEditVariant.add(false);
      _addValue(_variants.length - 1);
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
            _labelFocusNodes[i].removeAt(j);
            _labelOptionErrors[i].removeAt(j);
            if (i == 0 && enableImageForVariant) _imageUrls.removeAt(j);
            _variants[i] = _variants[i].copyWith(options: _options[i]);
            break;
          }
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
          _labelFocusNodes[i].removeLast();
          _labelOptionErrors[i].removeLast();
          if (i == 0 && enableImageForVariant) _imageUrls.removeLast();
          _variants[i] = _variants[i].copyWith(options: _options[i]);
        }
      }
    });
  }

  bool _validateDataBeforeSave() {
    bool isValid = true;
    setState(() {
      _labelErrors = List.filled(_variants.length, null, growable: true);
      _labelOptionErrors = _options
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
                      while (_imageUrls.length <= optionIndex) {
                        _imageUrls.add('');
                      }
                      _imageUrls[optionIndex] = pickedImage.path;
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
                      while (_imageUrls.length <= optionIndex) {
                        _imageUrls.add('');
                      }
                      _imageUrls[optionIndex] = pickedImage.path;
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
      for (int i = 0; i < _variants.length; i++) {
        for (int j = 0; j < _options[i].length; j++) {
          final name = _labelOptionControllers[i][j].text;
          // Chỉ lưu imageUrl cho variant đầu tiên nếu enableImageForVariant bật
          String? imageUrl;
          if (i == 0 && enableImageForVariant && j < _imageUrls.length) {
            imageUrl = _imageUrls[j].isNotEmpty ? _imageUrls[j] : null;
          }
          _options[i][j] = _options[i][j].copyWith(
            name: name,
            imageUrl: imageUrl,
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

      int totalCombinations = _variants.length == 1
          ? _options[0].length
          : _options[0].length * _options[1].length;
      while (product.optionInfos.length < totalCombinations) {
        product.optionInfos.add(OptionInfo(
            price: 0,
            stock: 0,
            weight: product.optionInfos.isNotEmpty
                ? product.optionInfos[0].weight
                : null));
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã lưu phân loại thành công")),
      );
      Navigator.pushNamed(context, SetVariantInfoScreen.routeName,
              arguments: product)
          .then((result) {
        if (result != null) {
          Navigator.pop(context, result);
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi lưu dữ liệu: $e")),
      );
    }
  }

  Future<bool> _showExitConfirmationDialog() async {
    return await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              actionsPadding: EdgeInsets.zero,
              titlePadding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
              title: const Text("Hủy thay đổi?"),
              titleTextStyle: TextStyle(fontSize: 14, color: Colors.grey),
              actions: [
                Row(
                  children: [
                    Expanded(
                        child: Container(
                      alignment: Alignment.center,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border(
                            top: BorderSide(width: 0.2, color: Colors.grey),
                            right: BorderSide(width: 0.2, color: Colors.grey)),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop(false);
                        },
                        child: Text(
                          "HỦY",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    )),
                    Expanded(
                        child: Container(
                      alignment: Alignment.center,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(width: 0.2, color: Colors.grey),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop(true);
                        },
                        child: Text(
                          "HỦY THAY ĐỔI",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.brown,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )),
                  ],
                )
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await _showExitConfirmationDialog()) {
          return true;
        } else
          return false;
      },
      child: GestureDetector(
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
                        if (_variants.isEmpty)
                          const Center(
                            child: Text(
                              "Chưa có phân loại nào, hãy thêm phân loại mới",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ),
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
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isEditVariant[index] =
                                              !isEditVariant[index];
                                        });
                                      },
                                      child: Text(
                                        isEditVariant[index] == false
                                            ? 'Sửa'
                                            : 'Xong',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.brown,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
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

                                      return Stack(
                                        children: [
                                          IntrinsicWidth(
                                            child: Container(
                                              height: 35,
                                              constraints:
                                                  BoxConstraints(minWidth: 80),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(2),
                                                border: Border.all(
                                                    color: Colors.grey,
                                                    width: 0.6),
                                              ),
                                              alignment: Alignment.center,
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
                                                      _labelOptionErrors[index]
                                                          [optIndex],
                                                ),
                                                controller:
                                                    _labelOptionControllers[
                                                        index][optIndex],
                                                focusNode:
                                                    _labelFocusNodes[index]
                                                        [optIndex],
                                                onChanged: (value) {
                                                  setState(() {
                                                    _options[index][optIndex] =
                                                        _options[index]
                                                                [optIndex]
                                                            .copyWith(
                                                                name: value);
                                                    _variants[index] =
                                                        _variants[index]
                                                            .copyWith(
                                                                options:
                                                                    _options[
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
                                          ),
                                          if (_options[index].length >= 1 &&
                                              isEditVariant[index])
                                            Positioned(
                                              top: 0,
                                              right: 0,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _options[index]
                                                        .removeAt(optIndex);
                                                    _labelOptionControllers[
                                                            index]
                                                        .removeAt(optIndex);
                                                    _labelFocusNodes[index]
                                                        .removeAt(optIndex);
                                                    _labelOptionErrors[index]
                                                        .removeAt(optIndex);
                                                    if (index == 0 &&
                                                        enableImageForVariant)
                                                      _imageUrls
                                                          .removeAt(optIndex);
                                                    _variants[index] =
                                                        _variants[index]
                                                            .copyWith(
                                                                options:
                                                                    _options[
                                                                        index]);
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
                                        width: 80,
                                        height: 35,
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 8),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 0.5, color: Colors.red),
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                        child: const Text("+ Thêm",
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ),
                                    )
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
                                              _imageUrls.clear();
                                            } else if (_options.isNotEmpty) {
                                              _imageUrls =
                                                  _options[0].map((option) {
                                                return option.imageUrl ?? '';
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
                                          child: Column(
                                            children: [
                                              Container(
                                                height: 80,
                                                width: 80,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      width: 0.5,
                                                      color: Colors.red),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft: Radius
                                                              .circular(2),
                                                          topRight:
                                                              Radius.circular(
                                                                  2)),
                                                  image: optIndex <
                                                              _imageUrls
                                                                  .length &&
                                                          _imageUrls[optIndex]
                                                              .isNotEmpty
                                                      ? DecorationImage(
                                                          image: _imageUrls[
                                                                      optIndex]
                                                                  .startsWith(
                                                                      'http')
                                                              ? NetworkImage(
                                                                  _imageUrls[
                                                                      optIndex])
                                                              : FileImage(File(
                                                                  _imageUrls[
                                                                      optIndex])),
                                                          fit: BoxFit.cover,
                                                        )
                                                      : null,
                                                ),
                                                child: optIndex >=
                                                            _imageUrls.length ||
                                                        _imageUrls[optIndex]
                                                            .isEmpty
                                                    ? const Text('',
                                                        style: TextStyle(
                                                            color: Colors.red))
                                                    : null,
                                              ),
                                              Container(
                                                width: 80,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: Colors.deepOrange,
                                                  border: Border.all(
                                                      width: 0.5,
                                                      color: Colors.red),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          bottomLeft: Radius
                                                              .circular(2),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  2)),
                                                ),
                                                child: Text(
                                                  value.name,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                              )
                                            ],
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
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
                        onTap: () async {
                          if (await _showExitConfirmationDialog()) {
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
                            "Tiếp: Chỉnh kho và giá bán",
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
      ),
    );
  }
}
