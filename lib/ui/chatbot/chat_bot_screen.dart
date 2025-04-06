import 'package:flutter/material.dart';
import 'package:luanvan/services/chatbot_service.dart';
import 'package:luanvan/services/product_service.dart';

class ChatbotScreen extends StatefulWidget {
  static String routeName = 'chatbot_screen';
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  TextEditingController _controller = TextEditingController();
  List<String> messages = [];

  void _sendMessage() async {
    final query = _controller.text;
    setState(() {
      messages.add('You: $query');
      _controller.clear();
    });

    final relevantProducts = await ChatbotService().searchProducts(query);

    final answer =
        await ChatbotService().generateAnswer(query, relevantProducts);
    print(answer);
    setState(() {
      messages.add('Bot: $answer');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chatbot'),
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.white,
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(messages[index]),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration:
                          InputDecoration(hintText: 'Ask me anything...'),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: _sendMessage,
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
