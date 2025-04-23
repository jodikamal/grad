import 'package:flutter/material.dart';
import '../models/product.dart';
import 'ProductDetailsPage.dart';

class NewArrivalsPage extends StatelessWidget {
  NewArrivalsPage({super.key});

  final List<Product> newArrivals = [
    Product(
      name: 'Trendy Jacket',
      imagePath: 'assets/images/clothes2.png',
      price: 59.99,
      description: 'A stylish jacket for the modern look.',
      size: 'M',
      height: 175,
      rating: 4.5,
      reviewCount: 30,
      sectionName: 'New Arrivals',
    ),
    Product(
      name: 'Women\'s Watch',
      imagePath: 'assets/images/watchwo.png',
      price: 79.99,
      description: 'Elegant watch for every occasion.',
      size: 'One Size',
      height: 0,
      rating: 4.7,
      reviewCount: 25,
      sectionName: 'New Arrivals',
    ),
    Product(
      name: 'Men\'s Sunglasses',
      imagePath: 'assets/images/sun-men.png',
      price: 27.99,
      description: 'Trendy sunglasses for men.',
      size: 'One Size',
      height: 0,
      rating: 4.3,
      reviewCount: 18,
      sectionName: 'New Arrivals',
    ),
    Product(
      name: 'Stylish Blazer',
      imagePath: 'assets/images/clothes3.png',
      price: 69.99,
      description: 'Perfect blazer for formal events.',
      size: 'L',
      height: 180,
      rating: 4.6,
      reviewCount: 22,
      sectionName: 'New Arrivals',
    ),
    Product(
      name: 'Leather Bracelet',
      imagePath: 'assets/images/bracelets.png',
      price: 12.99,
      description: 'Sleek leather bracelet.',
      size: 'One Size',
      height: 0,
      rating: 4.4,
      reviewCount: 15,
      sectionName: 'New Arrivals',
    ),
    Product(
      name: 'Summer T-Shirt',
      imagePath: 'assets/images/tshirt.png',
      price: 21.99,
      description: 'Comfortable t-shirt for summer.',
      size: 'M',
      height: 170,
      rating: 4.2,
      reviewCount: 20,
      sectionName: 'New Arrivals',
    ),
    Product(
      name: 'Casual Pants',
      imagePath: 'assets/images/pants.png',
      price: 36.99,
      description: 'Casual pants for everyday wear.',
      size: 'L',
      height: 175,
      rating: 4.5,
      reviewCount: 28,
      sectionName: 'New Arrivals',
    ),
    Product(
      name: 'Golden Necklace',
      imagePath: 'assets/images/necklace.png',
      price: 29.99,
      description: 'Elegant golden necklace.',
      size: 'One Size',
      height: 0,
      rating: 4.8,
      reviewCount: 35,
      sectionName: 'New Arrivals',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Arrivals'),
        backgroundColor: const Color.fromARGB(255, 169, 140, 174),
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
        itemCount: newArrivals.length,
        itemBuilder: (context, index) {
          final product = newArrivals[index];
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
