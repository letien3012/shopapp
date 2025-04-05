import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/category/category_bloc.dart';
import 'package:luanvan/blocs/category/category_event.dart';
import 'package:luanvan/blocs/category/category_state.dart';

class AllCategoriesScreen extends StatelessWidget {
  static const routeName = 'all-categories';
  AllCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<CategoryBloc>().add(FetchCategoriesEvent());
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: const Text(
          'DANH MỤC NGÀNH HÀNG',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.brown,
          ),
        ),
      ),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CategoryError) {
            return Center(child: Text(state.message));
          }
          if (state is CategoryLoaded) {
            final allcategory = state.categories;
            return Container(
              constraints:
                  BoxConstraints(minHeight: MediaQuery.of(context).size.height),
              color: Colors.white,
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 0.8,
                ),
                itemCount: allcategory.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  return CategoryItem(
                    imageUrl: allcategory[index].imageUrl ?? '',
                    label: allcategory[index].name,
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final String imageUrl;
  final String label;

  const CategoryItem({
    super.key,
    required this.imageUrl,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(30),
            ),
            child: Image.network(
              imageUrl,
              height: 30,
              width: 30,
            )),
        const SizedBox(height: 8),
        SizedBox(
          height: 42,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
