// lib/Repositories/BuyerPanel/BuyerOrderRepository.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../Constants/ApiConstants.dart';
import '../../Models/BuyerModels/BuyerOrderModels.dart';
import '../../Services/AppSession.dart';

class BuyerOrderRepository {
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
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success'] == true) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Request failed');
      }
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
   * Create a new order
   * POST /api/buyer/orders
   */
  Future<CreateOrderResponse> createOrder(CreateOrderRequest request) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/orders');

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(request.toJson()),
      );

      print("URL: $url");
      print("Request Body: ${json.encode(request.toJson())}");
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final data = _handleResponse(response);
      return CreateOrderResponse.fromJson(data['data']);
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  /**
   * Get buyer's orders with pagination
   * GET /api/buyer/orders?page=1&limit=10
   */
  Future<OrdersListResponse> getBuyerOrders({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/orders?page=$page&limit=$limit');

      final response = await http.get(url, headers: headers);

      print('URL: $url');
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final data = _handleResponse(response);
      return OrdersListResponse.fromJson(data['data']);
    } catch (e) {
      throw Exception('Failed to get orders: $e');
    }
  }

  /**
   * Get order details by ID
   * GET /api/buyer/orders/:orderId
   */
  Future<MainOrder> getOrderDetails(String orderId) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/orders/$orderId');

      final response = await http.get(url, headers: headers);

      print('URL: $url');
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final data = _handleResponse(response);
      return MainOrder.fromJson(data['data']);
    } catch (e) {
      throw Exception('Failed to get order details: $e');
    }
  }

  /**
   * Get tracking information for a sub-order
   * GET /api/buyer/orders/tracking/:subOrderId
   */
  Future<TrackingInfoResponse> getTrackingInfo(String subOrderId) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/orders/tracking/$subOrderId');

      final response = await http.get(url, headers: headers);

      final data = _handleResponse(response);
      return TrackingInfoResponse.fromJson(data['data']);
    } catch (e) {
      throw Exception('Failed to get tracking information: $e');
    }
  }
}

// Helper service to get auth token
class BuyerSessionService {
  Future<String?> getAuthToken() async {
    await AppSession.ensureInitialized();
    return AppSession.instance.authToken;
  }
}