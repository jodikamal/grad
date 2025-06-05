class Product {
  final int productId;
  final String name;
  final String description;
  final double price;
  final String imagePath;
  final String size;
  final int quantity;
  final double averageRating;
  final int categoryId;

  Product({
    required this.productId,
    required this.name,
    required this.description,
    required this.price,
    required this.imagePath,
    required this.size,
    required this.quantity,
    required this.averageRating,
    required this.categoryId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['product_id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      imagePath: json['image_url'] ?? 'default.png',
      size: json['size'] ?? '',
      quantity: json['quantity'] ?? 0,
      averageRating:
          double.tryParse(json['average_rating']?.toString() ?? '0') ?? 0.0,
      categoryId: json['category_id'] ?? 0,
    );
  }

  get reviewCount => null;
}

class CartItem {
  final Product product;
  int quantity;
  int maxQuantity;
  String? imageDesigned;

  CartItem({
    required this.product,
    required this.quantity,
    required this.maxQuantity,
    this.imageDesigned,
  });
}
