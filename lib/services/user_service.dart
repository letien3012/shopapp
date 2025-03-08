import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luanvan/models/seller_registration.dart';
import 'package:luanvan/models/user_info_model.dart';

class UserService {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  Future<UserInfoModel> fetchUserInfo(String userId) async {
    final QuerySnapshot querySnapshot = await firebaseFirestore
        .collection('users')
        .where('id', isEqualTo: userId)
        .limit(1)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      for (var doc in querySnapshot.docs) {
        print("User Data: ${doc.data()}");
      }
    } else {
      print("User not found!");
    }
    final UserInfoModel userInfoModel = UserInfoModel.fromFirestore(
        querySnapshot.docs.first.data() as Map<String, dynamic>);
    return userInfoModel;
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

  Future<void> registrationSeller(SellerRegistration sellerRegistration) async {
    await firebaseFirestore
        .collection('registrationsellers')
        .add(sellerRegistration.toMap());

    await firebaseFirestore
        .collection('users')
        .doc(sellerRegistration.userId)
        .update({
      'addressSeleer': sellerRegistration.address.toMap(),
      'role': 1,
    });
  }
}
