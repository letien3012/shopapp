import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:luanvan/blocs/allmessage/all_message_bloc.dart';
import 'package:luanvan/blocs/allmessage/all_message_event.dart';
import 'package:luanvan/blocs/allmessage/all_message_state.dart';
import 'package:luanvan/blocs/auth/auth_bloc.dart';
import 'package:luanvan/blocs/auth/auth_state.dart';
import 'package:luanvan/blocs/chat/chat_bloc.dart';
import 'package:luanvan/blocs/chat/chat_event.dart';
import 'package:luanvan/blocs/chat_room/chat_room_bloc.dart';
import 'package:luanvan/blocs/chat_room/chat_room_event.dart';
import 'package:luanvan/blocs/chat_room/chat_room_state.dart';
import 'package:luanvan/blocs/list_user/list_user_bloc.dart';
import 'package:luanvan/blocs/list_user/list_user_event.dart';
import 'package:luanvan/blocs/list_user/list_user_state.dart';
import 'package:luanvan/blocs/shop/shop_bloc.dart';
import 'package:luanvan/blocs/shop/shop_state.dart';
import 'package:luanvan/models/chat_room.dart';
import 'package:luanvan/ui/helper/icon_helper.dart';
import 'package:luanvan/ui/shop/chat/shop_chat_detail_screen.dart';

enum ChatFilter {
  all('Tất cả'),
  unread('Chưa đọc'),
  unanswered('Chưa phản hồi');

  final String label;
  const ChatFilter(this.label);
}

class ShopChatScreen extends StatefulWidget {
  const ShopChatScreen({super.key});
  static String routeName = "shop_chat_screen";

  @override
  State<ShopChatScreen> createState() => _ShopChatScreenState();
}

