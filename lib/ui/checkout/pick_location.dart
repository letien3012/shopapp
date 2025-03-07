import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:dvhcvn/dvhcvn.dart' as dvhcvn;

class PickLocation extends StatefulWidget {
  const PickLocation({super.key});
  static String routeName = "pick_location";

  @override
  State<PickLocation> createState() => _PickLocationState();
}

class _PickLocationState extends State<PickLocation> {
  int pickLevel = 0;
  int stepPick = 0;
  final List<dvhcvn.Level1> provinces = dvhcvn.level1s;
  String _lv1PickId = '';
  String _lv2PickId = '';
  String _lv3PickId = '';
  String _lv1PickName = '';
  String _lv2PickName = '';
  String _lv3PickName = '';

  List<Map<String, String>> vietnamProvinces = [];
  List<Map<String, String>> filteredProvinces = [];
  String _labelSelect = 'Tỉnh/Thành phố';
  final TextEditingController _searchController = TextEditingController();

  // Nhận dữ liệu từ AddLocationShopScreen
  String? preSelectedLocation;
  String _province = '';
  String _district = '';
  String _ward = '';

  @override
  void initState() {
    super.initState();
    _loadProvinces(); // Tải danh sách tỉnh mặc định
    filteredProvinces = List.from(vietnamProvinces);
    _searchController.addListener(_filterLocations);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Lấy dữ liệu pre-selected từ arguments sau khi context sẵn sàng
    final args = ModalRoute.of(context)?.settings.arguments as String?;
    if (args != null &&
        args != "Tỉnh/Thành phố, Quận/Huyện, Phường/Xã" &&
        preSelectedLocation == null) {
      preSelectedLocation = args;
      _parsePreSelectedLocation();
    }
  }

  void _loadProvinces() {
    vietnamProvinces.clear();
    for (int i = 0; i < provinces.length; i++) {
      vietnamProvinces.add({
        "id": provinces[i].id,
        "name":
            provinces[i].name.replaceAll(RegExp(r'^(Tỉnh |Thành phố )'), ""),
      });
    }
    vietnamProvinces.sort((a, b) => a["name"]!.compareTo(b["name"]!));
  }

  // Phân tích dữ liệu pre-selected để pre-select
  void _parsePreSelectedLocation() {
    if (preSelectedLocation != null) {
      final parts = preSelectedLocation!.split(', ');
      if (parts.length == 3) {
        _ward = parts[0].trim();
        _district = parts[1].trim();
        _province = parts[2].trim();

        // Tìm và set ID tương ứng
        final provinceData = provinces.firstWhere(
          (p) =>
              p.name.replaceAll(RegExp(r'^(Tỉnh |Thành phố )'), "") ==
              _province,
          orElse: () => provinces[0],
        );
        _lv1PickId = provinceData.id;
        _lv1PickName = _province;

        if (_district.isNotEmpty) {
          final districtData = provinceData.children.firstWhere(
            (d) => d.name == _district,
            orElse: () => provinceData.children[0],
          );
          _lv2PickId = districtData.id;
          _lv2PickName = _district;

          if (_ward.isNotEmpty) {
            final wardData = districtData.children.firstWhere(
              (w) => w.name == _ward,
              orElse: () => districtData.children[0],
            );
            _lv3PickId = wardData.id;
            _lv3PickName = _ward;
            pickLevel = 2; // Đặt level là 2 (phường/xã)
            stepPick = 2; // Hiển thị cấp phường/xã
            _labelSelect = "Phường/Xã";
            // Tải danh sách phường/xã
            vietnamProvinces.clear();
            for (var ward in districtData.children) {
              vietnamProvinces.add({
                "id": ward.id,
                "name": ward.name,
              });
            }
          } else {
            pickLevel = 1; // Đặt level 1 nếu chỉ có district
            stepPick = 1; // Hiển thị cấp quận/huyện
            _labelSelect = "Quận/Huyện";
            // Tải danh sách quận/huyện
            vietnamProvinces.clear();
            for (var district in provinceData.children) {
              vietnamProvinces.add({
                "id": district.id,
                "name": district.name,
              });
            }
          }
        } else {
          pickLevel = 0; // Đặt level 0 nếu chỉ có province
          stepPick = 0; // Hiển thị cấp tỉnh/thành phố
          _labelSelect = "Tỉnh/Thành phố";
          _loadProvinces(); // Tải danh sách tỉnh
        }
        setState(() {
          filteredProvinces = List.from(vietnamProvinces); // Cập nhật giao diện
        });
      }
    }
  }

