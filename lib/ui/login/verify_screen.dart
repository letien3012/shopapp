import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/auth/auth_bloc.dart';
import 'package:luanvan/blocs/auth/auth_event.dart';
import 'package:luanvan/blocs/auth/auth_state.dart';
import 'package:luanvan/ui/login/create_password_screen.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});
  static String routeName = 'verify_screen';

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _code2Controller = TextEditingController();
  final TextEditingController _code3Controller = TextEditingController();
  final TextEditingController _code4Controller = TextEditingController();
  final TextEditingController _code5Controller = TextEditingController();
  final TextEditingController _code6Controller = TextEditingController();

  final FocusNode _codeFocus = FocusNode();
  final FocusNode _code2Focus = FocusNode();
  final FocusNode _code3Focus = FocusNode();
  final FocusNode _code4Focus = FocusNode();
  final FocusNode _code5Focus = FocusNode();
  final FocusNode _code6Focus = FocusNode();

  @override
  void dispose() {
    _codeController.dispose();
    _code2Controller.dispose();
    _code3Controller.dispose();
    _code4Controller.dispose();
    _code5Controller.dispose();
    _code6Controller.dispose();
    _codeFocus.dispose();
    _code2Focus.dispose();
    _code3Focus.dispose();
    _code4Focus.dispose();
    _code5Focus.dispose();
    _code6Focus.dispose();
    super.dispose();
  }

  void _handleCodeInput(String value, FocusNode nextFocus) {
    if (value.length == 1) {
      nextFocus.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác thực email'),
        backgroundColor: Colors.brown,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthEmailVerified) {
            Navigator.of(context).pushNamed(CreatePasswordScreen.routeName);
          }
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nhập mã xác thực',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Vui lòng nhập mã xác thực đã được gửi đến email của bạn',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 45,
                          child: TextFormField(
                            controller: _codeController,
                            focusNode: _codeFocus,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              counterText: '',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) =>
                                _handleCodeInput(value, _code2Focus),
                          ),
                        ),
                        SizedBox(
                          width: 45,
                          child: TextFormField(
                            controller: _code2Controller,
                            focusNode: _code2Focus,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              counterText: '',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) =>
                                _handleCodeInput(value, _code3Focus),
                          ),
                        ),
                        SizedBox(
                          width: 45,
                          child: TextFormField(
                            controller: _code3Controller,
                            focusNode: _code3Focus,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              counterText: '',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) =>
                                _handleCodeInput(value, _code4Focus),
                          ),
                        ),
                        SizedBox(
                          width: 45,
                          child: TextFormField(
                            controller: _code4Controller,
                            focusNode: _code4Focus,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              counterText: '',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) =>
                                _handleCodeInput(value, _code5Focus),
                          ),
                        ),
                        SizedBox(
                          width: 45,
                          child: TextFormField(
                            controller: _code5Controller,
                            focusNode: _code5Focus,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              counterText: '',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) =>
                                _handleCodeInput(value, _code6Focus),
                          ),
                        ),
                        SizedBox(
                          width: 45,
                          child: TextFormField(
                            controller: _code6Controller,
                            focusNode: _code6Focus,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              counterText: '',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          final code = _codeController.text +
                              _code2Controller.text +
                              _code3Controller.text +
                              _code4Controller.text +
                              _code5Controller.text +
                              _code6Controller.text;

                          if (code.length == 6) {
                            context.read<AuthBloc>().add(
                                  VerifyEmailEvent(
                                    'verification_id', // TODO: Get from AuthBloc
                                    code,
                                  ),
                                );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Vui lòng nhập đủ 6 chữ số'),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Xác nhận',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
