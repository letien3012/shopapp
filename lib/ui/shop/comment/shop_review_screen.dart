import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/comment/comment_bloc.dart';
import 'package:luanvan/blocs/comment/comment_state.dart';
import 'package:luanvan/blocs/productcomment/product_comment_bloc.dart';
import 'package:luanvan/blocs/productcomment/product_comment_event.dart';
import 'package:luanvan/blocs/productcomment/product_comment_state.dart';
import 'package:luanvan/blocs/usercomment/list_user_comment_bloc.dart';
import 'package:luanvan/blocs/usercomment/list_user_comment_event.dart';
import 'package:luanvan/blocs/usercomment/list_user_comment_state.dart';
import 'package:luanvan/models/comment.dart';
import 'package:intl/intl.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/models/user_info_model.dart';
import 'package:luanvan/ui/shop/comment/reply_comment_screen.dart';
import 'package:video_player/video_player.dart';

class ShopReviewScreen extends StatefulWidget {
  static String routeName = "shop_review_screen";
  const ShopReviewScreen({super.key});

  @override
  State<ShopReviewScreen> createState() => _ShopReviewScreenState();
}

class _ShopReviewScreenState extends State<ShopReviewScreen> {
  Map<String, VideoPlayerController> _videoControllers = {};
  String _selectedFilter = 'Tất cả';
  int? _selectedRating;
  bool _hasImages = false;
  bool _hasReplies = false;

  List<Comment> _filterComments(List<Comment> comments) {
    return comments.where((comment) {
      if (_selectedFilter == 'Tất cả') return true;

      if (_selectedRating != null) {
        return comment.rating == _selectedRating;
      }

      if (_hasImages) {
        return comment.images.isNotEmpty || comment.videoUrl != null;
      }

      if (_hasReplies) {
        return comment.replyContent != null;
      }

      return true;
    }).toList();
  }

  Map<String, int> _getFilterCounts(List<Comment> comments) {
    Map<String, int> counts = {
      'Tất cả': comments.length,
      '5 Sao': comments.where((c) => c.rating == 5).length,
      '4 Sao': comments.where((c) => c.rating == 4).length,
      '3 Sao': comments.where((c) => c.rating == 3).length,
      '2 Sao': comments.where((c) => c.rating == 2).length,
      '1 Sao': comments.where((c) => c.rating == 1).length,
      'Có Hình ảnh': comments
          .where((c) => c.images.isNotEmpty || c.videoUrl != null)
          .length,
      'Có Phản hồi': comments.where((c) => c.replyContent != null).length,
    };
    return counts;
  }

  @override
  void dispose() {
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    _videoControllers.clear();
    super.dispose();
  }

