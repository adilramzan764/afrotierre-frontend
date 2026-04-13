// lib/Repository/BuyerRepository/BuyerCartRepo.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../Constants/ApiConstants.dart';
import '../../Models/BuyerModels/BuyerCartModels.dart';
import '../../res/Widgets/CustomSnackbar.dart';

class BuyerCartRepo {
  final String baseUrl = ApiConstants.baseUrlBuyer;

  Map<String, String> _getHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Add product to cart
  Future<AddToCartResponse> addToCart(
      String token,
      AddToCartRequest request, {
        BuildContext? context,
      }) async {
    try {
      final url = Uri.parse('$baseUrl${ApiConstants.addToCart}');
      print('🛒 POST Request: $url');
      print('🛒 Body: ${jsonEncode(request.toJson())}');

      final response = await http.post(
        url,
        headers: _getHeaders(token: token),
        body: jsonEncode(request.toJson()),
      );

      print('🛒 Response status: ${response.statusCode}');
      print('🛒 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (context != null && data['success'] == true) {
          print('Product added to cart successfully');

        }
        return AddToCartResponse.fromJson(data);
      } else {
        final data = jsonDecode(response.body);
        if (context != null) {
          CustomSnackbar.showError(
            context,
            data['message'] ?? 'Failed to add product to cart',
          );
        }
        throw Exception(data['message'] ?? 'Failed to add product to cart');
      }
    } catch (e) {
      if (context != null) {
        CustomSnackbar.showError(
          context,
          'Network error: ${e.toString()}',
        );
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Remove single product from cart
  Future<RemoveFromCartResponse> removeFromCart(
      String token,
      String productId, {
        BuildContext? context,
      }) async {
    try {
      final url = Uri.parse('$baseUrl${ApiConstants.removeFromCart}/$productId');
      print('🛒 DELETE Request: $url');
      print('🛒 Product ID: $productId');

      final response = await http.delete(
        url,
        headers: _getHeaders(token: token),
      );

      print('🛒 Response status: ${response.statusCode}');
      print('🛒 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (context != null && data['success'] == true) {
          CustomSnackbar.showSuccess(
            context,
            data['message'] ?? 'Product removed from cart',
          );
        }
        return RemoveFromCartResponse.fromJson(data);
      } else {
        final data = jsonDecode(response.body);
        if (context != null) {
          CustomSnackbar.showError(
            context,
            data['message'] ?? 'Failed to remove product from cart',
          );
        }
        throw Exception(data['message'] ?? 'Failed to remove product from cart');
      }
    } catch (e) {
      if (context != null) {
        CustomSnackbar.showError(
          context,
          'Network error: ${e.toString()}',
        );
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get user cart
  Future<GetCartResponse> getCart(
      String token, {
        BuildContext? context,
      }) async {
    try {
      final url = Uri.parse('$baseUrl${ApiConstants.getCart}');
      print('🛒 GET Request: $url');

      final response = await http.get(
        url,
        headers: _getHeaders(token: token),
      );

      print('🛒 Response status: ${response.statusCode}');
      print('🛒 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return GetCartResponse.fromJson(data);
      } else {
        final data = jsonDecode(response.body);
        if (context != null) {
          CustomSnackbar.showError(
            context,
            data['message'] ?? 'Failed to fetch cart',
          );
        }
        throw Exception(data['message'] ?? 'Failed to fetch cart');
      }
    } catch (e) {
      if (context != null) {
        CustomSnackbar.showError(
          context,
          'Network error: ${e.toString()}',
        );
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Update cart item quantity
  Future<AddToCartResponse> updateCartQuantity(
      String token,
      UpdateCartQuantityRequest request, {
        BuildContext? context,
      }) async {
    try {
      final url = Uri.parse('$baseUrl${ApiConstants.updateCart}');
      print('🛒 PUT Request: $url');
      print('🛒 Body: ${jsonEncode(request.toJson())}');

      final response = await http.put(
        url,
        headers: _getHeaders(token: token),
        body: jsonEncode(request.toJson()),
      );

      print('🛒 Response status: ${response.statusCode}');
      print('🛒 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (context != null && data['success'] == true) {
          print('Cart updated successfully');

        }
        return AddToCartResponse.fromJson(data);
      } else {
        final data = jsonDecode(response.body);
        if (context != null) {
          CustomSnackbar.showError(
            context,
            data['message'] ?? 'Failed to update cart',
          );
        }
        throw Exception(data['message'] ?? 'Failed to update cart');
      }
    } catch (e) {
      if (context != null) {
        CustomSnackbar.showError(
          context,
          'Network error: ${e.toString()}',
        );
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Clear entire cart
  Future<ClearCartResponse> clearCart(
      String token, {
        BuildContext? context,
      }) async {
    try {
      final url = Uri.parse('$baseUrl${ApiConstants.clearCart}');
      print('🛒 DELETE Request: $url');

      final response = await http.delete(
        url,
        headers: _getHeaders(token: token),
      );

      print('🛒 Response status: ${response.statusCode}');
      print('🛒 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (context != null && data['success'] == true) {
         print('Cart cleared successfully');
        }
        return ClearCartResponse.fromJson(data);
      } else {
        final data = jsonDecode(response.body);
        if (context != null) {
          CustomSnackbar.showError(
            context,
            data['message'] ?? 'Failed to clear cart',
          );
        }
        throw Exception(data['message'] ?? 'Failed to clear cart');
      }
    } catch (e) {
      if (context != null) {
        CustomSnackbar.showError(
          context,
          'Network error: ${e.toString()}',
        );
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }
}