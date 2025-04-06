import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/models/product_option.dart';
import 'package:luanvan/models/product_variant.dart';

class SearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<String>> searchNameProducts(String keyword) async {
    try {
      final response = await _firestore
          .collection('products')
          .where('isDeleted', isEqualTo: false)
          .where('isHidden', isEqualTo: false)
          .get();
      final listProduct = await Future.wait(
          response.docs.map((doc) => _fetchProductWithSubcollections(doc)));
      final results = listProduct
          .where((product) =>
              product.name.toLowerCase().contains(keyword.toLowerCase()) &&
              product.getMaxOptionStock() > 0)
          .toList();
      return results.map((product) => product.name).toList();
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  // Tìm kiếm sản phẩm theo tên
  Future<List<Product>> searchProducts(String query) async {
    try {
      // Lấy tất cả sản phẩm
      final response = await _firestore
          .collection('products')
          .where('isDeleted', isEqualTo: false)
          .where('isHidden', isEqualTo: false)
          .get();

      // Lọc sản phẩm có tên chứa query (không phân biệt hoa thường)
      final lowercaseQuery = query.toLowerCase();
      final products = await Future.wait(response.docs
          .map((doc) => _fetchProductWithSubcollections(doc))
          .toList());
      return products
          .where((product) =>
              product.name.toLowerCase().contains(lowercaseQuery) &&
              product.getMaxOptionStock() > 0)
          .toList();
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  Future<Product> _fetchProductWithSubcollections(DocumentSnapshot doc) async {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    final List<ProductVariant> variants = [];

    // Fetch variants
    final variantsSnapshot = await doc.reference.collection('variants').get();

    // Chuyển đổi thành list và sắp xếp theo variantIndex
    final variantsList = variantsSnapshot.docs.toList();
    variantsList.sort((a, b) {
      final aIndex = (a.data()['variantIndex'] as num?)?.toInt() ?? 0;
      final bIndex = (b.data()['variantIndex'] as num?)?.toInt() ?? 0;
      return aIndex.compareTo(bIndex);
    });

    for (var variantDoc in variantsList) {
      final variantData = variantDoc.data() as Map<String, dynamic>;
      final List<ProductOption> options = [];

      // Fetch options for each variant
      final optionsSnapshot =
          await variantDoc.reference.collection('options').get();

      // Chuyển đổi options thành list và sắp xếp theo optionIndex
      final optionsList = optionsSnapshot.docs.toList();
      optionsList.sort((a, b) {
        final aIndex = (a.data()['optionIndex'] as num?)?.toInt() ?? 0;
        final bIndex = (b.data()['optionIndex'] as num?)?.toInt() ?? 0;
        return aIndex.compareTo(bIndex);
      });

      for (var optionDoc in optionsList) {
        final optionData = optionDoc.data() as Map<String, dynamic>;
        options.add(ProductOption.fromMap({
          ...optionData,
          'id': optionDoc.id,
        }));
      }

      variants.add(ProductVariant(
        id: variantDoc.id,
        label: variantData['label'] as String,
        options: options,
        variantIndex: variantData['variantIndex'] as int? ?? 0,
      ));
    }

    return Product.fromMap({
      ...data,
      'id': doc.id,
      'variants': variants.map((v) => v.toMap()).toList(),
    });
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
