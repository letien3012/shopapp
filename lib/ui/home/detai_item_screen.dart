import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:luanvan/blocs/auth/auth_bloc.dart';
import 'package:luanvan/blocs/auth/auth_state.dart';
import 'package:luanvan/blocs/cart/cart_bloc.dart';
import 'package:luanvan/blocs/cart/cart_event.dart';
import 'package:luanvan/blocs/cart/cart_state.dart';
import 'package:luanvan/blocs/chat/chat_bloc.dart';
import 'package:luanvan/blocs/chat/chat_event.dart';
import 'package:luanvan/blocs/comment/comment_bloc.dart';
import 'package:luanvan/blocs/comment/comment_event.dart';
import 'package:luanvan/blocs/comment/comment_state.dart';
import 'package:luanvan/blocs/favoriteproduct/product_favorite_bloc.dart';
import 'package:luanvan/blocs/favoriteproduct/product_favorite_event.dart';
import 'package:luanvan/blocs/favoriteproduct/product_favorite_state.dart';
import 'package:luanvan/blocs/listproductbloc/listproduct_bloc.dart';
import 'package:luanvan/blocs/listproductbloc/listproduct_event.dart';
import 'package:luanvan/blocs/listproductbloc/listproduct_state.dart';
import 'package:luanvan/blocs/product/product_bloc.dart';
import 'package:luanvan/blocs/product/product_event.dart';
import 'package:luanvan/blocs/productdetail/productdetail_bloc.dart';
import 'package:luanvan/blocs/productdetail/productdetail_event.dart';
import 'package:luanvan/blocs/productdetail/productdetail_state.dart';
import 'package:luanvan/blocs/recommendation/recommendation_bloc.dart';
import 'package:luanvan/blocs/recommendation/recommendation_even.dart';
import 'package:luanvan/blocs/recommendation/recommendation_state.dart';
import 'package:luanvan/blocs/shop/shop_bloc.dart';
import 'package:luanvan/blocs/shop/shop_event.dart';
import 'package:luanvan/blocs/shop/shop_state.dart';
import 'package:luanvan/blocs/user/user_bloc.dart';
import 'package:luanvan/blocs/user/user_event.dart';
import 'package:luanvan/blocs/usercomment/list_user_comment_bloc.dart';
import 'package:luanvan/blocs/usercomment/list_user_comment_event.dart';
import 'package:luanvan/blocs/usercomment/list_user_comment_state.dart';
import 'package:luanvan/models/cart.dart';
import 'package:luanvan/models/comment.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/models/shop.dart';
import 'package:luanvan/models/user_info_model.dart';
import 'package:luanvan/services/product_service.dart';
import 'package:luanvan/ui/cart/cart_screen.dart';
import 'package:luanvan/ui/chat/chat_detail_screen.dart';
import 'package:luanvan/ui/helper/icon_helper.dart';
import 'package:luanvan/ui/home/shop_dashboard.dart';
import 'package:luanvan/ui/item/review_screen.dart';
import 'package:luanvan/ui/login/signin_screen.dart';
import 'package:luanvan/ui/search/search_screen.dart';
import 'package:intl/intl.dart';
import 'package:luanvan/ui/widgets/add_to_cart.dart';
import 'package:luanvan/ui/widgets/alert_diablog.dart';
import 'package:luanvan/ui/widgets/image_viewer.dart';
import 'package:video_player/video_player.dart';

class DetaiItemScreen extends StatefulWidget {
  const DetaiItemScreen({super.key});
  static String routeName = 'Detail_item';

  @override
  State<DetaiItemScreen> createState() => _DetaiItemScreenState();
}

