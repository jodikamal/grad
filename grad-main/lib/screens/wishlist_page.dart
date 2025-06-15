import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ipadress.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  List<Map<String, dynamic>> wishlistItems = [];

  @override
  void initState() {
    super.initState();
    fetchWishlistItemsFromServer();
  }

  // Fetch wishlist items from server
  Future<void> fetchWishlistItemsFromServer() async {
    final prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('userId');

    if (userId == null) {
      print('User not logged in');
      return;
    }

    final url = 'http://$ip:3000/wishlist/$userId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        setState(() {
          wishlistItems =
              responseData.map<Map<String, dynamic>>((item) {
                final price = item['price'];
                return {
                  ...item,
                  'price':
                      price == null
                          ? 0.0
                          : (price is String
                              ? double.tryParse(price) ?? 0.0
                              : (price as num).toDouble()),
                };
              }).toList();
        });
      } else {
        print('Failed to fetch wishlist items. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching wishlist items: $e');
    }
  }

  // Add item to wishlist
  Future<void> addItemToWishlist(int productId) async {
    final prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('userId');

    if (userId == null) {
      print('User not logged in');
      return;
    }

    final url = 'http://$ip:3000/wishlist/add';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId, 'product_id': productId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Item added to wishlist');
        await fetchWishlistItemsFromServer();
      } else {
        print('Failed to add item to wishlist: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding item to wishlist: $e');
    }
  }

  // Remove item from wishlist
  Future<void> removeItemFromWishlist(int wishlistId) async {
    final url = 'http://$ip:3000/wishlist/$wishlistId';

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('Item removed from wishlist');
        await fetchWishlistItemsFromServer();
      } else {
        print('Failed to remove item from wishlist: ${response.statusCode}');
      }
    } catch (e) {
      print('Error removing item from wishlist: $e');
    }
  }

  void removeItem(int index) async {
    final wishlistId = wishlistItems[index]['wishlist_id'];
    if (wishlistId == null) {
      print('Wishlist ID is null');
      return;
    }
    await removeItemFromWishlist(wishlistId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4FF),
      appBar: AppBar(
        title: const Text(
          'Your Wishlist',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.purple,
        elevation: 1,
      ),
      body:
          wishlistItems.isEmpty
              ? const Center(
                child: Text(
                  'Your wishlist is empty!',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: wishlistItems.length,
                itemBuilder: (context, index) {
                  final item = wishlistItems[index];
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
                              return const Icon(Icons.broken_image);
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
    );
  }
}
