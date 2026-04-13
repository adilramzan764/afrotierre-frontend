import 'dart:ui';

class ProductItem {
  final String id;
  final String name;
  final double price;
  final double? discountedPrice;
  final double rating;
  final int reviewCount;
  final String imageAsset;
  final String category;
  final Map<String, String> attributes;
  final List<Color> colors;
  final int stock;
  bool isWishlisted;

  ProductItem({
    required this.id,
    required this.name,
    required this.price,
    this.discountedPrice,
    required this.rating,
    required this.reviewCount,
    required this.imageAsset,
    required this.category,
    this.attributes = const {},
    this.colors = const [],
    required this.stock,
    this.isWishlisted = false,
  });

  int? get discountPercent {
    if (discountedPrice == null || price <= 0) return null;
    return ((price - discountedPrice!) / price * 100).round();
  }

  bool get inStock => stock > 0;
}