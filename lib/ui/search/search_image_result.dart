import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/productsearchimage/product_search_image_bloc.dart';
import 'package:luanvan/blocs/productsearchimage/product_search_image_event.dart';
import 'package:luanvan/blocs/productsearchimage/product_search_image_state.dart';
import 'package:luanvan/blocs/searchbyimage/search_image_bloc.dart';
import 'package:luanvan/blocs/searchbyimage/search_image_state.dart';
import 'package:luanvan/ui/home/detai_item_screen.dart';
import 'package:luanvan/ui/widgets/product_grid_item.dart';

class SearchImageResultScreen extends StatefulWidget {
  SearchImageResultScreen({super.key});
  static String routeName = "search_image_result_screen";
  @override
  State<SearchImageResultScreen> createState() =>
      _SearchImageResultScreenState();
}

class _SearchImageResultScreenState extends State<SearchImageResultScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Kết quả tìm kiếm bằng hình ảnh',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<SearchImageBloc, SearchImageState>(
        builder: (context, state) {
          if (state is SearchImageLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SearchImageError) {
            return Center(child: Text(state.message));
          }
          if (state is SearchImageLoaded) {
            final listImageFeature = state.imageFeature;
            if (listImageFeature.isEmpty) {
              return Container(
                color: Colors.grey[200],
                constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height),
                child: const Center(child: Text('Không tìm thấy sản phẩm')),
              );
            }
            final productIds =
                listImageFeature.map((e) => e.productId).toList();
            context.read<ProductSearchImageBloc>().add(
                  FetchMultipleProductsSearchImageEvent(productIds),
                );
            return BlocBuilder<ProductSearchImageBloc, ProductSearchImageState>(
              builder: (context, state) {
                if (state is ProductSearchImageLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ProductSearchImageError) {
                  return Center(child: Text(state.message));
                }
                if (state is ProductSearchImageListLoaded) {
                  final products = state.products;
                  return Container(
                    color: Colors.grey[200],
                    constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height),
                    child: Column(
                      children: [
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: const Row(
                            children: [
                              Text(
                                'Sản phẩm tương tự',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: GridView.builder(
                            padding: const EdgeInsets.all(8),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.9,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              mainAxisExtent: 270,
                            ),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final imageFeature = listImageFeature[index];
                              final product = products.firstWhere((element) =>
                                  element.id == imageFeature.productId);
                              return ProductGridItem(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    DetaiItemScreen.routeName,
                                    arguments: product.id,
                                  );
                                },
                                imageUrl: imageFeature.imageUrl,
                                name: product.name,
                                price: product.getMinOptionPrice(),
                                rating: product.averageRating,
                                quantitySold: product.quantitySold,
                              );
                            },
                          ),
                        ),
                      ],
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
    );
  }
}
