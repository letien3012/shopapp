import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/auth/auth_bloc.dart';
import 'package:luanvan/blocs/auth/auth_event.dart';
import 'package:luanvan/blocs/auth/auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import 'package:luanvan/ui/widgets/alert_diablog.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});
  static String routeName = "change_password";

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureOldText = true;
  bool _obscureNewText = true;
  bool _obscureConfirmText = true;
  bool _isOldPasswordVerified = false;
  bool _isVerifyingPassword = false;
  bool _isGoogleSignIn = false;
  bool _isEmailVerified = false;
  Timer? _timer;
  bool _isVerifyingEmail = false;

  @override
  void initState() {
    super.initState();
    _checkSignInMethod();
  }

  Future<void> _checkSignInMethod() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _isEmailVerified = user.emailVerified;
      });

      for (var info in user.providerData) {
        if (info.providerId == 'google.com') {
          setState(() {
            _isGoogleSignIn = true;
          });
          break;
        }
      }

      if (!_isEmailVerified) {
        _timer = Timer.periodic(
          const Duration(seconds: 1),
          (_) => startEmailVerificationCheck(),
        );
      }
    }
  }

  Future<void> _showChangePasswordSuccessDialog() async {
    return showAlertDialog(context, message: "Thay đổi mật khẩu thành công");
  }

  void startEmailVerificationCheck() {
    Timer.periodic(Duration(seconds: 5), (timer) async {
      User? user = FirebaseAuth.instance.currentUser;
      await user?.reload();
      user = FirebaseAuth.instance.currentUser;
      if (user != null && user.emailVerified) {
        print("✅ Email đã xác minh!");
        _isEmailVerified = true;
        _isVerifyingEmail = false;
        timer.cancel(); // Dừng kiểm tra
      } else {
        print("⏳ Chờ người dùng xác minh email...");
      }
    });
  }

  Future<void> _sendVerificationEmail() async {
    setState(() {
      _isVerifyingEmail = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email xác thực đã được gửi'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi gửi email xác thực: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isVerifyingEmail = false;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _verifyOldPassword() {
    if (_oldPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập mật khẩu hiện tại'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isVerifyingPassword = true;
    });

    context.read<AuthBloc>().add(
          VerifyPasswordEvent(
            password: _oldPasswordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            setState(() {
              _isVerifyingPassword = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is PasswordVerified) {
            setState(() {
              _isVerifyingPassword = false;
              _isOldPasswordVerified = true;
            });
          }
          if (state is AuthPasswordChanged) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đổi mật khẩu thành công'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return Stack(
            children: [
              _buildBody(context),
              _buildAppBar(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: 80,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(color: Colors.white),
        padding:
            const EdgeInsets.only(top: 30, left: 10, right: 10, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            const Expanded(
              child: Text(
                "Đổi mật khẩu",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.only(top: 80),
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!_isGoogleSignIn) ...[
                  const Text(
                    'Mật khẩu hiện tại',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _oldPasswordController,
                    obscureText: _obscureOldText,
                    enabled: !_isOldPasswordVerified,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      hintText: 'Nhập mật khẩu hiện tại',
                      hintStyle: const TextStyle(fontWeight: FontWeight.w300),
                      contentPadding: const EdgeInsets.only(left: 20),
                      errorStyle: const TextStyle(color: Colors.red),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isOldPasswordVerified)
                            const Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child:
                                  Icon(Icons.check_circle, color: Colors.green),
                            ),
                          IconButton(
                            icon: Icon(
                              _obscureOldText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureOldText = !_obscureOldText;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu hiện tại';
                      }
                      return null;
                    },
                  ),
                ],
                if (!_isGoogleSignIn && !_isOldPasswordVerified) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed:
                          _isVerifyingPassword ? null : _verifyOldPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isVerifyingPassword
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Xác nhận mật khẩu',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
                if (_isOldPasswordVerified || _isGoogleSignIn) ...[
                  if (!_isEmailVerified) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Xác thực email',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Vui lòng xác thực email của bạn trước khi đổi mật khẩu',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed:
                            _isVerifyingEmail ? null : _sendVerificationEmail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isVerifyingEmail
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'Gửi email xác thực',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    if (_isVerifyingEmail) ...[
                      const SizedBox(height: 20),
                      const Center(
                        child: Text(
                          'Đang chờ xác thực email...',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ],
                  if (_isEmailVerified) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Mật khẩu mới',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: _obscureNewText,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        hintText: 'Nhập mật khẩu mới',
                        hintStyle: const TextStyle(fontWeight: FontWeight.w300),
                        contentPadding: const EdgeInsets.only(left: 20),
                        errorStyle: const TextStyle(color: Colors.red),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureNewText
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureNewText = !_obscureNewText;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập mật khẩu mới';
                        }
                        if (value.length < 8) {
                          return 'Mật khẩu phải có ít nhất 8 ký tự';
                        }
                        if (!RegExp(r'[A-Z]').hasMatch(value)) {
                          return 'Mật khẩu phải chứa ít nhất một chữ hoa (A-Z)';
                        }
                        if (!RegExp(r'[a-z]').hasMatch(value)) {
                          return 'Mật khẩu phải chứa ít nhất một chữ thường (a-z)';
                        }
                        if (!RegExp(r'[0-9]').hasMatch(value)) {
                          return 'Mật khẩu phải chứa ít nhất một số (0-9)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Xác nhận mật khẩu mới',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmText,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        hintText: 'Nhập lại mật khẩu mới',
                        hintStyle: const TextStyle(fontWeight: FontWeight.w300),
                        contentPadding: const EdgeInsets.only(left: 20),
                        errorStyle: const TextStyle(color: Colors.red),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmText
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmText = !_obscureConfirmText;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập lại mật khẩu mới';
                        }
                        if (value != _newPasswordController.text) {
                          return 'Mật khẩu không khớp';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: GestureDetector(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            color: Colors.brown,
                            alignment: Alignment.center,
                            child: const Text(
                              'Xác nhận',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthBloc>().add(
                                  ChangePasswordEvent(
                                    oldPassword: _isGoogleSignIn
                                        ? ''
                                        : _oldPasswordController.text,
                                    newPassword: _newPasswordController.text,
                                  ),
                                );
                            await context.read<AuthBloc>().stream.firstWhere(
                                (element) => element is AuthAuthenticated);
                            await _showChangePasswordSuccessDialog();
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
