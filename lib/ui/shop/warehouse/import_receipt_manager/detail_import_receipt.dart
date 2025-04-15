import 'package:flutter/material.dart';
import 'package:luanvan/models/import_receipt.dart';

class DetailImportReceiptScreen extends StatefulWidget {
  static String routeName = 'detail_import_receipt';

  @override
  State<DetailImportReceiptScreen> createState() =>
      _DetailImportReceiptScreenState();
}

class _DetailImportReceiptScreenState extends State<DetailImportReceiptScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _supplierController = TextEditingController();
  final TextEditingController _expectedImportDateController =
      TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  late ImportReceipt importReceipts;
  @override
  void dispose() {
    _supplierController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the arguments passed from the warehouse screen
    importReceipts =
        ModalRoute.of(context)!.settings.arguments as ImportReceipt;
    _supplierController.text = importReceipts.supplier.name;
    _expectedImportDateController.text =
        '${importReceipts.expectedImportDate.day}/${importReceipts.expectedImportDate.month}/${importReceipts.expectedImportDate.year}';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Chi tiết phiếu nhập'),
      ),
      body: Container(
        color: Colors.white,
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
          minWidth: MediaQuery.of(context).size.width,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Divider(height: 1),
                Row(children: [
                  const SizedBox(width: 10),
                  Row(
                    children: [
                      const Text(
                        'Nhà cung cấp',
                        style: TextStyle(fontSize: 16),
                      ),
                      const Text(
                        ' *',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                  Expanded(
                    child: TextFormField(
                      textAlign: TextAlign.end,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                      ),
                      controller: _supplierController,
                      readOnly: true,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ]),
                const Divider(height: 1),

                Row(
                  children: [
                    const SizedBox(width: 10),
                    Row(
                      children: [
                        const Text(
                          'Ngày nhập dự kiến',
                          style: TextStyle(fontSize: 16),
                        ),
                        const Text(
                          ' *',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _expectedImportDateController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                        ),
                        textAlign: TextAlign.end,
                        readOnly: true,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
                Container(
                  height: 0.5,
                  color: Colors.grey,
                ),
                // Ghi chú
                Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            'Ghi chú',
                            style: TextStyle(fontSize: 16),
                          ),
                          const Spacer(),
                        ],
                      ),
                      TextField(
                        controller: _noteController,
                        decoration: const InputDecoration(
                          hintText: 'Không có ghi chú',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          counterText: '',
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 0.5,
                  color: Colors.grey,
                ),
                const SizedBox(height: 10),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: importReceipts.items.length,
                  itemBuilder: (context, index) {
                    final option = importReceipts.items[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(color: Colors.grey),
                        ),
                      ),
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  option.imageUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.network(
                                    'https://via.placeholder.com/80',
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      option.productName,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Phân loại: ${option.optionName}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            color: Colors.grey.shade200,
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Số lượng hiện tại:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${option.quantity}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Số lượng điều chỉnh dự kiến:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${option.adjustmentQuantities}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Số lượng hàng có sẵn (sau điều chỉnh):',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${option.quantity + option.adjustmentQuantities!}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
