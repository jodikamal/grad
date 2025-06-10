import 'package:flutter/material.dart';
import 'package:graduation/screens/DeliveryNotifications.dart';
import 'package:graduation/screens/ipadress.dart';
import 'package:graduation/screens/sign_in_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DeliveryOrdersPage extends StatefulWidget {
  const DeliveryOrdersPage({Key? key}) : super(key: key);

  @override
  State<DeliveryOrdersPage> createState() => _DeliveryOrdersPageState();
}

class _DeliveryOrdersPageState extends State<DeliveryOrdersPage> {
  List<dynamic> orders = [];

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final response = await http.get(
      Uri.parse('http://$ip:3000/delivery/orders'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        orders =
            data
                .where(
                  (order) =>
                      order['order_status'] == 'Your Order is Being Prepared' ||
                      order['order_status'] == 'Out for Delivery' ||
                      order['order_status'] == 'Delivered',
                )
                .toList();
      });
    } else {
      print('Failed to load orders');
    }
  }

  Future<void> updateStatus(int paymentId, String newStatus) async {
    final response = await http.post(
      Uri.parse('http://$ip:3000/delivery/update-status'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'payment_id': paymentId, 'new_status': newStatus}),
    );

    if (response.statusCode == 200) {
      fetchOrders();
    } else {
      print('Failed to update status');
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Your Order is Being Prepared':
        return Colors.orange;
      case 'Out for Delivery':
        return Colors.blue;
      case 'Delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case 'Your Order is Being Prepared':
        return Icons.kitchen;
      case 'Out for Delivery':
        return Icons.delivery_dining;
      case 'Delivered':
        return Icons.check_circle;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Image.asset('assets/images/homedel.png', height: 40),
            const SizedBox(width: 10),
            const Text(
              'Delivery Orders',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DeliveryNotificationsPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('userId');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SignInPage()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchOrders,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            final statusColor = getStatusColor(order['order_status']);
            final statusIcon = getStatusIcon(order['order_status']);

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.symmetric(vertical: 10),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: statusColor.withOpacity(0.1),
                        child: Icon(statusIcon, color: statusColor),
                      ),
                      title: Text(
                        'Order #${order['payment_id']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        order['user_name'],
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Amount:',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text('${order['amount']} \$'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Payment:',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(order['payment_method']),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Address:',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(order['delivery_option']),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 18, color: statusColor),
                          const SizedBox(width: 6),
                          Text(
                            order['order_status'],
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (order['order_status'] != 'Delivered')
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: statusColor,
                          minimumSize: const Size(double.infinity, 45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          String newStatus;
                          if (order['order_status'] ==
                              'Your Order is Being Prepared') {
                            newStatus = 'Out for Delivery';
                          } else if (order['order_status'] ==
                              'Out for Delivery') {
                            newStatus = 'Delivered';
                          } else {
                            return;
                          }

                          final response = await http.post(
                            Uri.parse('http://$ip:3000/delivery/update-status'),
                            headers: {'Content-Type': 'application/json'},
                            body: json.encode({
                              'payment_id': order['payment_id'],
                              'new_status': newStatus,
                            }),
                          );

                          if (response.statusCode == 200) {
                            setState(() {
                              if (newStatus == 'Delivered') {
                                orders.removeAt(index);
                              } else {
                                orders[index]['order_status'] = newStatus;
                              }
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('فشل في تحديث حالة الطلب'),
                              ),
                            );
                          }
                        },
                        child: Text(
                          order['order_status'] ==
                                  'Your Order is Being Prepared'
                              ? 'Mark as Out for Delivery'
                              : 'Mark as Delivered',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
