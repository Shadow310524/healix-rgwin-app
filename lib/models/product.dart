import 'category.dart';

class Product {
  final int id;
  final String name;
  final String price;
  final String? mrp;
  final String imageUrl;
  final String description;
  final String benefits;
  final String ingredients;
  final Category? category;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.mrp,
    required this.imageUrl,
    required this.description,
    required this.benefits,
    required this.ingredients,
    this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unnamed Product',
      price: json['price'] ?? '',
      mrp: json['mrp'],
      imageUrl: json['image_url'] ?? '',
      description: json['description'] ?? '',
      benefits: json['benefits'] ?? '',
      ingredients: json['ingredients'] ?? '',
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
    );
  }
}
