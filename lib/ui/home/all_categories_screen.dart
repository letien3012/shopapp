// import 'package:flutter/material.dart';
// import 'package:luanvan/models/category.dart';

// class AllCategoriesScreen extends StatelessWidget {
//   static const routeName = 'all-categories';
//   AllCategoriesScreen({super.key});
//   final allcategory = getMegaCategories();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.brown),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'DANH MỤC NGÀNH HÀNG',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: Colors.brown,
//           ),
//         ),
//       ),
//       body: Container(
//         constraints:
//             BoxConstraints(minHeight: MediaQuery.of(context).size.height),
//         color: Colors.white,
//         child: GridView.builder(
//           shrinkWrap: true,
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 4,
//             childAspectRatio: 0.8,
//           ),
//           itemCount: allcategory.length,
//           padding: const EdgeInsets.all(16),
//           itemBuilder: (context, index) {
//             return CategoryItem(
//               imageUrl: allcategory[index].iconUrl ?? '',
//               label: allcategory[index].name,
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// class CategoryItem extends StatelessWidget {
//   final String imageUrl;
//   final String label;

//   const CategoryItem({
//     super.key,
//     required this.imageUrl,
//     required this.label,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Container(
//             width: 60,
//             height: 60,
//             decoration: BoxDecoration(
//               color: Colors.grey[200],
//               borderRadius: BorderRadius.circular(30),
//             ),
//             child: Image.asset(
//               imageUrl,
//               height: 30,
//               width: 30,
//             )),
//         const SizedBox(height: 8),
//         SizedBox(
//           height: 42,
//           child: Text(
//             label,
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w500,
//             ),
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//       ],
//     );
//   }
// }
