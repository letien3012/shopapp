import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/suppiler/supplier_bloc.dart';
import 'package:luanvan/blocs/suppiler/supplier_event.dart';
import 'package:luanvan/blocs/suppiler/supplier_state.dart';
import 'package:luanvan/models/shop.dart';
import 'package:luanvan/models/supplier.dart';
import 'package:luanvan/ui/helper/icon_helper.dart';
import 'package:luanvan/ui/shop/supplier/add_supplier.dart';
import 'package:luanvan/ui/shop/supplier/edit_supplier.dart';
import 'package:luanvan/ui/widgets/alert_diablog.dart';

class MySupplierScreen extends StatefulWidget {
  const MySupplierScreen({super.key});
  static String routeName = "my_supplier";

  @override
  State<MySupplierScreen> createState() => _MySupplierScreenState();
}

class _MySupplierScreenState extends State<MySupplierScreen> {
  late Shop shop;
  String shopId = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupplierBloc>().add(LoadSuppliers());
    });
  }

  Future<void> _showDeleteSuccessDialog() async {
    await showAlertDialog(
      context,
      message: "Xóa nhà cung cấp thành công",
      iconPath: IconHelper.check,
      duration: Duration(seconds: 1),
    );
  }

  void _editSupplier(Supplier supplier) {
    Navigator.of(context).pushNamed(
      EditSupplierScreen.routeName,
      arguments: supplier,
    );
  }

  Future<void> _deleteSupplier(String supplierId) async {
    context.read<SupplierBloc>().add(DeleteSupplier(supplierId));
    await context
        .read<SupplierBloc>()
        .stream
        .firstWhere((state) => state is SupplierOperationSuccess);
    final supplierState = context.read<SupplierBloc>().state;
    if (supplierState is SupplierOperationSuccess &&
        supplierState.message == 'Xóa nhà cung cấp thành công') {
      context.read<SupplierBloc>().add(LoadSuppliers());
      _showDeleteSuccessDialog();
    }
  }

  Future<void> _updateStatus(Supplier supplier) async {
    context.read<SupplierBloc>().add(UpdateSupplier(supplier));
    await context
        .read<SupplierBloc>()
        .stream
        .firstWhere((state) => state is SupplierOperationSuccess);
    final supplierState = context.read<SupplierBloc>().state;
    if (supplierState is SupplierOperationSuccess &&
        supplierState.message == 'Cập nhật nhà cung cấp thành công') {
      context.read<SupplierBloc>().add(LoadSuppliers());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<SupplierBloc, SupplierState>(
        builder: (context, supplierState) {
          if (supplierState is SupplierLoading) {
            return _buildLoading();
          } else if (supplierState is SupplierLoaded) {
            return _buildSupplierContent(context, supplierState.suppliers);
          } else if (supplierState is SupplierError) {
            return _buildError(supplierState.message);
          }
          return _buildInitializing();
        },
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildError(String message) {
    return Center(child: Text('Error: $message'));
  }

  Widget _buildInitializing() {
    return const Center(child: Text('Đang khởi tạo'));
  }

  Widget _buildSupplierContent(BuildContext context, List<Supplier> suppliers) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height,
            minHeight: MediaQuery.of(context).size.height,
            minWidth: MediaQuery.of(context).size.width,
          ),
          padding: const EdgeInsets.only(top: 90, bottom: 60),
          child: _buildSupplierList(suppliers),
        ),
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
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
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
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 40,
                      child: Text(
                        "Quản lý nhà cung cấp",
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
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 70,
            width: double.infinity,
            color: Colors.white,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(
                  AddSupplierScreen.routeName,
                );
              },
              child: Container(
                margin: const EdgeInsets.all(10),
                height: 50,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.brown,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Thêm nhà cung cấp mới",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSupplierList(List<Supplier> suppliers) {
    if (suppliers.isEmpty) {
      return Center(
        child: Text(
          "Không có nhà cung cấp",
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 90),
      itemCount: suppliers.length,
      itemBuilder: (context, index) {
        final supplier = suppliers[index];
        return Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Nhà cung cấp: ${supplier.name}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Địa chỉ: ${supplier.address}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Số điện thoại: ${supplier.phone}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Email: ${supplier.email}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Text(
                              'Trạng thái: ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Container(
                              height: 30,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                    supplier.status ?? SupplierStatus.inactive),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButton<SupplierStatus>(
                                value:
                                    supplier.status ?? SupplierStatus.inactive,
                                underline: Container(),
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),

                                // dropdownColor: _getStatusColor(
                                //     supplier.status ?? SupplierStatus.active),
                                items: SupplierStatus.values
                                    .map((SupplierStatus status) {
                                  return DropdownMenuItem<SupplierStatus>(
                                    value: status,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(status),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      child: Text(
                                        _getStatusText(status),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (SupplierStatus? newValue) {
                                  if (newValue != null) {
                                    _updateStatus(
                                      supplier.copyWith(
                                        status:
                                            newValue.toString().split('.').last,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const SizedBox(width: 10),
                  _buildActionButton("Sửa", Colors.brown, Colors.white,
                      () => _editSupplier(supplier)),
                  const SizedBox(width: 10),
                  _buildActionButton("Xóa", Colors.red[800]!, Colors.white,
                      () => _deleteSupplier(supplier.id)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton(
      String label, Color bgColor, Color textColor, VoidCallback onTap) {
    return Material(
      color: bgColor,
      child: InkWell(
        splashColor: bgColor.withOpacity(0.2),
        highlightColor: bgColor.withOpacity(0.1),
        onTap: onTap,
        child: Container(
          height: 35,
          width: 80,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: textColor),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(SupplierStatus status) {
    switch (status) {
      case SupplierStatus.active:
        return Colors.green;
      case SupplierStatus.inactive:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(SupplierStatus status) {
    switch (status) {
      case SupplierStatus.active:
        return 'HOẠT ĐỘNG';
      case SupplierStatus.inactive:
        return 'NGỪNG HOẠT ĐỘNG';
      default:
        return '';
    }
  }
}
