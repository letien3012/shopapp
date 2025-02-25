import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key});
  static String routeName = "chat_detail_screen";
  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _chatController = TextEditingController();
  bool _showSendButton = false;

  @override
  void initState() {
    super.initState();
    _chatController.addListener(() {
      setState(() {
        _showSendButton = _chatController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 30, bottom: 10),
            color: Colors.white,
            height: MediaQuery.of(context).size.height * 0.1,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 10,
                ),
                const Icon(
                  Icons.arrow_back,
                  size: 28,
                  color: Colors.brown,
                ),
                const SizedBox(
                  width: 10,
                ),
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.brown,
                  child: ClipOval(
                    child: Image.network(
                        height: 40,
                        width: 40,
                        fit: BoxFit.cover,
                        'https://e7.pngegg.com/pngimages/84/165/png-clipart-united-states-avatar-organization-information-user-avatar-service-computer-wallpaper-thumbnail.png'),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                const Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Tên người nhận',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                    ),
                    Text(
                      "Truy cập 10 phút trước",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey),
                    )
                  ],
                ))
              ],
            ),
          ),
          Positioned.fill(
            top: MediaQuery.of(context).size.height * 0.1,
            child: Container(
              padding: EdgeInsets.only(top: 10, left: 10, right: 10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
              ),
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).size.height * 0.1 -
                        10 -
                        60,
                  ),
                  child: Column(
                    children: [
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 60),
                        itemCount: 11,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return Row(
                            mainAxisAlignment: index % 2 == 0
                                ? MainAxisAlignment.start
                                : MainAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width * 0.7,
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: index % 2 == 0
                                          ? Colors.grey[300]
                                          : Colors.green[200],
                                      borderRadius: BorderRadius.circular(10)),
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: const Text("Đây là tin nhắn Đ"),
                                ),
                              ),
                            ],
                          );
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              height: 60,
              decoration: const BoxDecoration(color: Colors.white),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: const Icon(
                      HeroIcons.plus_circle,
                      size: 30,
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey[400]!)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: TextField(
                              controller: _chatController,
                              decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Soạn tin...'),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: const Icon(
                              Icons.emoji_emotions,
                              size: 30,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          )
                        ],
                      ),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      );
                    },
                    child: _showSendButton
                        ? IconButton(
                            key: const ValueKey("sendButton"),
                            icon: const Icon(Icons.send, color: Colors.brown),
                            onPressed: () {
                              // Xử lý gửi nội dung
                              print("Gửi: ${_chatController.text}");
                              _chatController.clear();
                            },
                          )
                        : const SizedBox(
                            key: ValueKey("empty"),
                            width: 0,
                          ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
