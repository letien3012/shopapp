// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:luanvan/models/product.dart';
// import 'package:luanvan/services/chatbot_service.dart';
// import 'package:luanvan/services/product_service.dart';
// import 'package:luanvan/rag/product_chunk.dart';

// class ChatbotScreen extends StatefulWidget {
//   static String routeName = 'chatbot_screen';

//   @override
//   _ChatbotScreenState createState() => _ChatbotScreenState();
// }

// class _ChatbotScreenState extends State<ChatbotScreen> {
//   final TextEditingController _controller = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   final List<Map<String, dynamic>> messages = [];
//   String _streamingMessage = '';

//   void _sendMessage() async {
//     final query = _controller.text.trim();
//     if (query.isEmpty) return;

//     setState(() {
//       messages.add({
//         'text': query,
//         'isUser': true,
//         'time': DateTime.now(),
//         'isImage': false,
//       });
//       _controller.clear();
//     });
//     _scrollToBottom();

//     // Khung trống để stream vào
//     setState(() {
//       _streamingMessage = '';
//       messages.add({
//         'text': _streamingMessage,
//         'isUser': false,
//         'time': DateTime.now(),
//         'isImage': false,
//       });
//     });

//     // Lấy context từ Firebase
//     final allProducts = await FirebaseFirestore.instance
//         .collection('products')
//         .where('isDeleted', isEqualTo: false)
//         .where('isHidden', isEqualTo: false)
//         .get();
//     final contextChunks = await Future.wait(allProducts.docs.map((e) async {
//       return await generateProductChunks(Product.fromFirestore(e));
//     }));
//     final context = contextChunks.join('\n');

//     // Stream dữ liệu từ LLM
//     final stream = ChatbotService().generateAnswerStream(query, context);
//     await for (final chunk in stream) {
//       print(chunk);
//       final isImage = Uri.tryParse(chunk)?.isAbsolute == true &&
//           (chunk.endsWith('.jpg') ||
//               chunk.endsWith('.png') ||
//               chunk.startsWith('http'));

//       if (isImage) {
//         // Nếu là ảnh, thêm riêng vào messages
//         setState(() {
//           messages.add({
//             'text': chunk,
//             'isUser': false,
//             'time': DateTime.now(),
//             'isImage': true,
//           });
//         });
//       } else {
//         // Nếu là text, tiếp tục stream
//         setState(() {
//           _streamingMessage += chunk;
//           messages[messages.length - 1]['text'] = _streamingMessage;
//         });
//       }
//       _scrollToBottom();
//     }
//   }

//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent + 60,
//           duration: Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   Widget _buildMessageContent(String text, bool isUser, bool isImage) {
//     if (isImage) {
//       return ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: Image.network(
//           text,
//           width: 200,
//           fit: BoxFit.cover,
//           errorBuilder: (context, error, stackTrace) => Text('❌ Lỗi ảnh'),
//         ),
//       );
//     } else {
//       return Text(
//         text,
//         style: TextStyle(
//           color: isUser ? Colors.white : Colors.black87,
//           fontSize: 16,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Chatbot'),
//         backgroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: Container(
//         color: Colors.grey[100],
//         child: Column(
//           children: [
//             Expanded(
//               child: ListView.builder(
//                 controller: _scrollController,
//                 padding: EdgeInsets.all(16),
//                 itemCount: messages.length,
//                 itemBuilder: (context, index) {
//                   final message = messages[index];
//                   final isUser = message['isUser'] as bool;
//                   final time = message['time'] as DateTime;
//                   final isImage = message['isImage'] ?? false;
//                   return Align(
//                     alignment:
//                         isUser ? Alignment.centerRight : Alignment.centerLeft,
//                     child: Container(
//                       margin: EdgeInsets.only(bottom: 16),
//                       constraints: BoxConstraints(
//                         maxWidth: MediaQuery.of(context).size.width * 0.75,
//                       ),
//                       child: Column(
//                         crossAxisAlignment: isUser
//                             ? CrossAxisAlignment.end
//                             : CrossAxisAlignment.start,
//                         children: [
//                           Container(
//                             padding: EdgeInsets.symmetric(
//                                 horizontal: 16, vertical: 10),
//                             decoration: BoxDecoration(
//                               color: isUser ? Colors.blue[500] : Colors.white,
//                               borderRadius: BorderRadius.only(
//                                 topLeft: Radius.circular(16),
//                                 topRight: Radius.circular(16),
//                                 bottomLeft: Radius.circular(isUser ? 16 : 4),
//                                 bottomRight: Radius.circular(isUser ? 4 : 16),
//                               ),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.1),
//                                   blurRadius: 4,
//                                   offset: Offset(0, 2),
//                                 ),
//                               ],
//                             ),
//                             child: _buildMessageContent(
//                               message['text'],
//                               isUser,
//                               isImage,
//                             ),
//                           ),
//                           Padding(
//                             padding: EdgeInsets.only(top: 4),
//                             child: Text(
//                               DateFormat('HH:mm').format(time),
//                               style: TextStyle(
//                                 color: Colors.grey[600],
//                                 fontSize: 12,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             Container(
//               color: Colors.white,
//               padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: Colors.grey[100],
//                         borderRadius: BorderRadius.circular(24),
//                       ),
//                       child: TextField(
//                         controller: _controller,
//                         decoration: InputDecoration(
//                           hintText: 'Gửi đến chatbot...',
//                           border: InputBorder.none,
//                           contentPadding: EdgeInsets.symmetric(
//                               horizontal: 16, vertical: 12),
//                         ),
//                         maxLines: null,
//                         textInputAction: TextInputAction.newline,
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 8),
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.blue[500],
//                       shape: BoxShape.circle,
//                     ),
//                     child: IconButton(
//                       icon: Icon(Icons.send, color: Colors.white),
//                       onPressed: _sendMessage,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:luanvan/services/chatbot_service.dart';

