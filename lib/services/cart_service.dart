import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Cart?> getCartByUserId(String userId) async {
    final doc = await _firestore
        .collection('carts')
        .where('userId', isEqualTo: userId)
        .get();
    if (doc.docs.isNotEmpty) {
      return Cart.fromMap(doc.docs.first.data());
    }
    return null;
  }

  Future<void> createCart(Cart cart) async {
    await _firestore.collection('carts').doc(cart.userId).set(cart.toMap());
  }

  Future<void> updateCart(Cart cart) async {
    print(cart.toMap());
    await _firestore.collection('carts').doc(cart.id).update(cart.toMap());
  }

  Future<void> deleteCart(String userId) async {
    await _firestore.collection('carts').doc(userId).delete();
  }
}
