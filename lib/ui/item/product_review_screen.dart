import 'package:flutter/material.dart';
import 'package:luanvan/models/comment.dart';
import 'package:intl/intl.dart';

class ProductReviewScreen extends StatefulWidget {
  static String routeName = "product_review_screen";
  const ProductReviewScreen({super.key});

  @override
  State<ProductReviewScreen> createState() => _ProductReviewScreenState();
}

class _ProductReviewScreenState extends State<ProductReviewScreen> {
  final List<Comment> comments = [
    Comment(
      id: '1',
      userId: 'user1',
      // userName: 'Nguyễn Văn A',
      // userAvatar: 'https://picsum.photos/100',
      content:
          'Sản phẩm rất tốt, giao hàng nhanh. Robot hút bụi rất thông minh và dễ sử dụng.',
      rating: 5,
      images: [
        'https://picsum.photos/400',
        'https://picsum.photos/401',
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      isVerified: true,
      replyContent: 'Cảm ơn bạn đã mua hàng và đánh giá sản phẩm!',
      replyAt: DateTime.now().subtract(const Duration(days: 1)),
      productId: '',
      orderId: '',
    ),
    Comment(
      id: '2',
      userId: 'user2',
      // userName: 'Trần Thị B',
      // userAvatar: 'https://picsum.photos/101',
      content: 'Máy chạy êm, lau nhà sạch. Rất hài lòng với sản phẩm này.',
      rating: 4,
      images: [
        'https://picsum.photos/402',
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      isVerified: true,
      productId: '',
      orderId: '',
    ),
  ];

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
              'Đánh giá (999)',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Text(
                  '4.9',
                  style: TextStyle(
                    color: Colors.amber[700],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.star, color: Colors.amber[700], size: 16),
                const Text(
                  ' | 99% Đánh giá tích cực',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) =>
                  _buildCommentItem(comments[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
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
              children: [
                _buildFilterChip('Tất cả', true),
                _buildFilterChip('5 Sao (500)', false),
                _buildFilterChip('4 Sao (300)', false),
                _buildFilterChip('3 Sao (150)', false),
                _buildFilterChip('2 Sao (40)', false),
                _buildFilterChip('1 Sao (9)', false),
                _buildFilterChip('Có Bình luận (600)', false),
                _buildFilterChip('Có Hình ảnh (400)', false),
              ],
            ),
          ),
        ],
      ),
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
          // Handle filter selection
        },
        backgroundColor: Colors.grey[200],
        selectedColor: Colors.blue,
        checkmarkColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  Widget _buildCommentItem(Comment comment) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // CircleAvatar(
              //   radius: 16,
              //   backgroundImage: NetworkImage(comment.userAvatar),
              // ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(
                    //   comment.userName,
                    //   style: const TextStyle(
                    //     fontWeight: FontWeight.w500,
                    //   ),
                    // ),
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
              if (comment.isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle,
                          size: 12, color: Colors.green[700]),
                      const SizedBox(width: 4),
                      Text(
                        'Đã mua hàng',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          // if (comment.variation != null) ...[
          //   const SizedBox(height: 8),
          //   Text(
          //     'Phân loại: ${comment.variation}',
          //     style: TextStyle(
          //       color: Colors.grey[600],
          //       fontSize: 13,
          //     ),
          //   ),
          // ],
          const SizedBox(height: 8),
          Text(comment.content),
          if (comment.images.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: comment.images.length,
                itemBuilder: (context, index) => Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    image: DecorationImage(
                      image: NetworkImage(comment.images[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
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
                        'Phản hồi của Người bán',
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
        ],
      ),
    );
  }
}
