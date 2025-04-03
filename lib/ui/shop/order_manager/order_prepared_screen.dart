import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luanvan/blocs/order/order_bloc.dart';
import 'package:luanvan/blocs/order/order_event.dart';
import 'package:luanvan/blocs/order/order_state.dart';
import 'package:luanvan/models/order.dart';
import 'package:luanvan/ui/shop/order_manager/packing_slip_screen.dart';

class OrderPreparedScreen extends StatefulWidget {
  static const routeName = 'order-prepared';
  const OrderPreparedScreen({super.key});

  @override
  State<OrderPreparedScreen> createState() => _OrderPreparedScreenState();
}

class _OrderPreparedScreenState extends State<OrderPreparedScreen> {
  String orderId = '';
  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      orderId = ModalRoute.of(context)?.settings.arguments as String;
      context.read<OrderBloc>().add(FetchOrderById(orderId));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thông tin gửi hàng',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        elevation: 0,
      ),
      body: BlocBuilder<OrderBloc, OrderState>(builder: (context, state) {
        if (state is OrderDetailLoaded) {
          final order = state.order;
          return Container(
            color: Colors.grey[200],
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        color: Colors.white,
                        child: Text(
                          'Giao hàng ${order?.shipMethod.name} Mã vận đơn',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        color: Colors.white,
                        child: Center(
                          child: Column(
                            children: [
                              ClipOval(
                                child: Image.asset(
                                  order?.shipMethod.name == 'Tiết kiệm'
                                      ? 'assets/images/GHTK_Logo.webp'
                                      : 'assets/images/ghn_logo.png', // Make sure to add this image
                                  height: 60,
                                  width: 60,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                order?.shippingCode ?? '',
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.deepOrange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 80,
                        color: Colors.white,
                      ),
                      Container(
                        height: 10,
                        color: Colors.grey[200],
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Địa chỉ lấy hàng',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${order?.pickUpAdress?.receiverName}\n${order?.pickUpAdress?.receiverPhone}\n${order?.pickUpAdress?.addressLine}\n${order?.pickUpAdress?.ward}\n${order?.pickUpAdress?.district}\n${order?.pickUpAdress?.city}',
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                PackingSlipScreen.routeName,
                                arguments: order,
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(
                                left: 16,
                              ),
                              height: 50,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.brown),
                              ),
                              child: const Text('In phiếu giao'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              margin: const EdgeInsets.only(
                                right: 16,
                              ),
                              height: 50,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.brown,
                              ),
                              child: const Text(
                                'ĐỒNG Ý',
                                style: TextStyle(color: Colors.white),
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
        return const Center(
          child: CircularProgressIndicator(),
        );
      }),
    );
  }
}
