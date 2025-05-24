import 'package:flutter/material.dart';
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
                      order['order_status'] == 'Out for Delivery',
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
      fetchOrders(); // تحديث القائمة بعد تغيير الحالة
    } else {
      print('Failed to update status');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDF5FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Image.asset('assets/images/homedel.png', height: 40),
            const SizedBox(width: 10),
            const Text(
              'Delivery Orders',
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              //
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

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order ID: ${order['payment_id']}'),
                  Text('User: ${order['user_name']}'),
                  Text('Amount: ${order['amount']}'),
                  Text('Payment Method: ${order['payment_method']}'),
                  Text('Address: ${order['delivery_option']}'),
                  Text('Status: ${order['order_status']}'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      String newStatus;

                      if (order['order_status'] ==
                          'Your Order is Being Prepared') {
                        newStatus = 'Out for Delivery';
                      } else if (order['order_status'] == 'Out for Delivery') {
                        newStatus = 'Delivered';
                      } else {
                        return; // ما تعمل شيء لو الحالة وصلت Delivered
                      }

                      updateStatus(order['payment_id'], newStatus);
                    },
                    child: Text(
                      order['order_status'] == 'Your Order is Being Prepared'
                          ? 'Mark as Out for Delivery'
                          : order['order_status'] == 'Out for Delivery'
                          ? 'Mark as Delivered'
                          : 'Delivered',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
