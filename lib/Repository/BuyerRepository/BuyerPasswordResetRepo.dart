// lib/Repository/BuyerRepository/BuyerPasswordResetRepo.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../Constants/ApiConstants.dart';
import '../../Models/BuyerModels/BuyerPasswordResetModels.dart';
import '../../res/Widgets/CustomSnackbar.dart';

class BuyerPasswordResetRepo {
  final String baseUrl = ApiConstants.baseUrlBuyer;

  // Get default headers
  Map<String, String> _getHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Handle API response
  dynamic _handleResponse(http.Response response, BuildContext? context) {
    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      final message = data['message'] ?? 'Request failed';
      if (context != null) {
        CustomSnackbar.showError(context, message);
      }
      throw Exception(message);
    }
  }

  // Send OTP for password reset
  Future<SendOTPResponse> sendPasswordResetOTP(
      SendOTPRequest request, {
        BuildContext? context,
      }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/password-reset/send-otp'),
        headers: _getHeaders(),
        body: jsonEncode(request.toJson()),
      );
      print('URL: $baseUrl/password-reset/send-otp');

      final data = jsonDecode(response.body);
      print('Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        if (context != null && data['success'] == true) {
         print('OTP sent successfully: ${data['message']}');
        }
        return SendOTPResponse.fromJson(data);
      } else {
        if (context != null) {
          CustomSnackbar.showError(
            context,
            data['message'] ?? 'Failed to send OTP',
          );
        }
        throw Exception(data['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      if (context != null) {
        CustomSnackbar.showError(
          context,
          'Network error: ${e.toString()}',
        );
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Verify OTP for password reset
  Future<VerifyOTPResponse> verifyPasswordResetOTP(
      VerifyOTPRequest request, {
        BuildContext? context,
      }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/password-reset/verify-otp'),
        headers: _getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (context != null && data['success'] == true) {
          print('OTP verification successful: ${data['message']}');

        }
        return VerifyOTPResponse.fromJson(data);
      } else {
        if (context != null) {
          CustomSnackbar.showError(
            context,
            data['message'] ?? 'Failed to verify OTP',
          );
        }
        throw Exception(data['message'] ?? 'Failed to verify OTP');
      }
    } catch (e) {
      if (context != null) {
        CustomSnackbar.showError(
          context,
          'Network error: ${e.toString()}',
        );
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Reset password using OTP
  Future<ResetPasswordResponse> resetPassword(
      ResetPasswordRequest request, {
        BuildContext? context,
      }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/password-reset/reset'),
        headers: _getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (context != null && data['success'] == true) {
          print('Password reset successful: ${data['message']}');

        }
        return ResetPasswordResponse.fromJson(data);
      } else {
        if (context != null) {
          CustomSnackbar.showError(
            context,
            data['message'] ?? 'Failed to reset password',
          );
        }
        throw Exception(data['message'] ?? 'Failed to reset password');
      }
    } catch (e) {
      if (context != null) {
        CustomSnackbar.showError(
          context,
          'Network error: ${e.toString()}',
        );
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Change password (for authenticated buyers)
  Future<ChangePasswordResponse> changePassword(
      String token,
      ChangePasswordRequest request, {
        BuildContext? context,
      }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/change-password'),
        headers: _getHeaders(token: token),
        body: jsonEncode(request.toJson()),
      );

      final data = jsonDecode(response.body);
      print('URL: $baseUrl/change-password');

      print('Change Password Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        if (context != null && data['success'] == true) {
          print('Password change successful: ${data['message']}');
        }
        return ChangePasswordResponse.fromJson(data);
      } else {
        if (context != null) {
          CustomSnackbar.showError(
            context,
            data['message'],
          );
        }
        throw Exception(data['message']);
      }
    } catch (e) {
      if (context != null) {
        CustomSnackbar.showError(
          context,
          'Network error: ${e.toString()}',
        );
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Resend OTP for password reset
  Future<ResendOTPResponse> resendPasswordResetOTP(
      ResendOTPRequest request, {
        BuildContext? context,
      }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/password-reset/resend-otp'),
        headers: _getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (context != null && data['success'] == true) {
          CustomSnackbar.showSuccess(
            context,
            data['message'] ?? 'New OTP sent to your email',
          );
        }
        return ResendOTPResponse.fromJson(data);
      } else {
        if (context != null) {
          CustomSnackbar.showError(
            context,
            data['message'] ?? 'Failed to resend OTP',
          );
        }
        throw Exception(data['message'] ?? 'Failed to resend OTP');
      }
    } catch (e) {
      if (context != null) {
        CustomSnackbar.showError(
          context,
          'Network error: ${e.toString()}',
        );
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }
}