import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:graduation/screens/ipadress.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import 'ProductDetailsPage.dart';
import 'ipadress.dart';

class SunglassesSection extends StatefulWidget {
  const SunglassesSection({super.key});

  @override
  State<SunglassesSection> createState() => _SunglassesSectionState();
}

class _SunglassesSectionState extends State<SunglassesSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String searchQuery = "";

  bool isLoading = true;

  final Map<String, int> categoryIds = {
    'Women Sunglasses': 19,
    'Men sunglasses': 20,
  };

  final Map<String, List<Product>> productsByCategory = {
    'Women Sunglasses': [],
    'Men sunglasses': [],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categoryIds.length, vsync: this);
    fetchAllCategories();
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
    final url = Uri.parse(
      'http://$ip:3000/products/category/id/$categoryId',
    ); // Replace with your real base URL

    try {
      final response = await http.get(url);
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Raw data length for $categoryName: ${data.length}');

        final List<Product> products =
            data.map((item) {
              print('Product raw item: $item');
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
                categoryId:
                    item['category_id'] ?? categoryId, // 👈 أضف هذا السطر
              );
            }).toList();

        print('Parsed products count for $categoryName: ${products.length}');

        productsByCategory[categoryName] = products;

        print(
          'Stored productsByCategory[${categoryName}] length: ${productsByCategory[categoryName]?.length}',
        );
      } else {
        print('Failed to load $categoryName products');
      }
    } catch (e) {
      print('Error fetching $categoryName products: $e');
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
        title: const Text('Sunglasses', style: TextStyle(color: Colors.black)),
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
                        hintText: 'Search',
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
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              product.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
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
