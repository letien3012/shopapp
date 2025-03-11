import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luanvan/models/product.dart';

class ProductService {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  Future<void> addProduct(Product product) async {
    await firebaseFirestore.collection('products').add(product.toMap());
  }

  Future<List<Product>> fetchProductByShopId(String shopId) async {
    final List<Product> listProduct = [];

    QuerySnapshot querySnapshot = await firebaseFirestore
        .collection('products')
        .where('shopId', isEqualTo: shopId)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      for (var doc in querySnapshot.docs) {
        listProduct.add(Product.fromFirestore(doc));
      }
    } else {
      print("Product not found!");
    }
    return listProduct;
  }

  Future<void> deleteProductById(String productId) async {}
  Future<void> UpdateProductById(String productId) async {}
  Future<void> fetchProductById(String productId) async {}
}
