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
        // Tạo thông tin user trong Firestore
        String username = generateRandomUsername();
        bool isUsernameTaken = await checkUSerNameExits(username);

        while (isUsernameTaken) {
          username = generateRandomUsername();
          isUsernameTaken = await checkUSerNameExits(username);
        }

        final UserInfoModel userInfo = UserInfoModel(
          id: userCredential.user!.uid,
          name: userCredential.user!.displayName ?? "Người dùng",
          email: email,
          phone: userCredential.user!.phoneNumber,
          avataUrl: userCredential.user!.photoURL,
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
    } catch (e) {
      rethrow;
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

  Future<void> sendEmailVerification() async {
    try {
      await _firebaseAuth.currentUser?.sendEmailVerification();
    } catch (e) {
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

  Future<void> sendEmailVerificationCode(String email) async {
    try {
      // Tạo mã xác thực ngẫu nhiên 6 chữ số
      final code =
          (100000 + DateTime.now().millisecondsSinceEpoch % 900000).toString();

      // Lưu mã xác thực vào Firestore với thời gian hết hạn 5 phút
      await _firestore.collection('verification_codes').add({
        'email': email,
        'code': code,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': DateTime.now().add(const Duration(minutes: 5)),
      });

      // Gửi email chứa mã xác thực thông qua Cloud Function
      await _firestore.collection('email_queue').add({
        'to': email,
        'subject': 'Mã xác thực email',
        'body': '''
          Xin chào,
          
          Mã xác thực của bạn là: $code
          
          Mã này sẽ hết hạn sau 5 phút.
          
          Nếu bạn không yêu cầu mã này, vui lòng bỏ qua email này.
        ''',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Lỗi gửi mã xác thực: $e');
      rethrow;
    }
  }

  Future<bool> verifyEmailCode(String verificationId, String code) async {
    try {
      // Tìm mã xác thực trong Firestore
      final querySnapshot = await _firestore
          .collection('verification_codes')
          .where('code', isEqualTo: code)
          .where('expiresAt', isGreaterThan: DateTime.now())
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return false;
      }

      // Xóa mã đã sử dụng
      await querySnapshot.docs.first.reference.delete();

      // Cập nhật trạng thái xác thực email của user
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.updateEmail(querySnapshot.docs.first.data()['email']);
        await user.sendEmailVerification();
      }

      return true;
    } catch (e) {
      print('Lỗi xác thực mã: $e');
      return false;
    }
  }
}