class ChatbotScreen extends StatefulWidget {
  static String routeName = 'chatbot_screen';

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> messages = [];
  List<Map<String, String>> chatHistory = [];

  void _sendMessage() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      messages.add({
        'text': query,
        'isUser': true,
        'time': DateTime.now(),
        'isImage': false,
      });
      _controller.clear();
    });
    _scrollToBottom();

    // Gọi API không stream
    final answer = await ChatbotService().generateAnswer(query, chatHistory);
    chatHistory.add({"role": "user", "content": query});
    chatHistory.add({"role": "assistant", "content": answer});
    _handleTextWithImages(answer);
    _scrollToBottom();
  }

  void _handleTextWithImages(String fullAnswer) {
    final regex = RegExp(r'(https?:\/\/\S+\.(jpg|png|jpeg))');
    final matches = regex.allMatches(fullAnswer);

    int currentIndex = 0;
    String combinedText = '';

    for (final match in matches) {
      final start = match.start;
      final end = match.end;

      // Thêm phần text trước ảnh (nếu có)
      if (start > currentIndex) {
        final textPart = fullAnswer.substring(currentIndex, start).trim();
        if (textPart.isNotEmpty) {
          combinedText += textPart + '\n';
        }
      }

      // Thêm ảnh
      final imageUrl = fullAnswer.substring(start, end);
      combinedText += imageUrl + '\n';

      currentIndex = end;
    }

    // Thêm phần text còn lại (sau ảnh cuối)
    if (currentIndex < fullAnswer.length) {
      final remainingText = fullAnswer.substring(currentIndex).trim();
      if (remainingText.isNotEmpty) {
        combinedText += remainingText;
      }
    }

    // Thêm toàn bộ nội dung vào messages
    messages.add({
      'text': combinedText.trim(),
      'isUser': false,
      'time': DateTime.now(),
      'isImage': false,
    });

    setState(() {}); // cập nhật UI
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 60,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMessageContent(String text, bool isUser, bool isImage) {
    if (text.contains('http') &&
        (text.contains('.jpg') ||
            text.contains('.png') ||
            text.contains('.jpeg'))) {
      // Nếu text chứa URL ảnh, tách thành các phần và hiển thị
      final parts = text.split('\n');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: parts.map((part) {
          if (part.startsWith('http') &&
              (part.endsWith('.jpg') ||
                  part.endsWith('.png') ||
                  part.endsWith('.jpeg'))) {
            return Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  part,
                  width: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Text('❌ Lỗi ảnh'),
                ),
              ),
            );
          } else {
            return Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                part,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
              ),
            );
          }
        }).toList(),
      );
    } else {
      return Text(
        text,
        style: TextStyle(
          color: isUser ? Colors.white : Colors.black87,
          fontSize: 16,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chatbot'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey[100],
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isUser = message['isUser'] as bool;
                  final time = message['time'] as DateTime;
                  final isImage = message['isImage'] ?? false;
                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.only(bottom: 16),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      child: Column(
                        crossAxisAlignment: isUser
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isUser ? Colors.blue[500] : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                                bottomLeft: Radius.circular(isUser ? 16 : 4),
                                bottomRight: Radius.circular(isUser ? 4 : 16),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: _buildMessageContent(
                              message['text'],
                              isUser,
                              isImage,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text(
                              DateFormat('HH:mm').format(time),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Gửi đến chatbot...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.newline,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue[500],
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
