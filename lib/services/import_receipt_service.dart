import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luanvan/models/import_receipt.dart';
import 'package:luanvan/models/product.dart';

class ImportReceiptService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'import_receipts';

  Future<String> generateRandomNumberCode({int length = 15}) async {
    final random = Random();
    while (true) {
      final code = List.generate(length, (_) => random.nextInt(10)).join();

      // Kiểm tra xem mã đã tồn tại chưa
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('code', isEqualTo: code)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return code;
      }
    }
  }

  // Create a new import receipt
  Future<ImportReceipt> createImportReceipt(ImportReceipt receipt) async {
    try {
      final code = await generateRandomNumberCode();
      final receiptWithCode = receipt.copyWith(code: code);
      final docRef =
          await _firestore.collection(_collection).add(receiptWithCode.toMap());
      if (receiptWithCode.status == ImportReceiptStatus.completed) {
        for (var item in receipt.items) {
          final productRef =
              await _firestore.collection('products').doc(item.productId).get();

          final product = Product.fromFirestore(productRef);
          if (product.optionInfos.isNotEmpty) {
            final optionInfos = product.optionInfos;
            for (var optionInfo in optionInfos) {
              if (optionInfo.optionId2 != null) {
                if (optionInfo.optionId1 == item.optionId1 &&
                    optionInfo.optionId2 == item.optionId2) {
                  optionInfo.stock += item.adjustmentQuantities!;
                }
              } else {
                if (optionInfo.optionId1 == item.optionId1) {
                  optionInfo.stock += item.adjustmentQuantities!;
                }
              }
            }
            await _firestore
                .collection('products')
                .doc(item.productId)
                .update(product.copyWith(optionInfos: optionInfos).toMap());
          } else {
            await _firestore.collection('products').doc(item.productId).set({
              'quantity': FieldValue.increment(item.adjustmentQuantities!),
            });
          }
        }
      }
      return receipt.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Lỗi khi tạo phiếu nhập: $e');
    }
  }

  // Get all import receipts
  Future<List<ImportReceipt>> getImportReceipts() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => ImportReceipt.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy phiếu nhập: $e');
    }
  }

  Future<ImportReceipt?> getImportReceiptById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return ImportReceipt.fromMap({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      throw Exception('Lỗi khi lấy phiếu nhập: $e');
    }
  }

  // Update import receipt
  Future<void> updateImportReceipt(ImportReceipt receipt) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(receipt.id)
          .update(receipt.toMap());
    } catch (e) {
      throw Exception('Lỗi khi cập nhật phiếu nhập: $e');
    }
  }

  // Delete import receipt
  Future<void> deleteImportReceipt(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Lỗi khi xóa phiếu nhập: $e');
    }
  }

  // Get import receipts by status
  Future<List<ImportReceipt>> getImportReceiptsByStatus(
      ImportReceiptStatus status) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: status.name)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => ImportReceipt.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy phiếu nhập theo trạng thái: $e');
    }
  }
}
