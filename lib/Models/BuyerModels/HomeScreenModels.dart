// ── Models ────────────────────────────────────────────────────────────────────
class PromoBanner {
  final String id;
  final String tag;
  final String title;
  final String subtitle;
  final String buttonText;
  final String? imageAsset;
  final String backgroundColor;
  final String actionType; // 'category' | 'filter' | 'product' | 'none'
  final String? actionValue;

  const PromoBanner({
    required this.id,
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    this.imageAsset,
    required this.backgroundColor,
    required this.actionType,
    this.actionValue,
  });
}

class CategoryItem {
  final String name;
  final String imageAsset;
  const CategoryItem({required this.name, required this.imageAsset});
}

class ProductItem {
  final String name;
  final double price;
  final double? discountedPrice;
  final double rating;
  final int reviewCount;
  final String imageAsset;
  final String category;
  bool isWishlisted;

  ProductItem({
    required this.name,
    required this.price,
    this.discountedPrice,
    required this.rating,
    required this.reviewCount,
    required this.imageAsset,
    required this.category,
    this.isWishlisted = false,
  });

  int? get discountPercent {
    if (discountedPrice == null || price <= 0) return null;
    return ((price - discountedPrice!) / price * 100).round();
  }
}