import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:luanvan/blocs/auth/auth_bloc.dart';
import 'package:luanvan/blocs/auth/auth_state.dart';
import 'package:luanvan/blocs/user/user_bloc.dart';
import 'package:luanvan/blocs/user/user_event.dart';
import 'package:luanvan/blocs/user/user_state.dart';
import 'package:luanvan/models/user_info_model.dart';
import 'package:luanvan/ui/helper/icon_helper.dart';

class ChangeEmail extends StatefulWidget {
  const ChangeEmail({super.key});
  static String routeName = "change_email";

  @override
  State<ChangeEmail> createState() => _ChangeEmailState();
}

class _ChangeEmailState extends State<ChangeEmail> {
  TextEditingController _usernameController = TextEditingController();
  bool _isChange = false;
  String username = '';
  final _formKey = GlobalKey<FormState>();
  String? _emailEror;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        username = ModalRoute.of(context)!.settings.arguments as String;
        _usernameController.text = username;
      });
    });
    _usernameController.addListener(() {
      setState(() {
        _isChange = _usernameController.text != username;
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
    return Scaffold(body: BlocBuilder<UserBloc, UserState>(
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
    ));
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
                      controller: _usernameController,
                      textAlignVertical: TextAlignVertical.center,
                      autofocus: true,
                      maxLength: 100,
                      maxLengthEnforcement: MaxLengthEnforcement.none,
                      showCursor: true,
                      autovalidateMode: AutovalidateMode.disabled,
                      validator: (value) {
                        final RegExp emailRegex = RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        );
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập email';
                        } else if (!emailRegex.hasMatch(value)) {
                          return 'Email không hợp lệ';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          if (value.isEmpty) {
                            _emailEror = 'Vui lòng nhập email';
                          } else {
                            final RegExp emailRegex = RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            );
                            if (!emailRegex.hasMatch(value)) {
                              _emailEror = 'Email không hợp lệ';
                            } else {
                              _emailEror = null;
                            }
                          }
                        });
                      },
                      style: TextStyle(
                        fontSize: 13,
                      ),
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
                                _emailEror != null ? Colors.red : Colors.grey,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        prefixIconConstraints:
                            BoxConstraints(maxHeight: 35, maxWidth: 35),
                        prefixIcon: Container(
                          padding: EdgeInsets.all(5),
                          height: 35,
                          width: 35,
                          child: SvgPicture.asset(
                            IconHelper.mail,
                            fit: BoxFit.cover,
                          ),
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            _usernameController.clear();
                          },
                          child: _usernameController.text.isNotEmpty
                              ? Icon(
                                  Icons.cancel,
                                  size: 20,
                                  color: Colors.grey,
                                )
                              : Text(''),
                        ),
                      ),
                    ),
                    if (_emailEror != null)
                      Padding(
                        padding: EdgeInsets.only(left: 10, top: 4),
                        child: Text(
                          _emailEror!,
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
                  onTap: () {
                    if (_isChange && _formKey.currentState!.validate()) {
                      Navigator.of(context).pop(_usernameController.text);
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
            const Expanded(
              child: Text(
                "Thay đổi Email",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
