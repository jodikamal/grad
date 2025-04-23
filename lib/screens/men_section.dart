// screens/men_section.dart
import 'package:flutter/material.dart';
import '../models/product.dart';
import 'ProductDetailsPage.dart';

class MenSection extends StatefulWidget {
  const MenSection({super.key});

  @override
  State<MenSection> createState() => _MenSectionState();
}

class _MenSectionState extends State<MenSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Product> shirts = [
    Product(
      name: "Classic Shirt",
      imagePath: "assets/images/shirt.png",
      price: 49.99,
      description: "A classic men's shirt perfect for formal and casual wear.",
      height: 70,
      size: "L",
      sectionName: "shirts",
      rating: 4.5,
      reviewCount: 23,
    ),
  ];

  final List<Product> tshirts = [
    Product(
      name: "Cool T-Shirt",
      imagePath: "assets/images/tshirt.png",
      price: 29.99,
      description: "Casual t-shirt made from 100% cotton.",
      height: 68,
      size: "M",
      sectionName: "tshirt",
      rating: 4.2,
      reviewCount: 15,
    ),
  ];

  final List<Product> pants = [
    Product(
      name: "Slim Fit Pants",
      imagePath: "assets/images/pants.png",
      price: 59.99,
      description: "Modern slim fit pants for everyday style.",
      height: 102,
      size: "32",
      sectionName: "pants",
      rating: 4.6,
      reviewCount: 18,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  Widget buildProductGrid(List<Product> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: products.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 12,
        childAspectRatio: 0.7,
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
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  child: Image.asset(
                    product.imagePath,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF5FF),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: const Text("Men", style: TextStyle(color: Colors.black)),
          iconTheme: const IconThemeData(color: Colors.black),
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.purple,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: "Shirts"),
              Tab(text: "T-Shirts"),
              Tab(text: "Pants"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            buildProductGrid(shirts),
            buildProductGrid(tshirts),
            buildProductGrid(pants),
          ],
        ),
      ),
    );
  }
}
