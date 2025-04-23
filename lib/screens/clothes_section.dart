import 'package:flutter/material.dart';
import '../models/product.dart';
import 'ProductDetailsPage.dart';

class ClothesSection extends StatefulWidget {
  const ClothesSection({super.key});

  @override
  State<ClothesSection> createState() => _ClothesSectionState();
}

class _ClothesSectionState extends State<ClothesSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String searchQuery = '';

  final List<Product> allClothes = [
    Product(
      name: 'Casual Shirt',
      imagePath: 'assets/images/clothes1.png',
      price: 49.99,
      description: 'Comfortable casual shirt.',
      height: 75,
      size: 'M',
      sectionName: 'T-Shirts',
      rating: 4.5,
      reviewCount: 120,
    ),
    Product(
      name: 'Elegant Dress',
      imagePath: 'assets/images/clothes2.png',
      price: 89.99,
      description: 'Elegant dress for events.',
      height: 130,
      size: 'L',
      sectionName: 'Dresses',
      rating: 4.8,
      reviewCount: 98,
    ),
    Product(
      name: 'Denim Pants',
      imagePath: 'assets/images/clothes3.png',
      price: 69.99,
      description: 'Stylish denim pants.',
      height: 80,
      size: 'L',
      sectionName: 'Pants',
      rating: 4.3,
      reviewCount: 76,
    ),
  ];

  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
    super.initState();
  }

  List<Product> _filterByCategory(String category) {
    return category == 'All'
        ? allClothes
        : allClothes.where((p) => p.sectionName == category).toList();
  }

  List<Product> _filterBySearch(List<Product> list) {
    return list
        .where((p) => p.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['All', 'T-Shirts', 'Pants', 'Dresses'];

    return Scaffold(
      backgroundColor: const Color(0xFFFAF5FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Clothes', style: TextStyle(color: Colors.black)),
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
      body: Column(
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
                      _filterByCategory(category),
                    );
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
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
                                      (_) =>
                                          ProductDetailsPage(product: product),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                    child: Image.asset(
                                      product.imagePath,
                                      height: 120,
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
                                      '\$${product.price}',
                                      style: const TextStyle(
                                        color: Colors.purple,
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
