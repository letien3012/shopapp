import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:luanvan/blocs/auth/auth_bloc.dart';
import 'package:luanvan/blocs/auth/auth_state.dart';
import 'package:luanvan/blocs/user/user_bloc.dart';
import 'package:luanvan/blocs/user/user_event.dart';
import 'package:luanvan/blocs/user/user_state.dart';
import 'package:luanvan/models/user_info_model.dart';

class ChangeName extends StatefulWidget {
  const ChangeName({super.key});
  static String routeName = "change_name";

  @override
  State<ChangeName> createState() => _ChangeNameState();
}

class _ChangeNameState extends State<ChangeName> {
  TextEditingController _nameController = TextEditingController();
  bool _isChange = false;
  String name = '';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        name = ModalRoute.of(context)!.settings.arguments as String;
        _nameController.text = name;
      });
    });
    _nameController.addListener(() {
      setState(() {
        _isChange = _nameController.text != name;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<bool> _showExitConfirmationDialog() async {
    return await showDialog(
          context: context,
          barrierDismissible: false, // Người dùng phải chọn 1 trong 2 nút
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
        false; // Mặc định không thoát nếu hộp thoại bị đóng mà không chọn
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isChange,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        if (_isChange) {
          bool shouldExit = await _showExitConfirmationDialog();
          if (shouldExit) {
            Navigator.of(context).pop();
          }
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(body: BlocBuilder<UserBloc, UserState>(
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
      )),
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
        color: Colors.grey[200],
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
              height: 50,
              color: Colors.white,
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () {},
                child: TextFormField(
                  controller: _nameController,
                  textAlignVertical: TextAlignVertical.center,
                  autofocus: true,
                  maxLength: 100,
                  maxLengthEnforcement: MaxLengthEnforcement.none,
                  showCursor: true,
                  style: TextStyle(
                    fontSize: 13,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        _nameController.clear();
                      },
                      child: _nameController.text.isNotEmpty
                          ? Icon(
                              Icons.cancel,
                              size: 20,
                              color: Colors.grey,
                            )
                          : Text(''),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10, left: 10),
              alignment: Alignment.topLeft,
              child: Text(
                "Tối đa 100 ký tự",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            )
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
                  bool shouldExit = await _showExitConfirmationDialog();
                  if (shouldExit) {
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
                "Sửa hồ sơ",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (_isChange) {
                  Navigator.of(context).pop(_nameController.text);
                }
              },
              child: Container(
                height: 40,
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  "Lưu",
                  style: TextStyle(
                    fontSize: 14,
                    color: _isChange ? Colors.brown : Colors.grey,
                    fontWeight: _isChange ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
