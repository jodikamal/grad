import 'package:flutter/material.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  List<Map<String, String>> wishlistItems = List.generate(
    5,
    (index) => {
      'title': 'Stylish Jacket $index',
      'price': '\$49.99',
      'image': 'assets/images/homepage.png',
    },
  );

  void _removeFromWishlist(int index) {
    setState(() {
      wishlistItems.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Item removed from wishlist 💔")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Wishlist',
          style: TextStyle(color: Colors.purple),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.purple),
      ),
      backgroundColor: const Color(0xFFFAF5FF),
      body:
          wishlistItems.isEmpty
              ? const Center(
                child: Text(
                  'Your wishlist is empty 💔',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: wishlistItems.length,
                itemBuilder: (context, index) {
                  final item = wishlistItems[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 3,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(10),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          item['image']!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        item['title']!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        item['price']!,
                        style: const TextStyle(color: Colors.purple),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.purple),
                        onPressed: () => _removeFromWishlist(index),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
