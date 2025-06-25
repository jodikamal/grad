import 'package:flutter/material.dart';
import 'package:graduation/screens/ipadress.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({Key? key}) : super(key: key);

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  List<dynamic> orders = [];

  @override
  void initState() {
    super.initState();
    fetchUserOrders();
  }

  Future<void> fetchUserOrders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');

    final response = await http.get(
      Uri.parse('http://$ip:3000/user/orders/$userId'),
    );

    if (response.statusCode == 200) {
      setState(() {
        orders = json.decode(response.body);
      });
    } else {
      print('Failed to load user orders');
    }
  }

  Future<void> cancelOrder(int paymentId) async {
    final response = await http.post(
      Uri.parse('http://$ip:3000/user/cancel_order'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'payment_id': paymentId}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order #$paymentId cancelled successfully'),
          backgroundColor: Colors.red,
        ),
      );
      await fetchUserOrders();
    } else {
      print('Failed to cancel order: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cancel the order'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  bool canCancel(String status) {
    return status == "Your Order Sent Successfully!" ||
        status == "Your Order is Being Prepared";
  }

  Color getStatusColor(String status) {
    if (status.toLowerCase() == 'delivered') {
      return Colors.green[300]!;
    } else if (status.toLowerCase() == 'cancelled') {
      return Colors.red[300]!;
    } else {
      return Colors.yellow[300]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5FF),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 212, 64, 218),
        elevation: 0,
        foregroundColor: Colors.black,
        title: Row(
          children: [
            Icon(Icons.shopping_bag, color: Colors.white),
            const SizedBox(width: 8),
            const Text(
              'My Orders',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body:
          orders.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: orders.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final String status = order['order_status'].toString();
                  final bool isCancellable = canCancel(status);

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Order ID: ${order['payment_id']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: getStatusColor(status),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  status,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Amount: \$${order['amount']}'),
                          Text('Payment: ${order['payment_method']}'),
                          Text('Delivery: ${order['delivery_option']}'),
                          const SizedBox(height: 10),

                          /// زر Show Items
                          ElevatedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder:
                                    (_) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      title: const Text("Ordered Items"),
                                      content: SizedBox(
                                        width: double.maxFinite,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount:
                                              order['items']?.length ?? 0,
                                          itemBuilder: (context, i) {
                                            final item = order['items'][i];
                                            return ListTile(
                                              leading: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.network(
                                                  item['image'],
                                                  width: 50,
                                                  height: 50,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              title: Text(item['name']),
                                              subtitle: Text(
                                                'Quantity: ${item['quantity']}',
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(context),
                                          child: const Text("Close"),
                                        ),
                                      ],
                                    ),
                              );
                            },
                            icon: const Icon(Icons.remove_red_eye),
                            label: const Text("Show Items"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                            ),
                          ),

                          /// زر إلغاء الطلب
                          if (isCancellable) ...[
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        title: const Text("Cancel Order"),
                                        content: const Text(
                                          "Are you sure you want to cancel this order?",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                            child: const Text("No"),
                                          ),
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                            child: const Text("Yes"),
                                          ),
                                        ],
                                      ),
                                );

                                if (confirm == true) {
                                  cancelOrder(order['payment_id']);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text(
                                'Cancel Order',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
