import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/models/product_option.dart';
import 'package:luanvan/models/product_variant.dart';
import 'package:faker/faker.dart';
import 'dart:math';

class HomeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final faker = Faker();

  Future<List<Product>> getAllProducts() async {
    try {
      final List<Product> listProduct = [];
      final productSnapshot = await _firestore
          .collection('products')
          .where('isDeleted', isEqualTo: false)
          .where('isHidden', isEqualTo: false)
          .get();

      if (productSnapshot.docs.isNotEmpty) {
        for (var doc in productSnapshot.docs) {
          listProduct.add(await _fetchProductWithSubcollections(doc));
        }
      } else {
        print("Product not found!");
      }
      listProduct.sort((a, b) => b.quantitySold.compareTo(a.quantitySold));
      return listProduct
          .where((product) =>
              !product.isDeleted &&
              !product.isHidden &&
              product.getMaxOptionStock() > 0)
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  Future<Product> _fetchProductWithSubcollections(DocumentSnapshot doc) async {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    final List<ProductVariant> variants = [];

    // Fetch variants
    final variantsSnapshot = await doc.reference.collection('variants').get();
    for (var variantDoc in variantsSnapshot.docs) {
      final variantData = variantDoc.data() as Map<String, dynamic>;
      final List<ProductOption> options = [];

      // Fetch options for each variant
      final optionsSnapshot =
          await variantDoc.reference.collection('options').get();
      for (var optionDoc in optionsSnapshot.docs) {
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
      ));
    }

    return Product.fromMap({
      ...data,
      'id': doc.id,
      'variants': variants.map((v) => v.toMap()).toList(),
    });
  }

  Future<List<Product>> getRecommendedProducts() async {
    try {
      final List<Product> recommendedProducts = [];

      // Lấy tất cả shop đang mở
      final QuerySnapshot shopSnapshot = await _firestore
          .collection('shops')
          .where('isClose', isEqualTo: false)
          .get();

      final List<String> activeShopIds =
          shopSnapshot.docs.map((doc) => doc.id).toList();

      // Lấy sản phẩm theo các tiêu chí
      final productSnapshot = await _firestore
          .collection('products')
          .where('shopId', whereIn: activeShopIds)
          .where('isDeleted', isEqualTo: false)
          .orderBy('soldCount', descending: true) // Sản phẩm bán chạy
          .limit(10)
          .get();

      if (productSnapshot.docs.isNotEmpty) {
        for (var doc in productSnapshot.docs) {
          recommendedProducts.add(await _fetchProductWithSubcollections(doc));
        }
      }

      // Lấy sản phẩm mới nhất
      final newProductsSnapshot = await _firestore
          .collection('products')
          .where('shopId', whereIn: activeShopIds)
          .where('isDeleted', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();

      for (var doc in newProductsSnapshot.docs) {
        if (!recommendedProducts.any((p) => p.id == doc.id)) {
          recommendedProducts.add(await _fetchProductWithSubcollections(doc));
        }
      }

      // Lấy sản phẩm có đánh giá cao
      final highRatedSnapshot = await _firestore
          .collection('products')
          .where('shopId', whereIn: activeShopIds)
          .where('isDeleted', isEqualTo: false)
          .where('rating', isGreaterThanOrEqualTo: 4.0)
          .limit(5)
          .get();

      for (var doc in highRatedSnapshot.docs) {
        if (!recommendedProducts.any((p) => p.id == doc.id)) {
          recommendedProducts.add(await _fetchProductWithSubcollections(doc));
        }
      }

      // Lấy sản phẩm có giảm giá
      final discountedSnapshot = await _firestore
          .collection('products')
          .where('shopId', whereIn: activeShopIds)
          .where('isDeleted', isEqualTo: false)
          .where('discount', isGreaterThan: 0)
          .limit(5)
          .get();

      for (var doc in discountedSnapshot.docs) {
        if (!recommendedProducts.any((p) => p.id == doc.id)) {
          recommendedProducts.add(await _fetchProductWithSubcollections(doc));
        }
      }

      return recommendedProducts;
    } catch (e) {
      throw Exception('Failed to fetch recommended products: $e');
    }
  }

  // Cách 1: Sử dụng batch để insert nhiều document cùng lúc
  Future<void> batchInsertProducts(List<Product> products) async {
    try {
      WriteBatch batch = _firestore.batch();

      for (var product in products) {
        // Tạo reference cho document sản phẩm
        DocumentReference productRef = _firestore.collection('products').doc();

        // Thêm sản phẩm vào batch
        batch.set(productRef, product.toMap());

        // Thêm variants và options vào subcollections
        for (var variant in product.variants) {
          DocumentReference variantRef =
              productRef.collection('variants').doc();
          batch.set(variantRef, variant.toMap());

          for (var option in variant.options) {
            DocumentReference optionRef =
                variantRef.collection('options').doc();
            batch.set(optionRef, option.toMap());
          }
        }
      }

      // Commit batch
      await batch.commit();
      print('Batch insert completed successfully');
    } catch (e) {
      throw Exception('Failed to batch insert products: $e');
    }
  }

  // Cách 2: Sử dụng set với merge để cập nhật hoặc tạo mới nhiều document
  Future<void> bulkUpdateProducts(List<Product> products) async {
    try {
      // Tạo một Future list để chạy các thao tác song song
      List<Future<void>> futures = [];

      for (var product in products) {
        // Tạo reference cho document sản phẩm
        DocumentReference productRef =
            _firestore.collection('products').doc(product.id);

        // Thêm sản phẩm vào futures list
        futures.add(productRef.set(product.toMap(), SetOptions(merge: true)));

        // Thêm variants và options
        for (var variant in product.variants) {
          DocumentReference variantRef =
              productRef.collection('variants').doc(variant.id);
          futures.add(variantRef.set(variant.toMap(), SetOptions(merge: true)));

          for (var option in variant.options) {
            DocumentReference optionRef =
                variantRef.collection('options').doc(option.id);
            futures.add(optionRef.set(option.toMap(), SetOptions(merge: true)));
          }
        }
      }

      // Chờ tất cả các thao tác hoàn thành
      await Future.wait(futures);
      print('Bulk update completed successfully');
    } catch (e) {
      throw Exception('Failed to bulk update products: $e');
    }
  }

  // Ví dụ sử dụng batch để insert dữ liệu mẫu
  Future<void> insertSampleData() async {
    try {
      WriteBatch batch = _firestore.batch();

      // Tạo dữ liệu mẫu
      final sampleProducts = [
        {
          'name': 'Sample Product 1',
          'price': 100,
          'description': 'This is a sample product',
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Sample Product 2',
          'price': 200,
          'description': 'Another sample product',
          'createdAt': FieldValue.serverTimestamp(),
        },
      ];

      // Thêm vào batch
      for (var product in sampleProducts) {
        DocumentReference productRef = _firestore.collection('products').doc();
        batch.set(productRef, product);
      }

      // Commit batch
      await batch.commit();
      print('Sample data inserted successfully');
    } catch (e) {
      throw Exception('Failed to insert sample data: $e');
    }
  }

  // Danh sách URL hình ảnh từ Unsplash
  final List<String> _imageUrls = [
    'https://images.unsplash.com/photo-1505740420928-5e560c06d30e', // Headphones
    'https://images.unsplash.com/photo-1523275335684-37898b6baf30', // Watch
    'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f', // Camera
    'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9', // Laptop
    'https://images.unsplash.com/photo-1505740420928-5e560c06d30e', // Phone
    'https://images.unsplash.com/photo-1523275335684-37898b6baf30', // Tablet
    'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f', // Smartwatch
    'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9', // Camera
    'https://images.unsplash.com/photo-1505740420928-5e560c06d30e', // Headphones
    'https://images.unsplash.com/photo-1523275335684-37898b6baf30', // Watch
  ];

  // Tạo dữ liệu mẫu với 1000 sản phẩm
  Future<void> generateSampleData() async {
    try {
      WriteBatch batch = _firestore.batch();
      final random = Random();

      // Tạo 1000 sản phẩm
      for (int i = 0; i < 1000; i++) {
        // Tạo ID ngẫu nhiên cho sản phẩm
        final productId = faker.guid.guid();
        final DocumentReference productRef =
            _firestore.collection('products').doc(productId);

        // Tạo dữ liệu sản phẩm ngẫu nhiên
        final productData = {
          'id': productId,
          'name': faker.company.name(),
          'description': faker.lorem.sentences(3).join('\n'),
          'price':
              random.nextInt(1000000) + 10000, // Giá từ 10,000 đến 1,010,000
          'imageUrl': [_imageUrls[random.nextInt(_imageUrls.length)]],
          'category': faker.randomGenerator
              .element(['Electronics', 'Fashion', 'Home', 'Books', 'Sports']),
          'shopId': faker.guid.guid(), // ID shop ngẫu nhiên
          'rating': (random.nextDouble() * 2 + 3)
              .toStringAsFixed(1), // Rating từ 3.0 đến 5.0
          'soldCount': random.nextInt(1000), // Số lượng đã bán từ 0-1000
          'discount': random.nextInt(50), // Giảm giá từ 0-50%
          'isDeleted': false,
          'isHidden': false,
          'isViolated': false,
          'violationReason': '',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        // Thêm sản phẩm vào batch
        batch.set(productRef, productData);

        // Tạo variants ngẫu nhiên (1-3 variants)
        final variantCount = random.nextInt(3) + 1;
        for (int j = 0; j < variantCount; j++) {
          final variantId = faker.guid.guid();
          final variantRef = productRef.collection('variants').doc(variantId);

          final variantData = {
            'id': variantId,
            'label': faker.randomGenerator.element(['Size', 'Color', 'Style']),
          };

          batch.set(variantRef, variantData);

          // Tạo options trong subcollection
          final optionsCount = random.nextInt(3) + 2; // 2-4 options mỗi variant
          for (int k = 0; k < optionsCount; k++) {
            final optionId = faker.guid.guid();
            final optionRef = variantRef.collection('options').doc(optionId);

            final optionData = {
              'id': optionId,
              'name': faker.randomGenerator.element([
                'Small',
                'Medium',
                'Large',
                'Red',
                'Blue',
                'Green',
                'Black',
                'White'
              ]),
              'price':
                  random.nextInt(100000) + 5000, // Giá từ 5,000 đến 105,000
              'stock': random.nextInt(100), // Số lượng tồn từ 0-100
              'imageUrl': _imageUrls[random.nextInt(_imageUrls.length)],
            };

            batch.set(optionRef, optionData);
          }
        }

        // Commit batch mỗi 500 sản phẩm để tránh giới hạn
        if (i % 500 == 0) {
          await batch.commit();
          batch = _firestore.batch();
          print('Committed batch ${i ~/ 500 + 1}');
        }
      }

      // Commit batch cuối cùng nếu còn
      if (1000 % 500 != 0) {
        await batch.commit();
      }

      print('Successfully generated 1000 sample products');
    } catch (e) {
      throw Exception('Failed to generate sample data: $e');
    }
  }
}
