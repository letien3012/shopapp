import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:luanvan/blocs/user/user_bloc.dart';
import 'package:luanvan/blocs/user/user_event.dart';
import 'package:luanvan/blocs/user/user_state.dart';
import 'package:luanvan/models/address.dart';
import 'package:luanvan/models/shipping_method.dart';
import 'package:luanvan/models/shop.dart';
import 'package:luanvan/models/user_info_model.dart';
import 'package:luanvan/ui/helper/icon_helper.dart';
import 'package:luanvan/ui/shop/sign_shop/add_location_sign_shop_screen.dart';
import 'package:luanvan/ui/shop/shop_manager/my_shop_screen.dart';
import 'package:luanvan/ui/shop/sign_shop/add_shop_phone.dart';
import 'package:luanvan/ui/shop/sign_shop/ship_setting_screen.dart';
import 'package:luanvan/ui/user/change_info/change_email.dart';
import 'package:luanvan/ui/user/change_info/change_phone.dart';

class SignShop extends StatefulWidget {
  const SignShop({super.key});
  static String routeName = 'sign_shop';

  @override
  State<SignShop> createState() => _SignShopState();
}

class _SignShopState extends State<SignShop> {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  String avatarUrl = '';
  String userId = '';
  String default_background =
      'https://res.cloudinary.com/deegjkzbd/image/upload/v1743300824/background_defaults_hdasjj.jpg';
  late Address address = Address(
    addressLine: '',
    city: '',
    district: '',
    ward: '',
    isDefault: true,
    receiverName: '',
    receiverPhone: '',
  );
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _shopNameController = TextEditingController();

