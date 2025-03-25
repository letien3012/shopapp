import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:luanvan/models/product.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});
  static String routeName = "add_category";

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final List<String> _allCategories = [
    "Thời Trang Nam",
    "Thời Trang Nữ",
    "Điện Thoại & Phụ Kiện",
    "Mẹ & Bé",
    "Thiết Bị Điện Tử",
    "Nhà Cửa & Đời Sống",
    "Máy tính & Laptop",
    "Sức Khỏe & Sắc Đẹp",
    "Thể Thao & Du Lịch",
    "Ô Tô & Xe Máy & Xe Đạp",
    "Sách, Báo & Tạp Chí",
    "Thực Phẩm & Đồ Uống",
    "Văn Phòng Phẩm & Đồ Lưu Niệm",
    "Nhạc Cụ & Phụ Kiện Âm Nhạc",
    "Đồ Chơi & Trò Chơi",
    "Hàng Quốc Tế",
    "Siêu Thị Mini",
    "Thời Trang Trẻ Em",
    "Đồng Hồ",
    "Trang Sức",
    "Giày Dép Nam",
    "Giày Dép Nữ",
    "Túi Xách",
    "Phụ Kiện Thời Trang",
    "Nhà Sách Online",
    "Dịch Vụ & Du Lịch",
    "Voucher & Phiếu Quà Tặng",
    "Hàng Tiêu Dùng",
    "Đồ Nội Thất",
    "Dụng Cụ & Thiết Bị Tiện Ích",
    "Đồ Gia Dụng",
    "Phần Mềm & Ứng Dụng",
    "Đồ Chơi Công Nghệ",
    "Máy Ảnh & Máy Quay Phim",
    "Thiết Bị Chăm Sóc Sức Khỏe",
    "Thiết Bị Làm Đẹp",
    "Đồ Dùng Văn Phòng",
    "Dụng Cụ Học Sinh",
    "Đồ Dùng Tiệc & Sự Kiện",
    "Đồ Dùng Nhà Bếp",
    "Đồ Dùng Phòng Tắm",
    "Đồ Trang Trí Nhà Cửa",
    "Đèn & Thiết Bị Chiếu Sáng",
    "Đồ Dùng Lưu Trữ",
    "Dụng Cụ Vệ Sinh",
    "Sản Phẩm Chăm Sóc Thú Cưng",
    "Thức Ăn Thú Cưng",
    "Phụ Kiện Thú Cưng",
    "Sản Phẩm Nông Nghiệp",
    "Cây Cảnh & Hạt Giống",
    "Dụng Cụ Làm Vườn",
    "Đồ Dùng Phòng Ngủ",
    "Đồ Dùng Phòng Khách",
    "Đồ Dùng Phòng Ăn",
    "Sản Phẩm Chống Nước",
    "Sản Phẩm Chống Nắng",
    "Dụng Cụ Thể Thao Trong Nhà",
    "Dụng Cụ Thể Thao Ngoài Trời",
    "Quần Áo Thể Thao",
    "Giày Thể Thao",
    "Phụ Kiện Thể Thao",
    "Thiết Bị An Ninh",
    "Camera & Thiết Bị Giám Sát",
    "Thiết Bị Điện",
    "Dụng Cụ Sửa Chữa",
    "Dụng Cụ Xây Dựng",
    "Vật Liệu Xây Dựng",
    "Sản Phẩm Tiết Kiệm Năng Lượng",
    "Sản Phẩm Bảo Vệ Môi Trường",
    "Đồ Dùng Học Tập Trẻ Em",
    "Đồ Chơi Giáo Dục",
    "Đồ Dùng Cho Bé Sơ Sinh",
  ];

  // Map từ khóa với ngành hàng tương ứng
  final Map<String, List<String>> _keywordCategories = {
    'quần': ['Thời Trang Nam', 'Thời Trang Nữ', 'Thời Trang Trẻ Em'],
    'áo': ['Thời Trang Nam', 'Thời Trang Nữ', 'Thời Trang Trẻ Em'],
    'giày': ['Giày Dép Nam', 'Giày Dép Nữ', 'Giày Thể Thao'],
    'điện thoại': ['Điện Thoại & Phụ Kiện'],
    'laptop': ['Máy tính & Laptop'],
    'sách': ['Sách, Báo & Tạp Chí', 'Nhà Sách Online'],
    'thực phẩm': ['Thực Phẩm & Đồ Uống'],
    'mỹ phẩm': ['Sức Khỏe & Sắc Đẹp'],
    'đồ chơi': ['Đồ Chơi & Trò Chơi', 'Đồ Chơi Giáo Dục'],
    'camera': ['Máy Ảnh & Máy Quay Phim'],
    'túi': ['Túi Xách'],
    'đồng hồ': ['Đồng Hồ'],
    'trang sức': ['Trang Sức'],
    'nội thất': ['Đồ Nội Thất'],
    'thiết bị': ['Thiết Bị Điện Tử'],
    'phụ kiện': ['Phụ Kiện Thời Trang'],
    'thể thao': ['Thể Thao & Du Lịch', 'Quần Áo Thể Thao'],
  };

  // Danh sách hiển thị sau khi tìm kiếm
  List<String> categories = [];
  List<String> suggestedCategories = [];

  // Controller cho ô tìm kiếm
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    categories = _allCategories;
    _searchController.addListener(() {
      filterCategories(_searchController.text);
    });

    // Đợi build context sẵn sàng
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final product = args['product'] as Product?;
      print(product);
      // Đề xuất ngành hàng nếu có product
      if (product != null) {
        suggestedCategories =
            _suggestCategories(product.name, product.description ?? '');
        // Đưa các ngành hàng được đề xuất lên đầu danh sách
        setState(() {
          categories = [
            ...suggestedCategories,
            ..._allCategories.where((c) => !suggestedCategories.contains(c))
          ];
        });
      }
    });
  }

  // Hàm đề xuất ngành hàng dựa trên tên và mô tả
  List<String> _suggestCategories(String name, String description) {
    final Set<String> suggestions = {};
    final String searchText = '$name $description'.toLowerCase();

    _keywordCategories.forEach((keyword, categories) {
      if (searchText.contains(keyword.toLowerCase())) {
        suggestions.addAll(categories);
      }
    });

    return suggestions.toList();
  }

  // Hàm lọc danh sách theo từ khóa tìm kiếm
  void filterCategories(String keyword) {
    setState(() {
      if (keyword.isEmpty) {
        categories = _allCategories;
      } else {
        categories = _allCategories
            .where((category) =>
                category.toLowerCase().contains(keyword.toLowerCase()))
            .toList();
      }
    });
  }

  // Lưu trạng thái ngành hàng được chọn
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    selectedCategory = args['selectedCategory'] as String;

    // Đưa ngành hàng đã chọn lên đầu nếu có
    if (selectedCategory != null && selectedCategory != "Chọn ngành hàng") {
      categories = [
        selectedCategory!,
        ...categories.where((category) => category != selectedCategory),
      ];
    }

    return Scaffold(
      body: Stack(
        children: [
          // Nội dung chính (danh sách danh mục)
          SingleChildScrollView(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              padding: const EdgeInsets.only(top: 90, bottom: 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (suggestedCategories.isNotEmpty) ...[
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        "Đề xuất cho sản phẩm của bạn",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                    ),
                  ],
                  // Tiêu đề "Danh mục Ngành hàng"
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      "Danh mục Ngành hàng",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  // Danh sách các ngành hàng lớn
                  ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          ListTile(
                            titleTextStyle: TextStyle(
                                color: selectedCategory == categories[index]
                                    ? Colors.brown
                                    : Colors.black),
                            title: Text(categories[index]),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 15,
                              color: Colors.black54,
                            ),
                            onTap: () {
                              setState(() {
                                selectedCategory = categories[index];
                                Navigator.pop(context, selectedCategory);
                              });
                            },
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                          ),
                          const Divider(height: 0.5, thickness: 0.2),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // AppBar
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: 90,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.only(
                  top: 30, left: 10, right: 10, bottom: 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Icon trở về
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(bottom: 5),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.brown,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 40,
                      margin: const EdgeInsets.only(bottom: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          filterCategories(value);
                        },
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm ngành hàng...',
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, color: Colors.grey),
                                  onPressed: () {
                                    _searchController.clear();
                                    filterCategories('');
                                  },
                                )
                              : null,
                        ),
                      ),
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
}
