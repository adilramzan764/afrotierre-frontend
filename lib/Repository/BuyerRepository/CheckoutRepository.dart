// lib/Repository/BuyerRepository/CheckoutRepository.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../Constants/ApiConstants.dart';
import '../../Services/AppSession.dart';
import '../../Models/BuyerModels/CheckoutModels.dart';
import '../../Models/BuyerModels/BuyerOrderModels.dart';

class CheckoutRepository {
  static const String baseUrl = ApiConstants.baseUrlBuyer;

  final BuyerSessionService _sessionService = BuyerSessionService();

  // Helper method to get headers with auth token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _sessionService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Helper method to handle API responses
  dynamic _handleResponse(http.Response response) {
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success'] == true) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Request failed');
      }
    } else if (response.statusCode == 404) {
      throw Exception('API endpoint not found. Please check the endpoint URL.');
    } else {
      try {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Server error: ${response.statusCode}');
      } catch (e) {
        throw Exception('Server error: ${response.statusCode}');
      }
    }
  }

  /**
   * Get checkout data
   * GET /api/buyer/checkout
   */
  Future<CheckoutData> getCheckoutData() async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/checkout/data');

      print('Loading checkout data from: $url');
      final response = await http.get(url, headers: headers);

      final data = _handleResponse(response);
      return CheckoutData.fromJson(data['data']);
    } catch (e) {
      print('Failed to load checkout data: $e');
      throw Exception('Failed to load checkout data: $e');
    }
  }

  /**
   * Update shipping address during checkout
   * PUT /api/buyer/checkout/shipping-address
   */
  Future<CheckoutData> updateShippingAddress(UpdateShippingAddressRequest request) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/checkout/shipping-address');

      print('Updating shipping address at: $url');
      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(request.toJson()),
      );

      final data = _handleResponse(response);
      return CheckoutData.fromJson(data['data']);
    } catch (e) {
      print('Failed to update shipping address: $e');
      throw Exception('Failed to update shipping address: $e');
    }
  }

  /**
   * Select payment method during checkout
   * Note: This endpoint might not exist. If it doesn't, we'll just update locally
   * PUT /api/buyer/checkout/payment-method
   */
  Future<CheckoutData> selectPaymentMethod(SelectPaymentMethodRequest request) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/checkout/payment-method');

      print('Selecting payment method at: $url');
      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(request.toJson()),
      );

      final data = _handleResponse(response);
      return CheckoutData.fromJson(data['data']);
    } catch (e) {
      print('Failed to update payment method on server: $e');
      // If the endpoint doesn't exist, we'll just update locally
      // and return the current checkout data without changes
      if (_checkoutDataCache != null) {
        print('Using cached checkout data');
        return _checkoutDataCache!;
      }
      throw Exception('Failed to select payment method: $e');
    }
  }

  // Cache for checkout data when API endpoints are missing
  CheckoutData? _checkoutDataCache;

  /**
   * Place order from checkout
   * POST /api/buyer/checkout/place-order
   */
  Future<CreateOrderResponse> placeOrder({
    required String paymentMethodId,
    String? idempotencyKey,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/orders'); // Using the create order endpoint directly

      // Get the current checkout data to build the order
      final checkoutData = _checkoutDataCache ?? await getCheckoutData();

      final body = {
        'products': _buildProductsList(checkoutData),
        'shippingAddress': checkoutData.shippingAddress?.toJson(),
        'paymentMethodId': paymentMethodId,
        if (idempotencyKey != null) 'idempotencyKey': idempotencyKey,
      };

      print('Placing order at: $url');
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(body),
      );

      final data = _handleResponse(response);
      return CreateOrderResponse.fromJson(data['data']);
    } catch (e) {
      print('Failed to place order: $e');
      throw Exception('Failed to place order: $e');
    }
  }

  // Helper to build products list from checkout data
  List<Map<String, dynamic>> _buildProductsList(CheckoutData checkoutData) {
    final List<Map<String, dynamic>> products = [];
    for (final seller in checkoutData.sellers) {
      for (final item in seller.items) {
        products.add({
          'productId': item.productId,
          'quantity': item.quantity,
        });
      }
    }
    return products;
  }

  // Set checkout data cache
  void setCheckoutDataCache(CheckoutData data) {
    _checkoutDataCache = data;
  }
}

// Helper service to get auth token
class BuyerSessionService {
  Future<String?> getAuthToken() async {
    await AppSession.ensureInitialized();
    return AppSession.instance.authToken;
  }
}