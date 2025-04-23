import 'package:flutter/material.dart';
import '../models/product.dart';
import 'ProductDetailsPage.dart';

class AccessoriesSection extends StatefulWidget {
  const AccessoriesSection({super.key});

  @override
  State<AccessoriesSection> createState() => _AccessoriesSectionState();
}

class _AccessoriesSectionState extends State<AccessoriesSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Product> allProducts = [
    Product(
      name: 'Men Watch',
      imagePath: 'assets/images/watchmen.png',
      price: 59.99,
      description: 'Classic men\'s wristwatch.',
      height: 10,
      size: 'N/A',
      sectionName: 'Accessories',
      rating: 4.5,
      reviewCount: 87,
    ),
    Product(
      name: 'Women Watch',
      imagePath: 'assets/images/watchwo.png',
      price: 64.99,
      description: 'Elegant women\'s wristwatch.',
      height: 10,
      size: 'N/A',
      sectionName: 'Accessories',
      rating: 4.8,
      reviewCount: 103,
    ),
    Product(
      name: 'Gold Necklace',
      imagePath: 'assets/images/necklace.png',
      price: 120.00,
      description: 'Luxury gold necklace.',
      height: 5,
      size: 'N/A',
      sectionName: 'Accessories',
      rating: 4.9,
      reviewCount: 80,
    ),
    Product(
      name: 'Bracelet',
      imagePath: 'assets/images/bracelets.png',
      price: 35.00,
      description: 'Fashion bracelet.',
      height: 5,
      size: 'N/A',
      sectionName: 'Accessories',
      rating: 4.6,
      reviewCount: 65,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  List<Product> _filterProducts(String category) {
    switch (category) {
      case 'Watches (Men)':
        return allProducts.where((p) => p.name.contains('Men')).toList();
      case 'Watches (Women)':
        return allProducts.where((p) => p.name.contains('Women')).toList();
      case 'Necklaces':
        return allProducts.where((p) => p.name.contains('Necklace')).toList();
      case 'Bracelets':
        return allProducts.where((p) => p.name.contains('Bracelet')).toList();
      case 'All':
      default:
        return allProducts;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF5FF),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: const IconThemeData(color: Colors.black),
          title: const TextField(
            decoration: InputDecoration(
              hintText: 'Search accessories...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 20),
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: Colors.purple,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.purple,
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Watches (Men)'),
              Tab(text: 'Watches (Women)'),
              Tab(text: 'Necklaces'),
              Tab(text: 'Bracelets'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildGrid('All'),
            _buildGrid('Watches (Men)'),
            _buildGrid('Watches (Women)'),
            _buildGrid('Necklaces'),
            _buildGrid('Bracelets'),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(String category) {
    final products = _filterProducts(category);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemBuilder: (context, index) {
          final product = products[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailsPage(product: product),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
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
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      '\$${product.price}',
                      style: const TextStyle(color: Colors.purple),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
