import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luanvan/models/category.dart';

class CategoryService {
  final FirebaseFirestore _firestore;
  final String _collection = 'categories';

  CategoryService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Lấy tất cả danh mục
  Future<List<Category>> getAllCategories() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs
          .map((doc) => Category.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách danh mục: $e');
    }
  }

  // Lấy danh mục theo shop ID
  Future<List<Category>> getCategoriesByShopId(String shopId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('shopId', isEqualTo: shopId)
          .get();
      return snapshot.docs
          .map((doc) => Category.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách danh mục của cửa hàng: $e');
    }
  }

  // Thêm danh mục mới
  Future<void> createCategory(Category category) async {
    try {
      // Kiểm tra tên danh mục
      if (category.name.trim().isEmpty) {
        throw Exception('Tên danh mục không được để trống');
      }

      // Kiểm tra URL hình ảnh
      if (category.imageUrl == null || category.imageUrl!.isEmpty) {
        throw Exception('Hình ảnh danh mục không được để trống');
      }

      final catogoryref =
          await _firestore.collection(_collection).add(category.toJson());
      await _firestore
          .collection(_collection)
          .doc(catogoryref.id)
          .update({'id': catogoryref.id});
    } catch (e) {
      throw Exception('Lỗi khi thêm danh mục: $e');
    }
  }

  // Cập nhật danh mục
  Future<void> updateCategory(Category category) async {
    try {
      // Kiểm tra tên danh mục
      if (category.name.trim().isEmpty) {
        throw Exception('Tên danh mục không được để trống');
      }

      // Kiểm tra URL hình ảnh
      if (category.imageUrl == null || category.imageUrl!.isEmpty) {
        throw Exception('Hình ảnh danh mục không được để trống');
      }

      await _firestore
          .collection(_collection)
          .doc(category.id)
          .update(category.toJson());
    } catch (e) {
      throw Exception('Lỗi khi cập nhật danh mục: $e');
    }
  }

  // Xóa danh mục
  Future<void> deleteCategory(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Lỗi khi xóa danh mục: $e');
    }
  }

  // Lấy danh mục theo ID
  Future<Category?> getCategoryById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (!doc.exists) {
        return null;
      }
      return Category.fromJson({
        'id': doc.id,
        ...doc.data()!,
      });
    } catch (e) {
      throw Exception('Lỗi khi lấy thông tin danh mục: $e');
    }
  }
}
