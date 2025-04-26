import 'package:flutter/material.dart';
import 'package:graduation/models/product.dart';
import 'package:graduation/screens/ProductDetailsPage.dart';

class UniSexSection extends StatelessWidget {
  const UniSexSection({super.key});

  // قائمة المنتجات (هوديز وتيشيرتات)
  final List<Map<String, String>> products = const [
    {'name': 'Hoodie - Red', 'image': 'assets/images/h-r.png'},
    {'name': 'Hoodie - Yellow', 'image': 'assets/images/h-y.png'},
    {'name': 'Hoodie - White', 'image': 'assets/images/h-w.png'},
    {'name': 'Hoodie - Black', 'image': 'assets/images/h-b.png'},
    {'name': 'Hoodie - Green', 'image': 'assets/images/h-g.png'},
    {'name': 'Hoodie - Blue', 'image': 'assets/images/h-bl.png'},
    {'name': 'Hoodie - White/Gray', 'image': 'assets/images/h-wh.png'},
    {'name': 'Hoodie - Pink', 'image': 'assets/images/h-p.png'},
    {'name': 'Hoodie - Orange', 'image': 'assets/images/h-o.png'},
    {'name': 'T-Shirt - Red', 'image': 'assets/images/t-r.png'},
    {'name': 'T-Shirt - Green', 'image': 'assets/images/t-g.png'},
    {'name': 'T-Shirt - Blue', 'image': 'assets/images/t-b.png'},
    {'name': 'T-Shirt - Yellow', 'image': 'assets/images/t-y.png'},
    {'name': 'T-Shirt - White', 'image': 'assets/images/t-w.png'},
    {'name': 'T-Shirt - DarkBlue', 'image': 'assets/images/t-db.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uni-Sex'),
        backgroundColor: Colors.purple,
      ),
      backgroundColor: const Color(0xFFFAF5FF),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final product = products[index];
            return GestureDetector(
              onTap: () {
                final selectedProduct = Product(
                  name: product['name']!,
                  imagePath: product['image']!,
                  price: 39,
                  description:
                      'High quality and stylish unisex apparel.', // وصف
                  height: 70.0,
                  size: 'M',
                  sectionName: 'Uni-Sex',
                  rating: 4.5,
                  reviewCount: 25,
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            ProductDetailsPage(product: selectedProduct),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 5),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(15),
                        ),
                        child: Image.asset(
                          product['image']!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['name']!,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '\$39',
                            style: TextStyle(color: Colors.purple),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
