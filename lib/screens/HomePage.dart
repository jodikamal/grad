import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:graduation/screens/DeliveryNotifications.dart';
import 'package:graduation/screens/ipadress.dart';
import 'package:graduation/screens/notification_user.dart';
import 'package:http/http.dart' as http;
import '../screens/settings_page.dart';
import '../screens/clothes_section.dart';
import '../screens/accessories_section.dart';
import '../screens/sunglasses_section.dart';
import '../screens/men_section.dart';
import '../screens/new_arrivals_page.dart';
import '../screens/best_sellers_page.dart';
import '../models/product.dart';
import '../screens/ProductDetailsPage.dart';
import '../screens/uni_sex.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product> newArrivals = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNewArrivals();
  }

  Future<void> fetchNewArrivals() async {
    try {
      final response = await http.get(Uri.parse('http://$ip:3000/newarrivals'));

      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        print(data);
        setState(() {
          newArrivals = data.map((item) => Product.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load new arrivals');
      }
    } catch (e) {
      print('Error fetching new arrivals: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF5FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const TextField(
          decoration: InputDecoration(
            hintText: 'Search...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30)),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 20),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserNotificationsPage(),
                ),
              );
            },
          ),

          IconButton(
            icon: const Icon(Feather.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                'assets/images/homepage.png',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sections',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 70,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: [
                _buildCategory('Women', Icons.checkroom, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ClothesSection()),
                  );
                }),
                _buildCategory('Men', Icons.checkroom, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MenSection()),
                  );
                }),
                _buildCategory('Accessories', Icons.watch, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AccessoriesSection()),
                  );
                }),
                _buildCategory('Sunglasses', Icons.remove_red_eye_outlined, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SunglassesSection()),
                  );
                }),
                _buildCategory('Uni-Sex', Icons.checkroom, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UniSexSection()),
                  );
                }),
              ],
            ),

            const SizedBox(height: 20),

            // New Arrivals & Best Sellers Sections
            _buildProductGroup(
              'New Arrivals',
              context,
              newArrivals.take(4).toList(),
            ),
            /* _buildProductGroup(
              'Best Sellers',
              context,
              bestSellers.take(4).toList(),
            ),*/
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(String name, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Icon(icon, size: 30, color: Colors.purple),
          ),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildProductGroup(
    String title,
    BuildContext context,
    List<Product> products,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            TextButton(
              onPressed: () {
                if (title == 'New Arrivals') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => NewArrivalsPage()),
                  );
                } //else if (title == 'Best Sellers') {
                //Navigator.push(
                // context,
                //  MaterialPageRoute(builder: (_) => BestSellersPage()),
                // );
                // }
              },
              child: const Text(
                'See All',
                style: TextStyle(color: Colors.purple),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
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
                child: _buildProductCard(
                  product.imagePath,
                  product.name,
                  product.price.toStringAsFixed(0),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildProductCard(String image, String name, String price) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      width: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
            child: Image.network(
              image,
              height: 120,
              width: 150,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('\$$price', style: const TextStyle(color: Colors.purple)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
