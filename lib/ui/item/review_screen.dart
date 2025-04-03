import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
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
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: FutureBuilder(
                future: _initializeVideo(videoUrl),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    final controller = _videoControllers[videoUrl];
                    if (controller != null && controller.value.isInitialized) {
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
                                            onPressed: () =>
                                                _togglePlay(videoUrl),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              controller.value.volume == 0
                                                  ? Icons.volume_off
                                                  : Icons.volume_up,
                                              color: Colors.white,
                                            ),
                                            onPressed: () =>
                                                _toggleMute(videoUrl),
                                          ),
                                        ],
                                      ),
                                      StreamBuilder(
                                        stream: Stream.periodic(
                                            const Duration(milliseconds: 100)),
                                        builder: (context, snapshot) {
                                          return Text(
                                            _formatDuration(
                                                    controller.value.position) +
                                                ' / ' +
                                                _formatDuration(
                                                    controller.value.duration),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
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
                              icon:
                                  const Icon(Icons.close, color: Colors.white),
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

  void _showFullScreenImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            PhotoView(
              imageProvider: NetworkImage(imageUrl),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 3,
              initialScale: PhotoViewComputedScale.contained,
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              enableRotation: true,
              enablePanAlways: true,
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
          ],
        ),
      ),
    );
  }

  void _showFullScreenMedia(Comment comment, {int initialIndex = 0}) {
    int currentIndex = initialIndex;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // Photo Gallery
              PageView.builder(
                itemCount: comment.images.length,
                controller: PageController(initialPage: initialIndex),
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return PhotoView(
                    imageProvider: NetworkImage(comment.images[index]),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 3,
                    initialScale: PhotoViewComputedScale.contained,
                    backgroundDecoration:
                        const BoxDecoration(color: Colors.black),
                    enableRotation: true,
                    enablePanAlways: true,
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
              if (comment.images.length > 1)
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: Colors.black.withOpacity(0.5),
                    child: Text(
                      '${currentIndex + 1}/${comment.images.length}',
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
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height,
                        ),
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
                                          "${product.averageRating.toStringAsFixed(1)}/5",
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Row(
                                          children: List.generate(5, (index) {
                                            return Icon(
                                              Icons.star,
                                              color:
                                                  index < product.averageRating
                                                      ? Colors.yellow
                                                      : Colors.grey[300],
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
                                          // Tính số lượng đánh giá cho mỗi sao
                                          int count = comments
                                              .where((comment) =>
                                                  comment.rating == (5 - index))
                                              .length;
                                          // Tính tỷ lệ phần trăm
                                          double percentage = comments.isEmpty
                                              ? 0
                                              : (count / comments.length) * 100;

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
                                                        width: percentage,
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
                                                const SizedBox(width: 8),
                                                Text(
                                                  "$count",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
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
                                                        comment.variant ?? '',
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
                                        if (comment.replyContent != null) ...[
                                          const SizedBox(height: 12),
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Text(
                                                      'Phản hồi của Người bán',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      DateFormat('dd/MM/yyyy')
                                                          .format(
                                                              comment.replyAt!),
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
                                                  style: const TextStyle(
                                                      fontSize: 13),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
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
          onTap: () => _showFullScreenVideo(comment.videoUrl!),
          child: _buildVideoTile(comment.videoUrl!),
        ),
      );
    }

    // Thêm ảnh vào sau
    for (int i = 0; i < comment.images.length; i++) {
      mediaItems.add(
        GestureDetector(
          onTap: () => _showFullScreenMedia(comment, initialIndex: i),
          child: _buildImageTile(comment.images, i),
        ),
      );
    }

    // Luôn hiển thị 4 items khi số lượng media ≥ 4
    final int totalItems = mediaItems.length;
    const int maxVisibleItems = 4; // Luôn hiển thị 4 items

    return GridView.builder(
      padding: const EdgeInsets.only(top: 10),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: totalItems > maxVisibleItems ? maxVisibleItems : totalItems,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
      ),
      itemBuilder: (context, index) {
        if (index == 3 && totalItems > 4) {
          // Tính toán index của ảnh trong comment.images
          int imageIndex = comment.videoUrl != null ? index - 1 : index;

          return GestureDetector(
            onTap: () =>
                _showFullScreenMedia(comment, initialIndex: imageIndex),
            child: Stack(
              children: [
                mediaItems[index],
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '+${totalItems - maxVisibleItems}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return mediaItems[index];
      },
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
            // Video Controls
            if (controller != null && controller.value.isInitialized)
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => _togglePlay(videoUrl),
                        child: Icon(
                          controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          _formatDuration(controller.value.duration),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                          ),
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

  Widget _buildImageTile(List<String> images, int index) {
    return GestureDetector(
      onTap: () => _showFullScreenMedia(
          Comment(
            id: '',
            userId: '',
            productId: '',
            content: '',
            rating: 0,
            createdAt: DateTime.now(),
            images: images,
            videoUrl: null,
            orderId: '',
          ),
          initialIndex: index),
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