class _DetaiItemScreenState extends State<DetaiItemScreen> {
  // State variables
  final PageController _imageController = PageController();
  final ScrollController _appBarScrollController = ScrollController();
  final GlobalKey _details = GlobalKey();
  Map<String, VideoPlayerController> _videoControllers = {};
  int _currentImage = 0;
  bool _isExpanded = false;
  Color _appBarColor = Colors.transparent;
  Color _logoColor = Colors.white;
  Color _searchBarColor = Colors.transparent;
  Color _searchIconColor = Colors.transparent;
  Color _textSearchColor = Colors.transparent;
  int _quantityAddToCart = 1;
  final TextEditingController _quantityController = TextEditingController();
  int selectedIndexVariant1 = -1;
  String productId = '';
  bool isFavorited = false;
  Future<void> _showAddToCartDialog() async {
    showAlertDialog(
      context,
      message: 'Thêm vào giỏ hàng thành công',
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      productId = ModalRoute.of(context)!.settings.arguments as String;
      context.read<ProductBloc>().add(UpdateProductViewCountEvent(productId));
      context.read<RecommendationBloc>().add(LoadRecommendations(productId));
      // context.read<ProductBloc>().add(FetchProductEventByProductId(productId));

      context.read<CommentBloc>().add(LoadCommentsEvent(productId));
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        context
            .read<UserBloc>()
            .add(AddViewedProductEvent(authState.user.uid, productId));
        context.read<CartBloc>().add(FetchCartEventUserId(authState.user.uid));

        context
            .read<ProductFavoriteBloc>()
            .add(FetchFavoriteProductEvent(authState.user.uid));
      }

      final commentState = context.read<CommentBloc>().state;
      if (commentState is CommentLoaded) {
        final comments = commentState.comments;
        final userIds = comments.map((comment) => comment.userId).toList();
        context
            .read<ListUserCommentBloc>()
            .add(FetchListUserCommentEventByUserId(userIds));
      }
    });

    _imageController.addListener(() {
      setState(() {
        _currentImage = _imageController.page!.round();
      });
    });
    _appBarScrollController.addListener(onAppBarScroll);
    _quantityController.text = '1';
  }

  @override
  void dispose() {
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    _videoControllers.clear();
    _imageController.dispose();
    _appBarScrollController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _showProductNotExistDialog() async {
    await showAlertDialog(context,
        message: 'Sản phẩm không tồn tại', iconPath: IconHelper.warning);
  }

  void onAppBarScroll() {
    if (_appBarScrollController.offset >= 300.0) {
      setState(() {
        _appBarColor = Colors.white;
        _logoColor = Colors.brown;
        _searchBarColor = Colors.grey[200]!;
        _searchIconColor = Colors.grey[500]!;
        _textSearchColor = Colors.grey[500]!;
      });
    } else if (_appBarScrollController.offset >= 250.0) {
      setState(() {
        _appBarColor = Colors.white.withOpacity(0.7);
        _logoColor = Colors.white.withOpacity(0.7);
        _searchBarColor = Colors.white.withOpacity(0.5);
        _searchIconColor = Colors.grey.withOpacity(0.3);
        _textSearchColor = Colors.grey.withOpacity(0.3);
      });
    } else {
      _appBarColor = Colors.transparent;
      _logoColor = Colors.white;
      _searchBarColor = Colors.transparent;
      _searchIconColor = Colors.transparent;
      _textSearchColor = Colors.transparent;
    }
  }

  Future<void> _showCannotDisableAllDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        Timer(Duration(seconds: 1), () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        });
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),

          backgroundColor: Colors.transparent,
          elevation: 0,
          contentPadding: EdgeInsets.zero,
          content: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.black87,
            ),
            width: 200,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  IconHelper.check,
                  height: 40,
                  width: 40,
                  color: Colors.white,
                ),
                SizedBox(height: 10),
                Text(
                  "Phải có ít nhất 1 phương thức vận chuyển",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          actionsPadding: EdgeInsets.zero, // Xóa padding mặc định của actions
          actions: [], // Không cần nút, tự động đóng
        );
      },
    );
  }

  String formatPrice(double price) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return formatter.format(price.toInt());
  }

  Widget _buildImageSlider(Product product) {
    if (product.imageUrl.isEmpty) {
      return const SizedBox(
        height: 350,
        child: Center(child: Text("Không có hình ảnh")),
      );
    }

    // Tạo danh sách tất cả hình ảnh bao gồm cả hình ảnh phân loại
    List<String> allImages = List.from(product.imageUrl);
    if (product.hasVariantImages && product.variants.isNotEmpty) {
      allImages.addAll(
        product.variants[0].options
            .where((option) => option.imageUrl != null)
            .map((option) => option.imageUrl!)
            .toList(),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 410,
          width: double.infinity,
          child: Stack(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ImageViewer(
                        imageUrls: allImages,
                        initialIndex: _currentImage,
                      ),
                    ),
                  );
                },
                child: PageView.builder(
                  controller: _imageController,
                  scrollDirection: Axis.horizontal,
                  itemCount: allImages.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      allImages[index],
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              Positioned(
                right: 20,
                bottom: 20,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(221, 31, 30, 30),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  width: 50,
                  height: 25,
                  child: Center(
                    child: Text(
                      '${_currentImage + 1}/${allImages.length}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (product.hasVariantImages && product.variants.isNotEmpty)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
            alignment: Alignment.centerLeft,
            child: Text(
              '${product.variants[0].options.length.toString()} phân loại có sẵn',
              textAlign: TextAlign.start,
            ),
          ),
        if (product.hasVariantImages && product.variants.isNotEmpty)
          Container(
            color: Colors.white,
            height: 80,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: product.variants[0].options.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentImage = product.imageUrl.length + index;
                      _imageController.animateToPage(
                        _currentImage,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    });
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            _currentImage == (product.imageUrl.length + index)
                                ? Colors.brown
                                : Colors.grey.shade300,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        product.variants[0].options[index].imageUrl!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildProductInfo(Product product) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                product.variants.isNotEmpty
                    ? 'đ${product.getFormattedPriceText()}'
                    : 'đ${product.formatPrice(product.price!)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 151, 14, 4),
                ),
              ),
              Text('Đã bán ${product.quantitySold}'),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              product.name,
              textAlign: TextAlign.start,
              style: const TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(Product product) {
    return BlocBuilder<CommentBloc, CommentState>(
      builder: (context, state) {
        if (state is CommentLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is CommentLoaded) {
          final comments = state.comments;
          return BlocBuilder<ListUserCommentBloc, ListUserCommentState>(
            builder: (context, state) {
              if (state is ListUserCommentLoaded) {
                final userComments = state.users;
                return Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                                ReviewScreen.routeName,
                                arguments: product);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '${product.averageRating}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color.fromARGB(255, 143, 28, 20),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Row(
                                      children: List.generate(5, (index) {
                                        return Icon(
                                          Icons.star,
                                          color: index < product.averageRating
                                              ? Colors.yellow
                                              : Colors.grey[300],
                                          size: 20,
                                        );
                                      }),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      "Đánh giá sản phẩm (${comments.length})",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                const Icon(Icons.arrow_forward_ios, size: 16),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: 0.2,
                          color: Colors.grey,
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: comments.length > 2 ? 2 : comments.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                _buildReviewItem(comments[index], userComments),
                                if (index < 1)
                                  Container(height: 0.2, color: Colors.grey),
                              ],
                            );
                          },
                        ),
                      ],
                    ));
              }
              return const SizedBox.shrink();
            },
          );
        } else if (state is CommentEmpty) {
          return Container(
            padding: const EdgeInsets.all(10),
            height: 40,
            alignment: Alignment.centerLeft,
            color: Colors.white,
            child: const Text("Chưa có đánh giá"),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildReviewItem(Comment comment, List<UserInfoModel> userComments) {
    final userComment =
        userComments.firstWhere((user) => user.id == comment.userId);
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              const SizedBox(height: 10),
              ClipOval(
                child: Image.network(
                  userComment.avataUrl ?? '',
                  height: 30,
                  width: 30,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 30,
                    width: 30,
                    color: Colors.grey,
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userComment.name ?? ''),
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              Icons.star,
                              color: index < comment.rating
                                  ? Colors.yellow
                                  : Colors.grey[300],
                              size: 20,
                            );
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  textAlign: TextAlign.start,
                  comment.content,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Hiển thị video trước (nếu có)
                    if (comment.videoUrl != null &&
                        comment.videoUrl!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => _showFullScreenMedia(
                            context,
                            comment.videoUrl!,
                            true,
                          ),
                          child: Container(
                            width: 100,
                            height: 100,
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
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: InteractiveViewer(
                                            minScale: 0.5,
                                            maxScale: 4.0,
                                            child: SizedBox(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: MediaQuery.of(context)
                                                  .size
                                                  .height,
                                              child: AspectRatio(
                                                aspectRatio: controller
                                                    .value.aspectRatio,
                                                child: VideoPlayer(controller),
                                              ),
                                            ),
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                GestureDetector(
                                                  onTap: () => _togglePlay(
                                                      comment.videoUrl!),
                                                  child: Icon(
                                                    controller.value.isPlaying
                                                        ? Icons.pause
                                                        : Icons.play_arrow,
                                                    color: Colors.white,
                                                    size: 18,
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 4),
                                                  child: Text(
                                                    _formatDuration(controller
                                                        .value.duration),
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
                                    );
                                  }
                                }
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                    // Sau đó hiển thị ảnh (nếu còn chỗ)
                    if (comment.images.isNotEmpty)
                      ...comment.images
                          .take(comment.videoUrl?.isNotEmpty == true ? 2 : 3)
                          .map((imageUrl) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: GestureDetector(
                                  onTap: () => _showFullScreenMedia(
                                    context,
                                    imageUrl,
                                    false,
                                    imageUrls: comment.images,
                                    initialIndex:
                                        comment.images.indexOf(imageUrl),
                                  ),
                                  child: Hero(
                                    tag: imageUrl,
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        image: DecorationImage(
                                          image: NetworkImage(imageUrl),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopInfo(
      BuildContext context, Shop shop, List<Product> featuredProducts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipOval(
                child: Image.network(
                  shop.avatarUrl?.isNotEmpty == true
                      ? shop.avatarUrl!
                      : 'https://via.placeholder.com/60',
                  height: 60,
                  width: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 60,
                    width: 60,
                    color: Colors.grey,
                    child: const Icon(Icons.store, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shop.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        shop.addresses[0].city,
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(ShopDashboard.routeName);
                },
                child: Container(
                  height: 30,
                  width: 100,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.brown, width: 1),
                  ),
                  child: const Text(
                    "Xem shop",
                    style: TextStyle(fontSize: 14, color: Colors.brown),
                  ),
                ),
              ),
            ],
          ),
        ),

        /// Thêm tiêu đề danh sách sản phẩm nổi bật
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Sản phẩm khác của shop",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(ShopDashboard.routeName);
                },
                child: Row(
                  children: [
                    const Text(
                      "Xem tất cả",
                      style: TextStyle(fontSize: 14, color: Colors.red),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 15, color: Colors.red)
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          color: Colors.white,
          height: 230,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount:
                featuredProducts.length > 10 ? 10 : featuredProducts.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final product = featuredProducts[index];
              return _buildProductItem(product);
            },
          ),
        ),
      ],
    );
  }

  /// Widget sản phẩm đơn lẻ
  Widget _buildProductItem(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamed(DetaiItemScreen.routeName, arguments: product.id);
      },
      child: Container(
        width: 140, // Chiều rộng của mỗi sản phẩm
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 5,
              spreadRadius: 2,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
              child: Image.network(
                product.imageUrl.isNotEmpty ? product.imageUrl[0] : '',
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 100,
                  width: double.infinity,
                  color: Colors.grey,
                  child: const Icon(Icons.error, color: Colors.white),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 42,
                    width: 140,
                    child: Text(
                      product.name,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        product.averageRating.toString(),
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Đã bán ${product.quantitySold}",
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetails(Product product) {
    return Container(
      padding: const EdgeInsets.only(bottom: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey, width: 0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Chi tiết sản phẩm",
                    style: TextStyle(fontSize: 16, color: Colors.black)),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Xem chi tiết",
                    style: TextStyle(
                        fontSize: 16,
                        decoration: TextDecoration.none,
                        color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Mô tả sản phẩm", style: TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  height: _isExpanded
                      ? (_details.currentContext?.findRenderObject()
                              as RenderBox?)
                          ?.size
                          .height
                      : 100,
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Text(
                      key: _details,
                      product.description,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Container(
              height: 50,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey, width: 0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isExpanded ? "Thu gọn" : "Xem thêm ",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_outlined
                        : Icons.keyboard_arrow_down_outlined,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarProducts() {
    return BlocBuilder<RecommendationBloc, RecommendationState>(
        builder: (context, state) {
      if (state is RecommendationLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      if (state is RecommendationLoaded) {
        final products = state.recommendedProducts;
        if (products.isNotEmpty) {
          return Column(
            children: [
              Container(
                height: 50,
                width: double.infinity,
                color: Colors.grey[200],
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(height: 1, width: 50, color: Colors.black45),
                    const SizedBox(width: 10),
                    const Text("Các sản phẩm tương tự",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500)),
                    const SizedBox(width: 10),
                    Container(height: 1, width: 50, color: Colors.black45),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(bottom: 60),
                color: Colors.grey[200],
                child: GridView.builder(
                  padding: const EdgeInsets.only(top: 0, left: 10, right: 10),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 7,
                    crossAxisSpacing: 7,
                    mainAxisExtent: 280,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                            DetaiItemScreen.routeName,
                            arguments: product.id);
                      },
                      child: Container(
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.network(
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.contain,
                              product.imageUrl.isNotEmpty
                                  ? product.imageUrl[0]
                                  : '',
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              child: Column(
                                children: [
                                  Text(
                                    product.name,
                                    style: TextStyle(fontSize: 14),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                          "đ${formatPrice(product.getMinOptionPrice())}",
                                          style: TextStyle(
                                              fontSize: 16, color: Colors.red),
                                          maxLines: 1),
                                      Text('Đã bán ${product.quantitySold}',
                                          style: TextStyle(fontSize: 12),
                                          maxLines: 1),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
      }
      return const Center(child: CircularProgressIndicator());
    });
  }

  Widget _buildSepherated(BuildContext context) {
    return Container(
      height: 10,
      width: double.infinity,
      color: Colors.grey[200],
    );
  }

  Widget _buildAppBar(Cart cart) {
    return Positioned(
      child: AnimatedContainer(
        height: 80,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: _appBarColor,
          boxShadow: [
            BoxShadow(
              color: _appBarColor != Colors.transparent
                  ? Colors.grey.withOpacity(0.3)
                  : Colors.transparent,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding:
            const EdgeInsets.only(top: 30, left: 10, right: 10, bottom: 10),
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: ClipOval(
                child: Container(
                  height: 40,
                  width: 40,
                  alignment: Alignment.center,
                  color: Colors.black12,
                  child: Icon(Icons.arrow_back, color: _logoColor, size: 30),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(SearchScreen.routeName);
                },
                child: Container(
                  color: _searchBarColor,
                  height: 40,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 10),
                      Icon(Icons.search, color: _searchIconColor),
                      const SizedBox(width: 10),
                      Text("Nội dung đề xuất",
                          style:
                              TextStyle(fontSize: 14, color: _textSearchColor)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Row(
              children: [
                // GestureDetector(
                //   onTap: () {},
                //   child: ClipOval(
                //     child: Container(
                //       height: 40,
                //       width: 40,
                //       alignment: Alignment.center,
                //       color: Colors.black12,
                //       child: Icon(Icons.share_outlined,
                //           color: _logoColor, size: 25),
                //     ),
                //   ),
                // ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () {
                    if (context.read<AuthBloc>().state is AuthAuthenticated) {
                      Navigator.of(context).pushNamed(CartScreen.routeName);
                    } else {
                      Navigator.of(context).pushNamed(SigninScreen.routeName);
                    }
                  },
                  child: SizedBox(
                    height: 40,
                    width: 60,
                    child: Stack(
                      children: [
                        ClipOval(
                          child: Container(
                              color: Colors.black12,
                              height: 40,
                              width: 40,
                              alignment: Alignment.center,
                              child: SvgPicture.asset(
                                IconHelper.cartIcon,
                                height: 30,
                                width: 30,
                                color: _logoColor,
                              )),
                        ),
                        (context.read<AuthBloc>().state is AuthAuthenticated)
                            ? BlocSelector<CartBloc, CartState, String>(
                                builder: (BuildContext context, cartItem) {
                                  if (cartItem != '0') {
                                    return Positioned(
                                      right: 15,
                                      top: 5,
                                      child: Container(
                                        height: 20,
                                        width: 30,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              width: 1.5, color: Colors.white),
                                        ),
                                        child: Text(
                                          '$cartItem',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    );
                                  } else {
                                    return Container();
                                  }
                                },
                                selector: (state) {
                                  if (state is CartLoaded) {
                                    return state.cart.totalItems.toString();
                                  }
                                  return '';
                                },
                              )
                            : Container()
                      ],
                    ),
                  ),
                ),
                // GestureDetector(
                //   onTap: () {},
                //   child: ClipOval(
                //     child: Container(
                //       height: 40,
                //       width: 40,
                //       alignment: Alignment.center,
                //       color: Colors.black12,
                //       child: Icon(Icons.more_horiz_outlined,
                //           color: _logoColor, size: 30),
                //     ),
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(Product product) {
    return Positioned(
      bottom: 0,
      child: Container(
        height: 55,
        width: MediaQuery.of(context).size.width,
        color: Colors.brown[500],
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(top: 5),
                color: const Color.fromARGB(255, 240, 240, 221),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          final authState = context.read<AuthBloc>().state;
                          if (authState is AuthAuthenticated) {
                            context.read<ChatBloc>().add(StartChatEvent(
                                  authState.user.uid,
                                  product.shopId,
                                ));
                            final tempChatRoomId =
                                '${authState.user.uid}-${product.shopId}';
                            Navigator.pushNamed(
                              context,
                              ChatDetailScreen.routeName,
                              arguments: tempChatRoomId,
                            );
                          } else {
                            Navigator.of(context)
                                .pushNamed(SigninScreen.routeName);
                          }
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              IconHelper.chatIcon,
                              color: Colors.brown,
                              height: 30,
                              width: 30,
                            ),
                            const Text(
                              "Chat ngay",
                              style: TextStyle(
                                color: Colors.brown,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(width: 0.8, height: 30, color: Colors.black87),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final authState = context.read<AuthBloc>().state;
                          if (authState is AuthAuthenticated) {
                            if (product.variants.isEmpty ||
                                (product.variants.length == 2 &&
                                    product.variants.every((variant) =>
                                        variant.options.length <= 1)) ||
                                (product.variants.length == 1 &&
                                    product.variants[0].options.length <= 1)) {
                              context.read<CartBloc>().add(AddCartEvent(
                                  product.id,
                                  _quantityAddToCart,
                                  authState.user.uid,
                                  product.shopId,
                                  null,
                                  null,
                                  null,
                                  null));
                              await _showAddToCartDialog();
                            } else {
                              showAddToCart(context, product);
                            }
                          } else {
                            Navigator.of(context)
                                .pushNamed(SigninScreen.routeName);
                          }
                        },
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(FontAwesomeIcons.cartPlus,
                                color: Colors.brown),
                            Text(
                              "Thêm vào giỏ hàng",
                              style: TextStyle(
                                color: Colors.brown,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: BlocConsumer<ProductFavoriteBloc, ProductFavoriteState>(
                listener: (context, state) {
                  if (state is ProductFavoriteAdded ||
                      state is ProductFavoriteRemoved) {
                    final authState = context.read<AuthBloc>().state;
                    if (authState is AuthAuthenticated) {
                      context
                          .read<ProductFavoriteBloc>()
                          .add(FetchFavoriteProductEvent(authState.user.uid));
                    }
                  }
                },
                builder: (context, state) {
                  if (state is ProductFavoriteError) {
                    print(state.message);
                  }
                  if (state is ProductFavoriteLoaded) {
                    isFavorited = state.listProduct
                        .any((element) => element.id == product.id);
                  }
                  return GestureDetector(
                    onTap: () {
                      final authState = context.read<AuthBloc>().state;
                      if (authState is AuthAuthenticated) {
                        if (isFavorited) {
                          context.read<ProductFavoriteBloc>().add(
                                RemoveFavoriteProductEvent(
                                    product.id, authState.user.uid),
                              );
                          context.read<ProductBloc>().add(
                                DecrementProductFavoriteCountEvent(product.id),
                              );
                        } else {
                          context.read<ProductFavoriteBloc>().add(
                                AddFavoriteProductEvent(
                                    product.id, authState.user.uid),
                              );
                          context.read<ProductBloc>().add(
                                IncrementProductFavoriteCountEvent(product.id),
                              );
                        }
                      } else {
                        Navigator.of(context).pushNamed(SigninScreen.routeName);
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        isFavorited
                            ? IconHelper.heart_filled
                            : IconHelper.heart,
                        color: Colors.white,
                        height: 30,
                        width: 30,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showAddToCart(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      builder: (context) => AddToCartBottomSheet(
        productId: product.id,
        // product: product,
        parentContext: context,
      ),
    );
  }

  Widget _buildSkeletonImageSlider() {
    return Container(
      height: 410,
      color: Colors.grey[200],
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildSkeletonProductInfo() {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 20, width: 100, color: Colors.grey[300]),
          SizedBox(height: 10),
          Container(
              height: 14, width: double.infinity, color: Colors.grey[300]),
          SizedBox(height: 5),
          Container(height: 14, width: 200, color: Colors.grey[300]),
        ],
      ),
    );
  }

  Widget _buildSkeletonReviews() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            children: [
              Container(height: 16, width: 50, color: Colors.grey[300]),
              SizedBox(width: 10),
              Container(height: 16, width: 100, color: Colors.grey[300]),
            ],
          ),
          SizedBox(height: 10),
          Container(
              height: 100, width: double.infinity, color: Colors.grey[200]),
        ],
      ),
    );
  }

  Widget _buildSkeletonShopInfo() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Container(height: 60, width: 60, color: Colors.grey[300]),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 16, width: 150, color: Colors.grey[300]),
                SizedBox(height: 5),
                Container(height: 14, width: 100, color: Colors.grey[300]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonProductDetails() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 16, width: 120, color: Colors.grey[300]),
          SizedBox(height: 10),
          Container(
              height: 100, width: double.infinity, color: Colors.grey[200]),
        ],
      ),
    );
  }

  Widget _buildSkeletonBottomBar() {
    return Positioned(
      bottom: 0,
      child: Container(
        height: 55,
        width: MediaQuery.of(context).size.width,
        color: Colors.grey[300],
      ),
    );
  }

  bool _isOutOfStock(Product product) {
    int currentStock = 0;
    if (product.variants.isEmpty) {
      return true;
    } else if (product.variants.length == 1) {
      for (var optionInfo in product.optionInfos) {
        currentStock += optionInfo.stock;
      }
    }
    return currentStock == 0;
  }

  @override
  Widget build(BuildContext context) {
    productId = ModalRoute.of(context)!.settings.arguments as String;
    return BlocProvider(
      create: (context) => ProductdetailBloc(ProductService())
        ..add(FetchProductdetailEventByProductId(productId)),
      child: Scaffold(
        body: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                context
                    .read<ProductdetailBloc>()
                    .add(FetchProductdetailEventByProductId(productId));
              },
              child: SingleChildScrollView(
                controller: _appBarScrollController,
                child: Column(
                  children: [
                    // 1. Image Slider (Tải ngay từ ProductBloc)
                    BlocConsumer<ProductdetailBloc, ProductdetailState>(
                      listener: (context, state) async {
                        if (state is ProductdetailError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Lỗi tải sản phẩm: ${state.message}')),
                          );
                        }
                        if (state is ProductdetailLoaded) {
                          final product = state.product;

                          if (product.isDeleted ||
                              product.isHidden ||
                              _isOutOfStock(product)) {
                            await _showProductNotExistDialog();
                            Navigator.of(context).pop();
                          }
                        }
                      },
                      builder: (context, state) {
                        if (state is ProductdetailLoading) {
                          return _buildSkeletonImageSlider(); // Skeleton loading
                        } else if (state is ProductdetailLoaded) {
                          return _buildImageSlider(state.product);
                        }
                        return _buildSkeletonImageSlider(); // Mặc định hiển thị skeleton
                      },
                    ),
                    // 2. Product Info (Tải cùng ProductBloc)
                    BlocConsumer<ProductdetailBloc, ProductdetailState>(
                      listener: (context, state) {},
                      builder: (context, state) {
                        if (state is ProductdetailLoaded) {
                          return _buildProductInfo(state.product);
                        }
                        return _buildSkeletonProductInfo(); // Skeleton loading
                      },
                    ),
                    _buildSepherated(context),
                    // 3. Reviews Section (Tải từ ProductBloc, có thể chậm hơn)
                    BlocConsumer<ProductdetailBloc, ProductdetailState>(
                      listener: (context, state) {
                        if (state is ProductdetailLoaded) {
                          context.read<ShopBloc>().add(
                              FetchShopEventByShopId(state.product.shopId));
                        }
                      },
                      builder: (context, state) {
                        if (state is ProductdetailLoaded) {
                          return _buildReviewsSection(state.product);
                        }
                        return _buildSkeletonReviews(); // Skeleton loading
                      },
                    ),
                    _buildSepherated(context),
                    // 4. Shop Info (Tải từ ShopBloc, độc lập)
                    BlocConsumer<ShopBloc, ShopState>(
                      listener: (context, state) {
                        if (state is ShopLoaded) {
                          context.read<ListProductBloc>().add(
                              FetchListProductEventByShopId(
                                  state.shop.shopId!));
                        }
                        if (state is ShopError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Lỗi tải cửa hàng: ${state.message}')),
                          );
                        }
                      },
                      builder: (context, shopState) {
                        if (shopState is ShopLoading) {
                          return _buildSkeletonShopInfo();
                        } else if (shopState is ShopLoaded) {
                          return BlocBuilder<ListProductBloc, ListProductState>(
                            builder: (BuildContext context,
                                ListProductState listProductState) {
                              if (listProductState is ListProductLoaded) {
                                return _buildShopInfo(context, shopState.shop,
                                    listProductState.listProduct);
                              }
                              return _buildSkeletonShopInfo();
                            },
                          );
                        }
                        return _buildSkeletonShopInfo();
                      },
                    ),
                    _buildSepherated(context),
                    // 5. Product Details (Tải từ ProductBloc)
                    BlocConsumer<ProductdetailBloc, ProductdetailState>(
                      listener: (context, state) {},
                      builder: (context, state) {
                        if (state is ProductdetailLoaded) {
                          return _buildProductDetails(state.product);
                        }
                        return _buildSkeletonProductDetails(); // Skeleton loading
                      },
                    ),
                    // 6. Similar Products (Tạm giữ nguyên, có thể thêm BLoC riêng)
                    _buildSimilarProducts(),
                  ],
                ),
              ),
            ),
            // 7. AppBar (Tải từ CartBloc, luôn hiển thị)
            BlocConsumer<CartBloc, CartState>(
              listener: (context, state) {
                if (state is CartError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi giỏ hàng: ${state.message}')),
                  );
                }
              },
              builder: (context, state) {
                if (state is CartLoaded) {
                  return _buildAppBar(state.cart);
                }
                return _buildAppBar(Cart.initial());
              },
            ),
            // 8. BottomBar (Tải từ AuthBloc và ProductBloc)

            BlocConsumer<ProductdetailBloc, ProductdetailState>(
              listener: (context, state) {},
              builder: (context, productState) {
                if (productState is ProductdetailLoaded) {
                  return _buildBottomBar(productState.product);
                }
                return _buildSkeletonBottomBar(); // Skeleton loading
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildError(String message) {
    return Center(child: Text('Error: $message'));
  }

  Widget _buildInitializing() {
    return const Center(child: Text('Đang khởi tạo'));
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
                                height: MediaQuery.of(context).size.height,
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
                        height: MediaQuery.of(context).size.height,
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
}
