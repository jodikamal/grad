import 'package:flutter/material.dart';
import 'package:graduation/screens/payment_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ipadress.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> cartItems = [];

  @override
  void initState() {
    super.initState();
    fetchCartItemsFromServer();
  }

  //here is adding to cart
  Future<void> addItemToCart(int userId, int productId, int quantity) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');
    final String url = 'http://$ip:3000/cart/add';

    var headers = {'Content-Type': 'application/json'};

    var body = jsonEncode({
      'user_id': userId,
      'product_id': productId,
      'quantity': quantity,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Item added to cart');
        await fetchCartItemsFromServer(); // ⬅
      } else {
        print('Failed to add item to cart. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding item to cart: $e');
    }
  }

  //view the cart
  Future<void> fetchCartItemsFromServer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');

    print("***************************************************** $userId");

    final String url = 'http://$ip:3000/cart/$userId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<dynamic> responseData = jsonDecode(response.body);

        setState(() {
          cartItems =
              responseData.map<Map<String, dynamic>>((item) {
                final price = item['price'];
                final quantity = item['quantity'];
                final maxQuantity = item['max_quantity'];
                final imageDesigned = item['image_designed'];

                print(item);
                return {
                  ...item,
                  'price':
                      price == null
                          ? 0.0
                          : (price is String
                              ? double.tryParse(price) ?? 0.0
                              : (price as num).toDouble()),
                  'quantity':
                      quantity == null
                          ? 1
                          : (quantity is String
                              ? int.tryParse(quantity) ?? 1
                              : quantity),
                  'max_quantity':
                      maxQuantity == null
                          ? 10
                          : (maxQuantity is String
                              ? int.tryParse(maxQuantity) ?? 10
                              : maxQuantity),
                };
              }).toList();
        });
      } else {
        print('Failed to fetch cart items. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching cart items: $e');
    }
  }

  //delete the item from the cart
  Future<void> removeItemFromCart(int userId, int productId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');
    final String url = 'http://$ip:3000/cart/remove/$userId';

    var headers = {'Content-Type': 'application/json'};

    var body = jsonEncode({'product_id': productId});

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Item removed from cart');
        await fetchCartItemsFromServer();
      } else {
        print('Failed to remove item. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error removing item from cart: $e');
    }
  }

  Future<void> increaseQuantity(int productId) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      print('❌ User ID not found in SharedPreferences');
      return;
    }

    final url = Uri.parse('http://$ip:3000/cart/increase/$userId');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId, 'product_id': productId}),
      );

      if (response.statusCode == 200) {
        print('✅ Quantity increased successfully');
        await fetchCartItemsFromServer();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sorry! Sold out',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating, //
            duration: Duration(seconds: 3), //
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      print('❌ Error increasing quantity: $e');
    }
  }

  Future<void> decreaseQuantity(int productId) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      print('❌ User ID not found in SharedPreferences');
      return;
    }

    final url = Uri.parse('http://$ip:3000/cart/decrease/$userId');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId, 'product_id': productId}),
      );

      if (response.statusCode == 200) {
        print('✅ Quantity decreased successfully');
        await fetchCartItemsFromServer(); // تحديث السلة بعد التغيير
      } else {
        print('❌ Failed to decrease quantity: ${response.body}');
      }
    } catch (e) {
      print('❌ Error decreasing quantity: $e');
    }
  }

  /*
  //updating the quantity
  Future<void> updateItemQuantity(int productId, int quantity) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');
    final String url = 'http://$ip:3000/cart/update';

    var headers = {'Content-Type': 'application/json'};

    var body = jsonEncode({
      'user_id': userId,
      'product_id': productId,
      'quantity': quantity,
    });

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Quantity updated successfully');
        await fetchCartItemsFromServer(); //
      } else {
        print('Failed to update quantity. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating item quantity: $e');
    }
  }
*/

  double get total {
    return cartItems.fold(0.0, (sum, item) {
      double price = item['price'] as double;
      int quantity = item['quantity'] as int;

      // إضافة 15 دولار إذا كان هناك تصميم
      if (item['image_designed'] != null &&
          item['image_designed'].toString().isNotEmpty) {
        price += 15;
      }

      return sum + (price * quantity);
    });
  }

  /*void updateQuantity(int index, int delta) {
    setState(() {
      final newQuantity = cartItems[index]['quantity'] + delta;
      if (newQuantity > 0) {
        cartItems[index]['quantity'] = newQuantity;
      }
    });
  }*/
  void removeItem(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    final productId = cartItems[index]['product_id'];
    print("productId: $productId");
    print("userId: $userId");
    if (userId == null || productId == null) {
      print('❌ Cannot delete: user_id or product_id is null');
      return;
    }

    await removeItemFromCart(userId, productId);
  }

  // fun of the quantity
  void changeQuantity(int index, int productId, int delta) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      print('❌ user_id is null');
      return;
    }

    final item = cartItems[index];
    final quantity = item['quantity'];
    final maxQuantity = item['max_quantity'];

    if (quantity == null || maxQuantity == null) {
      print('❌ quantity or max_quantity is null');
      return;
    }

    // احسب الكمية الجديدة محليًا
    int newQuantity = quantity + delta;

    // لا تسمح بالتقليل لأقل من 1
    if (newQuantity < 1) return;

    // لا تسمح بتجاوز الحد الأقصى
    if (newQuantity > maxQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Sorry, the item is SOLD OUT."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final url = Uri.parse(
      'http://$ip:3000/cart/${delta > 0 ? 'increase' : 'decrease'}/$userId',
    );

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'product_id': productId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          cartItems[index]['quantity'] = newQuantity;
        });
        print("✅ Quantity updated successfully");
      } else {
        print("❌ Failed to update quantity: ${response.body}");
      }
    } catch (e) {
      print("❌ Error in updating quantity: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4FF),
      appBar: AppBar(
        title: const Text(
          'Your Cart',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.purple,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                double displayedPrice = item['price'];
                if (item['image_designed'] != null &&
                    item['image_designed'].toString().isNotEmpty) {
                  displayedPrice += 15;
                }
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          item['image_designed']?.isNotEmpty == true
                              ? item['image_designed']
                              : item['image_url'],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.broken_image);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '${item['price'].toStringAsFixed(2)} \$',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            if (item['image_designed'] != null &&
                                item['image_designed'].toString().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: Text(
                                  '+\$15',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () async {
                                    await increaseQuantity(
                                      cartItems[index]['product_id'],
                                    );
                                  },
                                ),
                                Text(
                                  '${cartItems[index]['quantity']}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.remove),
                                  onPressed: () async {
                                    await decreaseQuantity(
                                      cartItems[index]['product_id'],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => removeItem(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),

            child: Column(
              children: [
                Row(
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),

                    Text(
                      '${total.toStringAsFixed(2)} \$',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => PaymentPage(
                                amount: total,
                                selectedProducts:
                                    cartItems, // Pass all cart items
                              ),
                        ),
                      );
                    },
                    child: Text("Buy"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
