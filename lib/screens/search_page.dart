import 'package:flutter/material.dart';
import 'package:graduation/models/product.dart';
import 'package:graduation/screens/ProductDetailsPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ipadress.dart';

class SearchPage extends StatefulWidget {
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _results = [];

  Future<void> _search(String query) async {
    final url = Uri.parse('http://$ip:3000/search/products?name=$query');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          _results = List<Map<String, dynamic>>.from(data);
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search Item')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Search For Item...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  _search(value);
                } else {
                  setState(() {
                    _results = [];
                  });
                }
              },
            ),
          ),
          Expanded(
            child:
                _results.isEmpty
                    ? Center(child: Text('No Results'))
                    : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final product = _results[index];
                        return ListTile(
                          leading: SizedBox(
                            width: 60,
                            height: 60,
                            child: Image.network(
                              product['image_url'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.broken_image);
                              },
                            ),
                          ),

                          title: Text(product['name']),
                          subtitle: Text('${product['price']} \$'),
                          onTap: () {
                            final selectedProduct = Product(
                              productId: product['product_id'],
                              name: product['name'] ?? '',
                              description: product['description'] ?? '',
                              price:
                                  double.tryParse(
                                    product['price'].toString(),
                                  ) ??
                                  0.0,
                              imagePath: product['image_url'] ?? 'default.png',
                              size: product['size'] ?? '',
                              quantity: product['quantity'] ?? 0,
                              averageRating:
                                  double.tryParse(
                                    product['average_rating']?.toString() ??
                                        '0',
                                  ) ??
                                  0.0,
                              categoryId: product['category_id'] ?? 0,
                            );

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ProductDetailsPage(
                                      product: selectedProduct,
                                    ),
                              ),
                            );
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
