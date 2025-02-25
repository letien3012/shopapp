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
  // Map<String, Map<String, List<String>>> vietnamProvinces = {};
  int pickLevel = 0;
  int stepPick = 0;
  final List<dvhcvn.Level1> provices = dvhcvn.level1s;
  String _lv1PickId = '';
  String _lv2PickId = '';
  String _lv3PickId = '';
  String _lv1PickName = '';
  String _lv2PickName = '';
  String _lv3PickName = '';

  Map<String, Map<String, List<String>>> data = {};
  List<Map<String, String>> vietnamProvinces = [];
  String _labelSelect = 'Tỉnh/Thành phố';
  @override
  void initState() {
    for (int i = 0; i < provices.length; i++) {
      vietnamProvinces.add({
        "id": provices[i].id,
        "name": provices[i].name.replaceAll(RegExp(r'^(Tỉnh |Thành phố )'), ""),
      });
    }
    vietnamProvinces.sort((a, b) => a["name"]!.compareTo(b["name"]!));

    super.initState();
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
                          const SizedBox(
                            width: 5,
                          ),
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
                        //Chọn Tỉnh/Thành phố
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              stepPick = 0;
                              pickLevel = 0;
                              _labelSelect = "Tỉnh/Thành phố";
                              for (int i = 0; i < provices.length; i++) {
                                vietnamProvinces.add({
                                  "id": provices[i].id,
                                  "name": provices[i].name.replaceAll(
                                      RegExp(r'^(Tỉnh |Thành phố )'), ""),
                                });
                              }
                              vietnamProvinces.sort(
                                  (a, b) => a["name"]!.compareTo(b["name"]!));
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
                                              const SizedBox(
                                                height: 20,
                                              ),
                                              const SizedBox(
                                                height: 2,
                                              ),
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
                                    _lv1PickName,
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
                        //Chọn Quận/Huyện
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              stepPick = 1;
                              pickLevel = 1;

                              _labelSelect = "Quận/ Huyện";

                              final List<dvhcvn.Level2> _lv2 =
                                  dvhcvn.findLevel1ById(_lv1PickId)!.children;
                              vietnamProvinces.clear();
                              for (int i = 0; i < _lv2.length; i++) {
                                vietnamProvinces.add({
                                  "id": _lv2[i].id,
                                  "name": _lv2[i].name,
                                });
                              }
                            });
                          },
                          child: AnimatedContainer(
                            height: 50,
                            constraints: BoxConstraints(
                              maxHeight: _lv1PickId.isNotEmpty ? 50 : 0,
                            ),
                            margin: stepPick == 1
                                ? EdgeInsets.symmetric(horizontal: 10)
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
                            duration: Duration(milliseconds: 300),
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
                                                decoration: BoxDecoration(
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
                                              const SizedBox(
                                                height: 2,
                                              ),
                                              Container(
                                                height: 10,
                                                width: 10,
                                                decoration: BoxDecoration(
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
                        //Chọn Phường/Xã
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              stepPick = 2;
                              pickLevel = 2;
                              _labelSelect = "Phường/ Xã";
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
                            });
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
                            duration: Duration(milliseconds: 300),
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
                                              const SizedBox(
                                                height: 2,
                                              ),
                                              Container(
                                                height: 10,
                                                width: 10,
                                                decoration: const BoxDecoration(
                                                  color: Colors.grey,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 18,
                                              )
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
                  // Địa chỉ

                  ListView.builder(
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: vietnamProvinces.length,
                      itemBuilder: (context, index) {
                        // final List<dvhcvn.Level2> ab = dvhcvn
                        //     .findLevel1ById(vietnamProvinces[0]["id"]!)!
                        //     .children;
                        // print(ab[0].name);
                        String lastLabel;
                        index > 0
                            ? lastLabel = vietnamProvinces[index - 1]
                                    ["name"]![0]
                                .toUpperCase()
                            : lastLabel = '';
                        String label =
                            vietnamProvinces[index]["name"]![0].toUpperCase();
                        return GestureDetector(
                          onTap: () {
                            setState(
                              () {
                                pickLevel++;
                                stepPick++;
                                if (pickLevel == 1) {
                                  _labelSelect = "Quận/ Huyện";
                                  _lv1PickId = vietnamProvinces[index]["id"]!;
                                  _lv1PickName =
                                      vietnamProvinces[index]["name"]!;
                                  final List<dvhcvn.Level2> _lv2 = dvhcvn
                                      .findLevel1ById(
                                          vietnamProvinces[index]["id"]!)!
                                      .children;
                                  vietnamProvinces.clear();
                                  for (int i = 0; i < _lv2.length; i++) {
                                    vietnamProvinces.add({
                                      "id": _lv2[i].id,
                                      "name": _lv2[i].name,
                                    });
                                  }
                                }
                                if (pickLevel == 2) {
                                  _labelSelect = "Phường/ Xã";
                                  _lv2PickId = vietnamProvinces[index]["id"]!;
                                  _lv2PickName =
                                      vietnamProvinces[index]["name"]!;
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
                                }
                                if (pickLevel == 3) {
                                  _lv3PickId = vietnamProvinces[index]["id"]!;
                                  _lv3PickName =
                                      vietnamProvinces[index]["name"]!;
                                }
                              },
                            );
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
                                  vietnamProvinces[index]["name"]!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: [
                                      _lv1PickId,
                                      _lv2PickId,
                                      _lv3PickId
                                    ].contains(vietnamProvinces[index]["id"])
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
                      }),
                ],
              ),
            ),
          ),
          // Appbar
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
                  //Icon trở về
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
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: Container(
                      // alignment: Alignment.centerLeft,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        border: Border.all(
                          width: 0.1,
                          color: Colors.grey,
                        ),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Icon(
                              Icons.search,
                              size: 24,
                              color: Colors.grey,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              cursorHeight: 20,
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
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
                  const SizedBox(
                    width: 5,
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
