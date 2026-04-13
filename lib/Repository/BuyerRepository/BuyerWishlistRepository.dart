// lib/Repository/BuyerRepository/BuyerWishlistRepository.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../Constants/ApiConstants.dart';
import '../../Models/BuyerModels/BuyerHomeModels.dart';
import '../../Models/BuyerModels/BuyerWishListModels.dart';
import '../../Services/AppSession.dart';


class WishlistRepository {
  final http.Client _client = http.Client();
  final AppSession _appSession = AppSession.instance;

  Future<Map<String, String>> _getHeaders() async {
    final token = await _appSession.getValidToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get user's wishlist
  Future<WishlistResponse> getWishlist() async {
    try {
      final headers = await _getHeaders();
      final response = await _client.get(
        Uri.parse('${ApiConstants.baseUrlBuyer}/wishlist'),
        headers: headers,
      );

      print('Get Wishlist Response Status: ${response.statusCode}');
      print('Get Wishlist Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return WishlistResponse.fromJson(jsonData);
      } else {
        final errorData = json.decode(response.body);
        return WishlistResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to load wishlist',
          error: errorData['error'],
        );
      }
    } catch (e) {
      print('Error in getWishlist: $e');
      return WishlistResponse(
        success: false,
        message: e.toString(),
        error: e.toString(),
      );
    }
  }

  // Add product to wishlist
  Future<WishlistResponse> addToWishlist(String productId) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.post(
        Uri.parse('${ApiConstants.baseUrlBuyer}/wishlist/$productId'),
        headers: headers,
      );

      print('Add to Wishlist Response Status: ${response.statusCode}');
      print('Add to Wishlist Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('✅ Successfully added to wishlist');
        return WishlistResponse.fromJson(jsonData);
      } else {
        final errorData = json.decode(response.body);
        print('❌ Failed to add to wishlist: ${errorData['message']}');
        return WishlistResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to add to wishlist',
          error: errorData['error'],
        );
      }
    } catch (e) {
      print('❌ Exception in addToWishlist: $e');
      return WishlistResponse(
        success: false,
        message: e.toString(),
        error: e.toString(),
      );
    }
  }

  // Remove product from wishlist
  Future<WishlistResponse> removeFromWishlist(String productId) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.delete(
        Uri.parse('${ApiConstants.baseUrlBuyer}/wishlist/$productId'),
        headers: headers,
      );

      print('Remove from Wishlist Response Status: ${response.statusCode}');
      print('Remove from Wishlist Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('✅ Successfully removed from wishlist');
        return WishlistResponse.fromJson(jsonData);
      } else {
        final errorData = json.decode(response.body);
        print('❌ Failed to remove from wishlist: ${errorData['message']}');
        return WishlistResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to remove from wishlist',
          error: errorData['error'],
        );
      }
    } catch (e) {
      print('❌ Exception in removeFromWishlist: $e');
      return WishlistResponse(
        success: false,
        message: e.toString(),
        error: e.toString(),
      );
    }
  }

  // Check if product is in wishlist
  Future<WishlistStatusResponse> checkWishlistStatus(String productId) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.get(
        Uri.parse('${ApiConstants.baseUrlBuyer}/wishlist/check/$productId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return WishlistStatusResponse.fromJson(jsonData);
      } else {
        final errorData = json.decode(response.body);
        return WishlistStatusResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to check wishlist status',
          error: errorData['error'],
        );
      }
    } catch (e) {
      return WishlistStatusResponse(
        success: false,
        message: e.toString(),
        error: e.toString(),
      );
    }
  }

  // Clear entire wishlist
  Future<WishlistResponse> clearWishlist() async {
    try {
      final headers = await _getHeaders();
      final response = await _client.delete(
        Uri.parse('${ApiConstants.baseUrlBuyer}/wishlist'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return WishlistResponse.fromJson(jsonData);
      } else {
        final errorData = json.decode(response.body);
        return WishlistResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to clear wishlist',
          error: errorData['error'],
        );
      }
    } catch (e) {
      return WishlistResponse(
        success: false,
        message: e.toString(),
        error: e.toString(),
      );
    }
  }
  Future<MoveToCartResponse> moveSingleToCart(String productId) async {
    return moveToCart([productId]);
  }
  // Move wishlist items to cart
  Future<MoveToCartResponse> moveToCart(List<String> productIds) async {
    try {
      final headers = await _getHeaders();
      final response = await _client.post(
        Uri.parse('${ApiConstants.baseUrlBuyer}/wishlist/move-to-cart'),
        headers: headers,
        body: json.encode({'productIds': productIds}),
      );

      print('Move to Cart Response Status: ${response.statusCode}');
      print('Move to Cart Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return MoveToCartResponse.fromJson(jsonData);
      } else {
        final errorData = json.decode(response.body);
        return MoveToCartResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to move items to cart',
          error: errorData['error'],
        );
      }
    } catch (e) {
      return MoveToCartResponse(
        success: false,
        message: e.toString(),
        error: e.toString(),
      );
    }
  }

  void dispose() {
    _client.close();
  }
}

class WishlistStatusResponse {
  final bool success;
  final WishlistStatusData? data;
  final String? message;
  final String? error;

  WishlistStatusResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
  });

  factory WishlistStatusResponse.fromJson(Map<String, dynamic> json) {
    return WishlistStatusResponse(
      success: json['success'] as bool,
      data: json['data'] != null ? WishlistStatusData.fromJson(json['data']) : null,
      message: json['message'] as String?,
      error: json['error'] as String?,
    );
  }
}

class WishlistStatusData {
  final String productId;
  final bool isWishlisted;

  WishlistStatusData({
    required this.productId,
    required this.isWishlisted,
  });

  factory WishlistStatusData.fromJson(Map<String, dynamic> json) {
    return WishlistStatusData(
      productId: json['productId']?.toString() ?? '',
      isWishlisted: json['isWishlisted'] ?? false,
    );
  }
}

class MoveToCartResponse {
  final bool success;
  final MoveToCartData? data;
  final String? message;
  final String? error;

  MoveToCartResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
  });

  factory MoveToCartResponse.fromJson(Map<String, dynamic> json) {
    return MoveToCartResponse(
      success: json['success'] as bool,
      data: json['data'] != null ? MoveToCartData.fromJson(json['data']) : null,
      message: json['message'] as String?,
      error: json['error'] as String?,
    );
  }
}

class MoveToCartData {
  final int movedCount;
  final List<String> movedItems;
  final List<String> notFoundItems;
  final int wishlistCount;
  final int cartCount;

  MoveToCartData({
    required this.movedCount,
    required this.movedItems,
    required this.notFoundItems,
    required this.wishlistCount,
    required this.cartCount,
  });

  factory MoveToCartData.fromJson(Map<String, dynamic> json) {
    return MoveToCartData(
      movedCount: json['movedCount'] as int? ?? 0,
      movedItems: json['movedItems'] != null
          ? List<String>.from(json['movedItems'])
          : [],
      notFoundItems: json['notFoundItems'] != null
          ? List<String>.from(json['notFoundItems'])
          : [],
      wishlistCount: json['wishlistCount'] as int? ?? 0,
      cartCount: json['cartCount'] as int? ?? 0,
    );
  }
}