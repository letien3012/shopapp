import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/auth/auth_bloc.dart';
import 'package:luanvan/blocs/auth/auth_event.dart';
import 'package:luanvan/blocs/auth/auth_state.dart';
import 'package:luanvan/blocs/checkPhoneAndEmail/check_bloc.dart';
import 'package:luanvan/blocs/checkPhoneAndEmail/check_event.dart';
import 'package:luanvan/blocs/checkPhoneAndEmail/check_state.dart';
import 'package:luanvan/ui/widgets/alert_diablog.dart';

class ForgotpwScreen extends StatefulWidget {
  const ForgotpwScreen({super.key});
  static String routeName = 'forgotpw_screen';
  @override
  State<ForgotpwScreen> createState() => _ForgotpwScreenState();
}

class _ForgotpwScreenState extends State<ForgotpwScreen> {
  final _emailFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isCheckingEmail = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _showSendPasswordResetEmail(String email) async {
    showAlertDialog(
      context,
      message: 'Kiểm tra email để khôi phục mật khẩu',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<CheckBloc, CheckState>(
        listener: (context, state) {
          if (state is AuthError) {
            setState(() {
              _isCheckingEmail = false;
            });
          }
          if (state is EmailExists) {
            setState(() {
              _isCheckingEmail = false;
            });
            _showSendPasswordResetEmail(_emailController.text);
            context.read<AuthBloc>().add(
                  ForgotPasswordEvent(email: _emailController.text),
                );
          }
          if (state is EmailAvailable) {
            setState(() {
              _isCheckingEmail = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Email này chưa được đăng ký'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading || _isCheckingEmail) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return SingleChildScrollView(
            child: Container(
              color: Colors.white,
              constraints:
                  BoxConstraints(minHeight: MediaQuery.of(context).size.height),
              padding: EdgeInsets.symmetric(vertical: 50, horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 40,
                  ),
                  const Center(
                    child: Text(
                      'Quên mật khẩu',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  const Text(
                    'Nhập email đã đăng ký',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  Form(
                    key: _emailFormKey,
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        hintText: 'Nhập email đã đăng ký',
                        hintStyle: const TextStyle(fontWeight: FontWeight.w300),
                        contentPadding: const EdgeInsets.only(left: 20),
                        errorStyle: const TextStyle(color: Colors.red),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập email';
                        }
                        final emailRegExp = RegExp(
                          r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
                          caseSensitive: false,
                        );
                        if (!emailRegExp.hasMatch(value)) {
                          return 'Email không hợp lệ';
                        }
                        return null;
                      },
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Row(
                    children: [
                      Text(
                        '* ',
                        style: TextStyle(color: Colors.red),
                      ),
                      Text(
                        "Email khôi phục sẽ được gửi qua địa chỉ email đã đăng ký",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: GestureDetector(
                      onTap: () {
                        if (_emailFormKey.currentState!.validate()) {
                          setState(() {
                            _isCheckingEmail = true;
                          });
                          context.read<CheckBloc>().add(
                                CheckEmailEvent(_emailController.text),
                              );
                        }
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          color: _emailController.text.isNotEmpty
                              ? Colors.brown
                              : Colors.grey[300],
                          alignment: Alignment.center,
                          child: Text(
                            'Gửi email xác nhận',
                            style: TextStyle(
                              fontSize: 20,
                              color: _emailController.text.isNotEmpty
                                  ? Colors.white
                                  : Colors.grey,
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
        },
      ),
    );
  }
}
