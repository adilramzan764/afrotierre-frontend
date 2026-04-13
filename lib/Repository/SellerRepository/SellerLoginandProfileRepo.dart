// lib/repositories/seller_auth_repository.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../../Constants/ApiConstants.dart';
import '../../Models/SellerModels/SellerLoginandProfleModels.dart';

class SellerLoginandProfileRepo {
  final http.Client client;

  SellerLoginandProfileRepo({
    http.Client? client,
  }) : client = client ?? http.Client();

  // Helper method to build full URL
  String _buildUrl(String endpoint) {
    return '${ApiConstants.baseUrlSeller}$endpoint';
  }



  // Login Seller
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final request = LoginRequest(
        email: email,
        password: password,
      );

      final response = await client.post(
        Uri.parse(_buildUrl(ApiConstants.login)),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return AuthResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return AuthResponse(
          success: false,
          message: errorData['message'] ?? 'Login failed',
          errors: errorData['errors'] != null
              ? _parseErrors(errorData['errors'])
              : null,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error logging in: $e');
      }
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }


  // Check token validity
  Future<TokenCheckResponse> checkTokenValidity(String token) async {
    try {
      final response = await client.get(
        Uri.parse(_buildUrl(ApiConstants.checkToken)),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return TokenCheckResponse.fromJson(data);
      } else {
        return TokenCheckResponse(
          success: false,
          isValid: false,
          message: 'Invalid or expired token',
          expiresIn: 0,
          isAboutToExpire: false,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking token validity: $e');
      }
      return TokenCheckResponse(
        success: false,
        isValid: false,
        message: 'Network error: ${e.toString()}',
        expiresIn: 0,
        isAboutToExpire: false,
      );
    }
  }

  // Get current registration step
  Future<RegistrationStepResponse> getRegistrationStep(String token) async {
    try {
      final response = await client.get(
        Uri.parse(_buildUrl(ApiConstants.getRegistrationStep)),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return RegistrationStepResponse.fromJson(data);
      } else {
        return RegistrationStepResponse(
          success: false,
          message: 'Failed to get registration step',
          registrationStep: '',
          isEmailVerified: false,
          hasStoreDetails: false,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting registration step: $e');
      }
      return RegistrationStepResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        registrationStep: '',
        isEmailVerified: false,
        hasStoreDetails: false,
      );
    }
  }

  // Get seller profile
  Future<AuthResponse> getProfile(String token) async {
    try {
      final response = await client.get(
        Uri.parse(_buildUrl(ApiConstants.getProfile)),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return AuthResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return AuthResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to get profile',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting profile: $e');
      }
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Update seller profile
  Future<AuthResponse> updateProfile({
    required String token,
    required UpdateProfileRequest request,
    bool includeLogo = false,
  }) async {
    try {
      var uri = Uri.parse(_buildUrl(ApiConstants.updateProfile));

      if (includeLogo && request.logoPath != null) {
        // Multipart request for file upload
        var multipartRequest = http.MultipartRequest('PUT', uri);

        multipartRequest.headers['Authorization'] = 'Bearer $token';

        // Add text fields
        if (request.storeName != null) {
          multipartRequest.fields['storeName'] = request.storeName!;
        }
        if (request.phoneNumber != null) {
          multipartRequest.fields['phoneNumber'] = request.phoneNumber!;
        }
        if (request.businessEmail != null) {
          multipartRequest.fields['businessEmail'] = request.businessEmail!;
        }
        if (request.category != null) {
          for (int i = 0; i < request.category!.length; i++) {
            multipartRequest.fields['category[$i]'] = request.category![i];
          }
        }
        if (request.storeDescription != null) {
          multipartRequest.fields['storeDescription'] = request.storeDescription!;
        }

        if (request.logoPath != null) {
          final file = File(request.logoPath!);
          if (await file.exists()) {
            final mimeTypeData = lookupMimeType(file.path)?.split('/');
            var logoFile = await http.MultipartFile.fromPath(
              'logo',
              file.path,
              contentType: mimeTypeData != null
                  ? http.MediaType(mimeTypeData[0], mimeTypeData[1])
                  : http.MediaType('image', 'jpeg'),
            );
            multipartRequest.files.add(logoFile);
          }
        }

        var streamedResponse = await multipartRequest.send();
        var response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          return AuthResponse.fromJson(data);
        } else {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          return AuthResponse(
            success: false,
            message: errorData['message'] ?? 'Failed to update profile',
          );
        }
      } else {
        final response = await client.put(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(request.toJson()),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          return AuthResponse.fromJson(data);
        } else {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          return AuthResponse(
            success: false,
            message: errorData['message'] ?? 'Failed to update profile',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating profile: $e');
      }
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Helper method to parse errors from backend
  List<String> _parseErrors(dynamic errors) {
    List<String> errorMessages = [];

    if (errors is List) {
      for (var error in errors) {
        if (error is Map) {
          if (error['msg'] != null) {
            errorMessages.add(error['msg']);
          } else if (error['message'] != null) {
            errorMessages.add(error['message']);
          }
        } else if (error is String) {
          errorMessages.add(error);
        }
      }
    } else if (errors is Map) {
      if (errors['msg'] != null) {
        errorMessages.add(errors['msg']);
      } else if (errors['message'] != null) {
        errorMessages.add(errors['message']);
      }
    } else if (errors is String) {
      errorMessages.add(errors);
    }

    return errorMessages;
  }

  // Helper method to validate password (client-side validation)
  PasswordValidation validatePassword(String password) {
    final List<String> errors = [];

    if (password.length < 8) {
      errors.add('Password must be at least 8 characters long');
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      errors.add('Password must contain at least one uppercase letter');
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      errors.add('Password must contain at least one lowercase letter');
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      errors.add('Password must contain at least one number');
    }
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      errors.add('Password must contain at least one special character');
    }

    return PasswordValidation(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  void dispose() {
    client.close();
  }
}