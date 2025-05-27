import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:graduation/screens/ipadress.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import 'ProductDetailsPage.dart';
import 'ipadress.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClothesSection extends StatefulWidget {
  const ClothesSection({super.key});

  @override
  State<ClothesSection> createState() => _ClothesSectionState();
}

class _ClothesSectionState extends State<ClothesSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String searchQuery = '';
  bool isLoading = true;
  late SharedPreferences _prefs;
  Map<int, bool> _favorites = {};
  Map<int, int> _wishlistIds = {};

  final Map<String, int> categoryIds = {
    'T-Shirts': 9,
    'Pants': 10,
    'Dresses': 11,
  };

  final Map<String, List<Product>> productsByCategory = {
    'T-Shirts': [],
    'Pants': [],
    'Dresses': [],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categoryIds.length, vsync: this);
    _initSharedPreferences().then((_) => fetchAllCategories());
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    // Load initial favorites if needed
  }

  Future<void> fetchAllCategories() async {
    for (var entry in categoryIds.entries) {
      await fetchProductsByCategory(entry.key, entry.value);
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchProductsByCategory(
    String categoryName,
    int categoryId,
  ) async {
    final url = Uri.parse('http://$ip:3000/products/category/id/$categoryId');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<Product> products =
            data.map((item) {
              return Product(
                productId: item['product_id'] ?? 0,
                name: item['name'] ?? '',
                description: item['description'] ?? 'No description provided.',
                price: double.tryParse(item['price'].toString()) ?? 0.0,
                imagePath: item['image_url'] ?? 'default.png',
                size: item['size'] ?? 'M',
                quantity: item['quantity'] ?? 0,
                averageRating:
                    item['average_rating'] != null
                        ? double.tryParse(item['average_rating'].toString()) ??
                            0.0
                        : 0.0,
                categoryId: item['category_id'] ?? categoryId,
              );
            }).toList();

        productsByCategory[categoryName] = products;
        await _fetchWishlistStatus(products);
      }
    } catch (e) {
      print('Error fetching $categoryName products: $e');
    }
  }

  Future<void> _fetchWishlistStatus(List<Product> products) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');
    if (userId == null) return;

    try {
      final response = await http.get(
        Uri.parse('http://$ip:3000/wishlist/user/$userId'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> wishlistItems = jsonDecode(response.body);

        setState(() {
          for (var item in wishlistItems) {
            final productId = item['product_id'];
            _favorites[productId] = true;
            _wishlistIds[productId] = item['wishlist_id'];
          }
        });
      }
    } catch (e) {
      print('Error fetching wishlist: $e');
    }
  }

  Future<void> _toggleFavorite(int productId, bool isCurrentlyFavorite) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to add favorites')),
      );
      return;
    }

    setState(() {
      _favorites[productId] = !isCurrentlyFavorite;
    });

    try {
      if (isCurrentlyFavorite) {
        // Remove from favorites
        if (_wishlistIds.containsKey(productId)) {
          final wishlistId = _wishlistIds[productId];
          final response = await http.delete(
            Uri.parse('http://$ip:3000/wishlist/$wishlistId'),
          );

          if (response.statusCode == 200) {
            setState(() {
              _wishlistIds.remove(productId);
            });
          }
        }
      } else {
        // Add to favorites
        final response = await http.post(
          Uri.parse('http://$ip:3000/wishlist/$userId'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'product_id': productId}),
        );

        if (response.statusCode == 201) {
          final data = jsonDecode(response.body);
          setState(() {
            _wishlistIds[productId] = data['wishlist_id'];
          });
        }
      }
    } catch (e) {
      setState(() {
        _favorites[productId] = isCurrentlyFavorite; // Revert on error
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating favorites: $e')));
    }
  }

  List<Product> _filterBySearch(List<Product> list) {
    return list
        .where((p) => p.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final categories = categoryIds.keys.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF5FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Women Clothes',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.purple,
          unselectedLabelColor: Colors.grey,
          tabs: categories.map((c) => Tab(text: c)).toList(),
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search clothes...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children:
                          categories.map((category) {
                            final filtered = _filterBySearch(
                              productsByCategory[category]!,
                            );

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: GridView.builder(
                                itemCount: filtered.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 16,
                                      crossAxisSpacing: 16,
                                      childAspectRatio: 0.75,
                                    ),
                                itemBuilder: (context, index) {
                                  final product = filtered[index];
                                  final isFavorite =
                                      _favorites[product.productId] ?? false;

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => ProductDetailsPage(
                                                product: product,
                                              ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.vertical(
                                                      top: Radius.circular(12),
                                                    ),
                                                child: Image.network(
                                                  product.imagePath,
                                                  height: 140,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Positioned(
                                                top: 8,
                                                right: 8,
                                                child: GestureDetector(
                                                  onTap: () async {
                                                    await _toggleFavorite(
                                                      product.productId,
                                                      isFavorite,
                                                    );
                                                  },
                                                  child: Icon(
                                                    isFavorite
                                                        ? Icons.favorite
                                                        : Icons.favorite_border,
                                                    color:
                                                        isFavorite
                                                            ? Colors.red
                                                            : Colors.white,
                                                    size: 28,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              product.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0,
                                            ),
                                            child: Text(
                                              '\$${product.price.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                color: Colors.purple,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
    );
  }
}
