import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:luanvan/blocs/suppiler/supplier_bloc.dart';
import 'package:luanvan/blocs/suppiler/supplier_event.dart';
import 'package:luanvan/blocs/suppiler/supplier_state.dart';
import 'package:luanvan/models/supplier.dart';
import 'package:luanvan/ui/helper/icon_helper.dart';
import 'package:luanvan/ui/widgets/alert_diablog.dart';

class AddSupplierScreen extends StatefulWidget {
  const AddSupplierScreen({super.key});
  static String routeName = 'add_supplier';

  @override
  State<AddSupplierScreen> createState() => _AddSupplierScreenState();
}

class _AddSupplierScreenState extends State<AddSupplierScreen> {
  String shopId = '';
  late Supplier supplier;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    supplier = Supplier(id: '', name: '', address: '', phone: '', email: '');
    super.initState();
  }

  Future<void> _showAddSuccessDialog() async {
    await showAlertDialog(
      context,
      message: "Thêm nhà cung cấp thành công",
      iconPath: IconHelper.check,
      duration: Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      supplier.name = _nameController.text;
      supplier.address = _addressController.text;
      supplier.phone = _phoneController.text;
      supplier.email = _emailController.text;
      supplier.isDeleted = false;
      supplier.status = SupplierStatus.active;
      context.read<SupplierBloc>().add(AddSupplier(supplier));
      await context
          .read<SupplierBloc>()
          .stream
          .firstWhere((state) => state is SupplierOperationSuccess);
      final supplierState = context.read<SupplierBloc>().state;
      if (supplierState is SupplierOperationSuccess &&
          supplierState.message == 'Thêm nhà cung cấp thành công') {
        _showAddSuccessDialog();

        context.read<SupplierBloc>().add(LoadSuppliers());

        Future.delayed(Duration(seconds: 1), () {
          Navigator.of(context).pop();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        SingleChildScrollView(
          child: Container(
            color: Colors.grey[100],
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            padding:
                const EdgeInsets.only(top: 90, bottom: 80, left: 10, right: 10),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Row(
                              children: [
                                const Text(
                                  "Tên nhà cung cấp ",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  "*",
                                  style: TextStyle(color: Colors.red),
                                )
                              ],
                            ),
                            const Spacer(),
                            ValueListenableBuilder<TextEditingValue>(
                              valueListenable: _nameController,
                              builder: (context, value, child) {
                                return Text(
                                  "${value.text.length}/50",
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _nameController,
                          maxLength: 50,
                          decoration: const InputDecoration(
                            hintText: "Nhập tên nhà cung cấp",
                            border: InputBorder.none,
                            counterText: '',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Vui lòng nhập tên nhà cung cấp";
                            }

                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Row(
                              children: [
                                const Text(
                                  "Địa chỉ ",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  "*",
                                  style: TextStyle(color: Colors.red),
                                )
                              ],
                            ),
                            const Spacer(),
                            ValueListenableBuilder<TextEditingValue>(
                              valueListenable: _addressController,
                              builder: (context, value, child) {
                                return Text(
                                  "${value.text.length}/120",
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _addressController,
                          maxLength: 120,
                          decoration: const InputDecoration(
                            hintText: "Nhập địa chỉ",
                            border: InputBorder.none,
                            counterText: '',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Vui lòng nhập địa chỉ";
                            }

                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Row(
                              children: [
                                const Text(
                                  "Số điện thoại ",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  "*",
                                  style: TextStyle(color: Colors.red),
                                )
                              ],
                            ),
                            const Spacer(),
                            ValueListenableBuilder<TextEditingValue>(
                              valueListenable: _phoneController,
                              builder: (context, value, child) {
                                return Text(
                                  "${value.text.length}/10",
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _phoneController,
                          maxLength: 10,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            hintText: "Nhập số điện thoại",
                            border: InputBorder.none,
                            counterText: '',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Vui lòng nhập số điện thoại";
                            }
                            if (value.length != 10) {
                              return "Số điện thoại phải có 10 chữ số";
                            }
                            if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                              return "Số điện thoại chỉ được chứa chữ số";
                            }
                            if (!value.startsWith('0')) {
                              return "Số điện thoại phải bắt đầu bằng số 0";
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Row(
                              children: [
                                const Text(
                                  "Email ",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  "*",
                                  style: TextStyle(color: Colors.red),
                                )
                              ],
                            ),
                            const Spacer(),
                            ValueListenableBuilder<TextEditingValue>(
                              valueListenable: _emailController,
                              builder: (context, value, child) {
                                return Text(
                                  "${value.text.length}/30",
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _emailController,
                          maxLength: 30,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: "Nhập email",
                            border: InputBorder.none,
                            counterText: '',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Vui lòng nhập email";
                            }
                            final emailRegex = RegExp(
                              r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
                            );
                            if (!emailRegex.hasMatch(value)) {
                              return "Email không hợp lệ. Ví dụ: example@domain.com";
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // AppBar
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            height: 90,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            padding:
                const EdgeInsets.only(top: 30, left: 10, right: 10, bottom: 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Icon trở về
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(bottom: 5),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.brown,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const SizedBox(
                  height: 40,
                  child: Text(
                    "Thêm nhà cung cấp",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Bottom Appbar
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 70,
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _submitForm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Lưu",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ));
  }
}
