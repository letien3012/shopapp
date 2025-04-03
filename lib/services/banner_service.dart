import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luanvan/models/banner.dart';
import 'package:luanvan/models/category.dart';

class BannerService {
  final FirebaseFirestore _firestore;
  final String _collection = 'banners';

  BannerService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Lấy tất cả danh mục
  Future<List<Banner>> getAllBanners() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs
          .map((doc) => Banner.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách banner: $e');
    }
  }

  // Lấy danh mục theo shop ID
  Future<List<Banner>> getBannersByShopId(String shopId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('shopId', isEqualTo: shopId)
          .get();
      return snapshot.docs
          .map((doc) => Banner.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách banner của cửa hàng: $e');
    }
  }

  // Thêm danh mục mới
  Future<void> createBanner(Banner banner) async {
    try {
      // Kiểm tra URL hình ảnh
      if (banner.imageUrl == null || banner.imageUrl!.isEmpty) {
        throw Exception('Hình ảnh banner không được để trống');
      }

      final bannerref =
          await _firestore.collection(_collection).add(banner.toJson());
      await _firestore
          .collection(_collection)
          .doc(bannerref.id)
          .update({'id': bannerref.id});
    } catch (e) {
      throw Exception('Lỗi khi thêm banner: $e');
    }
  }

  // Cập nhật danh mục
  Future<void> updateBanner(Banner banner) async {
    try {
      // Kiểm tra URL hình ảnh
      if (banner.imageUrl == null || banner.imageUrl!.isEmpty) {
        throw Exception('Hình ảnh banner không được để trống');
      }

      await _firestore
          .collection(_collection)
          .doc(banner.id)
          .update(banner.toJson());
    } catch (e) {
      throw Exception('Lỗi khi cập nhật banner: $e');
    }
  }

  // Xóa danh mục
  Future<void> deleteBanner(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Lỗi khi xóa banner: $e');
    }
  }

  // Lấy danh mục theo ID
  Future<Banner?> getBannerById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (!doc.exists) {
        return null;
      }
      return Banner.fromJson({
        'id': doc.id,
        ...doc.data()!,
      });
    } catch (e) {
      throw Exception('Lỗi khi lấy thông tin banner: $e');
    }
  }
}
