import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/models/shop.dart';
import 'package:luanvan/models/user_info_model.dart';

class UserService {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  Future<List<UserInfoModel>> fetchAllUser() async {
    final QuerySnapshot querySnapshot =
        await firebaseFirestore.collection('users').get();
    return querySnapshot.docs
        .map((doc) =>
            UserInfoModel.fromFirestore(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<UserInfoModel> fetchUserInfo(String userId) async {
    final QuerySnapshot querySnapshot = await firebaseFirestore
        .collection('users')
        .where('id', isEqualTo: userId)
        .limit(1)
        .get();
    final UserInfoModel userInfoModel = UserInfoModel.fromFirestore(
        querySnapshot.docs.first.data() as Map<String, dynamic>);
    return userInfoModel;
  }

  Future<List<UserInfoModel>> fetchListUserByUserId(
      List<String> userIds) async {
    final QuerySnapshot querySnapshot = await firebaseFirestore
        .collection('users')
        .where('id', whereIn: userIds)
        .get();

    final List<UserInfoModel> userInfoModels = querySnapshot.docs
        .map((doc) =>
            UserInfoModel.fromFirestore(doc.data() as Map<String, dynamic>))
        .toList();
    return userInfoModels;
  }

  Future<List<UserInfoModel>> fetchListUserOrderByUserId(
      List<String> userIds) async {
    final QuerySnapshot querySnapshot = await firebaseFirestore
        .collection('users')
        .where('id', whereIn: userIds)
        .get();

    final List<UserInfoModel> userInfoModels = querySnapshot.docs
        .map((doc) =>
            UserInfoModel.fromFirestore(doc.data() as Map<String, dynamic>))
        .toList();
    return userInfoModels;
  }

  Future<void> updateBasicUserInfo(UserInfoModel user) async {
    await firebaseFirestore
        .collection('users')
        .doc(user.id)
        .set(user.toMap(), SetOptions(merge: true));
  }

  Future<void> updateUserName(String userName, String userId) async {
    await firebaseFirestore
        .collection('users')
        .doc(userId)
        .update({'userName': '(changed)$userName'});
  }

  Future<void> registrationSeller(Shop sellerRegistration) async {
    DocumentReference shopRef = await firebaseFirestore
        .collection('shops')
        .add(sellerRegistration.toMap());
    String shopId = shopRef.id;
    await firebaseFirestore
        .collection('shops')
        .doc(shopId)
        .update({'shopId': shopId});
    await firebaseFirestore
        .collection('users')
        .doc(sellerRegistration.userId)
        .update({
      'role': 1,
    });
  }

  Future<void> updateUser(UserInfoModel user) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.id)
        .update(user.toMap())
        .catchError((error) {
      print("Lỗi khi cập nhật: $error");
    });
  }

  Future<void> addFavoriteProduct(String productId, String userId) async {
    await firebaseFirestore.collection('users').doc(userId).update({
      'favoriteProducts': FieldValue.arrayUnion([productId])
    });
  }

  Future<void> removeFavoriteProduct(String productId, String userId) async {
    await firebaseFirestore.collection('users').doc(userId).update({
      'favoriteProducts': FieldValue.arrayRemove([productId])
    });
  }

  Future<List<String>> fetchFavoriteProduct(String userId) async {
    final querySnapshot =
        await firebaseFirestore.collection('users').doc(userId).get();
    if (!querySnapshot.exists) {
      return []; // Trả về danh sách rỗng nếu user không tồn tại
    }

    final data = querySnapshot.data();
    if (data == null || data['favoriteProducts'] == null) {
      return [];
    }

    final List<dynamic> favorites = data['favoriteProducts'];
    return favorites.map((item) => item.toString()).toList();
  }
}
