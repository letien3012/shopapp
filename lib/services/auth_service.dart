import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:luanvan/models/shop.dart';
import 'package:printing/printing.dart';
import '../models/user_info_model.dart';
import '../models/cart.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final String _defaultAvtarUrl =
      'https://res.cloudinary.com/deegjkzbd/image/upload/v1743234974/default-avatar_o0kinr.jpg';
  String generateRandomUsername() {
    final random = Random();
    const characters = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return 'user_' +
        List.generate(8, (_) => characters[random.nextInt(characters.length)])
            .join();
  }

  Future<User> changeEmail(String email) async {
    await _firebaseAuth.currentUser?.verifyBeforeUpdateEmail(email);
    await _firebaseAuth.currentUser?.reload();
    await _firestore
        .collection('users')
        .doc(_firebaseAuth.currentUser!.uid)
        .update({
      'email': email,
    });
    return _firebaseAuth.currentUser!;
  }

  Future<Shop?> checkAdmin(String email) async {
    QuerySnapshot query = await _firestore
        .collection('shops')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) {
      return Shop.fromFirestore(
          query.docs.first as DocumentSnapshot<Map<String, dynamic>>);
    }
    return null;
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
      final newCartId = cartCollection.doc().id;
      final newCart = Cart(
        id: newCartId,
        userId: userId,
        shops: [],
      );
      await cartCollection.doc(newCartId).set(newCart.toMap());
    }
  }

  Future<void> signUpWithPhone(
      String phoneNumber, Function(String) onCodeSent) async {
    String formattedPhone = phoneNumber;

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

  Future<User?> onSignUpWithEmailAndPassword(
      String email, String password) async {
    User? user = _firebaseAuth.currentUser;
    await user?.updatePassword(password);
    // UserCredential userCredential = await _firebaseAuth
    //     .signInWithEmailAndPassword(email: email, password: password);
    // User? user = userCredential.user;
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
          name: user.displayName,
          email: user.email,
          phone: user.phoneNumber,
          avataUrl: user.photoURL ?? _defaultAvtarUrl,
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
    return user;
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
          avataUrl: user.photoURL ?? _defaultAvtarUrl,
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
          QuerySnapshot querySnapshot = await _firestore
              .collection('users')
              .where('id', isEqualTo: user.uid)
              .limit(1)
              .get();

          late UserInfoModel userInfo;
          if (querySnapshot.docs.isEmpty) {
            String username = generateRandomUsername();
            bool isUsernameTaken = await checkUSerNameExits(username);

            while (isUsernameTaken) {
              username = generateRandomUsername();
              isUsernameTaken = await checkUSerNameExits(username);
            }
            userInfo = UserInfoModel(
              id: user.uid,
              name: user.displayName ?? "Người dùng Facebook",
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
                .doc(userInfo.id)
                .set(userInfo.toMap(), SetOptions(merge: true));
          } else {
            userInfo = UserInfoModel.fromFirestore(
                querySnapshot.docs.first.data() as Map<String, dynamic>);
          }

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
    await FacebookAuth.instance.logOut();
  }

  Future<UserCredential> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        String username = generateRandomUsername();
        bool isUsernameTaken = await checkUSerNameExits(username);
        while (isUsernameTaken) {
          username = generateRandomUsername();
          isUsernameTaken = await checkUSerNameExits(username);
        }

        final UserInfoModel userInfo = UserInfoModel(
          id: userCredential.user!.uid,
          name: userCredential.user!.displayName,
          email: email,
          phone: userCredential.user!.phoneNumber,
          avataUrl: userCredential.user!.photoURL ?? _defaultAvtarUrl,
          gender: null,
          date: null,
          userName: username,
          role: 0,
        );

        await _firestore
            .collection('users')
            .doc(userInfo.id)
            .set(userInfo.toMap(), SetOptions(merge: true));

        await createCartForUser(userCredential.user!.uid);
      }

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print(e.code);
      if (e.code == 'user-not-found') {
        throw Exception('Tài khoản không tồn tại.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Mật khẩu không chính xác.');
      } else {
        throw Exception('Đăng nhập thất bại: ${e.message}');
      }
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> verifyEmail(String verificationId) async {
    try {
      await _firebaseAuth.currentUser?.reload();
      if (!_firebaseAuth.currentUser!.emailVerified) {
        throw Exception('Email chưa được xác thực');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendEmailVerificationBeforeUpdateEmail(String email) async {
    try {
      await _firebaseAuth.currentUser?.verifyBeforeUpdateEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendEmailVerification(String email) async {
    try {
      try {
        final UserCredential userExits =
            await _firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: 'temporary_password',
        );
        if (userExits.user != null) {
          print('Tài khoản đã tồn tại');
          userExits.user!.delete();
        }
        final UserCredential userCredential =
            await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: 'temporary_password',
        );
        final user = userCredential.user;
        if (user == null) {
          throw Exception('Không tìm thấy người dùng');
        }
        await user.sendEmailVerification();
        await Future.delayed(const Duration(seconds: 1));
        await user.reload();
        if (!user.emailVerified) {
          // print('Email xác thực đã được gửi đến ${user.email}');
        }
      } on FirebaseAuthException catch (e) {
        final UserCredential userCredential =
            await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: 'temporary_password',
        );
        final user = userCredential.user;
        if (user == null) {
          throw Exception('Không tìm thấy người dùng');
        }
        await user.sendEmailVerification();
        await Future.delayed(const Duration(seconds: 1));
        await user.reload();
        if (!user.emailVerified) {
          // print('Email xác thực đã được gửi đến ${user.email}');
        }
      }
    } catch (e) {
      print('Lỗi gửi email xác thực: $e');
      rethrow;
    }
  }

  Future<bool> isEmailVerified() async {
    try {
      await _firebaseAuth.currentUser?.reload();
      return _firebaseAuth.currentUser?.emailVerified ?? false;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      return _firebaseAuth.currentUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> reloadUser() async {
    try {
      await _firebaseAuth.currentUser?.reload();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> checkPhoneNumberExists(String phoneNumber) async {
    try {
      // Kiểm tra trong collection users
      final querySnapshot = await _firestore
          .collection('users')
          .where('phone', isEqualTo: phoneNumber)
          .limit(1)
          .get();
      final querySnapshotShop = await _firestore
          .collection('shops')
          .where('phone', isEqualTo: phoneNumber)
          .limit(1)
          .get();
      return querySnapshot.docs.isNotEmpty || querySnapshotShop.docs.isNotEmpty;
    } catch (e) {
      print('Lỗi kiểm tra số điện thoại: $e');
      rethrow;
    }
  }

  Future<bool> checkEmailExists(String email) async {
    try {
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      return result.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check email existence: $e');
    }
  }
}
