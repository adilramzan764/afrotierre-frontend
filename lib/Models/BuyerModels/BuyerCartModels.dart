// lib/Models/BuyerModels/BuyerCartModels.dart

class CartItem {
  final String id;
  final String productId;
  final int quantity;
  final DateTime addedAt;
  final CartProductDetails? productDetails;

  CartItem({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.addedAt,
    this.productDetails,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    String productIdValue = '';
    CartProductDetails? productDetailsValue;

    // Handle productId which can be either a String or a Map
    if (json['productId'] is Map<String, dynamic>) {
      final productMap = json['productId'] as Map<String, dynamic>;
      productDetailsValue = CartProductDetails.fromJson(productMap);
      productIdValue = productMap['_id'] ?? productMap['id'] ?? '';
    } else if (json['productId'] is String) {
      productIdValue = json['productId'] as String;
    }

    // Also check for separate productDetails field
    if (json['productDetails'] != null && json['productDetails'] is Map<String, dynamic>) {
      productDetailsValue = CartProductDetails.fromJson(json['productDetails']);
    }

    return CartItem(
      id: json['_id'] ?? json['id'] ?? '',
      productId: productIdValue,
      quantity: json['quantity'] ?? 1,
      addedAt: json['addedAt'] != null
          ? DateTime.tryParse(json['addedAt']) ?? DateTime.now()
          : DateTime.now(),
      productDetails: productDetailsValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'productId': productId,
      'quantity': quantity,
      'addedAt': addedAt.toIso8601String(),
      if (productDetails != null) 'productDetails': productDetails!.toJson(),
    };
  }

  CartItem copyWith({
    String? id,
    String? productId,
    int? quantity,
    DateTime? addedAt,
    CartProductDetails? productDetails,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
      productDetails: productDetails ?? this.productDetails,
    );
  }
}

class CartProductDetails {
  final String id;
  final String name;
  final double price;
  final double? discountedPrice;
  final String? imageUrl;
  final String? category;
  final int? stock;
  final double? rating;
  final int? reviewCount;
  final bool inStock;
  final String? status;

  CartProductDetails({
    required this.id,
    required this.name,
    required this.price,
    this.discountedPrice,
    this.imageUrl,
    this.category,
    this.stock,
    this.rating,
    this.reviewCount,
    required this.inStock,
    this.status,
  });

  factory CartProductDetails.fromJson(Map<String, dynamic> json) {
    // Get image URL
    String? imageUrlValue;
    if (json['image'] != null && json['image'].toString().isNotEmpty) {
      imageUrlValue = json['image'];
    } else if (json['images'] != null && json['images'] is List && json['images'].isNotEmpty) {
      final firstImage = json['images'][0];
      if (firstImage is Map<String, dynamic>) {
        imageUrlValue = firstImage['url'];
      } else if (firstImage is String) {
        imageUrlValue = firstImage;
      }
    } else if (json['imageUrl'] != null) {
      imageUrlValue = json['imageUrl'];
    }

    // Get prices
    final originalPrice = (json['price'] ?? 0).toDouble();
    double? discountPrice = json['discountedPrice']?.toDouble();

    // Calculate discount if not provided
    if (discountPrice == null && json['discountPercent'] != null) {
      final discountPercent = (json['discountPercent'] as num).toDouble();
      discountPrice = originalPrice * (1 - discountPercent / 100);
    }

    // Determine stock status
    final stockValue = json['stock'] ?? 0;
    final statusValue = json['status'] ?? '';
    final bool inStockValue = stockValue > 0 || statusValue.toLowerCase() == 'in stock';

    return CartProductDetails(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      price: originalPrice,
      discountedPrice: discountPrice,
      imageUrl: imageUrlValue,
      category: json['category'],
      stock: stockValue is int ? stockValue : int.tryParse(stockValue.toString()) ?? 0,
      rating: json['rating'] is Map
          ? (json['rating']['average'] ?? 0).toDouble()
          : (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      inStock: inStockValue,
      status: statusValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'price': price,
      if (discountedPrice != null) 'discountedPrice': discountedPrice,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (category != null) 'category': category,
      if (stock != null) 'stock': stock,
      if (rating != null) 'rating': rating,
      if (reviewCount != null) 'reviewCount': reviewCount,
      'inStock': inStock,
      if (status != null) 'status': status,
    };
  }
}

class AddToCartRequest {
  final String productId;
  final int quantity;

  AddToCartRequest({
    required this.productId,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
    };
  }
}

class AddToCartResponse {
  final bool success;
  final String message;
  final List<CartItem> cart;

  AddToCartResponse({
    required this.success,
    required this.message,
    required this.cart,
  });

  factory AddToCartResponse.fromJson(Map<String, dynamic> json) {
    return AddToCartResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      cart: (json['cart'] as List?)
          ?.map((item) => CartItem.fromJson(item))
          .toList() ?? [],
    );
  }
}

class RemoveFromCartResponse {
  final bool success;
  final String message;
  final List<CartItem> cart;

  RemoveFromCartResponse({
    required this.success,
    required this.message,
    required this.cart,
  });

  factory RemoveFromCartResponse.fromJson(Map<String, dynamic> json) {
    return RemoveFromCartResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      cart: (json['cart'] as List?)
          ?.map((item) => CartItem.fromJson(item))
          .toList() ?? [],
    );
  }
}

class GetCartResponse {
  final bool success;
  final List<CartItem> cart;

  GetCartResponse({
    required this.success,
    required this.cart,
  });

  factory GetCartResponse.fromJson(Map<String, dynamic> json) {
    return GetCartResponse(
      success: json['success'] ?? false,
      cart: (json['cart'] as List?)
          ?.map((item) => CartItem.fromJson(item))
          .toList() ?? [],
    );
  }
}

class UpdateCartQuantityRequest {
  final String productId;
  final int quantity;

  UpdateCartQuantityRequest({
    required this.productId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
    };
  }
}

class ClearCartResponse {
  final bool success;
  final String message;
  final List<CartItem> cart;

  ClearCartResponse({
    required this.success,
    required this.message,
    required this.cart,
  });

  factory ClearCartResponse.fromJson(Map<String, dynamic> json) {
    return ClearCartResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      cart: (json['cart'] as List?)
          ?.map((item) => CartItem.fromJson(item))
          .toList() ?? [],
    );
  }
}