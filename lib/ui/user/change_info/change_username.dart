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

class ChangeUsername extends StatefulWidget {
  const ChangeUsername({super.key});
  static String routeName = "change_username";

  @override
  State<ChangeUsername> createState() => _ChangeUsernameState();
}

class _ChangeUsernameState extends State<ChangeUsername> {
  TextEditingController _usernameController = TextEditingController();
  bool _isChange = false;
  String username = '';
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
              child: TextFormField(
                controller: _usernameController,
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
                  prefixIconConstraints:
                      BoxConstraints(maxHeight: 35, maxWidth: 35),
                  prefixIcon: Container(
                    padding: EdgeInsets.all(5),
                    height: 35,
                    width: 35,
                    child: SvgPicture.asset(
                      IconHelper.userOutlineIcon,
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
            ),
            Container(
              height: 45,
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Material(
                color: Colors.brown,
                child: InkWell(
                  splashColor: Colors.transparent.withOpacity(0.2),
                  highlightColor: Colors.transparent.withOpacity(0.1),
                  onTap: () {
                    if (_isChange) {
                      context.read<UserBloc>().add(UpdateUserNameEvent(
                          _usernameController.text, userState.user.id));
                    }
                    Navigator.of(context).pop(_usernameController.text);
                  },
                  child: Center(
                    child: Text(
                      "Lưu",
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
                "Tên đăng nhập",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
