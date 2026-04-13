// lib/Models/SellerModels/ProductModels.dart

class ProductImage {
  final String id;        // 🔥 add this
  final String url;
  final String publicId;
  final bool isMain;      // 🔥 add this

  ProductImage({
    required this.id,
    required this.url,
    required this.publicId,
    required this.isMain,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['_id'] ?? '',
      url: json['url'] ?? '',
      publicId: json['publicId'] ?? '',
      isMain: json['isMain'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'url': url,
    'publicId': publicId,
    'isMain': isMain,
  };
}

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountedPrice;
  final int stock;
  final String category;
  final List<String> colors;
  final Map<String, dynamic> attributes;
  final List<String> sizes;
  final List<String> materials;
  final List<ProductImage> images;
  final String image;
  final String seller;
  final bool draft;
  final String status;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountedPrice,
    required this.stock,
    required this.category,
    required this.colors,
    required this.attributes,
    required this.sizes,
    required this.materials,
    required this.images,
    required this.image,
    required this.seller,
    required this.draft,
    required this.status,
    this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      discountedPrice: json['discountedPrice'] != null
          ? (json['discountedPrice']).toDouble()
          : null,
      stock: json['stock'] ?? 0,
      category: json['category'] ?? '',
      colors: json['colors'] != null
          ? List<String>.from(json['colors'])
          : [],
      attributes: json['attributes'] != null
          ? Map<String, dynamic>.from(json['attributes'])
          : {},
      sizes: json['sizes'] != null
          ? List<String>.from(json['sizes'])
          : [],
      materials: json['materials'] != null
          ? List<String>.from(json['materials'])
          : [],
      images: json['images'] != null
          ? (json['images'] as List).map((img) => ProductImage.fromJson(img)).toList()
          : [],
      image: json['image'] ?? 'assets/stock_image.png',
      seller: json['seller'] ?? '',
      draft: json['draft'] ?? false,
      status: json['status'] ?? 'Draft',
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'description': description,
    'price': price,
    'discountedPrice': discountedPrice,
    'stock': stock,
    'category': category,
    'colors': colors,
    'attributes': attributes,
    'sizes': sizes,
    'materials': materials,
    'images': images.map((img) => img.toJson()).toList(),
    'image': image,
    'seller': seller,
    'draft': draft,
    'status': status,
    'publishedAt': publishedAt?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  // Helper getters
  bool get isInStock => status == 'In Stock';
  bool get isLowStock => status == 'Low Stock';
  bool get isOutOfStock => status == 'Out of Stock';
  bool get isDiscontinued => status == 'Discontinued';
  bool get isPublished => !draft;
  double get finalPrice => discountedPrice ?? price;
  double get discountPercent {
    if (discountedPrice == null || price == 0) return 0;
    return ((price - discountedPrice!) / price * 100).roundToDouble();
  }
}

class CreateProductRequest {
  final String name;
  final String description;
  final double price;
  final double? discountedPrice;
  final int stock;
  final String category;
  final List<String> colors;
  final Map<String, dynamic> attributes;
  final List<String> sizes;
  final List<String> materials;
  final String? status;
  final String? image;
  final bool draft;

  CreateProductRequest({
    required this.name,
    required this.description,
    required this.price,
    this.discountedPrice,
    required this.stock,
    required this.category,
    required this.colors,
    required this.attributes,
    required this.sizes,
    required this.materials,
    this.status,
    this.image,
    this.draft = true,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'price': price,
    if (discountedPrice != null) 'discountedPrice': discountedPrice,
    'stock': stock,
    'category': category,
    'colors': colors,
    'attributes': attributes,
    'sizes': sizes,
    'materials': materials,
    if (status != null) 'status': status,
    if (image != null) 'image': image,
    'draft': draft,
  };
}

class UpdateProductRequest {
  String? name;
  String? description;
  double? price;
  double? discountedPrice;
  int? stock;
  String? category;
  List<String>? colors;
  Map<String, dynamic>? attributes;
  List<String>? sizes;
  List<String>? materials;
  String? status;
  String? image;

  UpdateProductRequest({
    this.name,
    this.description,
    this.price,
    this.discountedPrice,
    this.stock,
    this.category,
    this.colors,
    this.attributes,
    this.sizes,
    this.materials,
    this.status,
    this.image,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (description != null) map['description'] = description;
    if (price != null) map['price'] = price;
    if (discountedPrice != null) map['discountedPrice'] = discountedPrice;
    if (stock != null) map['stock'] = stock;
    if (category != null) map['category'] = category;
    if (colors != null) map['colors'] = colors;
    if (attributes != null) map['attributes'] = attributes;
    if (sizes != null) map['sizes'] = sizes;
    if (materials != null) map['materials'] = materials;
    if (status != null) map['status'] = status;
    if (image != null) map['image'] = image;
    return map;
  }
}

class UpdateStockRequest {
  final int stock;

