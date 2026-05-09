import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';
import '../../Constants/ApiConstants.dart';
import '../../Models/SellerModels/SellerAuthModels.dart';
import '../../Models/SellerModels/SellerLoginandProfleModels.dart';

class SellerLoginandProfileRepo {
  final http.Client client;

  SellerLoginandProfileRepo({
    http.Client? client,
  }) : client = client ?? http.Client();

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
      final response = await client.post(
        Uri.parse(_buildUrl(ApiConstants.appleAuth)),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idToken': identityToken,
          if (fullName != null) 'fullName': fullName,
          if (email != null) 'email': email,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return AuthResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return AuthResponse(
          success: false,
          message: errorData['message'] ?? 'Apple authentication failed',
          useAppleAuth: errorData['useAppleAuth'],
        );
      }
    } catch (e) {
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
      final response = await client.post(
        Uri.parse(_buildUrl(ApiConstants.linkApple)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'idToken': identityToken,
          if (fullName != null) 'fullName': fullName,
        }),
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
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // ==================== GOOGLE AUTH METHODS ====================

  Future<AuthResponse> googleAuth({required String idToken}) async {
    try {
      final response = await client.post(
        Uri.parse(_buildUrl(ApiConstants.googleAuth)),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return AuthResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return AuthResponse(
          success: false,
          message: errorData['message'] ?? 'Google authentication failed',
          useGoogleAuth: errorData['useGoogleAuth'],
        );
      }
    } catch (e) {
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return AuthResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return AuthResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to add pickup address',
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

  // ==================== LOGIN & PROFILE METHODS ====================

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final request = LoginRequest(email: email, password: password);

      final response = await client.post(
        Uri.parse(_buildUrl(ApiConstants.login)),
        headers: {'Content-Type': 'application/json'},
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
          useGoogleAuth: errorData['useGoogleAuth'],
          useAppleAuth: errorData['useAppleAuth'],
        );
      }
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<TokenCheckResponse> checkTokenValidity(String token) async {
    try {
      final response = await client.get(
        Uri.parse(_buildUrl(ApiConstants.checkToken)),
        headers: {'Authorization': 'Bearer $token'},
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
      return TokenCheckResponse(
        success: false,
        isValid: false,
        message: 'Network error: ${e.toString()}',
        expiresIn: 0,
        isAboutToExpire: false,
      );
    }
  }

  Future<RegistrationStepResponse> getRegistrationStep(String token) async {
    try {
      final response = await client.get(
        Uri.parse(_buildUrl(ApiConstants.getRegistrationStep)),
        headers: {'Authorization': 'Bearer $token'},
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
      return RegistrationStepResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        registrationStep: '',
        isEmailVerified: false,
        hasStoreDetails: false,
      );
    }
  }

  Future<AuthResponse> getProfile(String token) async {
    try {
      final response = await client.get(
        Uri.parse(_buildUrl(ApiConstants.getProfile)),
        headers: {'Authorization': 'Bearer $token'},
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
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<AuthResponse> updateProfile({
    required String token,
    required UpdateProfileRequest request,
    bool includeLogo = false,
  }) async {
    try {
      var uri = Uri.parse(_buildUrl(ApiConstants.updateProfile));

      if (includeLogo && request.logoPath != null) {
        var multipartRequest = http.MultipartRequest('PUT', uri);
        multipartRequest.headers['Authorization'] = 'Bearer $token';

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
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  void dispose() {
    client.close();
  }
}