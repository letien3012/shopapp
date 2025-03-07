import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:luanvan/ui/checkout/add_addressline_screen.dart.dart';
import 'package:luanvan/ui/checkout/pick_location.dart';

class AddLocationShopScreen extends StatefulWidget {
  const AddLocationShopScreen({super.key});
  static String routeName = "add_location_shop_screen";

  @override
  State<AddLocationShopScreen> createState() => _AddLocationShopScreenState();
}

class _AddLocationShopScreenState extends State<AddLocationShopScreen> {
  final FocusNode _focusName = FocusNode();
  final FocusNode _focusPhone = FocusNode();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isAddDefault = true;

  // Biến lưu địa chỉ đã chọn
  String _selectedLocation = "Tỉnh/Thành phố, Quận/Huyện, Phường/Xã";
  String _addressLine = "Tên đường, Tòa nhà, Số nhà";

  @override
  void initState() {
    super.initState();
    _focusName.addListener(() {
      setState(() {});
    });
    _focusPhone.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusName.dispose();
    _focusPhone.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() &&
        _selectedLocation != "Tỉnh/Thành phố, Quận/Huyện, Phường/Xã" &&
        _addressLine != "Tên đường, Tòa nhà, Số nhà") {}
  }

  void _pickLocation() async {
    final result = await Navigator.pushNamed(
      context,
      PickLocation.routeName,
      arguments: _selectedLocation,
    );
    if (result != null && result is Map<String, String>) {
      setState(() {
        _selectedLocation =
            "${result['ward']}, ${result['district']}, ${result['province']}";
      });
    }
  }

  void _addressLineFill() async {
    final result = await Navigator.pushNamed(
      context,
      AddAddresslineScreen.routeName,
      arguments: _addressLine,
    );
    if (result != null) {
      setState(() {
        print(result);
        _addressLine = "$result";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              width: MediaQuery.of(context).size.width,
              color: Colors.grey[200],
              padding: const EdgeInsets.only(
                  top: 90, bottom: 20, left: 10, right: 10),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Địa chỉ",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextFormField(
                            controller: _nameController,
                            focusNode: _focusName,
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              labelText: 'Họ và tên',
                              labelStyle: const TextStyle(fontSize: 13),
                              floatingLabelStyle: const TextStyle(fontSize: 16),
                              suffixIcon: _focusName.hasFocus
                                  ? IconButton(
                                      icon: const Icon(Icons.cancel, size: 18),
                                      onPressed: () {
                                        _nameController.clear();
                                        setState(() {});
                                      },
                                    )
                                  : null,
                              border: const UnderlineInputBorder(
                                borderSide:
                                    BorderSide(width: 0.5, color: Colors.grey),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide:
                                    BorderSide(width: 1, color: Colors.grey),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập họ và tên';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _phoneController,
                            focusNode: _focusPhone,
                            keyboardType:
                                const TextInputType.numberWithOptions(),
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              labelText: 'Số điện thoại',
                              labelStyle: const TextStyle(fontSize: 13),
                              floatingLabelStyle: const TextStyle(fontSize: 16),
                              suffixIcon: _focusPhone.hasFocus
                                  ? IconButton(
                                      icon: const Icon(Icons.cancel, size: 18),
                                      onPressed: () {
                                        _phoneController.clear();
                                        setState(() {});
                                      },
                                    )
                                  : null,
                              border: const UnderlineInputBorder(
                                borderSide:
                                    BorderSide(width: 0.5, color: Colors.grey),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide:
                                    BorderSide(width: 1, color: Colors.grey),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập số điện thoại';
                              }
                              if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                                return 'Số điện thoại phải là 10 chữ số';
                              }
                              return null;
                            },
                          ),
                          GestureDetector(
                            onTap: _pickLocation,
                            child: Container(
                              height: 60,
                              padding: EdgeInsets.only(bottom: 5),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom:
                                      BorderSide(width: 1, color: Colors.grey),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _selectedLocation,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _addressLineFill();
                            },
                            child: Container(
                              alignment: Alignment.bottomLeft,
                              height: 60,
                              padding: EdgeInsets.only(bottom: 5),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom:
                                      BorderSide(width: 1, color: Colors.grey),
                                ),
                              ),
                              child: Text(
                                _addressLine,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 60,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Đặt làm địa chỉ lấy hàng"),
                                CupertinoSwitch(
                                  value: isAddDefault,
                                  onChanged: (value) {
                                    setState(() {
                                      isAddDefault = !isAddDefault;
                                    });
                                  },
                                ),
                              ],
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
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              height: 80,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              padding: const EdgeInsets.only(
                  top: 30, left: 10, right: 10, bottom: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.brown,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const SizedBox(
                    height: 40,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Địa chỉ mới",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w400),
                        ),
                      ],
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
              child: GestureDetector(
                onTap: _submitForm,
                child: Container(
                  margin: const EdgeInsets.all(10),
                  height: 50,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: (_nameController.text.isNotEmpty &&
                            _phoneController.text.isNotEmpty)
                        ? Colors.brown
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "HOÀN THÀNH",
                    style: TextStyle(
                      fontSize: 18,
                      color: (_nameController.text.isNotEmpty &&
                              _phoneController.text.isNotEmpty)
                          ? Colors.white
                          : Colors.grey[500],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
