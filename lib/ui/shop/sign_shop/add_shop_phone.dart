import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:luanvan/blocs/checkPhoneAndEmail/check_bloc.dart';
import 'package:luanvan/blocs/checkPhoneAndEmail/check_event.dart';
import 'package:luanvan/blocs/checkPhoneAndEmail/check_state.dart';
import 'package:luanvan/blocs/user/user_bloc.dart';
import 'package:luanvan/blocs/user/user_state.dart';
import 'package:luanvan/ui/helper/icon_helper.dart';
import 'package:luanvan/ui/widgets/confirm_diablog.dart';

class AddShopPhone extends StatefulWidget {
  const AddShopPhone({super.key});
  static String routeName = "add_shop_phone";

  @override
  State<AddShopPhone> createState() => _AddShopPhoneState();
}

class _AddShopPhoneState extends State<AddShopPhone> {
  TextEditingController _phoneController = TextEditingController();
  bool _isChange = false;
  String phone = '';
  final _formKey = GlobalKey<FormState>();
  String? _phoneError;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        phone = ModalRoute.of(context)!.settings.arguments as String;
        _phoneController.text = phone;
      });
    });
    _phoneController.addListener(() {
      setState(() {
        _isChange = _phoneController.text != phone;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: () async {
      if (_isChange) {
        return await _showConfirmDialog();
      }
      return true;
    }, child: Scaffold(body: BlocBuilder<UserBloc, UserState>(
      builder: (context, userState) {
        if (userState is UserLoading) {
          return _buildLoading();
        } else if (userState is UserLoaded) {
          return _buildContent(context, userState);
        } else if (userState is UserError) {
          return _buildError(userState.message);
        }
        return _buildInitializing();
      },
    )));
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
    return const Center(child: Text('Initializing...'));
  }

  // Nội dung chính
  Widget _buildContent(BuildContext context, UserLoaded userState) {
    return Stack(
      children: [
        _buildBody(context, userState),
        _buildAppBar(context),
      ],
    );
  }

  // Phần body với thông tin người dùng
  Widget _buildBody(BuildContext context, UserLoaded userState) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.only(top: 80),
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        color: Colors.white,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  border: Border(
                top: BorderSide(width: 0.1, color: Colors.grey),
                bottom: BorderSide(width: 0.1, color: Colors.grey),
              )),
              height: 5,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              height: 80,
              color: Colors.white,
              alignment: Alignment.centerLeft,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _phoneController,
                      textAlignVertical: TextAlignVertical.center,
                      autofocus: true,
                      maxLength: 100,
                      maxLengthEnforcement: MaxLengthEnforcement.none,
                      showCursor: true,
                      autovalidateMode: AutovalidateMode.disabled,
                      onChanged: (value) {
                        setState(() {
                          if (value.isEmpty) {
                            _phoneError = 'Vui lòng nhập số điện thoại';
                          } else {
                            final RegExp vietnamPhoneRegExp = RegExp(
                              r'^0(3[2-9]|5[6-9]|7[0|6-9]|8[1-9]|9[0-9])[0-9]{7}$',
                            );
                            if (!vietnamPhoneRegExp.hasMatch(value) ||
                                value.length != 10) {
                              _phoneError = 'Số điện thoại không hợp lệ';
                            } else {
                              _phoneError = null;
                            }
                          }
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập số điện thoại';
                        }
                        final RegExp vietnamPhoneRegExp = RegExp(
                          r'^0(3[2-9]|5[6-9]|7[0|6-9]|8[1-9]|9[0-9])[0-9]{7}$',
                        );
                        if (!vietnamPhoneRegExp.hasMatch(value) ||
                            value.length != 10) {
                          return 'Số điện thoại không hợp lệ';
                        }
                        return null;
                      },
                      style: TextStyle(
                        fontSize: 13,
                      ),
                      keyboardType: TextInputType.numberWithOptions(),
                      decoration: InputDecoration(
                        counterText: '',
                        errorStyle: TextStyle(
                          height: 0,
                          fontSize: 0,
                          color: Colors.transparent,
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            width: 1,
                            color: Colors.grey,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            width: 1,
                            color: Colors.grey,
                          ),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            width: 1,
                            color:
                                _phoneError != null ? Colors.red : Colors.grey,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        prefixIconConstraints:
                            BoxConstraints(maxHeight: 35, maxWidth: 40),
                        prefixIcon: Align(
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            IconHelper.phone,
                            height: 25,
                            width: 25,
                            fit: BoxFit.cover,
                          ),
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            _phoneController.clear();
                            setState(() {
                              _phoneError = 'Vui lòng nhập số điện thoại';
                            });
                          },
                          child: _phoneController.text.isNotEmpty
                              ? Icon(
                                  Icons.cancel,
                                  size: 20,
                                  color: Colors.grey,
                                )
                              : Text(''),
                        ),
                      ),
                    ),
                    if (_phoneError != null)
                      Padding(
                        padding: EdgeInsets.only(left: 10, top: 4),
                        child: Text(
                          _phoneError!,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Container(
              height: 45,
              margin: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              child: Material(
                color: Colors.brown,
                child: InkWell(
                  splashColor: Colors.transparent.withOpacity(0.2),
                  highlightColor: Colors.transparent.withOpacity(0.1),
                  onTap: () async {
                    if (_formKey.currentState!.validate()) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: Colors.brown,
                            ),
                          );
                        },
                      );

                      final phoneExists =
                          await _checkPhoneExists(_phoneController.text);

                      Navigator.of(context).pop();

                      if (phoneExists) {
                        await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Lỗi'),
                              content: Text('Số điện thoại đã được sử dụng'),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('OK')),
                              ],
                            );
                          },
                        );
                      } else {
                        Navigator.of(context).pop(_phoneController.text);
                      }
                    }
                  },
                  child: Center(
                    child: Text(
                      "Tiếp theo",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight:
                            _isChange ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // AppBar
  Widget _buildAppBar(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: AnimatedContainer(
        height: 80,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(color: Colors.white),
        padding:
            const EdgeInsets.only(top: 30, left: 10, right: 10, bottom: 10),
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () async {
                if (_isChange) {
                  final shouldPop = await _showConfirmDialog();
                  if (shouldPop) {
                    Navigator.of(context).pop();
                  }
                } else {
                  Navigator.of(context).pop();
                }
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
            const Expanded(
              child: Text(
                "Thêm số điện thoại",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Thêm method hiển thị dialog xác nhận
  Future<bool> _showConfirmDialog() async {
    final confirmed = await ConfirmDialog(
      title: "Bạn có chắc muốn hủy thay đổi số điện thoại?",
    ).show(context);
    return confirmed;
  }

  // Thêm phương thức kiểm tra số điện thoại
  Future<bool> _checkPhoneExists(String phone) async {
    try {
      context.read<CheckBloc>().add(CheckPhoneNumberEvent(phone));

      bool exists = await Future.any([
        context.read<CheckBloc>().stream.firstWhere((state) {
          if (state is PhoneNumberExists) {
            return true;
          } else if (state is PhoneNumberAvailable) {
            return true;
          }
          return false;
        }).then((state) => state is PhoneNumberExists),
        Future.delayed(Duration(seconds: 10)).then((_) {
          throw Exception('Timeout');
        }),
      ]);

      return exists;
    } catch (e) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Lỗi'),
            content: Text('Đã xảy ra lỗi khi kiểm tra số điện thoại'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK')),
            ],
          );
        },
      );
      return false;
    }
  }
}
