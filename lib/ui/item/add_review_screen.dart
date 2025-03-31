import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:luanvan/blocs/comment/comment_bloc.dart';
import 'package:luanvan/blocs/comment/comment_event.dart';
import 'package:luanvan/blocs/comment/comment_state.dart';
import 'package:luanvan/blocs/order/order_bloc.dart';
import 'package:luanvan/blocs/order/order_event.dart';
import 'package:luanvan/blocs/order/order_state.dart';
import 'package:luanvan/blocs/productorder/product_order_bloc.dart';
import 'package:luanvan/blocs/productorder/product_order_state.dart';
import 'package:luanvan/blocs/shop/shop_bloc.dart';
import 'package:luanvan/blocs/shop/shop_state.dart';
import 'package:luanvan/models/address.dart';
import 'package:luanvan/models/cart_item.dart';
import 'package:luanvan/models/comment.dart';
import 'package:luanvan/models/order.dart';
import 'package:luanvan/models/product.dart';
import 'package:luanvan/models/shipping_method.dart';
import 'package:luanvan/models/shop_comment.dart';
import 'package:luanvan/ui/helper/icon_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luanvan/ui/widgets/alert_diablog.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:luanvan/services/storage_service.dart';

class AddReviewScreen extends StatefulWidget {
  static String routeName = 'add_review';
  const AddReviewScreen({super.key});

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final TextEditingController _reviewController = TextEditingController();
  final Color primaryBrown = const Color(0xFF8B4513);
  final StorageService _storageService = StorageService();
  final ImagePicker _imagePicker = ImagePicker();
  List<String> _selectedImages = [];

  // Danh sách rating cho từng sản phẩm
  Map<String, int> _productRatings = {};
  Map<String, TextEditingController> _productReviewControllers = {};
  Map<String, List<File>> _productImages = {};
  Map<String, List<File>> _productVideos = {};

  // Rating cho shop
  int _shopRating = 0;

  // Mock data for testing
  List<String> _itemIds = [];
  Order order = Order(
      id: '',
      item: [],
      shopId: '',
      userId: '',
      shipMethod: ShippingMethod(
          name: '', cost: 0, additionalWeightCost: 0, estimatedDeliveryDays: 0),
      createdAt: DateTime.now(),
      receiveAdress: Address(
          addressLine: '',
          ward: '',
          district: '',
          city: '',
          isDefault: false,
          receiverName: '',
          receiverPhone: ''),
      totalProductPrice: 0,
      totalShipFee: 0,
      totalPrice: 0);

