// lib/Models/BuyerModels/wishlist_models.dart

class WishlistResponse {
  final bool success;
  final WishlistData? data;
  final String? message;
  final String? error;

  WishlistResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
  });

  factory WishlistResponse.fromJson(Map<String, dynamic> json) {
    return WishlistResponse(
      success: json['success'] as bool,
      data: json['data'] != null ? WishlistData.fromJson(json['data']) : null,
      message: json['message'] as String?,
      error: json['error'] as String?,
    );
  }
}

class WishlistData {
  final List<WishlistProduct> wishlist;
  final int wishlistCount;

  WishlistData({
    required this.wishlist,
    required this.wishlistCount,
  });

  factory WishlistData.fromJson(Map<String, dynamic> json) {
    // Handle both cases: when stats is present or not
    List<WishlistProduct> wishlistItems = [];

    if (json['wishlist'] != null) {
      wishlistItems = (json['wishlist'] as List)
          .map((item) => WishlistProduct.fromJson(item))
          .toList();
    }

    return WishlistData(
      wishlist: wishlistItems,
      wishlistCount: json['wishlistCount'] as int? ?? wishlistItems.length,
    );
  }
}

class WishlistProduct {
  final String id;
  final String name;
  final String? description;
  final double price;
  final double? discountedPrice;
  final int? discountPercent;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final String category;
  final int stock;
  final bool inStock;
  final String? status;
  final DateTime? addedAt;

  WishlistProduct({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.discountedPrice,
    this.discountPercent,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.category,
    required this.stock,
    required this.inStock,
    this.status,
    this.addedAt,
  });

  factory WishlistProduct.fromJson(Map<String, dynamic> json) {
    return WishlistProduct(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      price: (json['price'] ?? 0).toDouble(),
      discountedPrice: json['discountedPrice'] != null
          ? (json['discountedPrice'] as num).toDouble()
          : null,
      discountPercent: json['discountPercent'] != null
          ? (json['discountPercent'] as num).toInt()
          : null,
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      imageUrl: json['imageUrl']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      stock: json['stock'] ?? 0,
      inStock: json['inStock'] ?? false,
      status: json['status']?.toString(),
      addedAt: json['addedAt'] != null
          ? DateTime.tryParse(json['addedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'discountedPrice': discountedPrice,
      'discountPercent': discountPercent,
      'rating': rating,
      'reviewCount': reviewCount,
      'imageUrl': imageUrl,
      'category': category,
      'stock': stock,
      'inStock': inStock,
      'status': status,
      'addedAt': addedAt?.toIso8601String(),
    };
  }

  // Helper getters
  double get currentPrice => discountedPrice ?? price;
  bool get hasDiscount => discountedPrice != null && discountedPrice! > 0 && discountedPrice! < price;
  String get formattedPrice => '₦${currentPrice.toStringAsFixed(2)}';
  String? get formattedOriginalPrice => hasDiscount ? '₦${price.toStringAsFixed(2)}' : null;
}

class WishlistStats {
  final int totalItems;
  final int inStockItems;
  final int outOfStockItems;
  final double totalValue;
  final double potentialSavings;

  WishlistStats({
    required this.totalItems,
    required this.inStockItems,
    required this.outOfStockItems,
    required this.totalValue,
    required this.potentialSavings,
  });

  factory WishlistStats.fromJson(Map<String, dynamic> json) {
    return WishlistStats(
      totalItems: json['totalItems'] as int? ?? 0,
      inStockItems: json['inStockItems'] as int? ?? 0,
      outOfStockItems: json['outOfStockItems'] as int? ?? 0,
      totalValue: (json['totalValue'] as num?)?.toDouble() ?? 0.0,
      potentialSavings: (json['potentialSavings'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalItems': totalItems,
      'inStockItems': inStockItems,
      'outOfStockItems': outOfStockItems,
      'totalValue': totalValue,
      'potentialSavings': potentialSavings,
    };
  }
}