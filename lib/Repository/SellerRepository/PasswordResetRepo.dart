// lib/Repository/SellerRepository/PasswordResetRepo.dart

import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../Constants/ApiConstants.dart';
import '../../Models/SellerModels/PasswordResetModels.dart';
import '../../Services/AppSession.dart';

class PasswordResetRepo {
  String? _authToken;

  PasswordResetRepo({String? authToken}) {
    _authToken = authToken;
  }

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  String _buildUrl(String endpoint) {
    return '${ApiConstants.baseUrlSeller}$endpoint';
  }

  // Send OTP for password reset
  Future<PasswordResetResponse> sendPasswordResetOTP(String email) async {
    try {
      final uri = Uri.parse(_buildUrl('${ApiConstants.passwordReset_sendOTP}'));
      print('URL: $uri');
      final request = SendOTPRequest(email: email);

      if (kDebugMode) {
        log('Sending OTP to: $email');
        log('URL: $uri');
      }

      final response = await http.post(
        uri,
        headers: _getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      if (kDebugMode) {
        log('Send OTP response status: ${response.statusCode}');
        log('Send OTP response body: ${response.body}');
      }

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return PasswordResetResponse.fromJson(data);
      } else {
        return PasswordResetResponse(
          success: false,
          message: data['message'] ?? 'Failed to send OTP',
          error: data['error'],
        );
      }
    } catch (e) {
      if (kDebugMode) {
        log('Error sending OTP: $e');
      }
      return PasswordResetResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        error: e.toString(),
      );
    }
  }

  // Verify OTP
  Future<PasswordResetResponse> verifyOTP(String email, String otp) async {
    try {
      final uri = Uri.parse(_buildUrl('${ApiConstants.verifyOTP}'));
      final request = VerifyOTPRequest(email: email, otp: otp);

      if (kDebugMode) {
        log('Verifying OTP for: $email');
        log('URL: $uri');
      }

      final response = await http.post(
        uri,
        headers: _getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      if (kDebugMode) {
        log('Verify OTP response status: ${response.statusCode}');
        log('Verify OTP response body: ${response.body}');
      }

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return PasswordResetResponse.fromJson(data);
      } else {
        return PasswordResetResponse(
          success: false,
          message: data['message'] ?? 'Failed to verify OTP',
          error: data['error'],
        );
      }
    } catch (e) {
      if (kDebugMode) {
        log('Error verifying OTP: $e');
      }
      return PasswordResetResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        error: e.toString(),
      );
    }
  }

  // Reset password with OTP
  Future<PasswordResetResponse> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final uri = Uri.parse(_buildUrl('${ApiConstants.resetPassword}'));
      final request = ResetPasswordRequest(
        email: email,
        otp: otp,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      if (kDebugMode) {
        log('Resetting password for: $email');
        log('URL: $uri');
      }

      final response = await http.post(
        uri,
        headers: _getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      if (kDebugMode) {
        log('Reset password response status: ${response.statusCode}');
        log('Reset password response body: ${response.body}');
      }

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return PasswordResetResponse.fromJson(data);
      } else {
        return PasswordResetResponse(
          success: false,
          message: data['message'] ?? 'Failed to reset password',
          error: data['error'],
        );
      }
    } catch (e) {
      if (kDebugMode) {
        log('Error resetting password: $e');
      }
      return PasswordResetResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        error: e.toString(),
      );
    }
  }

  Future<PasswordResetResponse> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final uri = Uri.parse(_buildUrl(ApiConstants.changePassword));

      // ✅ GET TOKEN FROM SESSION
      final token = AppSession.instance.authToken;

      if (kDebugMode) {
        log('🔐 Changing password...');
        log('🌐 URL: $uri');
        log('🔑 Token: ${token != null ? token.substring(0, 20) + "..." : "NULL"}');
      }

      // ❌ If no token → stop here
      if (token == null || token.isEmpty) {
        return PasswordResetResponse(
          success: false,
          message: 'User not authenticated. Please login again.',
          error: 'NO_TOKEN',
        );
      }

      final request = ChangePasswordRequest(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // ✅ FIXED
        },
        body: jsonEncode(request.toJson()),
      );

      if (kDebugMode) {
        log('📡 Status Code: ${response.statusCode}');
        log('📦 Response Body: ${response.body}');
      }

      final Map<String, dynamic> data = jsonDecode(response.body);

      // ✅ SUCCESS
      if (response.statusCode == 200) {
        return PasswordResetResponse.fromJson(data);
      }

      // 🔒 UNAUTHORIZED (Token expired / invalid)
      if (response.statusCode == 401) {
        // Optional: clear session
        AppSession.instance.clearSession();

        return PasswordResetResponse(
          success: false,
          message: data['message'] ?? 'Session expired. Please login again.',
          error: 'UNAUTHORIZED',
        );
      }

      // ❌ OTHER ERRORS
      return PasswordResetResponse(
        success: false,
        message: data['message'] ?? 'Failed to change password',
        error: data['error'],
      );
    } catch (e) {
      if (kDebugMode) {
        log('❌ Error changing password: $e');
      }

      return PasswordResetResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        error: e.toString(),
      );
    }
  }

  // Resend OTP
  Future<PasswordResetResponse> resendOTP(String email) async {
    try {
      final uri = Uri.parse(_buildUrl('${ApiConstants.resendOTP}'));
      final request = SendOTPRequest(email: email);

      if (kDebugMode) {
        log('Resending OTP to: $email');
        log('URL: $uri');
      }

      final response = await http.post(
        uri,
        headers: _getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      if (kDebugMode) {
        log('Resend OTP response status: ${response.statusCode}');
        log('Resend OTP response body: ${response.body}');
      }

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return PasswordResetResponse.fromJson(data);
      } else {
        return PasswordResetResponse(
          success: false,
          message: data['message'] ?? 'Failed to resend OTP',
          error: data['error'],
        );
      }
    } catch (e) {
      if (kDebugMode) {
        log('Error resending OTP: $e');
      }
      return PasswordResetResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        error: e.toString(),
      );
    }
  }
}