// Home Data Models
class HomeDataResponse {
  final bool success;
  final HomeData data;

  HomeDataResponse({
    required this.success,
    required this.data,
  });

  factory HomeDataResponse.fromJson(Map<String, dynamic> json) {
    return HomeDataResponse(
      success: json['success'] ?? false,
      data: HomeData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }
}

class HomeData {
  final UserInfo? userInfo;
  final List<BannerItem> banners;
  final List<CategoryItem> categories;
  final List<ProductItem> flashSale;
  final List<ProductItem> newArrivals;

  HomeData({
    this.userInfo,
    required this.banners,
    required this.categories,
    required this.flashSale,
    required this.newArrivals,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      userInfo: json['userInfo'] != null
          ? UserInfo.fromJson(json['userInfo'])
          : null,
      banners: (json['banners'] as List?)
          ?.map((e) => BannerItem.fromJson(e))
          .toList() ?? [],
      categories: (json['categories'] as List?)
          ?.map((e) => CategoryItem.fromJson(e))
          .toList() ?? [],
      flashSale: (json['flashSale'] as List?)
          ?.map((e) => ProductItem.fromJson(e))
          .toList() ?? [],
      newArrivals: (json['newArrivals'] as List?)
          ?.map((e) => ProductItem.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userInfo': userInfo?.toJson(),
      'banners': banners.map((e) => e.toJson()).toList(),
      'categories': categories.map((e) => e.toJson()).toList(),
      'flashSale': flashSale.map((e) => e.toJson()).toList(),
      'newArrivals': newArrivals.map((e) => e.toJson()).toList(),
    };
  }
}

class UserInfo {
  final String fullName;
  final String? profilePicture;

  UserInfo({
    required this.fullName,
    this.profilePicture,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      fullName: json['fullName'] ?? 'Guest',
      profilePicture: json['profilePicture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'profilePicture': profilePicture,
    };
  }
}

class BannerItem {
  final String id;
  final String? tag;
  final String? title;
  final String? subtitle;
  final String? buttonText;
  final String? imageUrl;
  final String? backgroundColor;
  final String? actionType;
  final String? actionValue;

  BannerItem({
    required this.id,
    this.tag,
    this.title,
    this.subtitle,
    this.buttonText,
    this.imageUrl,
    this.backgroundColor,
    this.actionType,
    this.actionValue,
  });

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      id: json['id'] ?? '',
      tag: json['tag'],
      title: json['title'],
      subtitle: json['subtitle'],
      buttonText: json['buttonText'],
      imageUrl: json['imageUrl'],
      backgroundColor: json['backgroundColor'],
      actionType: json['actionType'],
      actionValue: json['actionValue'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tag': tag,
      'title': title,
      'subtitle': subtitle,
      'buttonText': buttonText,
      'imageUrl': imageUrl,
      'backgroundColor': backgroundColor,
      'actionType': actionType,
      'actionValue': actionValue,
    };
  }
}

class CategoryItem {
  final String id;
  final String name;
  final String? imageUrl;
  final int productCount;

  CategoryItem({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.productCount,
  });

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'],
      productCount: json['productCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'productCount': productCount,
    };
  }
}
class ProductItem {
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
  final bool isWishlisted;
  final String? status;

  ProductItem({
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
    required this.isWishlisted,
    this.status,
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
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
      isWishlisted: json['isWishlisted'] ?? false,
      status: json['status']?.toString(),
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
      'isWishlisted': isWishlisted,
      'status': status,
    };
  }

  ProductItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? discountedPrice,
    int? discountPercent,
    double? rating,
    int? reviewCount,
    String? imageUrl,
    String? category,
    int? stock,
    bool? isWishlisted,
    String? status,
  }) {
    return ProductItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      discountPercent: discountPercent ?? this.discountPercent,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      isWishlisted: isWishlisted ?? this.isWishlisted,
      status: status ?? this.status,
    );
  }

  // Helper getters
  double get currentPrice => discountedPrice ?? price;

  bool get hasDiscount => discountedPrice != null && discountedPrice! > 0 && discountedPrice! < price;

  String get formattedPrice => '₦${currentPrice.toStringAsFixed(2)}';

  String? get formattedOriginalPrice => hasDiscount ? '₦${price.toStringAsFixed(2)}' : null;

  bool get isInStock => stock > 0;
}

