// lib/models/seller_auth_models.dart
import 'dart:convert';

import 'SellerAuthModels.dart';


class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
}




class UpdateProfileRequest {
  String? storeName;
  String? phoneNumber;
  String? businessEmail;
  List<String>? category;
  String? storeDescription;
  String? logoPath;

  UpdateProfileRequest({
    this.storeName,
    this.phoneNumber,
    this.businessEmail,
    this.category,
    this.storeDescription,
    this.logoPath,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (storeName != null) data['storeName'] = storeName;
    if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
    if (businessEmail != null) data['businessEmail'] = businessEmail;
    if (category != null) data['category'] = category;
    if (storeDescription != null) data['storeDescription'] = storeDescription;
    return data;
  }
}

class AuthResponse {
  final bool success;
  final String message;
  final String? token;
  final SellerModel? seller;
  final List<String>? errors;
  final bool? isValid;
  final int? expiresIn;
  final bool? isAboutToExpire;

  AuthResponse({
    required this.success,
    required this.message,
    this.token,
    this.seller,
    this.errors,
    this.isValid,
    this.expiresIn,
    this.isAboutToExpire,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Parse errors if they exist
    List<String>? errorList;
    if (json['errors'] != null) {
      if (json['errors'] is List) {
        errorList = [];
        for (var error in json['errors']) {
          if (error is Map && error['msg'] != null) {
            errorList.add(error['msg']);
          } else if (error is String) {
            errorList.add(error);
          }
        }
      } else if (json['errors'] is String) {
        errorList = [json['errors']];
      }
    }

    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      token: json['token'],
      seller: json['seller'] != null
          ? SellerModel.fromJson(json['seller'])
          : null,
      errors: errorList,
      isValid: json['isValid'],
      expiresIn: json['expiresIn'],
      isAboutToExpire: json['isAboutToExpire'],
    );
  }

  // Helper method to get formatted error message
  String getFormattedErrorMessage() {
    if (errors != null && errors!.isNotEmpty) {
      return errors!.join('\n');
    }
    return message;
  }
}

class RegistrationStepResponse {
  final bool success;
  final String message;
  final String registrationStep;
  final bool isEmailVerified;
  final bool hasStoreDetails;

  RegistrationStepResponse({
    required this.success,
    required this.message,
    required this.registrationStep,
    required this.isEmailVerified,
    required this.hasStoreDetails,
  });

  factory RegistrationStepResponse.fromJson(Map<String, dynamic> json) {
    return RegistrationStepResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      registrationStep: json['registrationStep'] ?? '',
      isEmailVerified: json['isEmailVerified'] ?? false,
      hasStoreDetails: json['hasStoreDetails'] ?? false,
    );
  }
}

class TokenCheckResponse {
  final bool success;
  final bool isValid;
  final String message;
  final int expiresIn;
  final bool isAboutToExpire;
  final SellerModel? seller;

  TokenCheckResponse({
    required this.success,
    required this.isValid,
    required this.message,
    required this.expiresIn,
    required this.isAboutToExpire,
    this.seller,
  });

  factory TokenCheckResponse.fromJson(Map<String, dynamic> json) {
    return TokenCheckResponse(
      success: json['success'] ?? false,
      isValid: json['isValid'] ?? false,
      message: json['message'] ?? '',
      expiresIn: json['expiresIn'] ?? 0,
      isAboutToExpire: json['isAboutToExpire'] ?? false,
      seller: json['seller'] != null
          ? SellerModel.fromJson(json['seller'])
          : null,
    );
  }
}


class PasswordValidation {
  final bool isValid;
  final List<String> errors;

  PasswordValidation({
    required this.isValid,
    required this.errors,
  });

  factory PasswordValidation.fromJson(Map<String, dynamic> json) {
    return PasswordValidation(
      isValid: json['isValid'] ?? false,
      errors: json['errors'] != null
          ? List<String>.from(json['errors'])
          : [],
    );
  }
}

// Enum for registration steps
enum RegistrationStep {
  walletCreation('wallet_creation'),
  storeDetails('store_details'),
  completed('completed');

  final String value;
  const RegistrationStep(this.value);

  static RegistrationStep fromString(String value) {
    switch (value) {
      case 'wallet_creation':
        return RegistrationStep.walletCreation;
      case 'store_details':
        return RegistrationStep.storeDetails;
      case 'completed':
        return RegistrationStep.completed;
      default:
        return RegistrationStep.walletCreation;
    }
  }
}