  UpdateStockRequest({required this.stock});

  Map<String, dynamic> toJson() => {'stock': stock};
}

class ProductResponse {
  final bool success;
  final String message;
  final Product? product;
  final List<Product>? products;
  final PaginationInfo? pagination;
  final String? error;

  ProductResponse({
    required this.success,
    required this.message,
    this.product,
    this.products,
    this.pagination,
    this.error,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      product: json['product'] != null
          ? Product.fromJson(json['product'])
          : null,
      products: json['products'] != null
          ? (json['products'] as List).map((p) => Product.fromJson(p)).toList()
          : null,
      pagination: json['pagination'] != null
          ? PaginationInfo.fromJson(json['pagination'])
          : null,
      error: json['error'],
    );
  }
}

class PaginationInfo {
  final int page;
  final int limit;
  final int total;
  final int pages;

  PaginationInfo({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      pages: json['pages'] ?? 0,
    );
  }
}

class ProductStatsResponse {
  final bool success;
  final String message;
  final ProductStats? stats;
  final String? error;

  ProductStatsResponse({
    required this.success,
    required this.message,
    this.stats,
    this.error,
  });

  factory ProductStatsResponse.fromJson(Map<String, dynamic> json) {
    return ProductStatsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      stats: json['stats'] != null
          ? ProductStats.fromJson(json['stats'])
          : null,
      error: json['error'],
    );
  }
}

class ProductStats {
  final int total;
  final int drafts;
  final int published;
  final int inStock;
  final int lowStock;
  final int outOfStock;
  final int discontinued;
  final List<CategoryCount> categories;
  final List<String> allowedCategories;

  ProductStats({
    required this.total,
    required this.drafts,
    required this.published,
    required this.inStock,
    required this.lowStock,
    required this.outOfStock,
    required this.discontinued,
    required this.categories,
    required this.allowedCategories,
  });

  factory ProductStats.fromJson(Map<String, dynamic> json) {
    return ProductStats(
      total: json['total'] ?? 0,
      drafts: json['drafts'] ?? 0,
      published: json['published'] ?? 0,
      inStock: json['inStock'] ?? 0,
      lowStock: json['lowStock'] ?? 0,
      outOfStock: json['outOfStock'] ?? 0,
      discontinued: json['discontinued'] ?? 0,
      categories: json['categories'] != null
          ? (json['categories'] as List).map((c) => CategoryCount.fromJson(c)).toList()
          : [],
      allowedCategories: json['allowedCategories'] != null
          ? List<String>.from(json['allowedCategories'])
          : [],
    );
  }
}

class CategoryCount {
  final String id;
  final int count;

  CategoryCount({required this.id, required this.count});

  factory CategoryCount.fromJson(Map<String, dynamic> json) {
    return CategoryCount(
      id: json['_id'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class SellerCategoriesResponse {
  final bool success;
  final List<String> categories;
  final bool hasCategories;
  final String message;
  final String? error;

  SellerCategoriesResponse({
    required this.success,
    required this.categories,
    required this.hasCategories,
    required this.message,
    this.error,
  });

  factory SellerCategoriesResponse.fromJson(Map<String, dynamic> json) {
    return SellerCategoriesResponse(
      success: json['success'] ?? false,
      categories: json['categories'] != null
          ? List<String>.from(json['categories'])
          : [],
      hasCategories: json['hasCategories'] ?? false,
      message: json['message'] ?? '',
      error: json['error'],
    );
  }
}

// Enum for product status
enum ProductStatus {
  inStock('In Stock'),
  lowStock('Low Stock'),
  outOfStock('Out of Stock'),
  discontinued('Discontinued');

  final String value;
  const ProductStatus(this.value);

  static ProductStatus fromString(String value) {
    switch (value) {
      case 'In Stock':
        return ProductStatus.inStock;
      case 'Low Stock':
        return ProductStatus.lowStock;
      case 'Out of Stock':
        return ProductStatus.outOfStock;
      case 'Discontinued':
        return ProductStatus.discontinued;
      default:
        return ProductStatus.outOfStock;
    }
  }
}