/*
import 'package:flutter/material.dart';
import '../models/product.dart';
import 'ProductDetailsPage.dart';

class BestSellersPage extends StatelessWidget {
  BestSellersPage({super.key}); // ← شلنا const من الكونستركتر

  final List<Product> bestSellers = [
    Product(
      name: 'Elegant Dress',
      imagePath: 'assets/images/clothes1.png',
      price: 49.99,
      description: 'A classy elegant dress for any occasion.',
      size: 'M',
      height: 170,
      rating: 4.6,
      reviewCount: 32,
      sectionName: 'Best Sellers',
    ),
    Product(
      name: 'Casual T-Shirt',
      imagePath: 'assets/images/tshirt.png',
      price: 19.99,
      description: 'Comfortable cotton T-shirt.',
      size: 'L',
      height: 175,
      rating: 4.4,
      reviewCount: 18,
      sectionName: 'Best Sellers',
    ),
    Product(
      name: 'Men\'s Watch',
      imagePath: 'assets/images/watchmen.png',
      price: 89.99,
      description: 'Stylish men’s watch with leather strap.',
      size: 'One Size',
      height: 0,
      rating: 4.8,
      reviewCount: 45,
      sectionName: 'Best Sellers',
    ),
    Product(
      name: 'Women\'s Sunglasses',
      imagePath: 'assets/images/sun-wo.png',
      price: 29.99,
      description: 'Trendy sunglasses for women.',
      size: 'One Size',
      height: 0,
      rating: 4.3,
      reviewCount: 20,
      sectionName: 'Best Sellers',
    ),
    Product(
      name: 'Stylish Pants',
      imagePath: 'assets/images/pants.png',
      price: 39.99,
      description: 'Modern style comfortable pants.',
      size: 'L',
      height: 180,
      rating: 4.2,
      reviewCount: 17,
      sectionName: 'Best Sellers',
    ),
    Product(
      name: 'Bracelet Set',
      imagePath: 'assets/images/bracelets.png',
      price: 14.99,
      description: 'Fashionable bracelet set.',
      size: 'One Size',
      height: 0,
      rating: 4.7,
      reviewCount: 28,
      sectionName: 'Best Sellers',
    ),
    Product(
      name: 'Formal Shirt',
      imagePath: 'assets/images/shirt.png',
      price: 34.99,
      description: 'Perfect for formal occasions.',
      size: 'M',
      height: 170,
      rating: 4.5,
      reviewCount: 19,
      sectionName: 'Best Sellers',
    ),
    Product(
      name: 'Necklace',
      imagePath: 'assets/images/necklace.png',
      price: 24.99,
      description: 'Elegant women’s necklace.',
      size: 'One Size',
      height: 0,
      rating: 4.6,
      reviewCount: 25,
      sectionName: 'Best Sellers',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Best Sellers'),
        backgroundColor: const Color.fromARGB(255, 206, 181, 210),
      ),
      backgroundColor: const Color(0xFFFAF5FF),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: bestSellers.length,
        itemBuilder: (context, index) {
          final product = bestSellers[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailsPage(product: product),
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
                      height: 130,
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
                      '\$${product.price.toStringAsFixed(2)}',
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
*/
