import 'package:flutter/material.dart';
import 'package:luanvan/common/constants/app_colors.dart';
import 'package:intl/intl.dart';

class ProductGridItem extends StatelessWidget {
  final String imageUrl;
  final String name;
  final double price;
  final double? originalPrice;
  final int? discount;
  final double? rating;
  final int? quantitySold;
  final String? location;
  final bool isOfficial;
  final VoidCallback? onTap;

  const ProductGridItem({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.price,
    this.originalPrice,
    this.discount,
    this.rating,
    this.quantitySold,
    this.location,
    this.isOfficial = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
          side: const BorderSide(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(2)),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.error_outline),
                      ),
                    );
                  },
                ),
              ),
            ),
            Container(
              height: 1,
              color: Colors.grey[200],
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isOfficial)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: const Text(
                          'Official',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormat.format(price),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (originalPrice != null && originalPrice! > price) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            currencyFormat.format(originalPrice),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          if (discount != null) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Text(
                                '-$discount%',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                    const Spacer(),
                    if (rating != null && quantitySold != null)
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 12,
                            color: Colors.amber[700],
                          ),
                          const SizedBox(width: 2),
                          Text(
                            rating!.toString(),
                            style: const TextStyle(fontSize: 12),
                          ),
                          Expanded(
                            child: Text(
                              'Đã bán $quantitySold',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (location != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        location!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
