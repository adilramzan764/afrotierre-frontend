import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../../Constants/ApiConstants.dart';
import '../../Models/BuyerModels/BuyerHomeModels.dart';
import '../../res/Widgets/CustomSnackbar.dart';

class BuyerHomeRepo {
  final String baseUrl = ApiConstants.baseUrlBuyer;
  final Map<String, String>? customHeaders;

  BuyerHomeRepo({
    this.customHeaders,
  });

  // Get default headers
  Map<String, String> _getHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?customHeaders,
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Get Home Data
  Future<HomeDataResponse> getHomeData({
    String? token,
    BuildContext? context,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/home'),
        headers: _getHeaders(token: token),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return HomeDataResponse.fromJson(data);
      } else {
        if (context != null) {
          CustomSnackbar.showError(context, data['message'] ?? 'Failed to load home data');
        }
        throw Exception(data['message'] ?? 'Failed to load home data');
      }
    } catch (e) {
      if (context != null) {
        CustomSnackbar.showError(context, 'Network error: ${e.toString()}');
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get Products with filters
  Future<ProductsResponse> getProducts({
    String? token,
    String? category,
    String? filter,
    String? search,
    double? minPrice,
    double? maxPrice,
    String sort = 'newest',
    int page = 1,
    int limit = 20,
    BuildContext? context,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{
        'sort': sort,
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (filter != null && filter.isNotEmpty) {
        queryParams['filter'] = filter;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (minPrice != null) {
        queryParams['minPrice'] = minPrice.toString();
      }
      if (maxPrice != null) {
        queryParams['maxPrice'] = maxPrice.toString();
      }

      final uri = Uri.parse('$baseUrl/products').replace(queryParameters: queryParams);
      final response = await http.get(
        uri,
        headers: _getHeaders(token: token),
      );
      print("Request URL: $uri");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print("Response Data: $data"); // Debugging log
        return ProductsResponse.fromJson(data);
      } else {
        if (context != null) {
          CustomSnackbar.showError(context, data['message'] ?? 'Failed to load products');
        }
        throw Exception(data['message'] ?? 'Failed to load products');
      }
    } catch (e) {
      if (context != null) {
        CustomSnackbar.showError(context, 'Network error: ${e.toString()}');
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get Product Details
  Future<ProductDetailsResponse> getProductDetails({
    required String productId,
    String? token,
    BuildContext? context,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/$productId'),
        headers: _getHeaders(token: token),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ProductDetailsResponse.fromJson(data);
      } else {
        if (context != null) {
          CustomSnackbar.showError(context, data['message'] ?? 'Failed to load product details');
        }
        throw Exception(data['message'] ?? 'Failed to load product details');
      }
    } catch (e) {
      if (context != null) {
        CustomSnackbar.showError(context, 'Network error: ${e.toString()}');
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Search Products
  Future<SearchResponse> searchProducts({
    required String query,
    int page = 1,
    int limit = 20,
    String? token,
    BuildContext? context,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/products/search').replace(queryParameters: {
        'q': query,
        'page': page.toString(),
        'limit': limit.toString(),
      });

      final response = await http.get(
        uri,
        headers: _getHeaders(token: token),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return SearchResponse.fromJson(data);
      } else {
        if (context != null) {
          CustomSnackbar.showError(context, data['message'] ?? 'Failed to search products');
        }
        throw Exception(data['message'] ?? 'Failed to search products');
      }
    } catch (e) {
      if (context != null) {
        CustomSnackbar.showError(context, 'Network error: ${e.toString()}');
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get Categories
  Future<CategoriesResponse> getCategories({
    String? token,
    BuildContext? context,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories'),
        headers: _getHeaders(token: token),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return CategoriesResponse.fromJson(data);
      } else {
        if (context != null) {
          CustomSnackbar.showError(context, data['message'] ?? 'Failed to load categories');
        }
        throw Exception(data['message'] ?? 'Failed to load categories');
      }
    } catch (e) {
      if (context != null) {
        CustomSnackbar.showError(context, 'Network error: ${e.toString()}');
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get Category Products
  Future<CategoryProductsResponse> getCategoryProducts({
    required String categoryId,
    int page = 1,
    int limit = 20,
    String? token,
    BuildContext? context,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/categories/$categoryId/products').replace(queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
      });

      final response = await http.get(
        uri,
        headers: _getHeaders(token: token),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return CategoryProductsResponse.fromJson(data);
      } else {
        if (context != null) {
          CustomSnackbar.showError(context, data['message'] ?? 'Failed to load category products');
        }
        throw Exception(data['message'] ?? 'Failed to load category products');
      }
    } catch (e) {
      if (context != null) {
        CustomSnackbar.showError(context, 'Network error: ${e.toString()}');
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get Filters
  Future<FiltersResponse> getFilters({
    String? token,
    BuildContext? context,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/filters'),
        headers: _getHeaders(token: token),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return FiltersResponse.fromJson(data);
      } else {
        if (context != null) {
          CustomSnackbar.showError(context, data['message'] ?? 'Failed to load filters');
        }
        throw Exception(data['message'] ?? 'Failed to load filters');
      }
    } catch (e) {
      if (context != null) {
        CustomSnackbar.showError(context, 'Network error: ${e.toString()}');
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }
}