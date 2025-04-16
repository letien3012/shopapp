import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:luanvan/models/order.dart';

class PackingSlipScreen extends StatefulWidget {
  static const routeName = 'packing-slip';

  const PackingSlipScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<PackingSlipScreen> createState() => _PackingSlipScreenState();
}

class _PackingSlipScreenState extends State<PackingSlipScreen> {
  Order? order;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args is Order) {
          setState(() {
            order = args;
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'Không tìm thấy thông tin đơn hàng';
            isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          errorMessage = 'Đã xảy ra lỗi khi tải thông tin đơn hàng';
          isLoading = false;
        });
      }
    });
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    if (order == null) {
      throw Exception('Không có thông tin đơn hàng');
    }

    final pdf = pw.Document();

    try {
      // Load Noto Sans fonts from assets
      final regularFontData =
          await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
      final boldFontData =
          await rootBundle.load('assets/fonts/NotoSans-Bold.ttf');

      final regularFont = pw.Font.ttf(regularFontData);
      final boldFont = pw.Font.ttf(boldFontData);

      // Add logo from assets
      final logoImage = await rootBundle.load(
        order?.shipMethod.name == 'Nhanh'
            ? 'assets/images/ghn_print.webp'
            : 'assets/images/GHTK_print.png',
      );
      final logoImageData = pw.MemoryImage(logoImage.buffer.asUint8List());

      pdf.addPage(
        pw.Page(
          pageFormat: format,
          theme: pw.ThemeData.withFont(
            base: regularFont,
            bold: boldFont,
          ),
          build: (context) {
            return pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 1),
              ),
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(10),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Header with logo and barcode
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Image(logoImageData, width: 200, height: 100),
                            pw.SizedBox(height: 2),
                            pw.Text(
                              'Mã vận đơn: ${order?.shippingCode ?? ''}',
                              style:
                                  pw.TextStyle(fontSize: 10, font: regularFont),
                            ),
                            pw.Text(
                              'Mã đơn hàng: ${order?.trackingNumber ?? ''}',
                              style:
                                  pw.TextStyle(fontSize: 10, font: regularFont),
                            ),
                          ],
                        ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.BarcodeWidget(
                              data: order?.shippingCode ?? '',
                              barcode: pw.Barcode.code128(),
                              width: 160,
                              height: 50,
                            ),
                            pw.SizedBox(height: 2),
                            pw.Text(
                              'Ngày đặt hàng: ${order?.createdAt ?? ''}',
                              style:
                                  pw.TextStyle(fontSize: 10, font: regularFont),
                            ),
                          ],
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    // Order code section
                    pw.Container(
                      width: double.infinity,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(width: 0.5),
                      ),
                      child: pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 8),
                        child: pw.Text(
                          order?.shippingCode ?? '',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            font: boldFont,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    // Addresses section with border
                    pw.Container(
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(width: 0.5),
                      ),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Expanded(
                            child: pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text('Từ:',
                                      style: pw.TextStyle(
                                        fontSize: 11,
                                        fontWeight: pw.FontWeight.bold,
                                        font: boldFont,
                                      )),
                                  pw.SizedBox(height: 4),
                                  pw.Text(
                                      order?.pickUpAdress?.receiverName ?? '',
                                      style: pw.TextStyle(
                                          fontSize: 11, font: regularFont)),
                                  pw.Text(
                                      order?.pickUpAdress?.receiverPhone ?? '',
                                      style: pw.TextStyle(
                                          fontSize: 11, font: regularFont)),
                                  pw.Text(
                                      '${order?.pickUpAdress?.addressLine ?? ''}, ${order?.pickUpAdress?.ward ?? ''}, ${order?.pickUpAdress?.district ?? ''}, ${order?.pickUpAdress?.city ?? ''}',
                                      style: pw.TextStyle(
                                          fontSize: 11, font: regularFont)),
                                ],
                              ),
                            ),
                          ),
                          pw.Container(
                            width: 0.5,
                            height: 100,
                            color: PdfColors.black,
                          ),
                          pw.Expanded(
                            child: pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text('Đến:',
                                      style: pw.TextStyle(
                                        fontSize: 11,
                                        fontWeight: pw.FontWeight.bold,
                                        font: boldFont,
                                      )),
                                  pw.SizedBox(height: 4),
                                  pw.Text(
                                      order?.receiveAdress?.receiverName ?? '',
                                      style: pw.TextStyle(
                                          fontSize: 11, font: regularFont)),
                                  pw.Text(
                                      order?.receiveAdress?.receiverPhone ?? '',
                                      style: pw.TextStyle(
                                          fontSize: 11, font: regularFont)),
                                  pw.Text(
                                      '${order?.receiveAdress?.addressLine ?? ''}, ${order?.receiveAdress?.ward ?? ''}, ${order?.receiveAdress?.district ?? ''}, ${order?.receiveAdress?.city ?? ''}',
                                      style: pw.TextStyle(
                                          fontSize: 11, font: regularFont)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    // Products section with border
                    pw.Container(
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(width: 0.5),
                      ),
                      child: pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                                'Nội dung hàng (Tổng SL sản phẩm: ${order!.item.length})',
                                style: pw.TextStyle(
                                  fontSize: 11,
                                  fontWeight: pw.FontWeight.bold,
                                  font: boldFont,
                                )),
                            pw.SizedBox(height: 4),
                            ...order!.item.map((item) => pw.Padding(
                                  padding: const pw.EdgeInsets.only(top: 2),
                                  child: pw.Text(
                                    '${item.productName} ${item.productVariation ?? ''} - SL: ${item.quantity}',
                                    style: pw.TextStyle(
                                        fontSize: 11, font: regularFont),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    // Payment and weight info with QR code
                    pw.Row(
                      children: [
                        pw.Expanded(
                          flex: 2,
                          child: pw.Container(
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(width: 0.5),
                            ),
                            child: pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    'Tiền thu người nhận:',
                                    style: pw.TextStyle(
                                      fontSize: 11,
                                      fontWeight: pw.FontWeight.bold,
                                      font: boldFont,
                                    ),
                                  ),
                                  pw.SizedBox(height: 4),
                                  pw.Text(
                                    '${order?.totalPrice ?? 0} VND',
                                    style: pw.TextStyle(
                                      fontSize: 14,
                                      fontWeight: pw.FontWeight.bold,
                                      font: boldFont,
                                    ),
                                  ),
                                  pw.SizedBox(height: 4),
                                  pw.Text(
                                    'Khối lượng: ${order?.weight ?? 0} gram',
                                    style: pw.TextStyle(
                                        fontSize: 11, font: regularFont),
                                  ),
                                  pw.SizedBox(height: 4),
                                  pw.Text(
                                    'Phương thức vận chuyển: ${order?.shipMethod.name ?? ''}',
                                    style: pw.TextStyle(
                                        fontSize: 11, font: regularFont),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        pw.SizedBox(width: 8),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Container(
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(width: 0.5),
                            ),
                            child: pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.BarcodeWidget(
                                data: order?.shippingCode ?? '',
                                barcode: pw.Barcode.qrCode(),
                                width: 80,
                                height: 80,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    // Footer notes
                    pw.Container(
                      width: double.infinity,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(width: 0.5),
                      ),
                      child: pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Chú ý:',
                              style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                font: boldFont,
                              ),
                            ),
                            pw.SizedBox(height: 2),
                            pw.Text(
                              '- Cho xem, không thử hàng\n- Chuyển hoàn sau 3 lần phát\n- Lưu kho tối đa 5 ngày',
                              style:
                                  pw.TextStyle(fontSize: 10, font: regularFont),
                            ),
                          ],
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

      return pdf.save();
    } catch (e) {
      throw Exception('Lỗi khi tạo PDF: $e');
    }
  }

  Future<void> _sharePdf() async {
    try {
      final bytes = await _generatePdf(PdfPageFormat.a4);
      final output = await getTemporaryDirectory();
      final file =
          File('${output.path}/shipping_label_${order?.shippingCode}.pdf');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Phiếu giao hàng ${order?.shippingCode}',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể chia sẻ file PDF: $e')),
      );
    }
  }

  Future<void> _savePdf() async {
    try {
      final bytes = await _generatePdf(PdfPageFormat.a4);

      // First save to temporary directory
      final tempDir = await getTemporaryDirectory();
      final tempFile =
          File('${tempDir.path}/shipping_label_${order?.shippingCode}.pdf');
      await tempFile.writeAsBytes(bytes);

      // Let user choose save location
      String? outputPath = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Chọn thư mục lưu file PDF',
      );

      if (outputPath != null) {
        try {
          // Try to copy file to selected location
          final targetFile =
              File('$outputPath/shipping_label_${order?.shippingCode}.pdf');
          await tempFile.copy(targetFile.path);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Đã tải xuống thành công: ${targetFile.path}')),
          );
        } catch (e) {
          // If copy fails, try to save directly
          try {
            final file =
                File('$outputPath/shipping_label_${order?.shippingCode}.pdf');
            await file.writeAsBytes(bytes);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Đã tải xuống thành công: ${file.path}')),
            );
          } catch (e) {
            // If both methods fail, show error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Không thể lưu file: $e')),
            );
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải file PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Xem trước',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () async {
              try {
                final bytes = await _generatePdf(PdfPageFormat.a4);
                await Printing.layoutPdf(
                  onLayout: (PdfPageFormat format) async => bytes,
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Không thể in: $e')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              try {
                final bytes = await _generatePdf(PdfPageFormat.a4);
                final output = await getTemporaryDirectory();
                final file = File(
                    '${output.path}/shipping_label_${order?.shippingCode}.pdf');
                await file.writeAsBytes(bytes);

                await Share.shareXFiles(
                  [XFile(file.path)],
                  text: 'Phiếu giao hàng ${order?.shippingCode}',
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Không thể chia sẻ: $e')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _savePdf,
          ),
        ],
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : order == null
                  ? const Center(child: Text('Không có thông tin đơn hàng'))
                  : InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: PdfPreview(
                        build: (format) => _generatePdf(format),
                        canChangeOrientation: false,
                        canChangePageFormat: false,
                        canDebug: false,
                        allowPrinting: false,
                        allowSharing: false,
                        pdfFileName:
                            'shipping_label_${order?.shippingCode}.pdf',
                        loadingWidget: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
    );
  }
}
