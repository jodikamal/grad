import 'package:flutter/material.dart';
import '../models/product.dart';
import 'ProductDetailsPage.dart';

class SunglassesSection extends StatefulWidget {
  const SunglassesSection({super.key});

  @override
  State<SunglassesSection> createState() => _SunglassesSectionState();
}

class _SunglassesSectionState extends State<SunglassesSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String searchQuery = "";

  final List<Product> menSunglasses = [
    Product(
      name: 'Men Aviator',
      imagePath: 'assets/images/sn-m2.png',
      price: 89.99,
      description: 'Classic aviator sunglasses for men.',
      height: 10,
      size: 'N/A',
      sectionName: 'Sunglasses',
      rating: 4.6,
      reviewCount: 120,
    ),
    Product(
      name: 'Men Aviator',
      imagePath: 'assets/images/sn-m1.png',
      price: 89.99,
      description: 'Classic aviator sunglasses for men.',
      height: 10,
      size: 'N/A',
      sectionName: 'Sunglasses',
      rating: 4.6,
      reviewCount: 120,
    ),
    Product(
      name: 'Men Aviator',
      imagePath: 'assets/images/sn-m3.png',
      price: 89.99,
      description: 'Classic aviator sunglasses for men.',
      height: 10,
      size: 'N/A',
      sectionName: 'Sunglasses',
      rating: 4.6,
      reviewCount: 120,
    ),
    Product(
      name: 'Men Aviator',
      imagePath: 'assets/images/sn-m4.png',
      price: 89.99,
      description: 'Classic aviator sunglasses for men.',
      height: 10,
      size: 'N/A',
      sectionName: 'Sunglasses',
      rating: 4.6,
      reviewCount: 120,
    ),
  ];

  final List<Product> womenSunglasses = [
    Product(
      name: 'Women Retro',
      imagePath: 'assets/images/sun-wo.png',
      price: 99.99,
      description: 'Retro round sunglasses for women.',
      height: 11,
      size: 'N/A',
      sectionName: 'Sunglasses',
      rating: 4.8,
      reviewCount: 100,
    ),
    Product(
      name: 'Women Retro',
      imagePath: 'assets/images/sn-w1.png',
      price: 99.99,
      description: 'Retro round sunglasses for women.',
      height: 11,
      size: 'N/A',
      sectionName: 'Sunglasses',
      rating: 4.8,
      reviewCount: 100,
    ),
    Product(
      name: 'Women Retro',
      imagePath: 'assets/images/sn-w2.png',
      price: 99.99,
      description: 'Retro round sunglasses for women.',
      height: 11,
      size: 'N/A',
      sectionName: 'Sunglasses',
      rating: 4.8,
      reviewCount: 100,
    ),
    Product(
      name: 'Women Retro',
      imagePath: 'assets/images/sn-w3.png',
      price: 99.99,
      description: 'Retro round sunglasses for women.',
      height: 11,
      size: 'N/A',
      sectionName: 'Sunglasses',
      rating: 4.8,
      reviewCount: 100,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  List<Product> filterProducts(List<Product> list) {
    return list
        .where(
          (product) =>
              product.name.toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();
  }

  Widget buildProductGrid(List<Product> list) {
    final filteredList = filterProducts(list);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        itemCount: filteredList.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemBuilder: (context, index) {
          final product = filteredList[index];
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF5FF),
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          elevation: 1,
          title: const Text(
            'Sunglasses',
            style: TextStyle(color: Colors.black),
          ),
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.purple,
            unselectedLabelColor: Colors.grey,
            tabs: const [Tab(text: 'Men'), Tab(text: 'Women')],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search sunglasses...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) => setState(() => searchQuery = value),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  buildProductGrid(menSunglasses),
                  buildProductGrid(womenSunglasses),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