class _ShopChatScreenState extends State<ShopChatScreen> {
  String shopId = '';
  List<String> userIds = [];
  ChatFilter selectedFilter = ChatFilter.all;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    // Lấy userId từ AuthBloc và gửi sự kiện LoadChatRoomsEvent
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AdminAuthenticated) {
        shopId = authState.shop.shopId!;
        context.read<ChatRoomBloc>().add(LoadChatRoomsShopEvent(shopId));
        context.read<AllMessageBloc>().add(LoadAllMessagesEvent());
      }
      // final chatState = context.read<ChatRoomBloc>().state;
      // if (chatState is ChatRoomsUserLoaded) {
      //   userIds =
      //       chatState.chatRooms.map((chatRoom) => chatRoom.buyerId).toList();
      //   context
      //       .read<ListUserBloc>()
      //       .add(FetchListUserChatEventByUserId(userIds));
      // }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ShopBloc, ShopState>(
        builder: (context, shopState) {
          if (shopState is ShopLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (shopState is ShopLoaded) {
            return BlocBuilder<ChatRoomBloc, ChatRoomState>(
              builder: (context, chatState) {
                if (chatState is ChatRoomsShopLoaded) {
                  userIds = chatState.chatRooms
                      .map((chatRoom) => chatRoom.buyerId)
                      .toList();
                  context
                      .read<ListUserBloc>()
                      .add(FetchListUserChatEventByUserId(userIds));
                  context.read<AllMessageBloc>().add(LoadAllMessagesEvent());
                }
                return Stack(
                  children: [
                    RefreshIndicator(
                      onRefresh: () async {
                        context.read<ChatRoomBloc>().add(
                            LoadChatRoomsShopEvent(shopState.shop.shopId!));
                        context
                            .read<AllMessageBloc>()
                            .add(LoadAllMessagesEvent());
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Container(
                          constraints: BoxConstraints(
                            minHeight: MediaQuery.of(context).size.height,
                          ),
                          width: MediaQuery.of(context).size.width,
                          color: Colors.grey[200],
                          padding: const EdgeInsets.only(top: 80, bottom: 20),
                          child: Column(
                            children: [
                              _buildFilterDropdown(),
                              _buildSearchBar(context),
                              if (chatState is ChatRoomLoading)
                                const Center(child: CircularProgressIndicator())
                              else if (chatState is ChatRoomsShopLoaded)
                                chatState.chatRooms.isEmpty
                                    ? _buildEmptyChatList()
                                    : _buildFilteredChatRoomList(context,
                                        chatState.chatRooms, selectedFilter)
                              else if (chatState is ChatRoomError)
                                Center(child: Text(chatState.message))
                            ],
                          ),
                        ),
                      ),
                    ),
                    _buildAppBar(context),
                  ],
                );
              },
            );
          }
          return const Center(
              child: Text('Vui lòng đăng nhập để sử dụng chat'));
        },
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        children: [
          PopupMenuButton<ChatFilter>(
            initialValue: selectedFilter,
            onSelected: (ChatFilter filter) {
              setState(() {
                selectedFilter = filter;
              });
            },
            color: Colors.white,
            itemBuilder: (BuildContext context) => ChatFilter.values
                .map((filter) => PopupMenuItem<ChatFilter>(
                      value: filter,
                      child: Text(filter.label),
                    ))
                .toList(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(selectedFilter.label),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_drop_down, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChatList() {
    return Container(
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height - 140,
      ),
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              IconHelper.chatbubblequestion,
              width: 150,
              height: 150,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Không có lịch sử Chat',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      color: Colors.white,
      child: Container(
        height: 40,
        margin: const EdgeInsets.all(10),
        color: Colors.grey[200],
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Icon(
                Icons.search,
                size: 24,
                color: Colors.grey[900],
              ),
            ),
            Expanded(
              child: TextField(
                controller: _searchController,
                cursorHeight: 20,
                textAlignVertical: TextAlignVertical.center,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(bottom: 11),
                  border: InputBorder.none,
                  hintText: 'Tìm kiếm',
                  hintMaxLines: 1,
                  hintStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _searchController.clear();
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Icon(
                    Icons.close,
                    size: 24,
                    color: Colors.grey[900],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilteredChatRoomList(
      BuildContext context, List<ChatRoom> chatRooms, ChatFilter filter) {
    if (chatRooms.isEmpty) {
      return const Center(child: Text('No chat rooms available'));
    }

    var filteredRooms = chatRooms;

    // Apply filter
    if (filter == ChatFilter.unread) {
      filteredRooms =
          filteredRooms.where((room) => room.unreadCountShop > 0).toList();
    } else if (filter == ChatFilter.unanswered) {
      filteredRooms = filteredRooms
          .where((room) => room.lastMessageSenderId != shopId)
          .toList();
    }

    // Apply search
    if (_searchQuery.isNotEmpty) {
      return BlocBuilder<ListUserBloc, ListUserState>(
        builder: (context, listUserState) {
          if (listUserState is ListUserChatLoaded) {
            filteredRooms = filteredRooms.where((room) {
              final user = listUserState.users.firstWhere(
                (user) => user.id == room.buyerId,
                orElse: () => listUserState.users.first,
              );
              final userName = user.userName?.toLowerCase() ?? '';
              return userName.contains(_searchQuery.toLowerCase());
            }).toList();
          }
          return _buildChatRoomList(context, filteredRooms);
        },
      );
    }

    return _buildChatRoomList(context, filteredRooms);
  }

  Widget _buildChatRoomList(BuildContext context, List<ChatRoom> chatRooms) {
    return BlocBuilder<ListUserBloc, ListUserState>(
      builder: (context, listUserState) {
        if (listUserState is ListUserChatLoaded) {
          return BlocBuilder<AllMessageBloc, AllMessageState>(
            builder: (context, allMessageState) {
              if (allMessageState is AllMessageLoaded) {
                return ListView.builder(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: chatRooms.length,
                  itemBuilder: (context, index) {
                    final chatRoom = chatRooms[index];
                    final user = listUserState.users
                        .firstWhere((user) => user.id == chatRoom.buyerId);
                    final lastMessage = allMessageState.messages.firstWhere(
                        (message) =>
                            message.messageId == chatRoom.lastMessageId);
                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom:
                              BorderSide(width: 1, color: Colors.grey[300]!),
                        ),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          context
                              .read<ChatBloc>()
                              .add(ReadMessageEvent(true, chatRoom.chatRoomId));
                          Navigator.of(context).pushNamed(
                            ShopChatDetailScreen.routeName,
                            arguments: chatRoom.chatRoomId,
                          );
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipOval(
                              child: Image.network(
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                user.avataUrl ??
                                    '', // Thay bằng ảnh của shop nếu có
                                errorBuilder: (context, error, stackTrace) =>
                                    const Text(
                                  "Lỗi",
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          user.userName ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          lastMessage.sentAt
                                              .toString()
                                              .substring(11, 16),
                                          maxLines: 1,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        )
                                      ],
                                    ),
                                    Text(
                                      lastMessage.content,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (chatRoom.unreadCountShop > 0)
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${chatRoom.unreadCountShop}',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        height: 80,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        padding:
            const EdgeInsets.only(top: 30, left: 10, right: 10, bottom: 10),
        child: Row(
          children: [
            const SizedBox(width: 10),
            const SizedBox(
              height: 40,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Chat",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
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
