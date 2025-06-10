import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import 'package:graduation/screens/HomePage.dart';
import 'package:graduation/screens/MainNavigation.dart';
import 'package:graduation/screens/cart_page.dart';
import 'package:graduation/screens/ipadress.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:another_flushbar/flushbar.dart';

class PaymentPage extends StatefulWidget {
  final double amount;
  final double deliveryCost;
  final List<dynamic> selectedProducts; // Add this parameter

  const PaymentPage({
    Key? key,
    required this.amount,
    this.deliveryCost = 20.0,
    required this.selectedProducts, // Add this parameter
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _selectedPaymentMethod = 'Cash';
  bool _isLoading = false;
  int? _userId;
  Map<String, dynamic>? paymentIntent;
  bool isPay = false;

  // Make sure you fill this list before payment
  List<int> selectedListToPay = [];

  // Move productCart to a getter so it uses the passed selectedProducts
  List<Map<String, dynamic>> get productCart {
    return widget.selectedProducts.map((product) {
      return {
        "product_id": product['product_id'],
        "quantity": product['quantity'],
        "cart_id": product['cart_id'],
      };
    }).toList();
  }

  Function()? onPaymentSuccess;

  // Update quantities for products after payment
  Future<void> updateQuantityOfProduct(List<int> cart_ids, int user_id) async {
    print('Updating quantities for cart IDs: $cart_ids');
    final response = await http.put(
      Uri.parse('http://$ip:3000/updateTheQuantityToPayment'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<dynamic, dynamic>{
        'cart_ids': cart_ids,
        'user_id': user_id,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Quantity number updated successfully');
    } else {
      print('Failed to update quantity');
    }
  }

  Future<void> makePayment(BuildContext context, double amount) async {
    print(amount);
    String merchantCountryCode = "IL";
    String currencyCode = "ILS";

    print(merchantCountryCode);
    print(currencyCode);
    try {
      paymentIntent = await createPaymentIntent(amount, context, currencyCode);
      var gPay = PaymentSheetGooglePay(
        merchantCountryCode: merchantCountryCode,
        currencyCode: currencyCode,
        testEnv: true,
      );
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent!["client_secret"],
          style: ThemeMode.dark,
          merchantDisplayName: "Sabir",
          googlePay: gPay,
        ),
      );
      await displayPaymentIntent(context, amount);
    } catch (e) {
      print('Error in makePayment: $e');
    }
  }

  Future<void> displayPaymentIntent(BuildContext context, double amount) async {
    try {
      await Stripe.instance.presentPaymentSheet();

      isPay = true;
      print('Payment Done');

      // Update quantities after successful payment
      if (_userId != null && selectedListToPay.isNotEmpty) {
        await updateQuantityOfProduct(selectedListToPay, _userId!);
      }

      Flushbar(
        message: "Payment Done",
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
      ).show(context);

      await Future.delayed(Duration(seconds: 3));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CartPage()),
      );

      if (onPaymentSuccess != null) {
        onPaymentSuccess!();
      }
    } catch (e) {
      Flushbar(
        message: "Payment Failed",
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red,
        margin: EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
      ).show(context);
      print('Failed Pay: $e');
    }
  }

  Future<Map<String, dynamic>?> createPaymentIntent(
    double amount,
    BuildContext context,
    String currencyCode,
  ) async {
    try {
      print(amount);
      print(currencyCode);
      final secretKey =
          "sk_test_51PDnd7BlhJuWT9ZMI7PKGzLG8tKIJ93YvXrYO1tbE8gXXzbNnknpzlVM5Fnkav4SlwMh7FYatLdAqNK5APr2b19K00Pm3FFumg";
      int amountInCents = (amount * 100).toInt();
      Map<String, dynamic> body = {
        "amount": amountInCents.toString(),
        "currency": currencyCode,
      };
      http.Response response = await http.post(
        Uri.parse("https://api.stripe.com/v1/payment_intents"),
        body: body,
        headers: {
          "Authorization": "Bearer $secretKey",
          "Content-Type": "application/x-www-form-urlencoded",
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        var json = jsonDecode(response.body);
        print(json);
        return json;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "CHECKOUT Failed\nSelect Item to CHECKOUT",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
        print('error in calling payment intent');
        return null;
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserId();

    // Debug: Print the selected products to verify they're passed correctly
    print(
      'Selected products in PaymentPage: ${widget.selectedProducts.length}',
    );
    print('Product cart: $productCart');
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('userId');
    });
  }

  Future<void> _submitPayment() async {
    selectedListToPay =
        widget.selectedProducts
            .map<int>((product) => product['cart_id'] as int)
            .toList();

    if (_userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('User not logged in')));
      return;
    }

    // Check if there are products to pay for
    if (productCart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No products selected for payment')),
      );
      return;
    }

    if (_selectedPaymentMethod == 'Visa') {
      onPaymentSuccess = () async {
        await _sendPaymentToBackend('Visa');

        // Update quantities after successful Visa payment
        if (_userId != null && selectedListToPay.isNotEmpty) {
          await updateQuantityOfProduct(selectedListToPay, _userId!);
        }
      };
      await makePayment(context, widget.amount + widget.deliveryCost);
    } else {
      // Cash payment
      await _sendPaymentToBackend('Cash');

      if (_userId != null && selectedListToPay.isNotEmpty) {
        await updateQuantityOfProduct(selectedListToPay, _userId!);
      }
    }
  }

  Future<void> _sendPaymentToBackend(String method) async {
    setState(() {
      _isLoading = true;
    });

    // Debug prints
    print('Product Cart: $productCart');
    print('Selected products: ${widget.selectedProducts.length}');
    print('User ID: $_userId');

    final url = Uri.parse('http://$ip:3000/api/payment');
    final body = jsonEncode({
      'user_id': _userId,
      'amount': widget.amount,
      'payment_method': method,
      'delivery_cost': widget.deliveryCost,
      'items': productCart,
    });

    print('Sending to backend: $body');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Payment Successful')),
        );

        // Navigate back to cart or home after successful payment
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed. Please try again.')),
        );
      }
    } catch (e) {
      print('Error in payment: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error occurred: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.amount + widget.deliveryCost;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Colors.deepPurple,
      ),
      body:
          _userId == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Show selected products count
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Selected Items: ${widget.selectedProducts.length}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Icon(Icons.shopping_cart, color: Colors.deepPurple),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Items Total",
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  "${widget.amount.toStringAsFixed(2)} \$",
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Delivery",
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  "${widget.deliveryCost.toStringAsFixed(2)} \$",
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const Divider(thickness: 1.2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Total",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "${total.toStringAsFixed(2)} \$",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade100,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text(
                              'Select Payment Method',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          RadioListTile<String>(
                            title: const Text('Cash'),
                            value: 'Cash',
                            groupValue: _selectedPaymentMethod,
                            onChanged: (value) {
                              setState(() {
                                _selectedPaymentMethod = value!;
                              });
                            },
                          ),
                          RadioListTile<String>(
                            title: const Text('Visa'),
                            value: 'Visa',
                            groupValue: _selectedPaymentMethod,
                            onChanged: (value) {
                              setState(() {
                                _selectedPaymentMethod = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                          _isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text(
                                "Pay Now",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ],
                ),
              ),
    );
  }
}
