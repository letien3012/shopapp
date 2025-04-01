import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:luanvan/blocs/auth/auth_bloc.dart';
import 'package:luanvan/blocs/auth/auth_state.dart';
import 'package:luanvan/blocs/chat/chat_bloc.dart';
import 'package:luanvan/blocs/chat/chat_event.dart';
import 'package:luanvan/blocs/chat/chat_state.dart';
import 'package:luanvan/blocs/chat_room/chat_room_bloc.dart';
import 'package:luanvan/blocs/chat_room/chat_room_event.dart';
import 'package:luanvan/blocs/chat_room/chat_room_state.dart';
import 'package:luanvan/blocs/list_shop/list_shop_bloc.dart';
import 'package:luanvan/blocs/list_shop/list_shop_event.dart';
import 'package:luanvan/blocs/list_shop/list_shop_state.dart';
import 'package:luanvan/models/chat_room.dart';
import 'package:luanvan/ui/chat/chat_detail_screen.dart';
import 'package:luanvan/ui/helper/icon_helper.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  static String routeName = "chat_screen";

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<String> shopIds = [];
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
      if (authState is AuthAuthenticated) {
        context
            .read<ChatRoomBloc>()
            .add(LoadChatRoomsUserEvent(authState.user.uid));
      }
      final chatState = context.read<ChatRoomBloc>().state;
      if (chatState is ChatRoomsUserLoaded) {
        shopIds =
            chatState.chatRooms.map((chatRoom) => chatRoom.shopId).toList();
        context.read<ListShopBloc>().add(FetchListShopEventByShopId(shopIds));
      }
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
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (authState is AuthAuthenticated) {
            return BlocBuilder<ChatRoomBloc, ChatRoomState>(
              builder: (context, chatState) {
                if (chatState is ChatRoomsUserLoaded) {
                  shopIds = chatState.chatRooms
                      .map((chatRoom) => chatRoom.shopId)
                      .toList();
                  context
                      .read<ListShopBloc>()
                      .add(FetchListShopEventByShopId(shopIds));
                }
                return Stack(
                  children: [
                    RefreshIndicator(
                      onRefresh: () async {
                        context
                            .read<ChatRoomBloc>()
                            .add(LoadChatRoomsUserEvent(authState.user.uid));
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Container(
                          constraints: BoxConstraints(
                            minHeight: MediaQuery.of(context).size.height - 60,
                          ),
                          width: MediaQuery.of(context).size.width,
                          color: Colors.grey[200],
                          padding: const EdgeInsets.only(top: 80, bottom: 20),
                          child: Column(
                            children: [
                              _buildSearchBar(context),
                              if (chatState is ChatRoomLoading)
                                const Center(child: CircularProgressIndicator())
                              else if (chatState is ChatRoomsUserLoaded)
                                chatState.chatRooms.isEmpty
                                    ? _buildEmptyChatList()
                                    : _buildFilteredChatRoomList(
                                        context,
                                        chatState.chatRooms,
                                      )
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

  Widget _buildEmptyChatList() {
    return Container(
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height - 200,
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
      BuildContext context, List<ChatRoom> chatRooms) {
    if (chatRooms.isEmpty) {
      return const Center(child: Text('No chat rooms available'));
    }

    var filteredRooms = chatRooms;

    // Apply search
    if (_searchQuery.isNotEmpty) {
      return BlocBuilder<ListShopBloc, ListShopState>(
        builder: (context, listShopState) {
          if (listShopState is ListShopLoaded) {
            filteredRooms = filteredRooms.where((room) {
              try {
                final shop = listShopState.shops.firstWhere(
                  (shop) => shop.shopId == room.shopId,
                );
                final shopName = shop.name.toLowerCase();
                return shopName.contains(_searchQuery.toLowerCase());
              } catch (e) {
                return false; // Skip rooms where shop is not found
              }
            }).toList();
          }
          return _buildChatRoomList(context, filteredRooms);
        },
      );
    }

    return _buildChatRoomList(context, filteredRooms);
  }

  Widget _buildChatRoomList(BuildContext context, List<ChatRoom> chatRooms) {
    return BlocBuilder<ListShopBloc, ListShopState>(
      builder: (context, listShopState) {
        if (listShopState is ListShopLoaded) {
          return ListView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              context
                  .read<ChatBloc>()
                  .add(LoadMessagesEvent(chatRooms[index].chatRoomId));
              final chatRoom = chatRooms[index];
              try {
                final shop = listShopState.shops.firstWhere(
                  (shop) => shop.shopId == chatRoom.shopId,
                );
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(width: 1, color: Colors.grey[300]!),
                    ),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        ChatDetailScreen.routeName,
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
                            shop.avatarUrl ?? '',
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
                                      shop.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      chatRoom.createdAt
                                          .toString()
                                          .substring(11, 16),
                                      maxLines: 1,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                                BlocSelector<ChatBloc, ChatState, String>(
                                  selector: (state) {
                                    if (state is MessagesLoaded) {
                                      return state.messages.last.content;
                                    }
                                    return "";
                                  },
                                  builder: (BuildContext context,
                                      String lastMessage) {
                                    return Text(
                                      lastMessage,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (chatRoom.unreadCountBuyer > 0)
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${chatRoom.unreadCountBuyer}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              } catch (e) {
                return const SizedBox
                    .shrink(); // Skip items where shop is not found
              }
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
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                height: 40,
                width: 40,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.brown,
                  size: 30,
                ),
              ),
            ),
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
