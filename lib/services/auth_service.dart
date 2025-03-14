import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_info_model.dart';
import '../models/cart.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  String generateRandomUsername() {
    final random = Random();
    const characters = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return 'user_' +
        List.generate(8, (_) => characters[random.nextInt(characters.length)])
            .join();
  }

  Future<bool> checkUSerNameExits(String userName) async {
    QuerySnapshot query = await _firestore
        .collection('users')
        .where('userName', isEqualTo: userName)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  Future<void> createCartForUser(String userId) async {
    final cartCollection = _firestore.collection('carts');
    final querySnapshot =
        await cartCollection.where('userId', isEqualTo: userId).limit(1).get();

    if (querySnapshot.docs.isEmpty) {
      final newCartId = cartCollection.doc().id; // Tạo ID tự động
      final newCart = Cart(
          id: newCartId,
          userId: userId,
          productIdAndQuantity: {},
          listShopId: [],
          productVariantIndexes: {},
          productOptionIndexes: {});
      await cartCollection.doc(newCartId).set(newCart.toMap());
    }
  }

  Future<void> signUpWithPhone(
      String phoneNumber, Function(String) onCodeSent) async {
    String formattedPhone = phoneNumber;
    if (phoneNumber.startsWith('0')) {
      formattedPhone = '+84${phoneNumber.substring(1)}';
    }
    print('Số điện thoại gửi đi: $formattedPhone');

    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: formattedPhone,
      verificationCompleted: (PhoneAuthCredential credential) async {},
      verificationFailed: (FirebaseAuthException e) {
        throw Exception('Xác thực thất bại: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        print('Mã đã gửi, verificationId: $verificationId');
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print('Hết thời gian tự động lấy mã: $verificationId');
      },
    );
  }

  Future<UserCredential> verifyPhoneCode(
      String verificationId, String smsCode) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    UserCredential userCredential =
        await _firebaseAuth.signInWithCredential(credential);
    User? user = userCredential.user;
    if (user != null) {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('id', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        String username = generateRandomUsername();
        bool isUsernameTaken = await checkUSerNameExits(username);

        while (isUsernameTaken) {
          username = generateRandomUsername();
          isUsernameTaken = await checkUSerNameExits(username);
        }

        UserInfoModel newUser = UserInfoModel(
          id: user.uid,
          name: user.displayName ?? "Người dùng",
          email: user.email,
          phone: user.phoneNumber,
          avataUrl: user.photoURL,
          gender: null,
          date: null,
          userName: username,
          role: 0,
        );
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(newUser.toMap(), SetOptions(merge: true));
      }
      await createCartForUser(user.uid);
    }
    return userCredential;
  }

  Future<UserCredential> signInWithFacebook() async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

    try {
      final LoginResult loginResult = await FacebookAuth.instance.login(
        permissions: ['public_profile'],
      );
      if (loginResult.status != LoginStatus.success) {
        throw Exception('Đăng nhập thất bại: ${loginResult.message}');
      }

      print('Access Token: ${loginResult.accessToken!.tokenString}');
      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);

      late UserCredential userCredential;
      try {
        userCredential =
            await _firebaseAuth.signInWithCredential(facebookAuthCredential);
        print('Đăng nhập thành công: ${userCredential.user?.displayName}');
        User? user = userCredential.user;
        if (user != null) {
          await createCartForUser(user.uid);
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {}
      }
      return userCredential;
    } catch (e) {
      print('Lỗi: $e');
      rethrow;
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();

      if (googleSignInAccount == null) {
        throw Exception("Kết nối Google thất bại");
      }

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      if (googleSignInAuthentication.accessToken == null ||
          googleSignInAuthentication.idToken == null) {
        throw Exception("Thiếu thông tin xác thực");
      }

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken!,
        idToken: googleSignInAuthentication.idToken!,
      );

      UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      User? firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception("Không thể lấy thông tin người dùng");
      }

      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('id', isEqualTo: firebaseUser.uid)
          .limit(1)
          .get();

      late UserInfoModel user;
      if (querySnapshot.docs.isEmpty) {
        String username = generateRandomUsername();
        bool isUsernameTaken = await checkUSerNameExits(username);

        while (isUsernameTaken) {
          username = generateRandomUsername();
          isUsernameTaken = await checkUSerNameExits(username);
        }
        user = UserInfoModel(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? "Người dùng Google",
          email: firebaseUser.email,
          phone: firebaseUser.phoneNumber,
          avataUrl: firebaseUser.photoURL,
          gender: null,
          date: null,
          userName: username,
          role: 0,
        );
        await _firestore
            .collection('users')
            .doc(user.id)
            .set(user.toMap(), SetOptions(merge: true));
      } else {
        user = UserInfoModel.fromFirestore(
            querySnapshot.docs.first.data() as Map<String, dynamic>);
      }

      await createCartForUser(firebaseUser.uid);

      return userCredential;
    } catch (e) {
      print('Lỗi đăng nhập Google: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }
}
