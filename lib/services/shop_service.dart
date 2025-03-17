import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luanvan/models/shop.dart';
import 'package:luanvan/models/user_info_model.dart';

class ShopService {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  Future<Shop> fetchShop(String userId) async {
    final QuerySnapshot querySnapshot = await firebaseFirestore
        .collection('shops')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    final Shop shop = Shop.fromFirestore(
        querySnapshot.docs.first as DocumentSnapshot<Map<String, dynamic>>);
    return shop;
  }

  Future<Shop> fetchShopByShopId(String shopId) async {
    final querySnapshot =
        await firebaseFirestore.collection('shops').doc(shopId).get();

    final Shop shop = Shop.fromFirestore(
        querySnapshot as DocumentSnapshot<Map<String, dynamic>>);
    return shop;
  }

  Future<void> updateShop(Shop shop) async {
    await firebaseFirestore
        .collection('shops')
        .doc(shop.shopId)
        .update(shop.toMap());
  }

  Future<void> hideShop(Shop sellerRegistration) async {
    await firebaseFirestore.collection('shops').add(sellerRegistration.toMap());

    await firebaseFirestore
        .collection('users')
        .doc(sellerRegistration.userId)
        .update({
      'role': 1,
    });
  }
}
