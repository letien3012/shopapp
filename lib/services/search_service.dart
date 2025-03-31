import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/services/api_service.dart';

class SearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ApiService _apiService;

  SearchService(this._apiService);
  Future<List<String>> searchNameProducts(String keyword) async {
    try {
      final response = await _firestore.collection('products').get();

      final results = response.docs.where((doc) {
        final name = doc['name'].toString().toLowerCase();
        return name.contains(keyword.toLowerCase());
      }).toList();
      return results.map((doc) => doc['name'] as String).toList();
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  // Tìm kiếm sản phẩm theo tên
  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await _firestore
          .collection('products')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .get();
      print(response.docs.length);
      return response.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Product.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  // Tìm kiếm sản phẩm theo tên với phân trang
  Future<List<Product>> searchProductsWithPagination(
    String keyword, {
    int limit = 10,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      final lowercaseKeyword = keyword.toLowerCase();
      Query query = _firestore
          .collection('products')
          .where('name', isGreaterThanOrEqualTo: lowercaseKeyword)
          .where('name', isLessThanOrEqualTo: lowercaseKeyword + '\uf8ff')
          .limit(limit);

      // Nếu có lastDocument, thêm startAfter để phân trang
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final QuerySnapshot querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Product.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error searching products with pagination: $e');
      return [];
    }
  }

  // Tìm kiếm sản phẩm theo tên và shopId
  Future<List<Product>> searchProductsByShop(
    String keyword,
    String shopId, {
    int limit = 10,
  }) async {
    try {
      final lowercaseKeyword = keyword.toLowerCase();
      final QuerySnapshot querySnapshot = await _firestore
          .collection('products')
          .where('shopId', isEqualTo: shopId)
          .where('name', isGreaterThanOrEqualTo: lowercaseKeyword)
          .where('name', isLessThanOrEqualTo: lowercaseKeyword + '\uf8ff')
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Product.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error searching products by shop: $e');
      return [];
    }
  }
}
