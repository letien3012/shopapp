import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luanvan/models/product.dart';

class ProductService {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  Future<void> addProduct(Product product) async {
    final docRef =
        await firebaseFirestore.collection('products').add(product.toMap());
    await docRef.update({'id': docRef.id});
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

  Future<Product> fetchProductByProductId(String productId) async {
    final Product product;
    final querySnapshot =
        await firebaseFirestore.collection('products').doc(productId).get();

    product = Product.fromFirestore(querySnapshot);

    return product;
  }

  Future<List<Product>> fetchProductsByListProductId(
      List<String> productIds) async {
    final response = await firebaseFirestore
        .collection('products')
        .where('id', whereIn: productIds)
        .get();

    return response.docs.map((doc) => Product.fromFirestore(doc)).toList();
  }

  Future<void> deleteProduct(String productId) async {
    await firebaseFirestore.collection('products').doc(productId).delete();
  }

  Future<void> UpdateProduct(Product product) async {
    await firebaseFirestore
        .collection('products')
        .doc(product.id)
        .update(product.toMap());
  }

  Future<void> fetchProductById(String productId) async {}
}
