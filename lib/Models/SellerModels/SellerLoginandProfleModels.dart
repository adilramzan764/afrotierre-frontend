// lib/Models/SellerModels/SellerLoginandProfleModels.dart

import 'dart:convert';
import 'SellerAuthModels.dart';

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

// Updated RegistrationStep enum with all steps
enum RegistrationStep {
  walletCreation('wallet_creation'),
  emailVerification('email_verification'),
  storeDetails('store_details'),
  pickupAddress('pickup_address'),
  completed('completed');

  final String value;
  const RegistrationStep(this.value);

  static RegistrationStep fromString(String value) {
    switch (value) {
      case 'wallet_creation':
        return RegistrationStep.walletCreation;
      case 'email_verification':
        return RegistrationStep.emailVerification;
      case 'store_details':
        return RegistrationStep.storeDetails;
      case 'pickup_address':
        return RegistrationStep.pickupAddress;
      case 'completed':
        return RegistrationStep.completed;
      default:
        return RegistrationStep.walletCreation;
    }
  }

  bool get canProceedToStoreDetails =>
      this == RegistrationStep.storeDetails ||
          this == RegistrationStep.pickupAddress;

  bool get canProceedToPickupAddress =>
      this == RegistrationStep.pickupAddress;

  bool get isComplete => this == RegistrationStep.completed;

  String get displayName {
    switch (this) {
      case RegistrationStep.walletCreation:
        return 'Create Account';
      case RegistrationStep.emailVerification:
        return 'Verify Email';
      case RegistrationStep.storeDetails:
        return 'Store Details';
      case RegistrationStep.pickupAddress:
        return 'Pickup Address';
      case RegistrationStep.completed:
        return 'Completed';
    }
  }
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

class RefreshTokenRequest {
  final String refreshToken;

  RefreshTokenRequest({
    required this.refreshToken,
  });

  Map<String, dynamic> toJson() => {
    'refreshToken': refreshToken,
  };
}

class RefreshTokenResponse {
  final bool success;
  final String message;
  final String token;
  final String? refreshToken;

  RefreshTokenResponse({
    required this.success,
    required this.message,
    required this.token,
    this.refreshToken,
  });

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      token: json['token'] ?? '',
      refreshToken: json['refreshToken'],
    );
  }
}