import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luanvan/models/product.dart';

class ProductService {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  Future<void> addProduct(Product product) async {}
  Future<void> deleteProductById(String productId) async {}
  Future<void> UpdateProductById(String productId) async {}
  Future<void> fetchProductById(String productId) async {}
}
