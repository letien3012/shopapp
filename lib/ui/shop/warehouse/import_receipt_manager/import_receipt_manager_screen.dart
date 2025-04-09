import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/import_receipt/import_receipt_bloc.dart';
import 'package:luanvan/blocs/import_receipt/import_receipt_event.dart';
import 'package:luanvan/blocs/import_receipt/import_receipt_state.dart';
import 'package:luanvan/models/import_item.dart';
import 'package:luanvan/models/import_receipt.dart';
import 'package:luanvan/models/supplier.dart';
import 'package:luanvan/ui/helper/icon_helper.dart';
import 'package:luanvan/ui/shop/product_manager/add_product_screen.dart';

import 'package:luanvan/ui/widgets/alert_diablog.dart';
import 'package:luanvan/ui/shop/warehouse/edit_stock_detail_screen.dart';

class ImportReceiptManagerScreen extends StatefulWidget {
  const ImportReceiptManagerScreen({super.key});
  static String routeName = "import_receipt_manager";

  @override
  State<ImportReceiptManagerScreen> createState() =>
      _ImportReceiptManagerScreenState();
}

class _ImportReceiptManagerScreenState extends State<ImportReceiptManagerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<ImportReceipt> pendingImportReceipts = [];
  List<ImportReceipt> completedImportReceipts = [];
  List<ImportReceipt> cancelledImportReceipts = [];
  Future<void> _showAlertDialog() async {
    await showAlertDialog(
      context,
      message: "Bạn chưa chọn sản phẩm nào để tạo phiếu nhập hàng",
      iconPath: IconHelper.warning,
      duration: Duration(seconds: 1),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ImportReceiptBloc>().add(LoadImportReceipts());
    });

    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ImportReceiptBloc, ImportReceiptState>(
        builder: (context, importReceiptState) {
          if (importReceiptState is ImportReceiptLoading) {
            return _buildLoading();
          } else if (importReceiptState is ImportReceiptsLoaded) {
            pendingImportReceipts = [];
            completedImportReceipts = [];
            cancelledImportReceipts = [];
            return _buildShopContent(context, importReceiptState.receipts);
          } else if (importReceiptState is ImportReceiptError) {
            return _buildError(importReceiptState.message);
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

  Widget _buildShopContent(
      BuildContext context, List<ImportReceipt> listImportReceipt) {
    // Filter products based on search query

    for (var importReceipt in listImportReceipt) {
      if (importReceipt.status == ImportReceiptStatus.pending) {
        pendingImportReceipts.add(importReceipt);
      } else if (importReceipt.status == ImportReceiptStatus.completed) {
        completedImportReceipts.add(importReceipt);
      } else if (importReceipt.status == ImportReceiptStatus.cancelled) {
        cancelledImportReceipts.add(importReceipt);
      }
    }

    return Column(
      children: [
        // Header
        Container(
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
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 40,
                child: Text(
                  "Kho hàng của tôi",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),

        // TabBar
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.brown,
            labelStyle: TextStyle(fontSize: 13),
            tabs: [
              Tab(text: 'Đang chờ xử lý (${pendingImportReceipts.length})'),
              Tab(text: 'Đã hoàn thành (${completedImportReceipts.length})'),
              Tab(text: 'Đã hủy (${cancelledImportReceipts.length})'),
            ],
          ),
        ),
        // TabBarView
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildImportReceiptList(pendingImportReceipts),
              completedImportReceipts.isEmpty
                  ? _buildEmptyTab("Không có phiếu nhập đã hoàn thành")
                  : _buildImportReceiptList(completedImportReceipts),
              cancelledImportReceipts.isEmpty
                  ? _buildEmptyTab("Không có phiếu nhập đã hủy")
                  : _buildImportReceiptList(cancelledImportReceipts),
            ],
          ),
        ),
        // Bottom buttons
      ],
    );
  }

  Widget _buildImportReceiptList(List<ImportReceipt> importReceipts) {
    return Container(
      color: Colors.white,
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height,
      ),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 90),
        itemCount: importReceipts.length,
        itemBuilder: (context, index) {
          final importReceipt = importReceipts[index];

          return Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: GestureDetector(
              onTap: () {},
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          importReceipt.code,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Nhà cung cấp: ${importReceipt.supplier.name}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Ngày tạo: ${importReceipt.createdAt.year}-${importReceipt.createdAt.month}-${importReceipt.createdAt.day}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Text(
                          "Ngày nhập hàng dự kiến: ${importReceipt.expectedImportDate.year}-${importReceipt.expectedImportDate.month}-${importReceipt.expectedImportDate.day}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
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

  Widget _buildEmptyTab(String message) {
    return Container(
      color: Colors.white,
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height,
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
      ),
    );
  }
}
