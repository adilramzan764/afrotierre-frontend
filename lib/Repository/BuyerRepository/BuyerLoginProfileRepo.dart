// lib/repositories/buyer_login_profile_repo.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../Constants/ApiConstants.dart';
import '../../Models/BuyerModels/BuyerAuthModels.dart';
import '../../Models/BuyerModels/BuyerLoginandProfileModels.dart';
import '../../res/Widgets/CustomSnackbar.dart';

class BuyerLoginProfileRepo {
  final String baseUrl = ApiConstants.baseUrlBuyer;
  final Map<String, String>? customHeaders;

  BuyerLoginProfileRepo({
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

  // Helper method to lookup MIME type
  String? _lookupMimeType(String path) {
    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  // ==================== APPLE AUTH METHODS ====================

  /// Apple Sign-In / Sign-Up for Buyers
  Future<AuthResponse> appleAuth({
    required String identityToken,
    Map<String, String>? fullName,
    String? email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiConstants.appleAuthBuyer}'),
        headers: _getHeaders(),
        body: jsonEncode({
          'identityToken': identityToken,
          if (fullName != null) 'fullName': fullName,
          if (email != null) 'email': email,
        }),
      );

      print('Apple Auth Response Status: ${response.statusCode}');
      print('Apple Auth Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponse.fromJson(data);
      } else {
        return AuthResponse(
          success: false,
          message: data['message'] ?? 'Apple authentication failed',
          useAppleAuth: data['useAppleAuth'],
        );
      }
    } catch (e) {
      print('Apple auth error: $e');
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Link Apple account to existing email/password account
  Future<AuthResponse> linkAppleAccount({
    required String token,
    required String identityToken,
    Map<String, String>? fullName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiConstants.linkAppleBuyer}'),
        headers: _getHeaders(token: token),
        body: jsonEncode({
          'identityToken': identityToken,
          if (fullName != null) 'fullName': fullName,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(data);
      } else {
        return AuthResponse(
          success: false,
          message: data['message'] ?? 'Failed to link Apple account',
        );
      }
    } catch (e) {
      print('Link Apple account error: $e');
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Unlink Apple account
  Future<AuthResponse> unlinkAppleAccount({
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiConstants.unlinkAppleBuyer}'),
        headers: _getHeaders(token: token),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(data);
      } else {
        return AuthResponse(
          success: false,
          message: data['message'] ?? 'Failed to unlink Apple account',
        );
      }
    } catch (e) {
      print('Unlink Apple account error: $e');
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // ==================== GOOGLE AUTH METHODS ====================

  /// Google Sign-In / Sign-Up for Buyers
  Future<AuthResponse> googleAuth({
    required String idToken,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiConstants.googleAuthBuyer}'),
        headers: _getHeaders(),
        body: jsonEncode({'idToken': idToken}),
      );

      print('Google Auth Response Status: ${response.statusCode}');
      print('Google Auth Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponse.fromJson(data);
      } else {
        return AuthResponse(
          success: false,
          message: data['message'] ?? 'Google authentication failed',
          useGoogleAuth: data['useGoogleAuth'],
        );
      }
    } catch (e) {
      print('Google auth error: $e');
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Link Google account to existing email/password account
  Future<AuthResponse> linkGoogleAccount({
    required String token,
    required String idToken,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiConstants.linkGoogleBuyer}'),
        headers: _getHeaders(token: token),
        body: jsonEncode({'idToken': idToken}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(data);
      } else {
        return AuthResponse(
          success: false,
          message: data['message'] ?? 'Failed to link Google account',
        );
      }
    } catch (e) {
      print('Link Google account error: $e');
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Unlink Google account
  Future<AuthResponse> unlinkGoogleAccount({
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiConstants.unlinkGoogleBuyer}'),
        headers: _getHeaders(token: token),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(data);
      } else {
        return AuthResponse(
          success: false,
          message: data['message'] ?? 'Failed to unlink Google account',
        );
      }
    } catch (e) {
      print('Unlink Google account error: $e');
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // ==================== EXISTING LOGIN METHODS ====================

  // Login buyer
  Future<BuyerLoginResponse> login(
      LoginRequest request, {
        BuildContext? context,
      }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiConstants.login}'),
        headers: _getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (context != null && data['success'] == true) {
          CustomSnackbar.showSuccess(context, data['message'] ?? 'Login successful!');
        }
        return BuyerLoginResponse.fromJson(data);
      } else {
        // Check if user should use Google Sign-In
        if (data['useGoogleAuth'] == true) {
          if (context != null) {
            CustomSnackbar.showError(
                context,
                'This account uses Google Sign-In. Please use "Continue with Google" button.'
            );
          }
        }
        // Check if user should use Apple Sign-In
        else if (data['useAppleAuth'] == true) {
          if (context != null) {
            CustomSnackbar.showError(
                context,
                'This account uses Apple Sign-In. Please use "Continue with Apple" button.'
            );
          }
        }
        else if (context != null) {
          CustomSnackbar.showError(context, data['message'] ?? 'Login failed');
        }
        throw Exception(data['message'] ?? 'Login failed');
      }
    } catch (e) {
      if (context != null) {
        CustomSnackbar.showError(context, 'Network error: ${e.toString()}');
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get buyer profile
  Future<BuyerProfile> getProfile(
      String token, {
        BuildContext? context,
      }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiConstants.getProfile}'),
        headers: _getHeaders(token: token),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return BuyerProfile.fromJson(data);
      } else {
        if (context != null) {
          CustomSnackbar.showError(context, data['message'] ?? 'Failed to fetch profile');
        }
        throw Exception(data['message'] ?? 'Failed to fetch profile');
      }
    } catch (e) {
      if (context != null) {
        CustomSnackbar.showError(context, 'Network error: ${e.toString()}');
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Update buyer profile with multipart form data (supports image upload)
  Future<BuyerProfile> updateProfile(
      String token,
      Map<String, dynamic> profileData, {
        File? profileImage,
        BuildContext? context,
      }) async {
    try {
      var uri = Uri.parse('$baseUrl${ApiConstants.updateProfile}');
      var request = http.MultipartRequest('PUT', uri);

      request.headers['Authorization'] = 'Bearer $token';

      profileData.forEach((key, value) {
        if (value != null) {
          if (value is Map || value is List) {
            request.fields[key] = jsonEncode(value);
          } else {
            request.fields[key] = value.toString();
          }
        }
      });

      if (profileImage != null && await profileImage.exists()) {
        final mimeTypeData = _lookupMimeType(profileImage.path)?.split('/');
        var imageFile = await http.MultipartFile.fromPath(
          'profilePicture',
          profileImage.path,
          contentType: mimeTypeData != null
              ? http.MediaType(mimeTypeData[0], mimeTypeData[1])
              : http.MediaType('image', 'jpeg'),
        );
        request.files.add(imageFile);
      }

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final data = jsonDecode(responseData);

      if (response.statusCode == 200) {
        if (context != null && data['success'] == true) {
          CustomSnackbar.showSuccess(context, data['message'] ?? 'Profile updated successfully');
        }
        return BuyerProfile.fromJson(data);
      } else {
        if (context != null) {
          CustomSnackbar.showError(context, data['message'] ?? 'Failed to update profile');
        }
        throw Exception(data['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      if (context != null) {
        CustomSnackbar.showError(context, 'Network error: ${e.toString()}');
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Submit profile details (after email verification)
  Future<BuyerLoginResponse> submitProfileDetails(
      String token,
      Map<String, dynamic> profileData, {
        BuildContext? context,
      }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiConstants.submitprofile}'),
        headers: _getHeaders(token: token),
        body: jsonEncode(profileData),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (context != null && data['success'] == true) {
          CustomSnackbar.showSuccess(context, data['message'] ?? 'Profile submitted successfully');
        }
        return BuyerLoginResponse.fromJson(data);
      } else {
        if (context != null) {
          CustomSnackbar.showError(context, data['message'] ?? 'Failed to submit profile');
        }
        throw Exception(data['message'] ?? 'Failed to submit profile');
      }
    } catch (e) {
      if (context != null) {
        CustomSnackbar.showError(context, 'Network error: ${e.toString()}');
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Check token validity
  Future<TokenValidityResponse> checkTokenValidity(
      String token, {
        BuildContext? context,
      }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiConstants.checkToken}'),
        headers: _getHeaders(token: token),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return TokenValidityResponse.fromJson(data);
      } else {
        if (context != null && response.statusCode != 401) {
          CustomSnackbar.showError(context, data['message'] ?? 'Token validation failed');
        }
        return TokenValidityResponse(
          success: false,
          isValid: false,
          needsRefresh: false,
          message: data['message'] ?? 'Token is invalid',
        );
      }
    } catch (e) {
      if (context != null) {
        CustomSnackbar.showError(context, 'Network error: ${e.toString()}');
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Refresh token
  Future<RefreshTokenResponse> refreshToken(
      RefreshTokenRequest request, {
        BuildContext? context,
      }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiConstants.refreshToken_buyer}'),
        headers: _getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (context != null && data['success'] == true) {
          CustomSnackbar.showSuccess(context, 'Token refreshed successfully');
        }
        return RefreshTokenResponse.fromJson(data);
      } else {
        if (context != null) {
          CustomSnackbar.showError(context, data['message'] ?? 'Failed to refresh token');
        }
        throw Exception(data['message'] ?? 'Failed to refresh token');
      }
    } catch (e) {
      if (context != null) {
        CustomSnackbar.showError(context, 'Network error: ${e.toString()}');
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // ==================== TOKEN MANAGEMENT METHODS ====================

  // Auto-refresh token if needed
  Future<String?> autoRefreshTokenIfNeeded(
      String token,
      String refreshTokenValue, {
        BuildContext? context,
      }) async {
    try {
      // Check current token validity
      final validity = await checkTokenValidity(token, context: context);

      if (!validity.isValid) {
        // Token is invalid, try to refresh
        final refreshResponse = await refreshToken(
          RefreshTokenRequest(refreshToken: refreshTokenValue),
          context: context,
        );

        if (refreshResponse.success) {
          // Return new token
          return refreshResponse.token;
        } else {
          if (context != null) {
            CustomSnackbar.showError(context, 'Session expired. Please login again.');
          }
          return null;
        }
      } else if (validity.needsRefresh) {
        // Token is about to expire, refresh it proactively
        final refreshResponse = await refreshToken(
          RefreshTokenRequest(refreshToken: refreshTokenValue),
          context: context,
        );

        if (refreshResponse.success) {
          return refreshResponse.token;
        }
      }

      // Token is valid and doesn't need refresh
      return token;
    } catch (e) {
      print('Auto-refresh error: $e');
      if (context != null) {
        CustomSnackbar.showError(context, 'Session error: ${e.toString()}');
      }
      return null;
    }
  }

  Future<BuyerRegistrationStepResponse> getRegistrationStep(String token) async {
    try {
      final url = Uri.parse('$baseUrl${ApiConstants.getRegistrationStep}');

      final response = await http.get(
        url,
        headers: _getHeaders(token: token),
      );

      print('📡 GET Registration Step URL: $url');
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return BuyerRegistrationStepResponse.fromJson(data);
      } else {
        return BuyerRegistrationStepResponse(
          success: false,
          message: data['message'] ?? 'Failed to get registration step',
          registrationStep: '',
          isEmailVerified: false,
          hasProfileDetails: false,
          isGoogleUser: false,
          isAppleUser: false,
        );
      }
    } catch (e) {
      print('Error getting registration step: $e');
      return BuyerRegistrationStepResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        registrationStep: '',
        isEmailVerified: false,
        hasProfileDetails: false,
        isGoogleUser: false,
        isAppleUser: false,
      );
    }
  }

  // Make authenticated API call with auto token refresh
  Future<http.Response> authenticatedRequest(
      String method,
      String endpoint,
      String token,
      String refreshToken, {
        Map<String, String>? headers,
        dynamic body,
        BuildContext? context,
      }) async {
    // Auto-refresh token if needed
    final newToken = await autoRefreshTokenIfNeeded(token, refreshToken, context: context);

    if (newToken == null) {
      throw Exception('Authentication failed. Please login again.');
    }

    // Make the actual request with the new token
    final finalHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?headers,
      'Authorization': 'Bearer $newToken',
    };

    Uri url = Uri.parse('$baseUrl$endpoint');
    http.Response response;

    try {
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(url, headers: finalHeaders);
          break;
        case 'POST':
          response = await http.post(
              url,
              headers: finalHeaders,
              body: body != null ? jsonEncode(body) : null
          );
          break;
        case 'PUT':
          response = await http.put(
              url,
              headers: finalHeaders,
              body: body != null ? jsonEncode(body) : null
          );
          break;
        case 'DELETE':
          response = await http.delete(url, headers: finalHeaders);
          break;
        case 'PATCH':
          response = await http.patch(
              url,
              headers: finalHeaders,
              body: body != null ? jsonEncode(body) : null
          );
          break;
        default:
          throw Exception('Unsupported HTTP method');
      }

      // If still unauthorized, throw exception
      if (response.statusCode == 401) {
        if (context != null) {
          CustomSnackbar.showError(context, 'Session expired. Please login again.');
        }
        throw Exception('Session expired. Please login again.');
      }

      return response;
    } catch (e) {
      if (context != null) {
        CustomSnackbar.showError(context, 'Request failed: ${e.toString()}');
      }
      throw Exception('Request failed: ${e.toString()}');
    }
  }

  // ==================== CONVENIENCE METHODS ====================

  Future<http.Response> authenticatedGet(
      String endpoint,
      String token,
      String refreshToken, {
        BuildContext? context,
      }) async {
    return await authenticatedRequest(
      'GET',
      endpoint,
      token,
      refreshToken,
      context: context,
    );
  }

  Future<http.Response> authenticatedPost(
      String endpoint,
      String token,
      String refreshToken,
      dynamic body, {
        BuildContext? context,
      }) async {
    return await authenticatedRequest(
      'POST',
      endpoint,
      token,
      refreshToken,
      body: body,
      context: context,
    );
  }

  Future<http.Response> authenticatedPut(
      String endpoint,
      String token,
      String refreshToken,
      dynamic body, {
        BuildContext? context,
      }) async {
    return await authenticatedRequest(
      'PUT',
      endpoint,
      token,
      refreshToken,
      body: body,
      context: context,
    );
  }

  Future<http.Response> authenticatedDelete(
      String endpoint,
      String token,
      String refreshToken, {
        BuildContext? context,
      }) async {
    return await authenticatedRequest(
      'DELETE',
      endpoint,
      token,
      refreshToken,
      context: context,
    );
  }

  // Dispose method for cleanup
  void dispose() {
    // Close any open connections if needed
  }
}