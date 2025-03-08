import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:luanvan/ui/helper/icon_helper.dart';

class AddVariantScreen extends StatefulWidget {
  const AddVariantScreen({super.key});
  static String routeName = "add_variant";

  @override
  State<AddVariantScreen> createState() => _AddVariantScreenState();
}

class _AddVariantScreenState extends State<AddVariantScreen> {
  // Danh sách các giá trị phân loại
  List<String> variantValues1 = [];
  List<String> variantValues2 = [];
  // Tên của hai loại phân loại (có thể chỉnh sửa)
  String variantLabel1 = "Màu sắc";
  String variantLabel2 = "Kích cỡ";
  // Trạng thái bật/tắt hình ảnh cho phân loại
  bool enableImageForVariant = false;
  // Controller và FocusNode cho các TextField
  final TextEditingController _valueController1 = TextEditingController();
  final TextEditingController _valueController2 = TextEditingController();
  final TextEditingController _labelController1 =
      TextEditingController(text: "Màu sắc");
  final TextEditingController _labelController2 =
      TextEditingController(text: "Kích cỡ");
  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode2 = FocusNode();

  @override
  void initState() {
    super.initState();
    // Lắng nghe sự kiện khi mất focus để cập nhật giá trị
    _focusNode1.addListener(() {
      if (!_focusNode1.hasFocus) {
        setState(() {
          variantLabel1 = _labelController1.text.isEmpty
              ? "Màu sắc"
              : _labelController1.text;
        });
      }
    });
    _focusNode2.addListener(() {
      if (!_focusNode2.hasFocus) {
        setState(() {
          variantLabel2 = _labelController2.text.isEmpty
              ? "Kích cỡ"
              : _labelController2.text;
        });
      }
    });
  }

  @override
  void dispose() {
    _valueController1.dispose();
    _valueController2.dispose();
    _labelController1.dispose();
    _labelController2.dispose();
    _focusNode1.dispose();
    _focusNode2.dispose();
    super.dispose();
  }

  void _addValue1() {
    if (_valueController1.text.isNotEmpty) {
      setState(() {
        variantValues1.add(_valueController1.text);
        _valueController1.clear();
      });
    }
  }

  void _addValue2() {
    if (_valueController2.text.isNotEmpty) {
      setState(() {
        variantValues2.add(_valueController2.text);
        _valueController2.clear();
      });
    }
  }

  // Hàm xóa phân loại 1
  void _removeVariant1() {
    setState(() {
      variantLabel1 = "";
      variantValues1.clear();
      _labelController1.clear();
    });
  }

  // Hàm xóa phân loại 2
  void _removeVariant2() {
    setState(() {
      variantLabel2 = "";
      variantValues2.clear();
      _labelController2.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    // Phân loại 1
                    if (variantLabel1.isNotEmpty) ...[
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
                                    focusNode: _focusNode1,
                                    decoration: const InputDecoration(
                                      hintText: "Nhập tên phân loại",
                                      border: InputBorder.none,
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        variantLabel1 = value;
                                      });
                                    },
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _focusNode1
                                        .requestFocus(); // Focus khi nhấn "Sửa"
                                  },
                                  child: Text(
                                    "Sửa",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.brown,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Danh sách giá trị phân loại 1
                            Wrap(
                              spacing: 8,
                              children: variantValues1.map((value) {
                                return Chip(
                                  label: Text(value),
                                  onDeleted: () {
                                    setState(() {
                                      variantValues1.remove(value);
                                    });
                                  },
                                  deleteIcon: const Icon(Icons.close, size: 18),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 10),
                            // Thêm giá trị mới
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _valueController1,
                                    decoration: InputDecoration(
                                      hintText: "Nhập $variantLabel1",
                                      border: const OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                IconButton(
                                  onPressed: _addValue1,
                                  icon: const Icon(Icons.add_circle_outline),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Bật/tắt hình ảnh cho phân loại
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    "Thêm hình ảnh cho phân loại $variantLabel1\nKhi bật tính năng này, tất cả hình ảnh phải được tải lên",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                Switch(
                                  value: enableImageForVariant,
                                  onChanged: (value) {
                                    setState(() {
                                      enableImageForVariant = value;
                                    });
                                  },
                                  activeColor: Colors.red,
                                ),
                              ],
                            ),
                            if (enableImageForVariant) ...[
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                children: variantValues1.map((value) {
                                  return GestureDetector(
                                    onTap: () {
                                      // Logic thêm hình ảnh cho từng giá trị
                                    },
                                    child: Container(
                                      height: 80,
                                      width: 80,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 0.5,
                                          color: Colors.red,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        value,
                                        style:
                                            const TextStyle(color: Colors.red),
                                      ),
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
                    // Phân loại 2
                    if (variantLabel2.isNotEmpty) ...[
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
                                    focusNode: _focusNode2,
                                    decoration: const InputDecoration(
                                      hintText: "Nhập tên phân loại",
                                      border: InputBorder.none,
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        variantLabel2 = value;
                                      });
                                    },
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _focusNode2
                                        .requestFocus(); // Focus khi nhấn "Sửa"
                                  },
                                  child: Text(
                                    "Sửa",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.brown,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Danh sách giá trị phân loại 2
                            Wrap(
                              spacing: 8,
                              children: variantValues2.map((value) {
                                return Chip(
                                  label: Text(value),
                                  onDeleted: () {
                                    setState(() {
                                      variantValues2.remove(value);
                                    });
                                  },
                                  deleteIcon: const Icon(Icons.close, size: 18),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 10),
                            // Thêm giá trị mới
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _valueController2,
                                    decoration: InputDecoration(
                                      hintText: "Nhập $variantLabel2",
                                      border: const OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                IconButton(
                                  onPressed: _addValue2,
                                  icon: const Icon(Icons.add_circle_outline),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20), // Đảm bảo chiều cao tối thiểu
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
              padding: const EdgeInsets.only(
                  top: 30, left: 10, right: 10, bottom: 0),
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
                  SizedBox(
                    height: 40,
                    child: Text(
                      "Thiết lập phân loại",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom AppBar
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
                        Navigator.pop(context, {
                          'variant1': variantLabel1,
                          'values1': variantValues1,
                          'variant2': variantLabel2,
                          'values2': variantValues2,
                          'enableImage': enableImageForVariant,
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: Text(
                        "Tiếp: Chính kho và giá bán",
                        style:
                            TextStyle(fontSize: 16, color: Colors.grey[500]!),
                      ),
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
}