// Products Response Model
class ProductsResponse {
  final bool success;
  final ProductsData data;

  ProductsResponse({
    required this.success,
    required this.data,
  });

  factory ProductsResponse.fromJson(Map<String, dynamic> json) {
    return ProductsResponse(
      success: json['success'] ?? false,
      data: ProductsData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }
}

class ProductsData {
  final List<ProductItem> products;
  final Pagination pagination;

  ProductsData({
    required this.products,
    required this.pagination,
  });

  factory ProductsData.fromJson(Map<String, dynamic> json) {
    return ProductsData(
      products: (json['products'] as List?)
          ?.map((e) => ProductItem.fromJson(e))
          .toList() ?? [],
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'products': products.map((e) => e.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}

class Pagination {
  final int page;
  final int limit;
  final int total;
  final int pages;

  Pagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      total: json['total'] ?? 0,
      pages: json['pages'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'total': total,
      'pages': pages,
    };
  }

  bool get hasNextPage => page < pages;
  bool get hasPreviousPage => page > 1;
}

// Product Details Model
class ProductDetailsResponse {
  final bool success;
  final ProductDetails data;

  ProductDetailsResponse({
    required this.success,
    required this.data,
  });

  factory ProductDetailsResponse.fromJson(Map<String, dynamic> json) {
    return ProductDetailsResponse(
      success: json['success'] ?? false,
      data: ProductDetails.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }
}

class ProductDetails {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountedPrice;
  final int? discountPercent;
  final int stock;
  final String status;
  final String category;
  final List<String> colors;
  final List<String> sizes;
  final List<String> materials;
  final Map<String, dynamic>? attributes;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final String? seller;
  final bool isWishlisted;
  final List<ProductItem> similarProducts;

  ProductDetails({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountedPrice,
    this.discountPercent,
    required this.stock,
    required this.status,
    required this.category,
    required this.colors,
    required this.sizes,
    required this.materials,
    this.attributes,
    required this.images,
    required this.rating,
    required this.reviewCount,
    this.seller,
    required this.isWishlisted,
    required this.similarProducts,
  });

  factory ProductDetails.fromJson(Map<String, dynamic> json) {
    return ProductDetails(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      discountedPrice: json['discountedPrice']?.toDouble(),
      discountPercent: json['discountPercent'],
      stock: json['stock'] ?? 0,
      status: json['status'] ?? '',
      category: json['category'] ?? '',
      colors: (json['colors'] as List?)?.map((e) => e.toString()).toList() ?? [],
      sizes: (json['sizes'] as List?)?.map((e) => e.toString()).toList() ?? [],
      materials: (json['materials'] as List?)?.map((e) => e.toString()).toList() ?? [],
      attributes: json['attributes'] != null
          ? Map<String, dynamic>.from(json['attributes'])
          : null,
      images: (json['images'] as List?)?.map((e) => e.toString()).toList() ?? [],
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      seller: json['seller'],
      isWishlisted: json['isWishlisted'] ?? false,
      similarProducts: (json['similarProducts'] as List?)
          ?.map((e) => ProductItem.fromJson(e))
          .toList() ?? [],
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
      'stock': stock,
      'status': status,
      'category': category,
      'colors': colors,
      'sizes': sizes,
      'materials': materials,
      'attributes': attributes,
      'images': images,
      'rating': rating,
      'reviewCount': reviewCount,
      'seller': seller,
      'isWishlisted': isWishlisted,
      'similarProducts': similarProducts.map((e) => e.toJson()).toList(),
    };
  }

  double get currentPrice => discountedPrice ?? price;
  bool get hasDiscount => discountedPrice != null && discountedPrice! > 0;
  bool get isInStock => stock > 0;
  bool get isOutOfStock => stock <= 0;
}

// Search Response Model
class SearchResponse {
  final bool success;
  final SearchData data;

  SearchResponse({
    required this.success,
    required this.data,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    return SearchResponse(
      success: json['success'] ?? false,
      data: SearchData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }
}

class SearchData {
  final List<ProductItem> products;
  final Pagination pagination;
  final String query;

  SearchData({
    required this.products,
    required this.pagination,
    required this.query,
  });

  factory SearchData.fromJson(Map<String, dynamic> json) {
    return SearchData(
      products: (json['products'] as List?)
          ?.map((e) => ProductItem.fromJson(e))
          .toList() ?? [],
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
      query: json['query'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'products': products.map((e) => e.toJson()).toList(),
      'pagination': pagination.toJson(),
      'query': query,
    };
  }
}

// Categories Response Model
class CategoriesResponse {
  final bool success;
  final List<CategoryItem> data;

  CategoriesResponse({
    required this.success,
    required this.data,
  });

  factory CategoriesResponse.fromJson(Map<String, dynamic> json) {
    return CategoriesResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List?)
          ?.map((e) => CategoryItem.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

// Category Products Response Model
class CategoryProductsResponse {
  final bool success;
  final CategoryProductsData data;

  CategoryProductsResponse({
    required this.success,
    required this.data,
  });

  factory CategoryProductsResponse.fromJson(Map<String, dynamic> json) {
    return CategoryProductsResponse(
      success: json['success'] ?? false,
      data: CategoryProductsData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }
}

class CategoryProductsData {
  final CategoryInfo category;
  final List<ProductItem> products;
  final Pagination pagination;

  CategoryProductsData({
    required this.category,
    required this.products,
    required this.pagination,
  });

  factory CategoryProductsData.fromJson(Map<String, dynamic> json) {
    return CategoryProductsData(
      category: CategoryInfo.fromJson(json['category'] ?? {}),
      products: (json['products'] as List?)
          ?.map((e) => ProductItem.fromJson(e))
          .toList() ?? [],
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category.toJson(),
      'products': products.map((e) => e.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}

class CategoryInfo {
  final String id;
  final String name;

  CategoryInfo({
    required this.id,
    required this.name,
  });

  factory CategoryInfo.fromJson(Map<String, dynamic> json) {
    return CategoryInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

// Filters Response Model
class FiltersResponse {
  final bool success;
  final FiltersData data;

  FiltersResponse({
    required this.success,
    required this.data,
  });

  factory FiltersResponse.fromJson(Map<String, dynamic> json) {
    return FiltersResponse(
      success: json['success'] ?? false,
      data: FiltersData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }
}

class FiltersData {
  final List<String> categories;
  final PriceRange priceRange;
  final List<String> sizes;
  final List<String> colors;

  FiltersData({
    required this.categories,
    required this.priceRange,
    required this.sizes,
    required this.colors,
  });

  factory FiltersData.fromJson(Map<String, dynamic> json) {
    return FiltersData(
      categories: (json['categories'] as List?)?.map((e) => e.toString()).toList() ?? [],
      priceRange: PriceRange.fromJson(json['priceRange'] ?? {}),
      sizes: (json['sizes'] as List?)?.map((e) => e.toString()).toList() ?? [],
      colors: (json['colors'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categories': categories,
      'priceRange': priceRange.toJson(),
      'sizes': sizes,
      'colors': colors,
    };
  }
}

class PriceRange {
  final double min;
  final double max;

  PriceRange({
    required this.min,
    required this.max,
  });

  factory PriceRange.fromJson(Map<String, dynamic> json) {
    return PriceRange(
      min: (json['min'] ?? 0).toDouble(),
      max: (json['max'] ?? 1000).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'min': min,
      'max': max,
    };
  }
}