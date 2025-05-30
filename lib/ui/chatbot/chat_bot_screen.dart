import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:luanvan/models/product_chatbot.dart';
import 'package:luanvan/services/chatbot_service.dart';
import 'package:luanvan/ui/home/detai_item_screen.dart';

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
  final FocusNode _chatbotSearch = FocusNode();
  double keyboardSize = 0;
  @override
  initState() {
    super.initState();
    _chatbotSearch.addListener(
      () {
        if (_chatbotSearch.hasFocus) {
          setState(() {
            keyboardSize = 225;
          });
        } else {
          setState(() {
            keyboardSize = 0;
          });
        }
      },
    );
  }

  List<ProductChatbot> parseProductsFromLLM(String content) {
    try {
      // Nếu content là một mảng JSON
      if (content.trim().startsWith('[')) {
        final decoded = json.decode(content) as List;
        return decoded
            .map(
                (item) => ProductChatbot.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      // Nếu content là một object JSON
      if (content.trim().startsWith('{')) {
        final decoded = json.decode(content) as Map<String, dynamic>;
        return [ProductChatbot.fromJson(decoded)];
      }

      return [];
    } catch (e) {
      print('Lỗi khi parse JSON từ LLM: $e');
      print('Content gây lỗi: $content');
      return [];
    }
  }

  Map<String, dynamic> splitAnswerAndJson(String content) {
    try {
      // Tìm JSON trong ```json ... ```
      final jsonStart = content.indexOf('[{');
      final jsonEnd = content.lastIndexOf('}]');
      if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
        final answerText = content.substring(0, jsonStart).trim();
        final jsonText = content.substring(jsonStart, jsonEnd + 2).trim();
        return {
          'text': answerText,
          'json': jsonText,
        };
      }

      // Nếu không tìm thấy JSON, trả về toàn bộ là text
      return {
        'text': content.trim(),
        'json': '[]',
      };
    } catch (e) {
      print('Lỗi khi tách answer và JSON: $e');
      return {
        'text': content.trim(),
        'json': '[]',
      };
    }
  }

  @override
  void dispose() {
    _chatbotSearch.removeListener(() {});
    super.dispose();
  }

  void _sendMessage() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      messages.add({
        'text': query,
        'isUser': true,
        'time': DateTime.now(),
        'isImage': false,
        'listProducts': <ProductChatbot>[],
      });
      _controller.clear();
    });
    _scrollToBottom();

    // Gọi API không stream
    final answer = await ChatbotService().generateAnswer(query, chatHistory);
    chatHistory.add({"role": "user", "content": query});
    chatHistory.add({"role": "assistant", "content": answer});
    final result = splitAnswerAndJson(answer);
    final answerText = result['text'];
    final productJson = result['json'];
    List<ProductChatbot> products = [];
    if (productJson.isNotEmpty) {
      products = parseProductsFromLLM(productJson);
    }
    setState(() {
      messages.add({
        'text': answerText.trim(),
        'isUser': false,
        'time': DateTime.now(),
        'isImage': false,
        'listProducts': products,
      });
    });
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
        automaticallyImplyLeading: false,
        title: Center(child: Text('Chatbot')),
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
                  final listProducts =
                      message['listProducts'] as List<ProductChatbot>;

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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildMessageContent(
                                  message['text'],
                                  isUser,
                                  isImage,
                                ),
                                if (!isUser && listProducts.isNotEmpty) ...[
                                  SizedBox(height: 10),
                                  Text(
                                    'Sản phẩm gợi ý:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  ...listProducts
                                      .map((product) => Padding(
                                            padding:
                                                EdgeInsets.only(bottom: 10),
                                            child: Row(
                                              children: [
                                                Image.network(
                                                  product.imageUrl,
                                                  width: 80,
                                                  height: 80,
                                                  fit: BoxFit.cover,
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    padding: EdgeInsets.only(
                                                        left: 10),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          '• ${product.name}',
                                                          style: TextStyle(
                                                              fontSize: 14),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        Text(
                                                          '${product.price}',
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      151,
                                                                      14,
                                                                      4)),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            Navigator.pushNamed(
                                                                context,
                                                                DetaiItemScreen
                                                                    .routeName,
                                                                arguments: product
                                                                    .productId);
                                                          },
                                                          child: Text(
                                                            'Xem chi tiết',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.blue,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ))
                                      .toList(),
                                ],
                              ],
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
            SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.only(bottom: keyboardSize),
              child: Container(
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
                          focusNode: _chatbotSearch,
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: 'Gửi đến chatbot...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          maxLines: null,
                          textInputAction: TextInputAction.newline,
                          onTapOutside: (event) => _chatbotSearch.unfocus(),
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
            ),
          ],
        ),
      ),
    );
  }
}
