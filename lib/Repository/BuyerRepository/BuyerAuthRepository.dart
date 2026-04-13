// lib/repositories/buyer_auth_repo.dart

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
        // Handle validation errors
        if (data['errors'] != null) {
          final errorResponse = CreateWalletErrorResponse.fromJson(data);
          throw Exception(errorResponse.message);
        }
        throw Exception(data['message'] ?? 'Failed to create wallet');
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
        throw Exception(data['message'] ?? 'Failed to verify email');
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
        throw Exception(data['message'] ?? 'Failed to resend OTP');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

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

      // Create multipart request
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

        // Determine content type
        MediaType? contentType;
        if (mimeTypeData != null) {
          final parts = mimeTypeData.split('/');
          if (parts.length == 2) {
            contentType = MediaType(parts[0], parts[1]);
          }
        }

        // Fallback content type if lookup fails
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
        throw Exception(data['message'] ?? 'Failed to submit profile details');
      }
    } catch (e) {
      print('Submit profile details error: $e');
      throw Exception('Network error: $e');
    }
  }

// Helper method to get image extension (if you don't want to use mime package)
  String _getImageExtension(String path) {
    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'jpeg';
      case 'png':
        return 'png';
      case 'gif':
        return 'gif';
      case 'webp':
        return 'webp';
      case 'heic':
        return 'heic';
      default:
        return 'jpeg';
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
        throw Exception(data['message'] ?? 'Failed to get profile');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

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

      if (profilePicture != null) {
        final stream = http.ByteStream(profilePicture.openRead());
        final length = await profilePicture.length();

        final multipartFile = http.MultipartFile(
          'profilePicture',
          stream,
          length,
          filename: profilePicture.path.split('/').last,
          contentType: MediaType('image', _getImageExtension(profilePicture.path)),
        );

        request.files.add(multipartFile);
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(data);
      } else {
        throw Exception(data['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      throw Exception('Network error: $e');
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
}