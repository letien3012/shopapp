import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:luanvan/blocs/auth/auth_bloc.dart';
import 'package:luanvan/blocs/auth/auth_state.dart';
import 'package:luanvan/blocs/chat/chat_bloc.dart';
import 'package:luanvan/blocs/chat/chat_event.dart';
import 'package:luanvan/blocs/chat/chat_state.dart';
import 'package:luanvan/blocs/user_chat/user_chat_bloc.dart';
import 'package:luanvan/blocs/user_chat/user_chat_event.dart';
import 'package:luanvan/blocs/user_chat/user_chat_state.dart';
import 'package:luanvan/models/user_info_model.dart';

class ShopChatDetailScreen extends StatefulWidget {
  const ShopChatDetailScreen({super.key});
  static String routeName = "shop_chat_detail_screen";

  @override
  State<ShopChatDetailScreen> createState() => _ShopChatDetailScreenState();
}

class _ShopChatDetailScreenState extends State<ShopChatDetailScreen> {
  final _chatController = TextEditingController();
  bool _showSendButton = false;
  String _chatRoomId = '';
  String _userId = '';
  bool _shouldReverse = false;
  bool _hasMeasured = false;
  int _lastMessageCount = 0;
  final FocusNode focusNode = FocusNode();
  final _scrollController = ScrollController();
  bool _isKeyboardVisible = false;
  UserInfoModel? user;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chatRoomId = ModalRoute.of(context)!.settings.arguments as String;
      context.read<ChatBloc>().add(LoadMessagesEvent(_chatRoomId));
      _userId = _chatRoomId.split('-')[0];
      context.read<UserChatBloc>().add(FetchUserChatEvent(_userId));
    });

    _chatController.addListener(() {
      setState(() {
        _showSendButton = _chatController.text.trim().isNotEmpty;
      });
    });
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
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
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
    return BlocBuilder<UserChatBloc, UserChatState>(
      builder: (context, userState) {
        if (userState is UserChatLoaded) {
          user = userState.user;
        }
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
                    user!.avataUrl ?? '',
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
                          user!.name ?? '',
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
      },
    );
  }

  Widget _buildMessagesArea(BuildContext context, String currentUserId) {
    final GlobalKey contentKey = GlobalKey();

    return Container(
      key: contentKey,
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
              _shouldReverse = false;
              _hasMeasured = false;
              return const Center(
                child: Text(
                  'Chưa có tin nhắn nào. Hãy gửi tin nhắn đầu tiên!',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            if (!_hasMeasured || messages.length != _lastMessageCount) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final RenderBox? renderBox =
                    contentKey.currentContext?.findRenderObject() as RenderBox?;
                if (renderBox != null && mounted) {
                  final contentHeight = renderBox.size.height;
                  final availableHeight = MediaQuery.of(context).size.height -
                      MediaQuery.of(context).size.height * 0.1 -
                      60;
                  print('$contentHeight - $availableHeight');
                  final newReverse = contentHeight > availableHeight;
                  if (newReverse) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                  if (newReverse != _shouldReverse) {
                    setState(() {
                      _shouldReverse = newReverse;
                      _hasMeasured = true; // Đánh dấu đã đo
                      _lastMessageCount = messages.length;
                    });
                  }
                }
              });
            }

            List<Widget> messageWidgets = [];
            DateTime? lastDate;

            for (int index = 0; index < messages.length; index++) {
              final message = messages[index];
              final messageDate = message.sentAt; // Giả sử message có timestamp
              final isSender = message.senderId == currentUserId;

              // Kiểm tra xem có cần hiển thị nhãn ngày không
              if (lastDate == null ||
                  messageDate.day != lastDate.day ||
                  messageDate.month != lastDate.month ||
                  messageDate.year != lastDate.year) {
                lastDate = messageDate;
                messageWidgets.add(
                  Center(
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
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              }

              // Tạo widget tin nhắn
              messageWidgets.add(
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
                              ? Colors.lightBlue[100] // Tin nhắn của người gửi
                              : Colors.white, // Tin nhắn của người nhận
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
                            if (message.imageUrl != null)
                              Image.network(
                                message.imageUrl!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            if (message.productId != null)
                              Text('Sản phẩm: ${message.productId}'),
                            if (message.orderId != null)
                              Text('Đơn hàng: ${message.orderId}'),
                            const SizedBox(height: 5),
                            // Thêm thời gian của tin nhắn
                            Text(
                              _formatTime(messageDate),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black54,
                              ),
                              textAlign:
                                  isSender ? TextAlign.end : TextAlign.start,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              controller: _scrollController,
              reverse: _shouldReverse,
              physics: const AlwaysScrollableScrollPhysics(),
              child: ListView(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: messageWidgets,
              ),
            );
          }
          if (state is ChatError) {
            return Center(child: Text('Lỗi: ${state.message}'));
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

  Widget _buildInputArea(BuildContext context, String userId) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {},
            child: const Icon(
              HeroIcons.plus_circle,
              size: 30,
            ),
          ),
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
    );
  }
}
