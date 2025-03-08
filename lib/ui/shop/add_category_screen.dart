import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});
  static String routeName = "add_category";

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  // Danh sách các ngành hàng lớn (List<String>)
  final List<String> categories = [
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

  // Lưu trạng thái ngành hàng được chọn
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
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
                  SizedBox(
                    height: 40,
                    child: Text(
                      "Chọn ngành hàng",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500),
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
