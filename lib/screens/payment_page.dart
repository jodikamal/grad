import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:graduation/screens/ipadress.dart';
import 'package:http/http.dart' as http;
import '../models/payment.dart';
import 'ipadress.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  List<Payment> payments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPayments();
  }

  Future<void> fetchPayments() async {
    final url = Uri.parse('http://$ip:3000/admin/orders');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List decoded = jsonDecode(response.body);
        setState(() {
          payments = decoded.map((e) => Payment.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        print('Failed to fetch payments');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payments')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: payments.length,
                itemBuilder: (context, index) {
                  final payment = payments[index];
                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      title: Text('💵 \$${payment.amount}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('🧾 Method: ${payment.paymentMethod}'),
                          Text('📦 Delivery: ${payment.deliveryOption}'),
                          Text('📅 Date: ${payment.paymentDate}'),
                          if (payment.userName != null)
                            Text('👤 User: ${payment.userName}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
