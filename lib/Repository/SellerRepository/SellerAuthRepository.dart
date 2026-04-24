import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';
import '../../Constants/ApiConstants.dart';
import '../../Models/SellerModels/SellerAuthModels.dart';
import '../../Models/SellerModels/SellerLoginandProfleModels.dart' show PasswordValidation, RefreshTokenRequest, RefreshTokenResponse;

class SellerAuthRepository {
  final http.Client client;

  SellerAuthRepository({
    http.Client? client,
  }) : client = client ?? http.Client();

  // Helper method to build full URL
  String _buildUrl(String endpoint) {
    return '${ApiConstants.baseUrlSeller}$endpoint';
  }

  // ==================== APPLE AUTH METHODS ====================

  Future<AuthResponse> appleAuth({
    required String identityToken,
    Map<String, String>? fullName,
    String? email,
  }) async {
    try {
      final request = AppleAuthRequest(
        identityToken: identityToken,
        fullName: fullName,
        email: email,
      );

      final response = await client.post(
        Uri.parse(_buildUrl(ApiConstants.appleAuth)),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      print('URL: ${_buildUrl(ApiConstants.appleAuth)}');
      print('Request Body: ${jsonEncode(request.toJson())}');
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return AuthResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return AuthResponse(
          success: false,
          message: errorData['message'] ?? 'Apple authentication failed',
          errors: errorData['errors'] != null
              ? _parseErrors(errorData['errors'])
              : null,
          useAppleAuth: errorData['useAppleAuth'],
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error with Apple auth: $e');
      }
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<AuthResponse> linkAppleAccount({
    required String token,
    required String identityToken,
    Map<String, String>? fullName,
  }) async {
    try {
      final request = LinkAppleRequest(
        identityToken: identityToken,
        fullName: fullName,
      );

      final response = await client.post(
        Uri.parse(_buildUrl(ApiConstants.linkApple)),
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
          message: errorData['message'] ?? 'Failed to link Apple account',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error linking Apple account: $e');
      }
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<AuthResponse> unlinkAppleAccount({
    required String token,
  }) async {
    try {
      final response = await client.post(
        Uri.parse(_buildUrl(ApiConstants.unlinkApple)),
        headers: {
          'Content-Type': 'application/json',
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
          message: errorData['message'] ?? 'Failed to unlink Apple account',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error unlinking Apple account: $e');
      }
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // ==================== GOOGLE AUTH METHODS ====================

  Future<AuthResponse> googleAuth({
    required String idToken,
  }) async {
    try {
      final request = GoogleAuthRequest(idToken: idToken);

      final response = await client.post(
        Uri.parse(_buildUrl(ApiConstants.googleAuth)),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      print('URL: ${_buildUrl(ApiConstants.googleAuth)}');
      print('Request Body: ${jsonEncode(request.toJson())}');
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return AuthResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return AuthResponse(
          success: false,
          message: errorData['message'] ?? 'Google authentication failed',
          errors: errorData['errors'] != null
              ? _parseErrors(errorData['errors'])
              : null,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error with Google auth: $e');
      }
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<AuthResponse> linkGoogleAccount({
    required String token,
    required String idToken,
  }) async {
    try {
      final request = LinkGoogleRequest(idToken: idToken);

      final response = await client.post(
        Uri.parse(_buildUrl(ApiConstants.linkGoogle)),
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
          message: errorData['message'] ?? 'Failed to link Google account',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error linking Google account: $e');
      }
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<AuthResponse> unlinkGoogleAccount({
    required String token,
  }) async {
    try {
      final response = await client.post(
        Uri.parse(_buildUrl(ApiConstants.unlinkGoogle)),
        headers: {
          'Content-Type': 'application/json',
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
          message: errorData['message'] ?? 'Failed to unlink Google account',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error unlinking Google account: $e');
      }
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // ==================== PICKUP ADDRESS METHODS ====================

  Future<AuthResponse> addPickupAddress({
    required String token,
    required PickupAddressRequest request,
  }) async {
    try {
      final response = await client.post(
        Uri.parse(_buildUrl(ApiConstants.addPickupAddress)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      print('URL: ${_buildUrl(ApiConstants.addPickupAddress)}');
      print('Request Body: ${jsonEncode(request.toJson())}');
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return AuthResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);

        // Parse detailed validation errors
        List<String> detailedErrors = [];
        String validationSource = '';
        bool needsCorrection = false;
        Map<String, dynamic>? suggestedAddress;

        // Check for validation errors structure
        if (errorData['errors'] != null) {
          if (errorData['errors'] is List) {
            detailedErrors = List<String>.from(errorData['errors']);
          } else if (errorData['errors'] is String) {
            detailedErrors = [errorData['errors']];
          }
        }

        // Get validation source if available
        if (errorData['validationSource'] != null) {
          validationSource = errorData['validationSource'];
        }

        // Check if needs correction
        if (errorData['needsCorrection'] != null) {
          needsCorrection = errorData['needsCorrection'];
        }

        // Get suggested address if available
        if (errorData['suggestedAddress'] != null || errorData['validatedAddress'] != null) {
          suggestedAddress = errorData['suggestedAddress'] ?? errorData['validatedAddress'];
        }

        // Get original address for context
        Map<String, dynamic>? originalAddress;
        if (errorData['address'] != null) {
          originalAddress = errorData['address'];
        }

        return AuthResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to add pickup address',
          errors: detailedErrors.isNotEmpty ? detailedErrors : null,
          validationSource: validationSource,
          needsCorrection: needsCorrection,
          suggestedAddress: suggestedAddress,
          originalAddress: originalAddress,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding pickup address: $e');
      }
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<List<PickupAddressModel>> getPickupAddresses(String token) async {
    try {
      final response = await client.get(
        Uri.parse(_buildUrl(ApiConstants.getPickupAddresses)),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['pickupAddresses'] != null) {
          return (data['pickupAddresses'] as List)
              .map((addr) => PickupAddressModel.fromJson(addr))
              .toList();
        }
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error getting pickup addresses: $e');
      }
      return [];
    }
  }

  // ==================== EXISTING AUTH METHODS ====================

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

  Future<AuthResponse> submitStoreDetails({
    required String token,
    required StoreDetailsRequest request,
    bool includeLogo = false,
  }) async {
    try {
      var uri = Uri.parse(_buildUrl(ApiConstants.submitStoreDetails));

      if (includeLogo && request.logoPath != null) {
        var multipartRequest = http.MultipartRequest('POST', uri);

        multipartRequest.headers['Authorization'] = 'Bearer $token';

        multipartRequest.fields['storeName'] = request.storeName;
        multipartRequest.fields['phoneNumber'] = request.phoneNumber;
        multipartRequest.fields['businessEmail'] = request.businessEmail;

        for (int i = 0; i < request.category.length; i++) {
          multipartRequest.fields['category[$i]'] = request.category[i];
        }

        multipartRequest.fields['storeDescription'] = request.storeDescription;

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

        if (response.statusCode == 200 || response.statusCode == 201) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          return AuthResponse.fromJson(data);
        } else {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
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
      } else {
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

  Future<AuthResponse> checkTokenValidity(String token) async {
    try {
      final response = await client.get(
        Uri.parse(_buildUrl(ApiConstants.checkToken)),
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

  Future<RefreshTokenResponse> refreshToken(RefreshTokenRequest request) async {
    try {
      final response = await client.post(
        Uri.parse(_buildUrl(ApiConstants.refreshToken)),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return RefreshTokenResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return RefreshTokenResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to refresh token',
          token: '',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error refreshing token: $e');
      }
      return RefreshTokenResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        token: '',
      );
    }
  }

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

    return PasswordValidation(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  void dispose() {
    client.close();
  }
}