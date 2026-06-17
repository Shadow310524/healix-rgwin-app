import 'category.dart';

/// Immutable data model for a Product.
/// Implements == and hashCode for safe use in Sets, Maps, and ListView keys.
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

  const Product({
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
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? 'Unnamed Product',
      price: (json['price'] as String?) ?? '',
      mrp: json['mrp'] as String?,
      imageUrl: (json['image_url'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      benefits: (json['benefits'] as String?) ?? '',
      ingredients: (json['ingredients'] as String?) ?? '',
      category: json['category'] != null
          ? Category.fromJson(json['category'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'mrp': mrp,
      'image_url': imageUrl,
      'description': description,
      'benefits': benefits,
      'ingredients': ingredients,
      'category': category?.toJson(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Product && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Product(id: $id, name: $name)';
}
