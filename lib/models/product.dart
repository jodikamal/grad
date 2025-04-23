// models/product.dart
class Product {
  final String name;
  final String imagePath;
  final double price;
  final String description;
  final double height;
  final String size;
  final String sectionName;
  final double rating;
  final int reviewCount;

  Product({
    required this.name,
    required this.imagePath,
    required this.price,
    required this.description,
    required this.height,
    required this.size,
    required this.sectionName,
    required this.rating,
    required this.reviewCount,
  });
}
