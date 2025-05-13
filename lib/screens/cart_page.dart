import 'package:flutter/material.dart';
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
        await fetchCartItemsFromServer(); // ⬅️
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

    if (userId == null) {
      print("User ID is null. User might not be logged in.");
      return;
    }

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
    final String url = 'http://$ip:3000/cart/remove';

    var headers = {'Content-Type': 'application/json'};

    var body = jsonEncode({'user_id': userId, 'product_id': productId});

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Item removed from cart');
        await fetchCartItemsFromServer(); // ⬅️ تحديث القائمة
      } else {
        print('Failed to remove item. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error removing item from cart: $e');
    }
  }

  //updating the quantity
  Future<void> updateItemQuantity(
    int userId,
    int productId,
    int quantity,
  ) async {
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
        await fetchCartItemsFromServer(); // ⬅️ تحديث القائمة
      } else {
        print('Failed to update quantity. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating item quantity: $e');
    }
  }

  double get total {
    return cartItems.fold(
      0.0,
      (sum, item) => sum + (item['price'] as num) * (item['quantity'] as num),
    );
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
    int userId = cartItems[index]['user_id'];
    int productId = cartItems[index]['product_id'];

    await removeItemFromCart(userId, productId);

    setState(() {
      cartItems.removeAt(index);
    });
  }

  // fun of the quantity
  void changeQuantity(int index, int productId, int delta) {
    setState(() {
      int currentQuantity = cartItems[index]['quantity'];
      int maxQuantity = cartItems[index]['max_quantity']; //

      int newQuantity = currentQuantity + delta;

      if (newQuantity < 1) return;

      if (newQuantity > maxQuantity) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Sorry, the item is SOLD OUT.",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      cartItems[index]['quantity'] = newQuantity;
      updateItemQuantity(cartItems[index]['user_id'], productId, newQuantity);
    });
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
                          item['image_url'],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.broken_image,
                            ); // في حال الصورة غير موجودة
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
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed:
                                      () => changeQuantity(
                                        index,
                                        item['product_id'],
                                        -1,
                                      ),
                                ),
                                Text(item['quantity'].toString()),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed:
                                      () => changeQuantity(
                                        index,
                                        item['product_id'],
                                        1,
                                      ),
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
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 228, 210, 231),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Buy',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