  void _filterLocations() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredProvinces = List.from(vietnamProvinces);
      } else {
        filteredProvinces = vietnamProvinces
            .where(
                (location) => location["name"]!.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  void _completeSelection() {
    if (_lv3PickId.isNotEmpty) {
      final selectedLocation = {
        'province': _lv1PickName,
        'district': _lv2PickName,
        'ward': _lv3PickName,
      };
      Navigator.pop(context, selectedLocation);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              width: MediaQuery.of(context).size.width,
              color: Colors.grey[200],
              padding: const EdgeInsets.only(top: 90, bottom: 20),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      height: 60,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(width: 0.4, color: Colors.grey)),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            HeroIcons.map_pin,
                            size: 25,
                            color: Colors.brown,
                          ),
                          SizedBox(width: 5),
                          Text(
                            "Sử dụng vị trí hiện tại của tôi",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: _lv1PickId.isNotEmpty
                        ? const EdgeInsets.symmetric(vertical: 10)
                        : null,
                    width: double.infinity,
                    color: Colors.white,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              stepPick = 0;
                              pickLevel = 0;
                              _labelSelect = "Tỉnh/Thành phố";
                              // Khi chọn lại tỉnh, xóa quận/huyện và phường/xã
                              _lv2PickId = '';
                              _lv2PickName = '';
                              _lv3PickId = '';
                              _lv3PickName = '';
                              _loadProvinces();
                              _filterLocations();
                            });
                          },
                          child: AnimatedContainer(
                            height: 50,
                            constraints: BoxConstraints(
                              maxHeight: _lv1PickId.isNotEmpty ? 50 : 0,
                            ),
                            margin: stepPick == 0
                                ? const EdgeInsets.symmetric(horizontal: 10)
                                : null,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: stepPick == 0
                                  ? Border.all(width: 1, color: Colors.grey)
                                  : null,
                              borderRadius: stepPick == 0
                                  ? BorderRadius.circular(10)
                                  : null,
                            ),
                            alignment: Alignment.centerLeft,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.linear,
                            child: SingleChildScrollView(
                              child: Row(
                                children: [
                                  stepPick == 0
                                      ? SizedBox(
                                          width: 30,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                height: 15,
                                                width: 15,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.brown,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : SizedBox(
                                          width: 50,
                                          height: 50,
                                          child: Column(
                                            children: [
                                              const SizedBox(height: 20),
                                              const SizedBox(height: 2),
                                              Container(
                                                height: 10,
                                                width: 10,
                                                decoration: const BoxDecoration(
                                                  color: Colors.grey,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              Container(
                                                height: 18,
                                                width: 1,
                                                color: Colors.grey,
                                              )
                                            ],
                                          ),
                                        ),
                                  Text(
                                    _lv1PickName.isNotEmpty
                                        ? _lv1PickName
                                        : 'Chọn Tỉnh/Thành phố',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: stepPick == 0
                                          ? Colors.brown
                                          : Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (_lv1PickId.isNotEmpty) {
                              setState(() {
                                stepPick = 1;
                                pickLevel = 1;
                                _labelSelect = "Quận/Huyện";
                                // Khi chọn lại quận/huyện, xóa phường/xã
                                _lv3PickId = '';
                                _lv3PickName = '';
                                final List<dvhcvn.Level2> _lv2 =
                                    dvhcvn.findLevel1ById(_lv1PickId)!.children;
                                vietnamProvinces.clear();
                                for (int i = 0; i < _lv2.length; i++) {
                                  vietnamProvinces.add({
                                    "id": _lv2[i].id,
                                    "name": _lv2[i].name,
                                  });
                                }
                                _filterLocations();
                              });
                            }
                          },
                          child: AnimatedContainer(
                            height: 50,
                            constraints: BoxConstraints(
                              maxHeight: _lv1PickId.isNotEmpty ? 50 : 0,
                            ),
                            margin: stepPick == 1
                                ? const EdgeInsets.symmetric(horizontal: 10)
                                : null,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: stepPick == 1
                                  ? Border.all(width: 1, color: Colors.grey)
                                  : null,
                              borderRadius: stepPick == 1
                                  ? BorderRadius.circular(10)
                                  : null,
                            ),
                            alignment: Alignment.centerLeft,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.linear,
                            child: SingleChildScrollView(
                              child: Row(
                                children: [
                                  stepPick == 1
                                      ? SizedBox(
                                          width: 30,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                height: 15,
                                                width: 15,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.brown,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : SizedBox(
                                          width: 50,
                                          height: 50,
                                          child: Column(
                                            children: [
                                              Container(
                                                width: 1,
                                                height: 20,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(height: 2),
                                              Container(
                                                height: 10,
                                                width: 10,
                                                decoration: const BoxDecoration(
                                                  color: Colors.grey,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              Container(
                                                height: 18,
                                                width: 1,
                                                color: Colors.grey,
                                              )
                                            ],
                                          ),
                                        ),
                                  Text(
                                    _lv2PickId.isNotEmpty
                                        ? _lv2PickName
                                        : 'Chọn Quận/Huyện',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: stepPick == 1
                                          ? Colors.brown
                                          : Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (_lv2PickId.isNotEmpty) {
                              setState(() {
                                stepPick = 2;
                                pickLevel = 2;
                                _labelSelect = "Phường/Xã";
                                final List<dvhcvn.Level3> _lv3 = dvhcvn
                                    .findLevel1ById(_lv1PickId)!
                                    .findLevel2ById(_lv2PickId)!
                                    .children;
                                vietnamProvinces.clear();
                                for (int i = 0; i < _lv3.length; i++) {
                                  vietnamProvinces.add({
                                    "id": _lv3[i].id,
                                    "name": _lv3[i].name,
                                  });
                                }
                                _filterLocations();
                              });
                            }
                          },
                          child: AnimatedContainer(
                            height: 50,
                            constraints: BoxConstraints(
                              maxHeight: _lv2PickId.isNotEmpty ? 50 : 0,
                            ),
                            margin: stepPick == 2
                                ? const EdgeInsets.symmetric(horizontal: 10)
                                : null,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: stepPick == 2
                                  ? Border.all(width: 1, color: Colors.grey)
                                  : null,
                              borderRadius: stepPick == 2
                                  ? BorderRadius.circular(10)
                                  : null,
                            ),
                            alignment: Alignment.centerLeft,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.linear,
                            child: SingleChildScrollView(
                              child: Row(
                                children: [
                                  stepPick == 2
                                      ? SizedBox(
                                          width: 30,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                height: 15,
                                                width: 15,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.brown,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : SizedBox(
                                          width: 50,
                                          height: 50,
                                          child: Column(
                                            children: [
                                              Container(
                                                width: 1,
                                                height: 20,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(height: 2),
                                              Container(
                                                height: 10,
                                                width: 10,
                                                decoration: const BoxDecoration(
                                                  color: Colors.grey,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(height: 18),
                                            ],
                                          ),
                                        ),
                                  Text(
                                    _lv3PickId.isNotEmpty
                                        ? _lv3PickName
                                        : 'Chọn Phường/Xã',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: stepPick == 2
                                          ? Colors.brown
                                          : Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    margin: const EdgeInsets.only(top: 10, bottom: 10),
                    alignment: Alignment.centerLeft,
                    color: Colors.grey[200],
                    height: 20,
                    child: Text(
                      _labelSelect,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: filteredProvinces.length,
                    itemBuilder: (context, index) {
                      String lastLabel = index > 0
                          ? filteredProvinces[index - 1]["name"]![0]
                              .toUpperCase()
                          : '';
                      String label =
                          filteredProvinces[index]["name"]![0].toUpperCase();
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (pickLevel == 0) {
                              _lv1PickId = filteredProvinces[index]["id"]!;
                              _lv1PickName = filteredProvinces[index]["name"]!;
                              // Khi chọn tỉnh mới, xóa quận/huyện và phường/xã
                              _lv2PickId = '';
                              _lv2PickName = '';
                              _lv3PickId = '';
                              _lv3PickName = '';
                              final List<dvhcvn.Level2> _lv2 =
                                  dvhcvn.findLevel1ById(_lv1PickId)!.children;
                              vietnamProvinces.clear();
                              for (int i = 0; i < _lv2.length; i++) {
                                vietnamProvinces.add({
                                  "id": _lv2[i].id,
                                  "name": _lv2[i].name,
                                });
                              }
                              _labelSelect = "Quận/Huyện";
                              pickLevel = 1;
                              stepPick = 1;
                            } else if (pickLevel == 1) {
                              _lv2PickId = filteredProvinces[index]["id"]!;
                              _lv2PickName = filteredProvinces[index]["name"]!;
                              // Khi chọn quận/huyện mới, xóa phường/xã
                              _lv3PickId = '';
                              _lv3PickName = '';
                              final List<dvhcvn.Level3> _lv3 = dvhcvn
                                  .findLevel1ById(_lv1PickId)!
                                  .findLevel2ById(_lv2PickId)!
                                  .children;
                              vietnamProvinces.clear();
                              for (int i = 0; i < _lv3.length; i++) {
                                vietnamProvinces.add({
                                  "id": _lv3[i].id,
                                  "name": _lv3[i].name,
                                });
                              }
                              _labelSelect = "Phường/Xã";
                              pickLevel = 2;
                              stepPick = 2;
                            } else if (pickLevel == 2) {
                              _lv3PickId = filteredProvinces[index]["id"]!;
                              _lv3PickName = filteredProvinces[index]["name"]!;
                              _completeSelection(); // Hoàn tất chọn phường/xã
                            }
                            _searchController.clear();
                            _filterLocations();
                          });
                        },
                        child: Container(
                          alignment: Alignment.centerLeft,
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  width: 1, color: Colors.grey[200]!),
                              top: BorderSide(
                                  width: 1, color: Colors.grey[200]!),
                            ),
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Container(
                                alignment: Alignment.center,
                                width: 50,
                                child: (lastLabel != label)
                                    ? Text(
                                        label,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w300,
                                        ),
                                      )
                                    : null,
                              ),
                              Text(
                                filteredProvinces[index]["name"]!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: [
                                    _lv1PickId,
                                    _lv2PickId,
                                    _lv3PickId
                                  ].contains(filteredProvinces[index]["id"])
                                      ? Colors.brown
                                      : Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              height: 80,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              padding: const EdgeInsets.only(
                  top: 30, left: 10, right: 10, bottom: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.brown,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        border: Border.all(width: 0.1, color: Colors.grey),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Icon(
                              Icons.search,
                              size: 24,
                              color: Colors.grey,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              cursorHeight: 20,
                              textAlignVertical: TextAlignVertical.center,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(bottom: 11),
                                border: InputBorder.none,
                                hintText: 'Tìm kiếm Quận/Huyện, Phường/Xã',
                                hintMaxLines: 1,
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
