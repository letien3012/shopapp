import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:luanvan/blocs/auth/auth_bloc.dart';
import 'package:luanvan/blocs/auth/auth_state.dart';
import 'package:luanvan/blocs/cart/cart_bloc.dart';
import 'package:luanvan/blocs/cart/cart_event.dart';
import 'package:luanvan/models/product.dart';

class AddToCartBottomSheet extends StatefulWidget {
  final Product product;
  final BuildContext parentContext;

  const AddToCartBottomSheet({
    Key? key,
    required this.product,
    required this.parentContext,
  }) : super(key: key);

  @override
  _AddToCartBottomSheetState createState() => _AddToCartBottomSheetState();
}

class _AddToCartBottomSheetState extends State<AddToCartBottomSheet> {
  int _quantityAddToCart = 1;
  int selectedIndexVariant1 = -1;
  int selectedIndexVariant2 = -1;
  late TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: '1');
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  String formatPrice(double price) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return formatter.format(price.toInt());
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey, width: 0.6),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                      widget.product.imageUrl[0],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 110,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              (widget.product.variants.isNotEmpty)
                                  ? 'đ${formatPrice(widget.product.getMinOptionPrice())} - '
                                  : 'đ${formatPrice(widget.product.price!)}',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 151, 14, 4)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              (widget.product.variants[0].label.isNotEmpty)
                                  ? 'đ${formatPrice(widget.product.getMaxOptionPrice())}'
                                  : '',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 151, 14, 4)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text('Kho: ${widget.product.getTotalOptionStock()}',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  height: 0.5, width: double.infinity, color: Colors.grey[300]),
              Container(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.product.variants[0].label,
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(
                          widget.product.variants[0].options.length, (index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndexVariant1 = index;
                            });
                          },
                          child: IntrinsicWidth(
                            child: Container(
                              constraints: const BoxConstraints(
                                  maxHeight: 45, minWidth: 60),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.grey[200],
                                border: index == selectedIndexVariant1
                                    ? Border.all(
                                        width: 1, color: Colors.brown[700]!)
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (widget.product.hasVariantImages)
                                    Image.network(
                                      widget.product.variants[0].options[index]
                                          .imageUrl!,
                                      width: 35,
                                      height: 35,
                                      fit: BoxFit.fitHeight,
                                    ),
                                  if (widget.product.hasVariantImages)
                                    SizedBox(
                                      width: 10,
                                    ),
                                  Text(
                                    widget.product.variants[0].options[index]
                                        .name,
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: index == selectedIndexVariant1
                                            ? Colors.brown[500]
                                            : Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.product.variants.length == 2)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    height: 0.5,
                    width: double.infinity,
                    color: Colors.grey[400]),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.variants[1].label,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(
                            widget.product.variants[1].options.length, (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIndexVariant2 = index;
                              });
                            },
                            child: IntrinsicWidth(
                              child: Container(
                                constraints: const BoxConstraints(
                                    maxHeight: 45, minWidth: 60),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.grey[200],
                                  border: index == selectedIndexVariant2
                                      ? Border.all(
                                          width: 1, color: Colors.brown[700]!)
                                      : null,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      widget.product.variants[1].options[index]
                                          .name,
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: index == selectedIndexVariant2
                                              ? Colors.brown[500]
                                              : Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          Column(
            children: [
              Container(
                  height: 0.5, width: double.infinity, color: Colors.grey[400]),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Số lượng",
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    Container(
                      height: 30,
                      width: 100,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (_quantityAddToCart > 1) {
                                  setState(() {
                                    _quantityAddToCart--;
                                    _quantityController.text =
                                        _quantityAddToCart.toString();
                                  });
                                }
                              },
                              child: Container(
                                height: double.infinity,
                                decoration: const BoxDecoration(
                                    border: Border(
                                        right: BorderSide(
                                            color: Colors.grey, width: 1))),
                                child: Icon(FontAwesomeIcons.minus,
                                    color: Colors.grey[700], size: 13),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(
                              alignment: Alignment.center,
                              height: 20,
                              child: TextFormField(
                                controller: _quantityController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide.none),
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (value) {
                                  int? quantity = int.tryParse(value);
                                  if (quantity != null) {
                                    if (quantity <= 1) {
                                      setState(() {
                                        _quantityAddToCart = quantity;
                                        _quantityController.text =
                                            _quantityAddToCart.toString();
                                      });
                                    } else {
                                      setState(() {
                                        _quantityAddToCart = quantity ~/ 10;
                                        _quantityController.text =
                                            _quantityAddToCart.toString();
                                      });
                                    }
                                  } else {
                                    setState(() {
                                      _quantityController.text =
                                          _quantityAddToCart.toString();
                                    });
                                  }
                                },
                                keyboardType:
                                    const TextInputType.numberWithOptions(),
                                textAlign: TextAlign.center,
                                textAlignVertical: TextAlignVertical.center,
                                cursorWidth: 1,
                                cursorHeight: 13,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (_quantityAddToCart < 1) {
                                  setState(() {
                                    _quantityAddToCart++;
                                    _quantityController.text =
                                        _quantityAddToCart.toString();
                                  });
                                }
                              },
                              child: Container(
                                height: double.infinity,
                                decoration: const BoxDecoration(
                                    border: Border(
                                        left: BorderSide(
                                            color: Colors.grey, width: 1))),
                                child: Icon(FontAwesomeIcons.plus,
                                    color: Colors.grey[700], size: 13),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(height: 5, width: double.infinity, color: Colors.grey[200]),
          Container(
            height: 50,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10)),
            alignment: Alignment.center,
            margin: const EdgeInsets.all(10),
            child: GestureDetector(
              onTap: () {
                // Thêm logic thêm vào giỏ hàng tại đây nếu cần
                if (widget.parentContext.read<AuthBloc>().state
                    is AuthAuthenticated) {
                  String userId = (widget.parentContext.read<AuthBloc>().state
                          as AuthAuthenticated)
                      .user
                      .uid;
                  widget.parentContext.read<CartBloc>().add(AddCartEvent(
                        widget.product.id,
                        _quantityAddToCart,
                        userId,
                        widget.product.shopId,
                        selectedIndexVariant1,
                        0,
                      ));
                }
                Navigator.pop(context);
              },
              child: const Text("Thêm vào giỏ hàng",
                  style: TextStyle(fontSize: 16, color: Colors.black38)),
            ),
          ),
        ],
      ),
    );
  }
}