  String getItemKey(CartItem item) {
    return '${item.productId}_${item.variantId1 ?? ''}_${item.optionId1 ?? ''}_${item.variantId2 ?? ''}_${item.optionId2 ?? ''}';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      order = ModalRoute.of(context)?.settings.arguments as Order;
      setState(() {
        order.item.forEach((element) {
          final itemId = getItemKey(element);
          _itemIds.add(itemId);
          _productRatings[itemId] = 0;
          _productReviewControllers[itemId] = TextEditingController();
          _productImages[itemId] = [];
          _productVideos[itemId] = [];
        });
      });
    });
  }

  @override
  void dispose() {
    _reviewController.dispose();
    // Dispose tất cả các controller
    _productReviewControllers.values
        .forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _pickImage(String itemId) async {
    try {
      // Khởi tạo mảng nếu chưa tồn tại
      _productImages[itemId] ??= [];

      int remainingSlots = 5 - (_productImages[itemId]?.length ?? 0);
      if (remainingSlots <= 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Bạn chỉ có thể tải lên tối đa 5 hình ảnh')),
          );
        }
        return;
      }

      // Lưu context hiện tại
      final currentContext = context;
      if (!mounted) return;

      // Show dialog for image selection method
      final result = await showDialog<bool>(
        context: currentContext,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            titlePadding: const EdgeInsets.symmetric(vertical: 10),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            title: const Stack(
              children: [
                Center(
                  child: Text(
                    'Thao tác',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ListTile(
                  title: const Text('Chụp ảnh'),
                  onTap: () async {
                    Navigator.pop(dialogContext, true);
                    final XFile? image = await _imagePicker.pickImage(
                      source: ImageSource.camera,
                      maxWidth: 1920,
                      maxHeight: 1080,
                      imageQuality: 85,
                    );

                    if (image != null && mounted) {
                      setState(() {
                        _productImages[itemId]?.add(File(image.path));
                      });
                    }
                  },
                ),
                ListTile(
                  title: const Text('Thư viện hình ảnh'),
                  onTap: () async {
                    Navigator.pop(dialogContext, true);
                    final List<XFile> images =
                        await _imagePicker.pickMultiImage(
                      maxWidth: 1920,
                      maxHeight: 1080,
                      imageQuality: 85,
                    );

                    if (images.isNotEmpty && mounted) {
                      // Kiểm tra số lượng ảnh có thể thêm
                      if (images.length > remainingSlots) {
                        if (mounted) {
                          ScaffoldMessenger.of(currentContext).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Bạn chỉ có thể thêm tối đa $remainingSlots ảnh nữa',
                              ),
                              action: SnackBarAction(
                                label: 'Chọn lại',
                                onPressed: () {
                                  // Đóng SnackBar trước
                                  ScaffoldMessenger.of(currentContext)
                                      .hideCurrentSnackBar();
                                  // Sau đó mới gọi lại hàm chọn ảnh
                                  Future.delayed(
                                      const Duration(milliseconds: 100), () {
                                    if (mounted) {
                                      _pickImage(itemId);
                                    }
                                  });
                                },
                              ),
                            ),
                          );
                        }
                        return;
                      }

                      setState(() {
                        for (var image in images) {
                          _productImages[itemId]?.add(File(image.path));
                        }
                      });
                    }
                  },
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          );
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải ảnh: $e')),
        );
      }
    }
  }

  Future<void> _pickVideo(String itemId) async {
    try {
      // Khởi tạo mảng nếu chưa tồn tại
      _productVideos[itemId] ??= [];

      // Check if already have 1 video
      if ((_productVideos[itemId]?.length ?? 0) >= 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Bạn chỉ có thể tải lên tối đa 1 video')),
        );
        return;
      }

      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 1),
      );

      if (video != null) {
        // Check file size (50MB = 50 * 1024 * 1024 bytes)
        final fileSize = await File(video.path).length();
        if (fileSize > 50 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Video không được vượt quá 50MB')),
          );
          return;
        }

        setState(() {
          // Thêm video vào đầu danh sách
          _productVideos[itemId]?.insert(0, File(video.path));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi chọn video: $e')),
      );
    }
  }

  void _removeImage(String itemId, int index) {
    setState(() {
      _productImages[itemId]?.removeAt(index);
    });
  }

  void _removeVideo(String itemId, int index) {
    setState(() {
      _productVideos[itemId]?.removeAt(index);
    });
  }

  Future<void> _submitReview() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Upload all images and videos for each product
      Map<String, List<String>> uploadedImages = {};
      Map<String, List<String>> uploadedVideos = {};

      for (var itemId in _itemIds) {
        // Upload images
        if (_productImages[itemId]?.isNotEmpty ?? false) {
          uploadedImages[itemId] = [];
          for (var imageFile in _productImages[itemId]!) {
            String? downloadUrl = await _storageService.uploadFile(
              imageFile,
              'image',
              'reviews',
              itemId,
            );
            if (downloadUrl != null) {
              uploadedImages[itemId]!.add(downloadUrl);
            }
          }
        }

        // Upload videos
        if (_productVideos[itemId]?.isNotEmpty ?? false) {
          uploadedVideos[itemId] = [];
          for (var videoFile in _productVideos[itemId]!) {
            // Compress video before uploading
            final MediaInfo? mediaInfo = await VideoCompress.compressVideo(
              videoFile.path,
              quality: VideoQuality.MediumQuality,
              deleteOrigin: false,
            );

            if (mediaInfo != null) {
              String? downloadUrl = await _storageService.uploadFile(
                File(mediaInfo.path!),
                'video',
                'reviews',
                itemId,
              );
              if (downloadUrl != null) {
                uploadedVideos[itemId]!.add(downloadUrl);
              }
            }
          }
        }
      }
      List<Comment> comments = [];

      // Submit review data to server
      for (var itemId in _itemIds) {
        final item =
            order.item.firstWhere((item) => getItemKey(item) == itemId);
        final rating = (_productRatings[itemId]! > 0)
            ? _productRatings[itemId]!
            : 5; // Default to 5 stars if not rated
        final reviewText = _productReviewControllers[itemId]?.text ?? '';
        final images = uploadedImages[itemId] ?? [];
        final videos = uploadedVideos[itemId] ?? [];

        comments.add(
          Comment(
            id: '',
            userId: order.userId,
            productId: item.productId,
            content: reviewText,
            rating: rating,
            variant: CommentVariant(
              variantId1: item.variantId1,
              optionId1: item.optionId1,
              variantId2: item.variantId2,
              optionId2: item.optionId2,
            ),
            videoUrl: videos.isNotEmpty ? videos.first : null,
            images: images,
            createdAt: DateTime.now(),
            orderId: order.id,
          ),
        );
      }

      // Submit shop rating
      final shopRating =
          _shopRating > 0 ? _shopRating : 5; // Default to 5 stars if not rated
      ShopComment shopComment = ShopComment(
        id: '',
        userId: order.userId,
        shopId: order.shopId,
        rating: shopRating,
        createdAt: DateTime.now(),
        orderId: order.id,
      );

      context.read<CommentBloc>().add(AddCommentEvent(
            comments: comments,
            shopComment: shopComment,
          ));

      context.read<OrderBloc>().add(
            UpdateOrderStatus(
              order.id,
              OrderStatus.reviewed,
              note: "Đơn hàng đã được đánh giá",
            ),
          );

      // Wait for the status update to complete
      await for (final state in context.read<OrderBloc>().stream) {
        if (state is OrderDetailLoaded) {
          // Reload orders after successful update

          context.read<OrderBloc>().add(FetchOrdersByUserId(order.userId));

          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đánh giá đã được gửi thành công')),
            );
            Navigator.pop(context);
          }
          break;
        } else if (state is OrderError) {
          // Show error message
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi đánh giá: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
          break;
        }
      }
    } catch (e) {
      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi đánh giá: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Hide loading indicator
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Đánh giá sản phẩm',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        color: Colors.white,
        constraints:
            BoxConstraints(minHeight: MediaQuery.of(context).size.height),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BlocBuilder<ProductOrderBloc, ProductOrderState>(
                      builder: (context, productOrderState) {
                        if (productOrderState is ProductOrderListLoaded) {
                          return ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: order.item.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 32),
                            itemBuilder: (context, index) {
                              final item = order.item[index];
                              final product =
                                  productOrderState.products.firstWhere(
                                (element) => element.id == item.productId,
                              );
                              return _buildProductReviewItem(product, item);
                            },
                          );
                        }
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildShopRating(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _submitReview,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.brown,
            minimumSize: const Size(double.infinity, 45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: const Text(
            'Gửi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductReviewItem(Product product, CartItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProductInfo(product, item),
        const SizedBox(height: 16),
        _buildRatingStars(getItemKey(item)),
        const SizedBox(height: 16),
        _buildImageUpload(getItemKey(item)),
        const SizedBox(height: 16),
        _buildReviewInput(getItemKey(item)),
      ],
    );
  }

  Widget _buildProductInfo(Product product, CartItem item) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.network(
            (product.hasVariantImages && product.variants.isNotEmpty)
                ? (product
                        .variants[0]
                        .options[product.variants[0].options.indexWhere(
                            (option) => option.id == item.optionId1)]
                        .imageUrl ??
                    product.imageUrl[0])
                : product.imageUrl[0],
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: const TextStyle(fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                children: [
                  Text(
                      (item.variantId1 != null)
                          ? product.variants
                              .firstWhere(
                                  (variant) => variant.id == item.variantId1)
                              .options
                              .firstWhere(
                                  (option) => option.id == item.optionId1)
                              .name
                          : '',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w300),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(
                      (item.variantId2 != null)
                          ? ', ${product.variants.firstWhere((variant) => variant.id == item.variantId2).options.firstWhere((option) => option.id == item.optionId2).name}'
                          : '',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w300),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingStars(String itemId) {
    return Column(
      children: [
        Container(
          height: 0.5,
          color: Colors.grey[200],
        ),
        const SizedBox(height: 10),
        const Text(
          'Đánh giá sản phẩm',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return IconButton(
              onPressed: () {
                setState(() {
                  _productRatings[itemId] = index + 1;
                  print(
                      'Rating updated for $itemId: ${_productRatings[itemId]}');
                });
              },
              icon: Icon(
                index < (_productRatings[itemId] ?? 0)
                    ? Icons.star
                    : Icons.star_border,
                color: Colors.amber,
                size: 40,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildShopRating() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Đánh giá dịch vụ của người bán',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                onPressed: () {
                  setState(() {
                    _shopRating = index + 1;
                  });
                },
                icon: Icon(
                  index < _shopRating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 40,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUpload(String itemId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Thêm ít nhất 1 hình ảnh/video về sản phẩm',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 8),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Display selected videos first
              ...(_productVideos[itemId] ?? []).map((videoFile) => Stack(
                    children: [
                      GestureDetector(
                        onTap: () => _playVideo(videoFile),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.grey[200],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.videocam,
                              size: 32,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 12,
                        top: 4,
                        child: GestureDetector(
                          onTap: () => _removeVideo(
                              itemId,
                              (_productVideos[itemId] ?? [])
                                  .indexOf(videoFile)),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
              // Then display selected images
              ...(_productImages[itemId] ?? []).map((imageFile) => Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          image: DecorationImage(
                            image: FileImage(imageFile),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 12,
                        top: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(
                              itemId,
                              (_productImages[itemId] ?? [])
                                  .indexOf(imageFile)),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
              // Add image button (only show if not at limit)
              if ((_productImages[itemId]?.length ?? 0) < 5)
                GestureDetector(
                  onTap: () => _pickImage(itemId),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt,
                            color: Colors.grey[400], size: 32),
                        const SizedBox(height: 4),
                        Text('Hình ảnh',
                            style: TextStyle(color: Colors.grey[400])),
                      ],
                    ),
                  ),
                ),
              // Add video button (only show if not at limit)
              if ((_productVideos[itemId]?.length ?? 0) < 1)
                GestureDetector(
                  onTap: () => _pickVideo(itemId),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.videocam, color: Colors.grey[400], size: 32),
                        const SizedBox(height: 4),
                        Text('Video',
                            style: TextStyle(color: Colors.grey[400])),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _playVideo(File videoFile) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Initialize video player
      final VideoPlayerController controller =
          VideoPlayerController.file(videoFile);
      await controller.initialize();

      // Hide loading indicator
      Navigator.of(context).pop();

      // Show video player dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: VideoPlayer(controller),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      controller.dispose();
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );

      // Start playing
      controller.play();
    } catch (e) {
      // Hide loading indicator
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi phát video: $e')),
      );
    }
  }

  Widget _buildReviewInput(String itemId) {
    return TextField(
      controller: _productReviewControllers[itemId],
      maxLines: 5,
      maxLength: 500,
      decoration: InputDecoration(
        hintText: 'Hãy chia sẻ nhận xét cho sản phẩm này bạn nhé!',
        hintStyle: TextStyle(color: Colors.grey[400]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: primaryBrown),
        ),
      ),
    );
  }
}
