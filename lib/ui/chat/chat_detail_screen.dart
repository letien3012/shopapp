import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/auth/auth_bloc.dart';
import 'package:luanvan/blocs/auth/auth_state.dart';
import 'package:luanvan/blocs/chat/chat_bloc.dart';
import 'package:luanvan/blocs/chat/chat_event.dart';
import 'package:luanvan/blocs/chat/chat_state.dart';
import 'package:luanvan/blocs/shop/shop_bloc.dart';
import 'package:luanvan/blocs/shop/shop_event.dart';
import 'package:luanvan/blocs/shop/shop_state.dart';
import 'package:luanvan/models/shop.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key});
  static String routeName = "chat_detail_screen";

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _chatController = TextEditingController();
  bool _showSendButton = false;
  String _chatRoomId = '';
  String _shopId = '';
  double keyboardSize = 0;
  int _lastMessageCount = 0;
  final FocusNode focusNode = FocusNode();
  final _scrollController = ScrollController();
  bool _isKeyboardVisible = false;

  Shop? shop;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chatRoomId = ModalRoute.of(context)!.settings.arguments as String;
      context.read<ChatBloc>().add(LoadMessagesEvent(_chatRoomId));
      _shopId = _chatRoomId.split('-')[1];
      context.read<ShopBloc>().add(FetchShopEventByShopId(_shopId));
    });

    _chatController.addListener(() {
      setState(() {
        _showSendButton = _chatController.text.trim().isNotEmpty;
      });
    });
    focusNode.addListener(
      () {
        if (focusNode.hasFocus) {
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

  @override
  void dispose() {
    focusNode.dispose();
    _chatController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      return 'Hôm nay';
    }
    return '${date.day} tháng ${date.month}, ${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.read<ChatBloc>().deleteEmptyChatRoom(_chatRoomId);
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is AuthLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (authState is AuthAuthenticated) {
              return SingleChildScrollView(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    children: [
                      _buildAppBar(context),
                      Expanded(
                        child: _buildMessagesArea(context, authState.user.uid),
                      ),
                      _buildInputArea(context, authState.user.uid),
                    ],
                  ),
                ),
              );
            }
            return const Center(child: Text('Vui lòng đăng nhập để chat'));
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return BlocBuilder<ShopBloc, ShopState>(
      builder: (context, shopState) {
        if (shopState is ShopLoaded) {
          shop = shopState.shop;

          return Container(
            padding: const EdgeInsets.only(top: 30, bottom: 10),
            color: Colors.white,
            height: MediaQuery.of(context).size.height * 0.1,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    context.read<ChatBloc>().deleteEmptyChatRoom(_chatRoomId);
                    Navigator.of(context).pop();
                  },
                  child: const Icon(
                    Icons.arrow_back,
                    size: 28,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.brown,
                  child: ClipOval(
                    child: Image.network(
                      height: 40,
                      width: 40,
                      fit: BoxFit.cover,
                      shop!.avatarUrl ?? '',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: BlocBuilder<ChatBloc, ChatState>(
                    builder: (context, chatState) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            shop!.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          const Text(
                            "Truy cập 10 phút trước",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMessagesArea(BuildContext context, String currentUserId) {
    return Container(
      padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
      ),
      child: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is MessagesLoaded && state.chatRoomId == _chatRoomId) {
            final messages = state.messages;
            if (messages.isEmpty) {
              return const Center(
                child: Text(
                  'Chưa có tin nhắn nào. Hãy gửi tin nhắn đầu tiên!',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            if (messages.length != _lastMessageCount) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollController
                    .jumpTo(_scrollController.position.maxScrollExtent);
                _lastMessageCount = messages.length;
              });
            }

            return ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final messageDate = message.sentAt;
                final isSender = message.senderId == currentUserId;

                Widget? dateWidget;
                if (index == 0 ||
                    _shouldShowDate(messages[index - 1].sentAt, messageDate)) {
                  dateWidget = Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _formatDate(messageDate),
                        style:
                            const TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    if (dateWidget != null) dateWidget,
                    Row(
                      mainAxisAlignment: isSender
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.7,
                            ),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSender
                                  ? Colors.lightBlue[100]
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.content,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  _formatTime(messageDate),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.black54,
                                  ),
                                  textAlign: isSender
                                      ? TextAlign.end
                                      : TextAlign.start,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          }
          return const Center(
            child: Text(
              'Chưa có tin nhắn nào. Hãy gửi tin nhắn đầu tiên!',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }

  bool _shouldShowDate(DateTime previous, DateTime current) {
    return previous.day != current.day ||
        previous.month != current.month ||
        previous.year != current.year;
  }

  Widget _buildInputArea(BuildContext context, String userId) {
    return Column(
      children: [
        Container(
          height: 60,
          color: Colors.white,
          padding: const EdgeInsets.all(5),
          child: Row(
            children: [
              // GestureDetector(
              //   onTap: () {},
              //   child: const Icon(
              //     HeroIcons.plus_circle,
              //     size: 30,
              //   ),
              // ),
              const SizedBox(width: 5),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          focusNode: focusNode,
                          controller: _chatController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Soạn tin...',
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                          onTap: () {
                            FocusScope.of(context).requestFocus(focusNode);
                          },
                          onSubmitted: (value) {
                            context.read<ChatBloc>().add(
                                  SendMessageEvent(
                                    chatRoomId: _chatRoomId,
                                    senderId: userId,
                                    content: value.trim(),
                                  ),
                                );
                            _chatController.clear();
                            focusNode.unfocus();
                          },
                          onTapOutside: (event) {
                            focusNode.unfocus();
                          },
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: const Icon(
                          Icons.emoji_emotions,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                ),
              ),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (Widget child, Animation<double> animation) {
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
                          context.read<ChatBloc>().add(
                                SendMessageEvent(
                                  chatRoomId: _chatRoomId,
                                  senderId: userId,
                                  content: _chatController.text.trim(),
                                ),
                              );
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
        SizedBox(
          height: keyboardSize > 0 ? keyboardSize + 55 : 0,
        )
      ],
    );
  }
}
