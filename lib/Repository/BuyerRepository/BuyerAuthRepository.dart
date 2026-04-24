import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import '../../Constants/ApiConstants.dart';
import '../../Models/BuyerModels/BuyerAuthModels.dart';

class BuyerAuthRepo {
  static const String _baseUrl = ApiConstants.baseUrlBuyer;

  // Headers for requests
  Map<String, String> _getHeaders({String? token}) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ==================== APPLE AUTH METHODS ====================

  /// Apple Sign-In / Sign-Up for Buyers
  Future<AuthResponse> appleAuth({
    required String identityToken,
    Map<String, String>? fullName,
    String? email,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl${ApiConstants.appleAuthBuyer}');
      final request = AppleAuthRequest(
        identityToken: identityToken,
        fullName: fullName,
        email: email,
      );

      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      print('URL: $url');
      print('Request Body: ${jsonEncode(request.toJson())}');
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

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
      final url = Uri.parse('$_baseUrl${ApiConstants.linkAppleBuyer}');
      final request = LinkAppleRequest(
        identityToken: identityToken,
        fullName: fullName,
      );

      final response = await http.post(
        url,
        headers: _getHeaders(token: token),
        body: jsonEncode(request.toJson()),
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
      final url = Uri.parse('$_baseUrl${ApiConstants.unlinkAppleBuyer}');

      final response = await http.post(
        url,
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
      final url = Uri.parse('$_baseUrl${ApiConstants.googleAuthBuyer}');
      final request = GoogleAuthRequest(idToken: idToken);

      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      print('URL: $url');
      print('Request Body: ${jsonEncode(request.toJson())}');
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

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
      final url = Uri.parse('$_baseUrl${ApiConstants.linkGoogleBuyer}');
      final request = LinkGoogleRequest(idToken: idToken);

      final response = await http.post(
        url,
        headers: _getHeaders(token: token),
        body: jsonEncode(request.toJson()),
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
      final url = Uri.parse('$_baseUrl${ApiConstants.unlinkGoogleBuyer}');

      final response = await http.post(
        url,
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

  // ==================== EXISTING AUTH METHODS ====================

  // Step 1: Create Wallet (Sign Up with Email & Password)
  Future<AuthResponse> createWallet({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl${ApiConstants.createWallet}');
      final body = CreateWalletRequest(email: email, password: password).toJson();

      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode(body),
      );
      print('Url: $url');
      print('Request Body: ${jsonEncode(body)}');
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return AuthResponse.fromJson(data);
      } else {
        if (data['errors'] != null) {
          final errorResponse = CreateWalletErrorResponse.fromJson(data);
          return AuthResponse(
            success: false,
            message: errorResponse.message,
            errors: errorResponse.errors?.map((e) => e.message).toList(),
          );
        }
        return AuthResponse(
          success: false,
          message: data['message'] ?? 'Failed to create wallet',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Step 2: Verify Email with OTP
  Future<AuthResponse> verifyEmail({
    required String email,
    required String otp,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl${ApiConstants.verifyEmail}');
      final body = VerifyEmailRequest(email: email, otp: otp).toJson();

      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(data);
      } else {
        return AuthResponse(
          success: false,
          message: data['message'] ?? 'Failed to verify email',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Resend OTP
  Future<AuthResponse> resendOTP({
    required String email,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl${ApiConstants.resendOTP}');
      final body = ResendOTPRequest(email: email).toJson();

      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(data);
      } else {
        return AuthResponse(
          success: false,
          message: data['message'] ?? 'Failed to resend OTP',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Submit Profile Details (Step 3)
  Future<AuthResponse> submitProfileDetails({
    required String token,
    required String fullName,
    required String phoneNumber,
    DateTime? dateOfBirth,
    Map<String, dynamic>? address,
    File? profilePicture,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl${ApiConstants.submitprofile}');

      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';

      // Add text fields
      request.fields['fullName'] = fullName;
      request.fields['phoneNumber'] = phoneNumber;

      if (dateOfBirth != null) {
        request.fields['dateOfBirth'] = dateOfBirth.toIso8601String();
      }

      if (address != null) {
        request.fields['address'] = jsonEncode(address);
      }

      // Add profile picture if provided
      if (profilePicture != null && await profilePicture.exists()) {
        final mimeTypeData = lookupMimeType(profilePicture.path);
        final extension = profilePicture.path.split('.').last.toLowerCase();

        MediaType? contentType;
        if (mimeTypeData != null) {
          final parts = mimeTypeData.split('/');
          if (parts.length == 2) {
            contentType = MediaType(parts[0], parts[1]);
          }
        }

        contentType ??= MediaType('image', extension == 'jpg' ? 'jpeg' : extension);

        final multipartFile = await http.MultipartFile.fromPath(
          'profilePicture',
          profilePicture.path,
          contentType: contentType,
        );

        request.files.add(multipartFile);
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponse.fromJson(data);
      } else {
        return AuthResponse(
          success: false,
          message: data['message'] ?? 'Failed to submit profile details',
        );
      }
    } catch (e) {
      print('Submit profile details error: $e');
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Get current buyer profile
  Future<AuthResponse> getProfile(String token) async {
    try {
      final url = Uri.parse('$_baseUrl${ApiConstants.getProfile}');

      final response = await http.get(
        url,
        headers: _getHeaders(token: token),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(data);
      } else {
        return AuthResponse(
          success: false,
          message: data['message'] ?? 'Failed to get profile',
        );
      }
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // ==================== REGISTRATION STEP METHODS ====================

  // Update profile
  Future<AuthResponse> updateProfile({
    required String token,
    String? fullName,
    String? phoneNumber,
    DateTime? dateOfBirth,
    Map<String, dynamic>? address,
    File? profilePicture,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl${ApiConstants.updateProfile}');

      final request = http.MultipartRequest('PUT', url);
      request.headers['Authorization'] = 'Bearer $token';

      if (fullName != null) {
        request.fields['fullName'] = fullName;
      }

      if (phoneNumber != null) {
        request.fields['phoneNumber'] = phoneNumber;
      }

      if (dateOfBirth != null) {
        request.fields['dateOfBirth'] = dateOfBirth.toIso8601String();
      }

      if (address != null) {
        request.fields['address'] = jsonEncode(address);
      }

      if (profilePicture != null && await profilePicture.exists()) {
        final mimeTypeData = lookupMimeType(profilePicture.path);
        final extension = profilePicture.path.split('.').last.toLowerCase();

        MediaType? contentType;
        if (mimeTypeData != null) {
          final parts = mimeTypeData.split('/');
          if (parts.length == 2) {
            contentType = MediaType(parts[0], parts[1]);
          }
        }

        contentType ??= MediaType('image', extension == 'jpg' ? 'jpeg' : extension);

        final multipartFile = await http.MultipartFile.fromPath(
          'profilePicture',
          profilePicture.path,
          contentType: contentType,
        );

        request.files.add(multipartFile);
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(data);
      } else {
        return AuthResponse(
          success: false,
          message: data['message'] ?? 'Failed to update profile',
        );
      }
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Validate password strength (client-side validation)
  static Map<String, dynamic> validatePassword(String password) {
    final errors = <String>[];

    if (password.isEmpty) {
      errors.add('Password is required');
      return {'isValid': false, 'errors': errors};
    }

    if (password.length < 8) {
      errors.add('Password must be at least 8 characters long');
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      errors.add('Password must contain at least one uppercase letter');
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      errors.add('Password must contain at least one lowercase letter');
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      errors.add('Password must contain at least one number');
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      errors.add('Password must contain at least one special character');
    }

    return {
      'isValid': errors.isEmpty,
      'errors': errors,
    };
  }

  void dispose() {
    // Close any open connections if needed
  }
}