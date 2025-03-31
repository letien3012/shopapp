import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:luanvan/blocs/comment/comment_bloc.dart';
import 'package:luanvan/blocs/comment/comment_state.dart';
import 'package:luanvan/blocs/product/product_bloc.dart';
import 'package:luanvan/blocs/product/product_state.dart';
import 'package:luanvan/blocs/usercomment/list_user_comment_bloc.dart';
import 'package:luanvan/blocs/usercomment/list_user_comment_event.dart';
import 'package:luanvan/blocs/usercomment/list_user_comment_state.dart';
import 'package:luanvan/models/comment.dart';
import 'package:video_player/video_player.dart';
import 'package:photo_view/photo_view.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});
  static String routeName = "review_screen";
  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  // bool _isExpanded = false;
  // final GlobalKey _details = GlobalKey();
  // Map<String, List<String>> _reviews = {};
  int soLuongAnh = 5;
  Map<String, VideoPlayerController> _videoControllers = {};
  bool _showMediaOnly = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _disposeVideoControllers();
    super.dispose();
  }

  void _disposeVideoControllers() {
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    _videoControllers.clear();
  }

  Future<void> _initializeVideo(String videoUrl) async {
    if (_videoControllers.containsKey(videoUrl)) return;

    final controller = VideoPlayerController.network(videoUrl);
    _videoControllers[videoUrl] = controller;

    try {
      await controller.initialize();
      controller.setLooping(true);
      controller.play();
      setState(() {});
    } catch (e) {
      print('Error initializing video: $e');
    }
  }

  void _showFullScreenVideo(String videoUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: VideoPlayer(_videoControllers[videoUrl]!),
          ),
        ),
      ),
    );
  }

  void _showFullScreenImage(String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: PhotoView(
            imageProvider: NetworkImage(imageUrl),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
            initialScale: PhotoViewComputedScale.contained,
            backgroundDecoration: const BoxDecoration(color: Colors.black),
          ),
        ),
      ),
    );
  }

  void _showFullScreenMedia(Comment comment) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: PageView.builder(
            itemCount:
                (comment.images.length + (comment.videoUrl != null ? 1 : 0)),
            itemBuilder: (context, index) {
              if (comment.videoUrl != null) {
                if (index == 0) {
                  return Center(
                    child: VideoPlayer(_videoControllers[comment.videoUrl!]!),
                  );
                }
                return PhotoView(
                  imageProvider: NetworkImage(comment.images[index - 1]),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2,
                  initialScale: PhotoViewComputedScale.contained,
                  backgroundDecoration:
                      const BoxDecoration(color: Colors.black),
                );
              }
              return PhotoView(
                imageProvider: NetworkImage(comment.images[index]),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
                initialScale: PhotoViewComputedScale.contained,
                backgroundDecoration: const BoxDecoration(color: Colors.black),
              );
            },
          ),
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} năm trước';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} tháng trước';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa nãy';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Danh sách đánh giá
          BlocBuilder<CommentBloc, CommentState>(
            builder: (context, state) {
              if (state is CommentLoaded) {
                final comments = state.comments;
                return BlocBuilder<ListUserCommentBloc, ListUserCommentState>(
                  builder: (context, state) {
                    if (state is ListUserCommentLoaded) {
                      final userComments = state.users;
                      final product =
                          (context.read<ProductBloc>().state as ProductLoaded)
                              .product;

                      // Lọc comments nếu đang ở tab "Có hình ảnh/video"
                      final filteredComments = _showMediaOnly
                          ? comments.where((comment) =>
                              comment.images.isNotEmpty ||
                              comment.videoUrl != null)
                          : comments;

                      return Container(
                        color: Colors.grey[200],
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(top: 130, bottom: 70),
                          child: Column(
                            children: [
                              // Thống kê đánh giá
                              Container(
                                padding: const EdgeInsets.all(15),
                                color: Colors.white,
                                child: Row(
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          "${product.averageRating}/5",
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Row(
                                          children: List.generate(5, (index) {
                                            return const Icon(
                                              Icons.star,
                                              color: Colors.yellow,
                                              size: 16,
                                            );
                                          }),
                                        ),
                                        Text(
                                          "${filteredComments.length} đánh giá",
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: Column(
                                        children: List.generate(5, (index) {
                                          return Container(
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 2),
                                            child: Row(
                                              children: [
                                                Text(
                                                  "${5 - index}",
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                ),
                                                const Icon(Icons.star,
                                                    size: 12),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Stack(
                                                    children: [
                                                      Container(
                                                        height: 4,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.grey[300],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(2),
                                                        ),
                                                      ),
                                                      Container(
                                                        height: 4,
                                                        width: 100 -
                                                            (index * 20)
                                                                .toDouble(),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.yellow,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(2),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Danh sách đánh giá
                              ListView.builder(
                                padding: EdgeInsets.zero,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: filteredComments.length,
                                itemBuilder: (context, index) {
                                  final comment =
                                      filteredComments.elementAt(index);
                                  final userComment = userComments.firstWhere(
                                      (user) => user.id == comment.userId);
                                  return Container(
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border(
                                        bottom: BorderSide(
                                            color: Colors.grey[200]!),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Thông tin người đánh giá
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            ClipOval(
                                              child: Image.network(
                                                userComment.avataUrl ?? '',
                                                width: 30,
                                                height: 30,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              userComment.name ?? '',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const Spacer(),
                                            Text(
                                              _getTimeAgo(comment.createdAt),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        // Rating
                                        Row(
                                          children:
                                              List.generate(5, (starIndex) {
                                            return Icon(
                                              Icons.star,
                                              size: 16,
                                              color: starIndex < 4
                                                  ? Colors.yellow
                                                  : Colors.grey[300],
                                            );
                                          }),
                                        ),
                                        const SizedBox(height: 5),
                                        (product.optionInfos.length > 1)
                                            ? IntrinsicWidth(
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      'Phân loại:',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        (comment.variant!
                                                                    .variantId1 !=
                                                                null)
                                                            ? product.variants
                                                                .firstWhere((variant) =>
                                                                    variant
                                                                        .id ==
                                                                    comment
                                                                        .variant!
                                                                        .variantId1)
                                                                .options
                                                                .firstWhere((option) =>
                                                                    option.id ==
                                                                    comment
                                                                        .variant!
                                                                        .optionId1)
                                                                .name
                                                            : '',
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            color: Colors
                                                                .grey[600],
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          (comment.variant!
                                                                      .variantId2 !=
                                                                  null)
                                                              ? ', ${product.variants.firstWhere((variant) => variant.id == comment.variant!.variantId2).options.firstWhere((option) => option.id == comment.variant!.optionId2).name}'
                                                              : '',
                                                          style: TextStyle(
                                                              fontSize: 13,
                                                              color: Colors
                                                                  .grey[600],
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : SizedBox.shrink(),
                                        // Phân loại hàng
                                        const SizedBox(height: 10),
                                        // Nội dung đánh giá
                                        Text(
                                          comment.content ?? '',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        const SizedBox(height: 10),
                                        // Ảnh/Video đánh giá
                                        if (comment.images.isNotEmpty ||
                                            comment.videoUrl != null)
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Tạo danh sách media chung
                                              if ((comment.images.length +
                                                      (comment.videoUrl != null
                                                          ? 1
                                                          : 0)) ==
                                                  3)
                                                _buildThreeMediaLayout(comment)
                                              else
                                                _buildGridMediaLayout(comment),
                                            ],
                                          ),

                                        // Nút like và reply
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // AppBar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  // AppBar chính
                  Container(
                    height: 90,
                    padding: const EdgeInsets.only(
                        top: 40, left: 15, right: 15, bottom: 10),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Text(
                            'Đánh giá sản phẩm',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Tab bar
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[200]!),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _showMediaOnly = false;
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: _showMediaOnly
                                        ? Colors.transparent
                                        : Colors.brown,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Tất cả',
                                style: TextStyle(
                                  color: _showMediaOnly
                                      ? Colors.black
                                      : Colors.brown,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _showMediaOnly = true;
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: _showMediaOnly
                                        ? Colors.brown
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Có hình ảnh/video',
                                style: TextStyle(
                                  color: _showMediaOnly
                                      ? Colors.brown
                                      : Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThreeMediaLayout(Comment comment) {
    List<Widget> mediaItems = [];

    // Thêm video vào đầu nếu có
    if (comment.videoUrl != null) {
      mediaItems.add(
        StaggeredGridTile.count(
          crossAxisCellCount: 2,
          mainAxisCellCount: 2,
          child: GestureDetector(
            onTap: () => _showFullScreenMedia(comment),
            child: _buildVideoTile(comment.videoUrl!),
          ),
        ),
      );
    }

    // Thêm ảnh vào sau
    for (int i = 0; i < comment.images.length; i++) {
      if (i == 0 && comment.videoUrl == null) {
        mediaItems.add(
          StaggeredGridTile.count(
            crossAxisCellCount: 2,
            mainAxisCellCount: 2,
            child: GestureDetector(
              onTap: () => _showFullScreenMedia(comment),
              child: _buildImageTile(comment.images, i),
            ),
          ),
        );
      } else {
        mediaItems.add(
          StaggeredGridTile.count(
            crossAxisCellCount: 1,
            mainAxisCellCount: 1,
            child: GestureDetector(
              onTap: () => _showFullScreenMedia(comment),
              child: _buildImageTile(comment.images, i),
            ),
          ),
        );
      }
    }

    return StaggeredGrid.count(
      crossAxisCount: 3,
      crossAxisSpacing: 5,
      mainAxisSpacing: 5,
      children: mediaItems,
    );
  }

  Widget _buildGridMediaLayout(Comment comment) {
    List<Widget> mediaItems = [];

    // Thêm video vào đầu nếu có
    if (comment.videoUrl != null) {
      mediaItems.add(
        GestureDetector(
          onTap: () => _showFullScreenMedia(comment),
          child: _buildVideoTile(comment.videoUrl!),
        ),
      );
    }

    // Thêm ảnh vào sau
    for (int i = 0; i < comment.images.length; i++) {
      mediaItems.add(
        GestureDetector(
          onTap: () => _showFullScreenMedia(comment),
          child: _buildImageTile(comment.images, i),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.only(top: 10),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: mediaItems.length > 4 ? 4 : mediaItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
      ),
      itemBuilder: (context, index) => mediaItems[index],
    );
  }

  Widget _buildVideoTile(String videoUrl) {
    _initializeVideo(videoUrl);
    final controller = _videoControllers[videoUrl];

    return GestureDetector(
      onTap: () => _showFullScreenVideo(videoUrl),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[300],
        ),
        child: Stack(
          children: [
            if (controller != null && controller.value.isInitialized)
              AspectRatio(
                aspectRatio: 1,
                child: VideoPlayer(controller),
              )
            else
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageTile(List<String> images, int index) {
    return GestureDetector(
      onTap: () => _showFullScreenImage(images[index]),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: NetworkImage(images[index]),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