  // Quản lý hai tham số vận chuyển
  bool isFastEnabled = false;
  bool isEconomyEnabled = false;
  bool isExpress = false;
  bool isCompleted = false; // Trạng thái hoàn thành
  bool isRegisCompelete = false;
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

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      // Kiểm tra Trang 0
      if (_currentStep == 0) {
        if (_shopNameController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Vui lòng nhập tên shop")),
          );
          return;
        }
        if (_addressController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Vui lòng nhập địa chỉ lấy hàng")),
          );
          return;
        }
        if (_emailController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Vui lòng nhập email")),
          );
          return;
        }
        if (_phoneController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Vui lòng nhập số điện thoại")),
          );
          return;
        }
      }

      // Kiểm tra Trang 1
      if (_currentStep == 1 && !isCompleted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text("Vui lòng kích hoạt ít nhất 01 phương thức vận chuyển"),
          ),
        );
        return;
      }

      if (_currentStep < 2) {
        setState(() => _currentStep++);
        _pageController.nextPage(
            duration: Duration(milliseconds: 300), curve: Curves.ease);
      } else {
        _submitForm();
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    }
  }

  void _submitForm() async {
    final Shop sellerRegistrationModel = Shop(
      userId: userId,
      name: _shopNameController.text,
      addresses: [],
      phoneNumber: _phoneController.text,
      email: _emailController.text,
      backgroundImageUrl: default_background,
      avatarUrl: avatarUrl,
      submittedAt: DateTime.now(),
      isClose: false,
      isLocked: false,
      shippingMethods: [],
    );
    sellerRegistrationModel.shippingMethods
        .addAll(ShippingMethod.defaultMethods);
    if (isEconomyEnabled) {
      sellerRegistrationModel.shippingMethods[0].isEnabled = isEconomyEnabled;
    }
    if (isFastEnabled) {
      sellerRegistrationModel.shippingMethods[1].isEnabled = isFastEnabled;
    }
    if (isExpress) {
      sellerRegistrationModel.shippingMethods[2].isEnabled = isExpress;
    }
    sellerRegistrationModel.addresses.add(address);
    context
        .read<UserBloc>()
        .add(RegistrationSellerEvent(sellerRegistrationModel));

    setState(() {
      isRegisCompelete = true;
    });
  }

  @override
  void initState() {
    super.initState();
    isCompleted = isFastEnabled || isEconomyEnabled;
    final userBloc = BlocProvider.of<UserBloc>(context, listen: false);
    if (userBloc.state is UserLoaded) {
      final user = (userBloc.state as UserLoaded).user;
      _shopNameController.text = user.userName!.replaceFirst("(changed)", "");
      if (user.phone != null && _phoneController.text.isEmpty) {
        _phoneController.text = user.phone!;
      }
      _emailController.text = user.email ?? '';
      userId = user.id;
      avatarUrl = user.avataUrl!;
    }
    isCompleted = isFastEnabled || isEconomyEnabled;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _shopNameController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: isRegisCompelete ? null : _showExitConfirmationDialog,
      child: BlocBuilder<UserBloc, UserState>(
        builder: (context, userState) {
          if (userState is UserLoading) {
            return _buildLoading();
          } else if (userState is UserLoaded) {
            return isRegisCompelete
                ? _buidRegisSuccess(context, userState.user)
                : _buildContent(context, userState.user);
          } else if (userState is UserError) {
            return _buildError(userState.message);
          }
          return _buildInitializing();
        },
      ),
    );
  }

  // Trạng thái đang tải
  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  // Trạng thái lỗi
  Widget _buildError(String message) {
    return Center(child: Text('Error: $message'));
  }

  // Trạng thái khởi tạo
  Widget _buildInitializing() {
    return const Center(child: Text('Đang khởi tạo'));
  }

  Widget _buidRegisSuccess(BuildContext context, UserInfoModel user) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
                minWidth: MediaQuery.of(context).size.width,
              ),
              padding: const EdgeInsets.only(top: 90, bottom: 60),
              child: Column(
                children: [
                  Container(
                    height: 5,
                    color: Colors.grey[200],
                  ),
                  SizedBox(
                    height: 160,
                  ),
                  SvgPicture.asset(
                    IconHelper.check,
                    height: 80,
                    width: 80,
                    color: Colors.green[600],
                  ),
                  Text(
                    "Đăng ký thành công",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    width: 220,
                    child: Text(
                      "Hãy đăng bán sản phẩm đầu tiên để khởi động hành trình",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.of(context)
                          .pushNamed(MyShopScreen.routeName, arguments: user);
                    },
                    child: Container(
                      margin: EdgeInsets.all(10),
                      height: 50,
                      width: 250,
                      color: Colors.brown,
                      alignment: Alignment.center,
                      child: Text(
                        "Đến shop của tôi",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          // AppBar
          Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                Container(
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
                      //Icon trở về
                      GestureDetector(
                        onTap: () async {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          height: 40,
                          width: 40,
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(bottom: 5),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.brown,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        height: 40,
                        child: Text(
                          "Đăng ký trở thành người bán",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, UserInfoModel user) {
    user.email != null ? _emailController.text = user.email! : null;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.only(top: 90, bottom: 60),
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
                minWidth: MediaQuery.of(context).size.width,
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height - 90,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: SizedBox(
                                height: 60,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Đường gạch ngang với 2 màu
                                    Positioned(
                                      top: 10,
                                      left: 20,
                                      right: 20,
                                      child: Row(
                                        children: List.generate(1, (index) {
                                          return Expanded(
                                            child: Container(
                                              margin:
                                                  EdgeInsets.only(bottom: 10),
                                              height: 2,
                                              color: _currentStep > index
                                                  ? Colors.brown
                                                  : Colors.grey,
                                            ),
                                          );
                                        }),
                                      ),
                                    ),

                                    // Các bước (Start - Center - End)
                                    Align(
                                      alignment: Alignment.topCenter,
                                      child: Row(
                                        children: [
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          Expanded(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children:
                                                  List.generate(2, (index) {
                                                bool isCompleted =
                                                    _currentStep > index;
                                                bool isActive =
                                                    _currentStep == index;

                                                return CircleAvatar(
                                                  radius: 12,
                                                  backgroundColor:
                                                      (isActive || isCompleted)
                                                          ? Colors.brown
                                                          : Colors.grey,
                                                  child: CircleAvatar(
                                                    radius: 10,
                                                    backgroundColor: isCompleted
                                                        ? Colors.brown
                                                        : Colors.white,
                                                    child: isCompleted
                                                        ? Icon(Icons.check,
                                                            color: Colors.white,
                                                            size: 15)
                                                        : null,
                                                  ),
                                                );
                                              }),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        const SizedBox(
                                          height: 30,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Thông tin shop",
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.brown,
                                              ),
                                            ),
                                            Text(
                                              "Cài đặt vận chuyển",
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.brown,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Nội dung từng bước
                          Expanded(
                            child: PageView(
                              controller: _pageController,
                              physics: NeverScrollableScrollPhysics(),
                              children: [
                                Container(
                                  color: Colors.grey[200],
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        color: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text("Tên Shop",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Text(" *",
                                                    style: TextStyle(
                                                        color: Colors.red)),
                                                Spacer(),
                                                Text(
                                                    "${_shopNameController.text.length}/30",
                                                    style: TextStyle(
                                                        color: Colors.grey)),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 40,
                                              child: TextFormField(
                                                controller: _shopNameController,
                                                onChanged: (value) {
                                                  setState(() {});
                                                },
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Vui lòng nhập tên shop';
                                                  }
                                                  return null;
                                                },
                                                maxLength: 30,
                                                maxLengthEnforcement:
                                                    MaxLengthEnforcement.none,
                                                decoration: InputDecoration(
                                                  counterText: '',
                                                  border: InputBorder.none,
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 8),
                                                  errorStyle: TextStyle(
                                                      color: Colors.red),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      _buildAddressItem("Địa chỉ lấy hàng",
                                          _addressController.text),
                                      _buildEmailItem(
                                          "Email", _emailController.text),
                                      _buildPhoneItem("Số điện thoại",
                                          _phoneController.text),
                                      Expanded(
                                          child: Container(
                                        color: Colors.grey[200],
                                      ))
                                    ],
                                  ),
                                ),
                                Container(
                                  height: double.infinity,
                                  color: Colors.grey[200],
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        color: Colors.white,
                                        margin: EdgeInsets.all(8),
                                        padding: EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            // Tiêu đề
                                            Text(
                                              "Cài đặt vận chuyển",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 8),

                                            // Nội dung mô tả
                                            Text(
                                              "Vui lòng kích hoạt ít nhất 01 Phương thức vận chuyển",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            SizedBox(height: 16),

                                            // Nút bấm thay đổi trạng thái
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                // Icon trạng thái
                                                Icon(
                                                  isCompleted
                                                      ? Icons.check_circle
                                                      : Icons.access_time,
                                                  color: isCompleted
                                                      ? Colors.green
                                                      : Colors.grey,
                                                ),
                                                GestureDetector(
                                                  onTap: () async {
                                                    final result =
                                                        await Navigator
                                                            .pushNamed(
                                                      context,
                                                      ShipSettingScreen
                                                          .routeName,
                                                      arguments: {
                                                        'isFastEnabled':
                                                            isFastEnabled,
                                                        'isEconomyEnabled':
                                                            isEconomyEnabled,
                                                        'isExpress': isExpress,
                                                      },
                                                    );
                                                    if (result != null &&
                                                        result is Map) {
                                                      setState(() {
                                                        isFastEnabled = result[
                                                                'isFastEnabled'] ??
                                                            false;
                                                        isEconomyEnabled = result[
                                                                'isEconomyEnabled'] ??
                                                            false;
                                                        isExpress = result[
                                                                'isExpress'] ??
                                                            false;
                                                        isCompleted =
                                                            isFastEnabled ||
                                                                isEconomyEnabled ||
                                                                isExpress;
                                                      });
                                                    }
                                                  },
                                                  child: Container(
                                                    height: 35,
                                                    width: 120,
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                        color: isCompleted
                                                            ? Colors.white
                                                            : Colors.brown,
                                                        border: isCompleted
                                                            ? Border.all(
                                                                width: 1,
                                                                color: Colors
                                                                    .brown)
                                                            : null),
                                                    child: Text(
                                                      !isCompleted
                                                          ? "Đang thực hiện"
                                                          : "Xem chi tiết",
                                                      style: TextStyle(
                                                          color: isCompleted
                                                              ? Colors.brown
                                                              : Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                          child: Container(
                                        color: Colors.grey[200],
                                      ))
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border(
                                          top: BorderSide(
                                        width: 5,
                                        color: Colors.grey[200]!,
                                      )),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, bottom: 10, left: 10),
                                      child: Material(
                                        color: Colors.white,
                                        child: InkWell(
                                          onTap: () {
                                            if (_currentStep > 0)
                                              _previousStep();
                                          },
                                          highlightColor: Colors.transparent
                                              .withOpacity(0.1),
                                          splashColor: Colors.transparent
                                              .withOpacity(0.2),
                                          child: Container(
                                            height: 40,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                width: 1,
                                                color: _currentStep == 0
                                                    ? Colors.grey
                                                    : Colors.brown,
                                              ),
                                            ),
                                            padding: EdgeInsets.all(10),
                                            child: Text(
                                              "Quay lại",
                                              style: TextStyle(
                                                color: Colors.brown,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border(
                                          top: BorderSide(
                                        width: 5,
                                        color: Colors.grey[200]!,
                                      )),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10,
                                          bottom: 10,
                                          left: 10,
                                          right: 10),
                                      child: Material(
                                        color: Colors.brown,
                                        child: InkWell(
                                          onTap: () {
                                            if (_currentStep < 3) _nextStep();
                                          },
                                          highlightColor: Colors.transparent
                                              .withOpacity(0.1),
                                          splashColor: Colors.transparent
                                              .withOpacity(0.2),
                                          child: Container(
                                            height: 20,
                                            alignment: Alignment.center,
                                            margin: EdgeInsets.all(10),
                                            child: Text(
                                              _currentStep >= 1
                                                  ? "Hoàn thành"
                                                  : "Tiếp theo",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
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
          // AppBar
          Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                Container(
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
                      //Icon trở về
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
                          margin: EdgeInsets.only(bottom: 5),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.brown,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        height: 40,
                        child: Text(
                          _currentStep == 0
                              ? "Thông tin shop"
                              : "Cài đặt vận chuyển",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressItem(String title, String value) {
    return Material(
      color: Colors.white,
      child: InkWell(
        splashColor: Colors.grey.withOpacity(0.3),
        highlightColor: Colors.grey.withOpacity(0.1),
        onTap: () async {
          final result = await Navigator.of(context).pushNamed(
              AddLocationShopSignShopScreen.routeName,
              arguments: address) as Address;
          if (mounted) {
            setState(() {
              address = result;
              print(result);
              _addressController.text =
                  "${result.addressLine}, ${result.ward}, ${result.district}, ${result.city}";
            });
          }
        },
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          width: double.infinity,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(width: 0.2, color: Colors.grey)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(" *", style: TextStyle(color: Colors.red)),
                ],
              ),
              value.isEmpty
                  ? SizedBox()
                  : const SizedBox(
                      width: 20,
                    ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        textAlign: TextAlign.end,
                        value.isNotEmpty ? value : "Thiết lập ngay",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: value.isEmpty ? Colors.grey : Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailItem(String title, String value) {
    return Material(
      color: Colors.white,
      child: InkWell(
        splashColor: Colors.grey.withOpacity(0.3),
        highlightColor: Colors.grey.withOpacity(0.1),
        onTap: () async {
          final newName = await Navigator.pushNamed(
            context,
            ChangeEmail.routeName,
            arguments: value,
          );

          if (newName != null) {
            setState(() {
              _emailController.text = newName as String;
              if (_emailController.text != value) {
                setState(() {});
              }
            });
          }
        },
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          width: double.infinity,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(width: 0.2, color: Colors.grey)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(" *", style: TextStyle(color: Colors.red)),
                ],
              ),
              Row(
                children: [
                  Text(
                    value.isNotEmpty ? value : "Thiết lập ngay",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: value.isEmpty ? Colors.grey : Colors.black,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneItem(String title, String value) {
    return Material(
      color: Colors.white,
      child: InkWell(
        splashColor: Colors.grey.withOpacity(0.3),
        highlightColor: Colors.grey.withOpacity(0.1),
        onTap: () async {
          final newPhone = await Navigator.pushNamed(
            context,
            AddShopPhone.routeName,
            arguments: value,
          );

          if (newPhone != null) {
            setState(() {
              // _phoneController.text = newPhone as String;
              setState(() {
                _phoneController.text = newPhone as String;
              });
            });
          }
        },
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          width: double.infinity,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(width: 0.2, color: Colors.grey)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(" *", style: TextStyle(color: Colors.red)),
                ],
              ),
              Row(
                children: [
                  Text(
                    value.isNotEmpty ? value : "Thiết lập ngay",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: value.isEmpty ? Colors.grey : Colors.black,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
