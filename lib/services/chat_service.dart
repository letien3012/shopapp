import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luanvan/models/chat_room.dart';
import 'package:luanvan/models/message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<ChatRoom> getChatRoomsById(String chatRoomId) async {
    try {
      final buyerQuery =
          await _firestore.collection('chatRooms').doc(chatRoomId).get();

      return ChatRoom.fromFirestore(buyerQuery.data()!);
    } catch (e) {
      throw Exception('Error fetching chat rooms: $e');
    }
  }

  // Lấy danh sách ChatRoom cho một user (buyer hoặc seller)
  Future<List<ChatRoom>> getChatRoomsForUser(String userId) async {
    try {
      final buyerQuery = await _firestore
          .collection('chatRooms')
          .where('buyerId', isEqualTo: userId)
          .get();

      return buyerQuery.docs
          .map((doc) => ChatRoom.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error fetching chat rooms: $e');
    }
  }

  Future<List<ChatRoom>> getChatRoomsForShop(String shopId) async {
    try {
      final shopQuery = await _firestore
          .collection('chatRooms')
          .where('shopId', isEqualTo: shopId)
          .get();

      return shopQuery.docs
          .map((doc) => ChatRoom.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error fetching chat rooms: $e');
    }
  }

  // Lấy danh sách Message cho một ChatRoom
  Future<List<Message>> getMessages(String chatRoomId) async {
    try {
      final querySnapshot = await _firestore
          .collection('messages')
          .where('chatRoomId', isEqualTo: chatRoomId)
          .get();

      List<Message> messages = querySnapshot.docs
          .map((doc) => Message.fromFirestore(doc.data()))
          .toList();

      // if (messages.isNotEmpty) {
      //   messages.sort((a, b) => b.sentAt.compareTo(a.sentAt));
      // }
      return messages;
    } catch (e) {
      throw Exception('Error fetching messages: $e');
    }
  }

  // Gửi tin nhắn
  Future<void> sendMessage(Message message) async {
    try {
      await _firestore
          .collection('messages')
          .doc(message.messageId)
          .set(message.toMap());

      // Cập nhật lastMessageId, lastMessageSenderId và unreadCount trong ChatRoom
      await _firestore.collection('chatRooms').doc(message.chatRoomId).update({
        'lastMessageId': message.messageId,
        'lastMessageSenderId': message.senderId,
        'unreadCountBuyer':
            message.senderId == (await _getBuyerId(message.chatRoomId))
                ? FieldValue.increment(0)
                : FieldValue.increment(1),
        'unreadCountShop':
            message.senderId == (await _getOwnerId(message.chatRoomId))
                ? FieldValue.increment(0)
                : FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  Future<void> updateRead(bool isShop, String chatRoomId) async {
    try {
      if (isShop) {
        await _firestore.collection('chatRooms').doc(chatRoomId).update({
          'unreadCountShop': 0,
        });
      } else {
        await _firestore.collection('chatRooms').doc(chatRoomId).update({
          'unreadCountBuyer': 0,
        });
      }
    } catch (e) {
      throw Exception('Lỗi cập nhật trạng thái đọc');
    }
  }

  Future<ChatRoom> startChat(String buyerId, String shopId) async {
    try {
      final query = await _firestore
          .collection('chatRooms')
          .where('buyerId', isEqualTo: buyerId)
          .where('shopId', isEqualTo: shopId)
          .get();

      if (query.docs.isNotEmpty) {
        return ChatRoom.fromFirestore(query.docs.first.data());
      } else {
        final newChatRoom = ChatRoom(
          chatRoomId: '$buyerId-$shopId',
          buyerId: buyerId,
          shopId: shopId,
          createdAt: DateTime.now(),
          isActive: true,
          lastMessageSenderId: buyerId,
        );
        await _firestore
            .collection('chatRooms')
            .doc(newChatRoom.chatRoomId)
            .set(newChatRoom.toMap());
        return newChatRoom;
      }
    } catch (e) {
      throw Exception('Error starting chat: $e');
    }
  }

  // Đánh dấu tin nhắn là đã đọc
  Future<void> markMessageAsRead(String messageId) async {
    try {
      await _firestore
          .collection('messages')
          .doc(messageId)
          .update({'isRead': true});
    } catch (e) {
      throw Exception('Error marking message as read: $e');
    }
  }

  // Helper: Lấy danh sách shopId của user
  Future<List<String>> _getOwnedShopIds(String userId) async {
    final query = await _firestore
        .collection('shops')
        .where('ownerId', isEqualTo: userId)
        .get();
    return query.docs.map((doc) => doc.id).toList();
  }

  // Helper: Lấy buyerId từ chatRoomId
  Future<String> _getBuyerId(String chatRoomId) async {
    final doc = await _firestore.collection('chatRooms').doc(chatRoomId).get();
    return doc.data()!['buyerId'] as String;
  }

  // Helper: Lấy ownerId từ shopId trong chatRoom
  Future<String> _getOwnerId(String chatRoomId) async {
    final doc = await _firestore.collection('chatRooms').doc(chatRoomId).get();
    return doc.data()!['shopId'] as String;
  }

  // Stream để lấy tin nhắn theo thời gian thực
  Stream<List<Message>> getMessagesStream(String chatRoomId) {
    return _firestore
        .collection('messages')
        .where('chatRoomId', isEqualTo: chatRoomId)
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Message.fromFirestore(doc.data()))
            .toList());
  }
}
