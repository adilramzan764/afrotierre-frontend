// lib/repositories/seller_auth_repository.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';
import '../../Constants/ApiConstants.dart';
import '../../Models/SellerModels/SellerAuthModels.dart';


class SellerAuthRepository {
  final http.Client client;

  SellerAuthRepository({
    http.Client? client,
  }) : client = client ?? http.Client();

  // Helper method to build full URL
  String _buildUrl(String endpoint) {
    return '${ApiConstants.baseUrlSeller}$endpoint';
  }

  // Step 1: Create Wallet (Sign Up with Email & Password)
  Future<AuthResponse> createWallet({
    required String email,
    required String password,
  }) async {
    try {
      final request = CreateWalletRequest(
        email: email,
        password: password,
      );

      final response = await client.post(
        Uri.parse(_buildUrl(ApiConstants.createWallet)),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return AuthResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return AuthResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to create wallet',
          errors: errorData['errors'] != null
              ? List<String>.from(errorData['errors'])
              : null,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating wallet: $e');
      }
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Step 2: Verify Email with OTP
  Future<AuthResponse> verifyEmail({
    required String email,
    required String otp,
  }) async {
    try {
      final request = VerifyEmailRequest(
        email: email,
        otp: otp,
      );

      final response = await client.post(
        Uri.parse(_buildUrl(ApiConstants.verifyEmail)),
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
          message: errorData['message'] ?? 'Failed to verify email',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error verifying email: $e');
      }
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Resend OTP
  Future<AuthResponse> resendOTP({
    required String email,
  }) async {
    try {
      final request = ResendOTPRequest(email: email);

      final response = await client.post(
        Uri.parse(_buildUrl(ApiConstants.resendOTP)),
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
          message: errorData['message'] ?? 'Failed to resend OTP',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error resending OTP: $e');
      }
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Step 3: Submit Store Details (with optional logo upload)
  Future<AuthResponse> submitStoreDetails({
    required String token,
    required StoreDetailsRequest request,
    bool includeLogo = false,
  }) async {
    try {
      var uri = Uri.parse(_buildUrl(ApiConstants.submitStoreDetails));

      if (includeLogo && request.logoPath != null) {
        // Multipart request for file upload
        var multipartRequest = http.MultipartRequest('POST', uri);

        // Add headers
        multipartRequest.headers['Authorization'] = 'Bearer $token';

        // Add text fields
        multipartRequest.fields['storeName'] = request.storeName;
        multipartRequest.fields['phoneNumber'] = request.phoneNumber;
        multipartRequest.fields['businessEmail'] = request.businessEmail;

        // Send categories as array
        for (int i = 0; i < request.category.length; i++) {
          multipartRequest.fields['category[$i]'] = request.category[i];
        }

        multipartRequest.fields['storeDescription'] = request.storeDescription;

        if (request.logoPath != null) {
          final file = File(request.logoPath!);

          if (!await file.exists()) {
            throw Exception("File not found");
          }

          final mimeTypeData = lookupMimeType(file.path)?.split('/');

          var logoFile = await http.MultipartFile.fromPath(
            'logo',
            file.path,
            contentType: mimeTypeData != null
                ? http.MediaType(mimeTypeData[0], mimeTypeData[1])
                : http.MediaType('image', 'jpeg'), // fallback
          );

          multipartRequest.files.add(logoFile);
        }

        // Send request
        var streamedResponse = await multipartRequest.send();
        var response = await http.Response.fromStream(streamedResponse);

        print("STATUS: ${response.statusCode}");
        print("BODY: ${response.body}");

        if (response.statusCode == 200 || response.statusCode == 201) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          return AuthResponse.fromJson(data);
        } else {
          final Map<String, dynamic> errorData = jsonDecode(response.body);

          // Parse validation errors
          String errorMessage = errorData['message'] ?? 'Failed to submit store details';

          // Check for detailed validation errors
          if (errorData['errors'] != null && errorData['errors'] is List) {
            List<dynamic> errors = errorData['errors'];
            if (errors.isNotEmpty) {
              // Get the first error message
              var firstError = errors[0];
              if (firstError is Map && firstError['msg'] != null) {
                errorMessage = firstError['msg'];
              } else if (firstError is String) {
                errorMessage = firstError;
              }
            }
          }

          return AuthResponse(
            success: false,
            message: errorMessage,
            errors: errorData['errors'] != null
                ? _parseErrors(errorData['errors'])
                : null,
          );
        }
      } else {
        // Regular JSON request without file
        final response = await client.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(request.toJson()),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          return AuthResponse.fromJson(data);
        } else {
          final Map<String, dynamic> errorData = jsonDecode(response.body);

          // Parse validation errors
          String errorMessage = errorData['message'] ?? 'Failed to submit store details';

          if (errorData['errors'] != null && errorData['errors'] is List) {
            List<dynamic> errors = errorData['errors'];
            if (errors.isNotEmpty) {
              var firstError = errors[0];
              if (firstError is Map && firstError['msg'] != null) {
                errorMessage = firstError['msg'];
              } else if (firstError is String) {
                errorMessage = firstError;
              }
            }
          }

          return AuthResponse(
            success: false,
            message: errorMessage,
            errors: errorData['errors'] != null
                ? _parseErrors(errorData['errors'])
                : null,
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error submitting store details: $e');
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

  // Check token validity
  Future<AuthResponse> checkTokenValidity(String token) async {
    try {
      final response = await client.get(
        Uri.parse(_buildUrl('/auth/check-token')), // You might need to add this endpoint to ApiConstants
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return AuthResponse.fromJson(data);
      } else {
        return AuthResponse(
          success: false,
          message: 'Invalid or expired token',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking token validity: $e');
      }
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
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