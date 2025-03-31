import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luanvan/models/comment.dart';
import 'package:luanvan/models/shop_comment.dart';

class CommentService {
  final FirebaseFirestore _firestore;

  CommentService({FirebaseFirestore? firestoreInstance})
      : _firestore = firestoreInstance ?? FirebaseFirestore.instance;

  // Lấy tất cả comment của một sản phẩm
  Future<List<Comment>> getCommentsByProductId(String productId) async {
    final response = await _firestore
        .collection('comments')
        .where('productId', isEqualTo: productId)
        .get();
    return response.docs.map((doc) => Comment.fromMap(doc.data())).toList();
  }

  // Lấy tất cả comment của một user
  Stream<List<Comment>> getCommentsByUserId(String userId) {
    return _firestore
        .collection('comments')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Comment.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  // Lấy trung bình rating của sản phẩm từ collection products
  Future<double> getAverageRating(String productId) async {
    try {
      final docSnapshot =
          await _firestore.collection('products').doc(productId).get();
      if (!docSnapshot.exists) return 0.0;
      return (docSnapshot.data()?['averageRating'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      print('Error getting average rating: $e');
      throw Exception('Failed to get average rating: $e');
    }
  }

  // Cập nhật average rating cho sản phẩm
  Future<void> updateProductAverageRating(String productId) async {
    try {
      // Lấy tất cả comment của sản phẩm
      final commentsSnapshot = await _firestore
          .collection('comments')
          .where('productId', isEqualTo: productId)
          .get();

      if (commentsSnapshot.docs.isEmpty) {
        // Nếu không có comment, set rating về 0
        await _firestore.collection('products').doc(productId).update({
          'averageRating': 0.0,
        });
        return;
      }

      // Tính tổng rating từ tất cả comment
      final totalRating = commentsSnapshot.docs.fold<double>(
        0,
        (sum, doc) => sum + (doc.data()['rating'] as num).toDouble(),
      );

      // Tính average rating mới
      final newAverageRating = totalRating / commentsSnapshot.docs.length;

      // Cập nhật average rating mới vào document sản phẩm
      await _firestore.collection('products').doc(productId).update({
        'averageRating': newAverageRating,
      });
    } catch (e) {
      print('Error updating product average rating: $e');
      throw Exception('Failed to update product average rating: $e');
    }
  }

  // Tạo comment mới
  Future<List<Comment>> createComment(
      List<Comment> comments, ShopComment shopComment) async {
    try {
      List<Comment> createdComments = [];

      // Create all comments sequentially
      for (var comment in comments) {
        try {
          // Create the comment document
          final docRef =
              await _firestore.collection('comments').add(comment.toMap());

          // Update the document with its ID
          await docRef.update({'id': docRef.id});

          // Get the updated document
          final doc = await docRef.get();

          // Create the comment object and add to list
          final createdComment =
              Comment.fromMap({...doc.data()!, 'id': doc.id});
          createdComments.add(createdComment);

          // Update product average rating
          await updateProductAverageRating(comment.productId);
        } catch (e) {
          throw Exception('Failed to create comment: $e');
        }
      }

      // Create shop comment separately
      try {
        final shopCommentRef = await _firestore
            .collection('shopComments')
            .add(shopComment.toMap());
        await shopCommentRef.update({'id': shopCommentRef.id});
        print('Created shop comment with ID: ${shopCommentRef.id}');
      } catch (e) {
        print('Error creating shop comment: $e');
        throw Exception('Failed to create shop comment: $e');
      }

      return createdComments;
    } catch (e) {
      print('Error in createComment: $e');
      throw Exception('Failed to create comments: $e');
    }
  }

  // Cập nhật comment
  Future<Comment> updateComment(Comment comment) async {
    try {
      final docRef = _firestore.collection('comments').doc(comment.id);
      await docRef.update(comment.toMap());
      return comment;
    } catch (e) {
      throw Exception('Failed to update comment: $e');
    }
  }

  // Xóa comment
  Future<void> deleteComment(String commentId) async {
    try {
      await _firestore.collection('comments').doc(commentId).delete();
    } catch (e) {
      throw Exception('Failed to delete comment: $e');
    }
  }

  // Lấy số lượng comment của sản phẩm
  Future<int> getCommentCount(String productId) async {
    try {
      final querySnapshot = await _firestore
          .collection('comments')
          .where('productId', isEqualTo: productId)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get comment count: $e');
    }
  }

  // Cập nhật reply cho comment
  Future<Comment> updateCommentReply(String commentId, String reply) async {
    try {
      final docRef = _firestore.collection('comments').doc(commentId);
      await docRef.update({
        'reply': reply,
        'replyAt': DateTime.now().toIso8601String(),
      });
      final doc = await docRef.get();
      return Comment.fromMap({...doc.data()!, 'id': doc.id});
    } catch (e) {
      throw Exception('Failed to update comment reply: $e');
    }
  }

  // Lấy comment có reply
  Stream<List<Comment>> getCommentsWithReply(String productId) {
    return _firestore
        .collection('comments')
        .where('productId', isEqualTo: productId)
        .where('reply', isNull: false)
        .orderBy('replyAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Comment.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  // Lấy comment đã xác thực mua hàng
  Stream<List<Comment>> getVerifiedComments(String productId) {
    return _firestore
        .collection('comments')
        .where('productId', isEqualTo: productId)
        .where('isVerified', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Comment.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }
}
