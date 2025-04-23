import '../models/product.dart';

// البيانات الأصلية كماب
const List<Map<String, String>> _newArrivalsData = [
  {
    'image': 'assets/images/clothes2.png',
    'name': 'Trendy Jacket',
    'price': '59.99',
  },
  {
    'image': 'assets/images/watchwo.png',
    'name': 'Women\'s Watch',
    'price': '79.99',
  },
  {
    'image': 'assets/images/sun-men.png',
    'name': 'Men\'s Sunglasses',
    'price': '27.99',
  },
  {
    'image': 'assets/images/clothes3.png',
    'name': 'Stylish Blazer',
    'price': '69.99',
  },
  {
    'image': 'assets/images/bracelets.png',
    'name': 'Leather Bracelet',
    'price': '12.99',
  },
];

const List<Map<String, String>> _bestSellersData = [
  {
    'image': 'assets/images/clothes1.png',
    'name': 'Classic Hoodie',
    'price': '49.99',
  },
  {
    'image': 'assets/images/watchmen.png',
    'name': 'Men\'s Watch',
    'price': '89.99',
  },
  {
    'image': 'assets/images/sun-wo.png',
    'name': 'Women\'s Sunglasses',
    'price': '29.99',
  },
  {
    'image': 'assets/images/shirt.png',
    'name': 'Elegant Shirt',
    'price': '35.99',
  },
  {
    'image': 'assets/images/necklace.png',
    'name': 'Silver Necklace',
    'price': '19.99',
  },
];

// تحويل البيانات إلى List<Product>
final List<Product> newArrivals =
    _newArrivalsData
        .map(
          (item) => Product(
            name: item['name']!,
            imagePath: item['image']!,
            price: double.parse(item['price']!),
            description: 'No description available',
            size: 'M',
            height: 170,
            rating: 4.5,
            reviewCount: 20,
            sectionName: 'New Arrivals',
          ),
        )
        .toList();

final List<Product> bestSellers =
    _bestSellersData
        .map(
          (item) => Product(
            name: item['name']!,
            imagePath: item['image']!,
            price: double.parse(item['price']!),
            description: 'No description available',
            size: 'M',
            height: 170,
            rating: 4.5,
            reviewCount: 20,
            sectionName: 'Best Sellers',
          ),
        )
        .toList();
