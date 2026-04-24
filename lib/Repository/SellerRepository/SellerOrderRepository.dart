// lib/Repository/SellerRepository/SellerOrderRepository.dart

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../Constants/ApiConstants.dart';
import '../../Models/SellerModels/SellerOrderModels.dart';
import '../../Services/AppSession.dart';

class SellerOrderRepository {
  static const String baseUrl = ApiConstants.baseUrlSeller;

  final SellerSessionService _sessionService = SellerSessionService();

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
   * Get seller's orders with pagination
   * GET /api/seller/orders?page=1&limit=10&status=shipped
   */
  Future<SellerOrdersListResponse> getSellerOrders({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final headers = await _getHeaders();
      String url = '$baseUrl/orders?page=$page&limit=$limit';
      if (status != null && status.isNotEmpty) {
        url += '&status=$status';
      }

      final response = await http.get(Uri.parse(url), headers: headers);

      print("URL: $url");
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final data = _handleResponse(response);
      return SellerOrdersListResponse.fromJson(data['data']);
    } catch (e) {
      throw Exception('Failed to get seller orders: $e');
    }
  }

  /**
   * Get single sub-order details for seller
   * GET /api/seller/orders/:subOrderId
   */
  Future<SellerSubOrder> getSubOrderDetails(String subOrderId) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/orders/$subOrderId');

      final response = await http.get(url, headers: headers);

      print("URL: $url");
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final data = _handleResponse(response);
      return SellerSubOrder.fromJson(data['data']);
    } catch (e) {
      throw Exception('Failed to get sub-order details: $e');
    }
  }

  /**
   * Update sub-order status
   * PUT /api/seller/orders/:subOrderId/status
   */
  Future<Map<String, dynamic>> updateSubOrderStatus(
      String subOrderId,
      UpdateOrderStatusRequest request,
      ) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/orders/$subOrderId/status');

      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(request.toJson()),
      );

      print("URL: $url");
      print("Request Body: ${json.encode(request.toJson())}");
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final data = _handleResponse(response);
      return {
        'success': true,
        'message': data['message'],
        'data': data['data'],
      };
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  /**
   * Get tracking information for seller's order
   * GET /api/seller/orders/:subOrderId/tracking
   */
  Future<SellerTrackingInfoResponse> getTrackingInfo(String subOrderId) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/orders/$subOrderId/tracking');

      final response = await http.get(url, headers: headers);

      print("URL: $url");
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final data = _handleResponse(response);
      return SellerTrackingInfoResponse.fromJson(data['data']);
    } catch (e) {
      throw Exception('Failed to get tracking information: $e');
    }
  }

  /**
   * Download shipping label
   * GET /api/seller/orders/:subOrderId/label
   */
  Future<Uint8List> downloadShippingLabel(String subOrderId) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/orders/$subOrderId/label');

      final response = await http.get(url, headers: headers);

      print("URL: $url");
      print("Response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to download shipping label');
      }
    } catch (e) {
      throw Exception('Failed to download shipping label: $e');
    }
  }

  /**
   * Get seller's shipping settings
   * GET /api/seller/shipping-settings
   */
  Future<ShippingSettingsResponse> getShippingSettings() async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/shipping-settings');

      final response = await http.get(url, headers: headers);

      print("URL: $url");
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final data = _handleResponse(response);
      return ShippingSettingsResponse.fromJson(data['data']);
    } catch (e) {
      throw Exception('Failed to get shipping settings: $e');
    }
  }

  /**
   * Update seller's shipping settings
   * PUT /api/seller/shipping-settings
   */
  Future<ShippingSettings> updateShippingSettings(
      UpdateShippingSettingsRequest request,
      ) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/shipping-settings');

      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(request.toJson()),
      );

      print("URL: $url");
      print("Request Body: ${json.encode(request.toJson())}");
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final data = _handleResponse(response);
      return ShippingSettings.fromJson(data['data']);
    } catch (e) {
      throw Exception('Failed to update shipping settings: $e');
    }
  }

  /**
   * Generate shipping label for an order (manual trigger)
   * POST /api/seller/orders/:subOrderId/generate-label
   */
  Future<GenerateLabelResponse> generateShippingLabel(String subOrderId) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/orders/$subOrderId/generate-label');

      final response = await http.post(url, headers: headers);

      print("URL: $url");
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final data = _handleResponse(response);
      return GenerateLabelResponse.fromJson(data);
    } catch (e) {
      throw Exception('Failed to generate shipping label: $e');
    }
  }
}

// Helper service to get auth token for seller
class SellerSessionService {
  Future<String?> getAuthToken() async {
    await AppSession.ensureInitialized();
    // Assuming you have a separate token for seller or same token
    return AppSession.instance.authToken;
  }
}