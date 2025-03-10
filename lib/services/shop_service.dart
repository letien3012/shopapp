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
    if (querySnapshot.docs.isNotEmpty) {
      for (var doc in querySnapshot.docs) {
        print("User Data: ${doc.data()}");
      }
    } else {
      print("User not found!");
    }
    final Shop shop = Shop.fromFirestore(
        querySnapshot.docs.first as DocumentSnapshot<Map<String, dynamic>>);
    return shop;
  }

  Future<void> updateShop(String userName, String userId) async {
    await firebaseFirestore
        .collection('users')
        .doc(userId)
        .update({'userName': '(changed)$userName'});
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
