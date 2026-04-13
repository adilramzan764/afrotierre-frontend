// lib/Repository/BuyerRepository/BuyerPaymentRepository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../Constants/ApiConstants.dart';
import '../../Constants/StripeKeys.dart';
import '../../Services/AppSession.dart';

class BuyerPaymentRepository {
  static const String baseUrl = ApiConstants.baseUrlBuyer;


  // Get auth token from AppSession
  static Future<String?> _getAuthToken() async {
    // Make sure AppSession is initialized
    await AppSession.ensureInitialized();
    return AppSession.instance.authToken;
  }

  // Setup customer and get client secret
  static Future<Map<String, dynamic>> setupCustomer() async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/payment/setup-customer'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Setup customer response: ${response.statusCode}');
      print('Setup customer body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['data'] as Map<String, dynamic>;
      } else {
        final Map<String, dynamic> error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to setup customer');
      }
    } catch (e) {
      print('Setup customer error: $e');
      rethrow;
    }
  }

  // Add payment method to customer
  static Future<Map<String, dynamic>> addPaymentMethod({
    required String paymentMethodId,
    required bool setAsDefault,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/payment/add-payment-method'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'paymentMethodId': paymentMethodId,
          'setAsDefault': setAsDefault,
        }),
      );

      print('Add payment method response: ${response.statusCode}');
      print('Add payment method body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['data'] as Map<String, dynamic>;
      } else {
        final Map<String, dynamic> error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to add payment method');
      }
    } catch (e) {
      print('Add payment method error: $e');
      rethrow;
    }
  }

  // Get all payment methods
  static Future<List<dynamic>> getPaymentMethods() async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        return [];
      }

      final response = await http.get(
        Uri.parse('$baseUrl/payment/payment-methods'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('Get payment methods response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['data'] as List<dynamic>;
      } else {
        return [];
      }
    } catch (e) {
      print('Get payment methods error: $e');
      return [];
    }
  }

  // Remove payment method
  static Future<void> removePaymentMethod(String paymentMethodId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/payment/payment-methods/$paymentMethodId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('Remove payment method response: ${response.statusCode}');

      if (response.statusCode != 200) {
        final Map<String, dynamic> error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to remove payment method');
      }
    } catch (e) {
      print('Remove payment method error: $e');
      rethrow;
    }
  }

  // Set default payment method
  static Future<void> setDefaultPaymentMethod(String paymentMethodId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/payment/payment-methods/$paymentMethodId/default'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('Set default payment method response: ${response.statusCode}');

      if (response.statusCode != 200) {
        final Map<String, dynamic> error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to set default payment method');
      }
    } catch (e) {
      print('Set default payment method error: $e');
      rethrow;
    }
  }

  // Create payment intent for checkout
  static Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    required String paymentMethodId,
    String currency = 'usd',
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/payment/create-payment-intent'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'amount': amount,
          'currency': currency,
          'paymentMethodId': paymentMethodId,
        }),
      );

      print('Create payment intent response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['data'] as Map<String, dynamic>;
      } else {
        final Map<String, dynamic> error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to create payment intent');
      }
    } catch (e) {
      print('Create payment intent error: $e');
      rethrow;
    }
  }
}