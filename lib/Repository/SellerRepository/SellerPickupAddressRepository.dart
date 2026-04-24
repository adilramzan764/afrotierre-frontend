// lib/Repositories/SellerPanel/SellerPickupAddressRepository.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../Constants/ApiConstants.dart';
import '../../Models/SellerModels/SellerPickupAddressModels.dart';
import '../../Services/AppSession.dart';

class SellerPickupAddressRepository {
  static const String baseUrl = ApiConstants.baseUrlSeller;

  String? get _authToken => AppSession.instance.authToken;

  // Helper method to get headers with auth token
  Future<Map<String, String>> _getHeaders() async {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_authToken',
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
      final Map<String, dynamic> errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Server error: ${response.statusCode}');
    }
  }

  /**
   * Validate an address without saving
   * POST /api/seller/pickup-addresses/validate
   */
  Future<AddressValidationResponse> validateAddress({
    required String street,
    required String city,
    required String state,
    required String zipCode,
    required String phoneNumber,
    String? addressLabel,
    String? apartment,
    String? country,
    String? company,
    String? email,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/pickup-addresses/validate');

      final body = {
        'street': street,
        'city': city,
        'state': state,
        'zipCode': zipCode,
        'phoneNumber': phoneNumber,
        if (addressLabel != null) 'addressLabel': addressLabel,
        if (apartment != null) 'apartment': apartment,
        if (country != null) 'country': country,
        if (company != null) 'company': company,
        if (email != null) 'email': email,
      };

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(body),
      );

      print('Validate address response: ${response.statusCode}');
      print('Validate address body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return AddressValidationResponse.fromJson(data);
      } else {
        return AddressValidationResponse(
          success: false,
          message: data['message'] ?? 'Address validation failed',
          errors: data['errors'] != null ? List<String>.from(data['errors']) : null,
          needsCorrection: data['needsCorrection'] ?? true,
          originalAddress: data['originalAddress'],
          suggestedAddress: data['suggestedAddress'],
        );
      }
    } catch (e) {
      throw Exception('Failed to validate address: $e');
    }
  }

  /**
   * Create a new pickup address
   * POST /api/seller/pickup-addresses
   */
  Future<PickupAddress> createPickupAddress(CreatePickupAddressRequest request) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/pickup-addresses');

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(request.toJson()),
      );
      print('Create pickup address response: ${response.statusCode}');
      print('Create pickup address body: ${response.body}');

      final data = _handleResponse(response);
      return PickupAddress.fromJson(data['data']);
    } catch (e) {
      throw Exception('Failed to create pickup address: $e');
    }
  }

  /**
   * Get all pickup addresses for a seller
   * GET /api/seller/pickup-addresses
   */
  Future<List<PickupAddress>> getPickupAddresses({bool includeInactive = false}) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/pickup-addresses?includeInactive=$includeInactive');

      final response = await http.get(url, headers: headers);

      final data = _handleResponse(response);
      final List<dynamic> addressesList = data['data'];
      return addressesList.map((json) => PickupAddress.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get pickup addresses: $e');
    }
  }

  /**
   * Get a single pickup address by ID
   * GET /api/seller/pickup-addresses/:id
   */
  Future<PickupAddress> getPickupAddressById(String id) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/pickup-addresses/$id');

      final response = await http.get(url, headers: headers);

      final data = _handleResponse(response);
      return PickupAddress.fromJson(data['data']);
    } catch (e) {
      throw Exception('Failed to get pickup address: $e');
    }
  }

  /**
   * Update a pickup address
   * PUT /api/seller/pickup-addresses/:id
   */
  Future<PickupAddress> updatePickupAddress(String id, UpdatePickupAddressRequest request) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/pickup-addresses/$id');

      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(request.toJson()),
      );

      final data = _handleResponse(response);
      return PickupAddress.fromJson(data['data']);
    } catch (e) {
      throw Exception('Failed to update pickup address: $e');
    }
  }

  /**
   * Delete a pickup address
   * DELETE /api/seller/pickup-addresses/:id
   */
  Future<void> deletePickupAddress(String id) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/pickup-addresses/$id');

      final response = await http.delete(url, headers: headers);

      _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to delete pickup address: $e');
    }
  }

  /**
   * Set a pickup address as default
   * PUT /api/seller/pickup-addresses/:id/default
   */
  Future<PickupAddress> setDefaultPickupAddress(String id) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/pickup-addresses/$id/default');

      final response = await http.put(url, headers: headers);

      final data = _handleResponse(response);
      return PickupAddress.fromJson(data['data']);
    } catch (e) {
      throw Exception('Failed to set default pickup address: $e');
    }
  }

  /**
   * Get the default pickup address for a seller
   * GET /api/seller/pickup-addresses/default
   */
  Future<PickupAddress?> getDefaultPickupAddress() async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/pickup-addresses/default');

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 404) {
        return null;
      }

      final data = _handleResponse(response);
      return PickupAddress.fromJson(data['data']);
    } catch (e) {
      // Return null if no default address found
      if (e.toString().contains('No pickup address found')) {
        return null;
      }
      throw Exception('Failed to get default pickup address: $e');
    }
  }

  /**
   * Bulk create/update pickup addresses (for onboarding)
   * POST /api/seller/pickup-addresses/bulk
   */
  Future<BulkUpdateResponse> bulkUpdatePickupAddresses(BulkAddressUpdateRequest request) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/pickup-addresses/bulk');

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(request.toJson()),
      );

      final data = _handleResponse(response);
      return BulkUpdateResponse.fromJson(data['data']);
    } catch (e) {
      throw Exception('Failed to bulk update pickup addresses: $e');
    }
  }
}