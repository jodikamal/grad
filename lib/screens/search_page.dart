import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String searchText = '';

  // بيانات وهمية
  final List<Map<String, dynamic>> fakeProducts = [
    {
      'name': 'Purple Blazer',
      'price': '\$59.99',
      'image': 'assets/images/blazer.png',
    },
    {
      'name': 'Gold Necklace',
      'price': '\$129.99',
      'image': 'assets/images/necklace.png',
    },
    {
      'name': 'Stylish Sunglasses',
      'price': '\$39.99',
      'image': 'assets/images/sunglasses.png',
    },
    {
      'name': 'Elegant Dress',
      'price': '\$79.99',
      'image': 'assets/images/dress.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF5FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Search',
          style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.purple),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // حقل البحث
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.purple),
              ),
              child: Row(
                children: [
                  const Icon(Feather.search, color: Colors.purple),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchText = value;
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: 'Search in Glamzy...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  if (searchText.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          searchText = '';
                        });
                      },
                      child: const Icon(Feather.x, color: Colors.purple),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // عرض النتائج
            if (searchText.isEmpty)
              const Text(
                'Start typing to find items...',
                style: TextStyle(color: Colors.grey),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: fakeProducts.length,
                  itemBuilder: (context, index) {
                    final product = fakeProducts[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            product['image'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          product['name'],
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(product['price']),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // فتح صفحة التفاصيل (لاحقًا)
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
