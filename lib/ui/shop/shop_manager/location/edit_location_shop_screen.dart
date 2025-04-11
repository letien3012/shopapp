import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:luanvan/blocs/shop/shop_bloc.dart';
import 'package:luanvan/blocs/shop/shop_event.dart';
import 'package:luanvan/models/address.dart';
import 'package:luanvan/models/shop.dart';
import 'package:luanvan/ui/checkout/add_addressline_screen.dart.dart';
import 'package:luanvan/ui/checkout/pick_location.dart';
import 'package:luanvan/ui/helper/icon_helper.dart';

class EditLocationShopScreen extends StatefulWidget {
  const EditLocationShopScreen({super.key});
  static String routeName = "edit_location_shop_screen";

  @override
  State<EditLocationShopScreen> createState() => _EditLocationShopScreenState();
}

class _EditLocationShopScreenState extends State<EditLocationShopScreen> {
  late Address address;
  Shop shop = Shop(
      userId: '',
      name: '',
      addresses: [],
      phoneNumber: '',
      email: '',
      submittedAt: DateTime.now(),
      shippingMethods: []);
  final FocusNode _focusName = FocusNode();
  final FocusNode _focusPhone = FocusNode();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isAddDefault = true;
  bool isCompleted = false;
  bool isButtonPressed = false;
  String _selectedLocation = "";
  String _addressLine = "";
  int locationIndex = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final arg = ModalRoute.of(context)?.settings.arguments;
      if (arg != null && arg is Map<String, dynamic>) {
        locationIndex = arg['index'] ?? 0;
        shop = arg['shop'];
        if (shop.addresses.isNotEmpty) {
          if (locationIndex >= 0 && locationIndex < shop.addresses.length) {
            address = shop.addresses[locationIndex];
            _nameController.text = address.receiverName;
            _phoneController.text = address.receiverPhone;
            _selectedLocation = address.city.isNotEmpty
                ? "${address.ward}, ${address.district}, ${address.city}"
                : 'Tỉnh/Thành phố, Quận/Huyện, Phường/Xã';
            _addressLine = address.addressLine.isNotEmpty
                ? address.addressLine
                : "Tên đường, Tòa nhà, Số nhà";
            isAddDefault = address.isDefault;
          } else {
            print("LocationIndex không hợp lệ: $locationIndex");
            Navigator.of(context).pop();
          }
        } else {
          // Xử lý trường hợp không có địa chỉ
          print("Không có địa chỉ nào được tìm thấy");
          Navigator.of(context).pop(); // Quay lại màn hình trước
        }
      } else {
        // Xử lý trường hợp không có đối số hợp lệ
        print("Không có đối số hợp lệ");
        Navigator.of(context).pop(); // Quay lại màn hình trước
      }
    });
    _focusName.addListener(_checkFormCompletion);
    _focusPhone.addListener(_checkFormCompletion);
    _nameController.addListener(_checkFormCompletion);
    _phoneController.addListener(_checkFormCompletion);
  }

  // Check if form is complete
  void _checkFormCompletion() {
    setState(() {
      isCompleted = _nameController.text.isNotEmpty &&
          _phoneController.text.isNotEmpty &&
          _selectedLocation != "Tỉnh/Thành phố, Quận/Huyện, Phường/Xã" &&
          _addressLine != "Tên đường, Tòa nhà, Số nhà";
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
        _addressLine != "Tên đường, Tòa nhà, Số nhà") {
      // Cập nhật thông tin địa chỉ
      Address updatedAddress = Address(
        addressLine: _addressLine,
        ward: _selectedLocation.split(',')[0].trim(),
        district: _selectedLocation.split(',')[1].trim(),
        city: _selectedLocation.split(',').last.trim(),
        receiverName: _nameController.text,
        receiverPhone: _phoneController.text,
        isDefault: isAddDefault,
      );

      // Tạo một danh sách mới từ danh sách địa chỉ hiện tại
      List<Address> updatedAddresses = List.from(shop.addresses);

      // Xóa địa chỉ cũ
      updatedAddresses.removeAt(locationIndex);

      // Nếu đây là địa chỉ mặc định mới, đặt tất cả các địa chỉ khác thành không mặc định
      if (isAddDefault) {
        for (int i = 0; i < updatedAddresses.length; i++) {
          updatedAddresses[i] = updatedAddresses[i].copyWith(isDefault: false);
        }
        // Thêm địa chỉ đã cập nhật vào đầu danh sách
        updatedAddresses.insert(0, updatedAddress);
      } else {
        // Nếu không phải địa chỉ mặc định, thêm vào vị trí cũ
        // Trừ khi địa chỉ cũ là mặc định, thì vẫn phải thêm một địa chỉ mặc định mới
        bool needDefaultAddress =
            locationIndex == 0 && shop.addresses[0].isDefault && !isAddDefault;

        if (needDefaultAddress && updatedAddresses.isNotEmpty) {
          // Đặt địa chỉ đầu tiên thành mặc định nếu địa chỉ hiện tại là mặc định và bị hủy
          updatedAddresses[0] = updatedAddresses[0].copyWith(isDefault: true);
        }

        // Thêm vào vị trí thích hợp (giữ nguyên vị trí nếu không phải địa chỉ mặc định)
        if (locationIndex < updatedAddresses.length) {
          updatedAddresses.insert(locationIndex, updatedAddress);
        } else {
          updatedAddresses.add(updatedAddress);
        }
      }

      // Đảm bảo có ít nhất một địa chỉ mặc định nếu có địa chỉ
      if (updatedAddresses.isNotEmpty &&
          !updatedAddresses.any((addr) => addr.isDefault)) {
        updatedAddresses[0] = updatedAddresses[0].copyWith(isDefault: true);
      }

      // Cập nhật user với danh sách địa chỉ mới
      Shop updatedShop = shop.copyWith(addresses: updatedAddresses);
      context.read<ShopBloc>().add(UpdateShopEvent(updatedShop));

      Navigator.of(context).pop();
    }
  }

  void _deleteAddress() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc chắn muốn xóa địa chỉ này không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              "Hủy",
              style: TextStyle(color: Colors.black),
            ),
          ),
          TextButton(
            onPressed: () {
              if (locationIndex == 0) {
                Navigator.of(context).pop();
                showDialog(
                    context: context,
                    builder: (context) => Dialog(
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0)),
                          child: Container(
                            color: Colors.white,
                            height: 80,
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  IconHelper.warning,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Không thể xóa địa chỉ mặc định",
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ));
              } else {
                List<Address> updatedAddresses = List.from(shop.addresses);
                updatedAddresses.removeAt(locationIndex);
                // Cập nhật user với danh sách địa chỉ mới
                Shop updatedShop = shop.copyWith(addresses: updatedAddresses);
                context.read<ShopBloc>().add(UpdateShopEvent(updatedShop));

                // Đóng dialog và quay về màn hình trước
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              }
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
        _checkFormCompletion();
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
        _checkFormCompletion();
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
                              padding: const EdgeInsets.only(bottom: 5),
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
                            onTap: _addressLineFill,
                            child: Container(
                              alignment: Alignment.bottomLeft,
                              height: 60,
                              padding: const EdgeInsets.only(bottom: 5),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom:
                                      BorderSide(width: 1, color: Colors.grey),
                                ),
                              ),
                              child: Text(
                                _addressLine,
                                style: const TextStyle(
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
                                const Text("Đặt làm địa chỉ lấy hàng mặc định"),
                                CupertinoSwitch(
                                  value: isAddDefault,
                                  onChanged: shop.addresses.length <= 1 ||
                                          locationIndex == 0
                                      ? null
                                      : (value) {
                                          setState(() {
                                            isAddDefault = value;
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
                          "Sửa địa chỉ",
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
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _deleteAddress,
                      child: Container(
                        margin: const EdgeInsets.only(
                            left: 10, top: 10, bottom: 10, right: 5),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.red),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Xóa địa chỉ",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: isCompleted ? _submitForm : null,
                      child: StatefulBuilder(builder:
                          (BuildContext context, StateSetter setState) {
                        return InkWell(
                          onTap: isCompleted
                              ? () {
                                  setState(() {
                                    isButtonPressed = true;
                                  });
                                  Future.delayed(
                                      const Duration(milliseconds: 200), () {
                                    setState(() {
                                      isButtonPressed = false;
                                    });
                                    _submitForm();
                                  });
                                }
                              : null,
                          child: Container(
                            margin: const EdgeInsets.only(
                                left: 5, top: 10, bottom: 10, right: 10),
                            height: 50,
                            width: double.infinity,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? (isButtonPressed
                                      ? Colors.brown[700]
                                      : Colors.brown)
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "HOÀN THÀNH",
                              style: TextStyle(
                                fontSize: 18,
                                color: isCompleted
                                    ? Colors.white
                                    : Colors.grey[500],
                              ),
                            ),
                          ),
                        );
                      }),
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
