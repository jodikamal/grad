import 'package:flutter/material.dart';
import 'package:graduation/models/product.dart';
import 'package:graduation/screens/ProductDetailsPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ipadress.dart';

class UniSexSection extends StatefulWidget {
  const UniSexSection({super.key});

  @override
  State<UniSexSection> createState() => _UniSexSectionState();
}

class _UniSexSectionState extends State<UniSexSection> {
  List<Product> _products = [];
  bool _isLoading = true;

  final String apiUrl =
      'http://$ip:3000/products/category/id/4'; //  category_id

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _products =
              data
                  .map(
                    (item) => Product(
                      productId: item['product_id'] ?? 0,
                      name: item['name'] ?? '',
                      description:
                          item['description'] ?? 'No description provided.',
                      price: double.tryParse(item['price'].toString()) ?? 0.0,
                      imagePath: item['image_url'] ?? 'default.png',
                      size: item['size'] ?? 'M',
                      quantity: item['quantity'] ?? 0,
                      averageRating:
                          item['average_rating'] != null
                              ? double.tryParse(
                                    item['average_rating'].toString(),
                                  ) ??
                                  0.0
                              : 0.0,
                      categoryId: item['category_id'] ?? 0,
                    ),
                  )
                  .toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print('Error fetching products: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uni-Sex'),
        backgroundColor: const Color.fromARGB(255, 243, 241, 244),
      ),
      backgroundColor: const Color(0xFFFAF5FF),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(12.0),
                child: GridView.builder(
                  itemCount: _products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    ProductDetailsPage(product: product),
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
                                child: Image.network(
                                  product.imagePath,
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
                                    product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$${product.price}',
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 186, 182, 186),
                                    ),
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