  Future<void> _initializeVideo(String videoUrl) async {
    if (_videoControllers.containsKey(videoUrl)) return;

    final controller = VideoPlayerController.network(videoUrl);
    _videoControllers[videoUrl] = controller;

    try {
      await controller.initialize();
      controller.setLooping(true);
      controller.setVolume(0);
      setState(() {});
    } catch (e) {
      print('Error initializing video: $e');
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  void _togglePlay(String videoUrl) {
    final controller = _videoControllers[videoUrl];
    if (controller != null) {
      if (controller.value.isPlaying) {
        controller.pause();
      } else {
        controller.play();
      }
    }
  }

  void _toggleMute(String videoUrl) {
    final controller = _videoControllers[videoUrl];
    if (controller != null) {
      controller.setVolume(controller.value.volume == 0 ? 1 : 0);
      setState(() {});
    }
  }

  void _showFullScreenMedia(BuildContext context, String url, bool isVideo,
      {List<String>? imageUrls, int? initialIndex}) {
    if (isVideo) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              Center(
                child: FutureBuilder(
                  future: _initializeVideo(url),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      final controller = _videoControllers[url];
                      if (controller != null &&
                          controller.value.isInitialized) {
                        return Stack(
                          children: [
                            InteractiveViewer(
                              minScale: 0.5,
                              maxScale: 4.0,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: AspectRatio(
                                  aspectRatio: controller.value.aspectRatio,
                                  child: VideoPlayer(controller),
                                ),
                              ),
                            ),
                            // Video Controls
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.7),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Progress Bar
                                    VideoProgressIndicator(
                                      controller,
                                      allowScrubbing: true,
                                      colors: const VideoProgressColors(
                                        playedColor: Colors.white,
                                        bufferedColor: Colors.white24,
                                        backgroundColor: Colors.white12,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Controls
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                controller.value.isPlaying
                                                    ? Icons.pause
                                                    : Icons.play_arrow,
                                                color: Colors.white,
                                              ),
                                              onPressed: () => _togglePlay(url),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                controller.value.volume == 0
                                                    ? Icons.volume_off
                                                    : Icons.volume_up,
                                                color: Colors.white,
                                              ),
                                              onPressed: () => _toggleMute(url),
                                            ),
                                          ],
                                        ),
                                        StreamBuilder(
                                          stream: Stream.periodic(
                                              const Duration(
                                                  milliseconds: 100)),
                                          builder: (context, snapshot) {
                                            return Text(
                                              _formatDuration(controller
                                                      .value.position) +
                                                  ' / ' +
                                                  _formatDuration(controller
                                                      .value.duration),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Close Button
                            Positioned(
                              top: 40,
                              right: 20,
                              child: IconButton(
                                icon: const Icon(Icons.close,
                                    color: Colors.white),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          ],
                        );
                      }
                    }
                    return const CircularProgressIndicator();
                  },
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => Dialog(
            backgroundColor: Colors.transparent,
            child: Stack(
              children: [
                // Photo Gallery
                PageView.builder(
                  itemCount: imageUrls?.length ?? 1,
                  controller: PageController(initialPage: initialIndex ?? 0),
                  onPageChanged: (index) {
                    setState(() {
                      initialIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Hero(
                          tag: imageUrls?[index] ?? url,
                          child: Image.network(
                            imageUrls?[index] ?? url,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Close Button
                Positioned(
                  top: 40,
                  right: 20,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                // Image Counter
                if (imageUrls != null && imageUrls.length > 1)
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      color: Colors.black.withOpacity(0.5),
                      child: Text(
                        '${(initialIndex ?? 0) + 1}/${imageUrls.length}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildFilterSection() {
    return BlocBuilder<CommentBloc, CommentState>(
      builder: (context, state) {
        if (state is CommentShopLoaded) {
          final comments = state.comments;
          final filterCounts = _getFilterCounts(comments);

          return Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lọc đánh giá theo',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: filterCounts.entries
                        .where((entry) => entry.value > 0)
                        .map((entry) => _buildFilterChip(
                              '${entry.key} (${entry.value})',
                              _selectedFilter == entry.key,
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          );
        }
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.all(12),
          child: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: 13,
          ),
        ),
        selected: isSelected,
        onSelected: (bool value) {
          setState(() {
            final baseLabel = label.split(' (')[0];
            if (baseLabel == 'Tất cả') {
              _selectedFilter = 'Tất cả';
              _selectedRating = null;
              _hasImages = false;
              _hasReplies = false;
            } else if (baseLabel.contains('Sao')) {
              _selectedFilter = baseLabel;
              _selectedRating = int.parse(baseLabel[0]);
              _hasImages = false;
              _hasReplies = false;
            } else if (baseLabel == 'Có Hình ảnh') {
              _selectedFilter = baseLabel;
              _selectedRating = null;
              _hasImages = value;
              _hasReplies = false;
            } else if (baseLabel == 'Có Phản hồi') {
              _selectedFilter = baseLabel;
              _selectedRating = null;
              _hasImages = false;
              _hasReplies = value;
            }
          });
        },
        backgroundColor: Colors.grey[200],
        selectedColor: Colors.brown,
        checkmarkColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  Widget _buildCommentItem(
      Comment comment, Product product, UserInfoModel user) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(user.avataUrl!),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        Row(
                          children: List.generate(
                            5,
                            (index) => Icon(
                              Icons.star,
                              size: 14,
                              color: index < comment.rating
                                  ? Colors.amber[700]
                                  : Colors.grey[300],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('dd/MM/yyyy').format(comment.createdAt),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (comment.variant != null) ...[
            Text(
              'Phân loại: ${comment.variant}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ],
          if (comment.imageProduct != null) ...[
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    comment.imageProduct!,
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          Text(comment.content),
          if (comment.videoUrl != null || comment.images.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  if (comment.videoUrl != null)
                    GestureDetector(
                      onTap: () => _showFullScreenMedia(
                        context,
                        comment.videoUrl!,
                        true,
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 80,
                        height: 80,
                        child: FutureBuilder(
                          future: _initializeVideo(comment.videoUrl!),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              final controller =
                                  _videoControllers[comment.videoUrl!];
                              if (controller != null &&
                                  controller.value.isInitialized) {
                                return Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: AspectRatio(
                                        aspectRatio: 1,
                                        child: VideoPlayer(controller),
                                      ),
                                    ),
                                    // Video Controls
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [
                                              Colors.black.withOpacity(0.7),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            GestureDetector(
                                              onTap: () => _togglePlay(
                                                  comment.videoUrl!),
                                              child: Icon(
                                                controller.value.isPlaying
                                                    ? Icons.pause
                                                    : Icons.play_arrow,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                            Text(
                                              _formatDuration(
                                                  controller.value.duration),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }
                            }
                            return const Center(
                                child: CircularProgressIndicator());
                          },
                        ),
                      ),
                    ),
                  if (comment.images.isNotEmpty)
                    ...comment.images
                        .map((imageUrl) => GestureDetector(
                              onTap: () => _showFullScreenMedia(
                                context,
                                imageUrl,
                                false,
                                imageUrls: comment.images,
                                initialIndex: comment.images.indexOf(imageUrl),
                              ),
                              child: Hero(
                                tag: imageUrl,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    image: DecorationImage(
                                      image: NetworkImage(imageUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                ],
              ),
            ),
          ],
          if (comment.replyContent != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Phản hồi của bạn',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('dd/MM/yyyy').format(comment.replyAt!),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    comment.replyContent!,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
          if (comment.replyContent == null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      ReplyCommentScreen.routeName,
                      arguments: {
                        'comment': comment,
                        'product': product,
                        'user': user,
                      },
                    );
                  },
                  child: Container(
                    height: 30,
                    width: 80,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.brown),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Phản hồi',
                      style: TextStyle(color: Colors.brown),
                    ),
                  ),
                )
              ],
            )
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Đánh giá Shop',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: BlocBuilder<CommentBloc, CommentState>(builder: (context, state) {
        if (state is CommentShopLoaded) {
          final comments = state.comments;
          final filteredComments = _filterComments(comments);
          final listUserId =
              filteredComments.map((comment) => comment.userId).toList();
          final listProductId =
              filteredComments.map((comment) => comment.productId).toList();
          context
              .read<ProductCommentBloc>()
              .add(FetchMultipleProductsCommentEvent(listProductId));
          context
              .read<ListUserCommentBloc>()
              .add(FetchListUserCommentEventByUserId(listUserId));
          return BlocBuilder<ListUserCommentBloc, ListUserCommentState>(
            builder: (context, state) {
              if (state is ListUserCommentLoaded) {
                final users = state.users;
                return BlocBuilder<ProductCommentBloc, ProductCommentState>(
                  builder: (context, state) {
                    if (state is ProductCommentListLoaded) {
                      final products = state.products;
                      return Container(
                        color: Colors.grey[200],
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height,
                        ),
                        child: SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              _buildFilterSection(),
                              ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: filteredComments.length,
                                itemBuilder: (context, index) {
                                  final product = products.firstWhere(
                                      (product) =>
                                          product.id ==
                                          filteredComments[index].productId);
                                  final user = users.firstWhere((user) =>
                                      user.id ==
                                      filteredComments[index].userId);
                                  return _buildCommentItem(
                                      filteredComments[index], product, user);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    if (state is ProductCommentLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return const Center(child: Text('Không có dữ liệu'));
                  },
                );
              }
              if (state is ListUserCommentLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return const Center(child: Text('Không có dữ liệu'));
            },
          );
        }
        if (state is CommentLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return const Center(child: Text('Không có dữ liệu'));
      }),
    );
  }
}
