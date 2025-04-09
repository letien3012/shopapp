import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luanvan/models/supplier.dart';

class SupplierService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'suppliers';

  // Lấy danh sách tất cả nhà cung cấp
  Future<List<Supplier>> getSuppliers() async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('isDeleted', isEqualTo: false)
        .get();
    return snapshot.docs
        .map((doc) => Supplier.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  // Lấy nhà cung cấp theo ID
  Future<Supplier?> getSupplierById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (doc.exists) {
      return Supplier.fromJson({...doc.data()!, 'id': doc.id});
    }
    return null;
  }

  // Thêm nhà cung cấp mới
  Future<void> addSupplier(Supplier supplier) async {
    await _firestore.collection(_collection).add(supplier.toJson());
  }

  // Cập nhật nhà cung cấp
  Future<void> updateSupplier(Supplier supplier) async {
    await _firestore
        .collection(_collection)
        .doc(supplier.id)
        .update(supplier.toJson());
  }

  // Xóa nhà cung cấp (soft delete)
  Future<void> deleteSupplier(String id) async {
    await _firestore.collection(_collection).doc(id).update({
      'isDeleted': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
