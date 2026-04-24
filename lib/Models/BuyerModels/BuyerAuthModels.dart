// lib/models/buyer_auth_models.dart

// ==================== APPLE AUTH MODELS ====================

class AppleAuthRequest {
  final String identityToken;
  final Map<String, String>? fullName;
  final String? email;

  AppleAuthRequest({
    required this.identityToken,
    this.fullName,
    this.email,
  });

  Map<String, dynamic> toJson() => {
    'identityToken': identityToken,
    if (fullName != null) 'fullName': fullName,
    if (email != null) 'email': email,
  };
}

class LinkAppleRequest {
  final String identityToken;
  final Map<String, String>? fullName;

  LinkAppleRequest({
    required this.identityToken,
    this.fullName,
  });

  Map<String, dynamic> toJson() => {
    'identityToken': identityToken,
    if (fullName != null) 'fullName': fullName,
  };
}

// ==================== GOOGLE AUTH MODELS ====================

class GoogleAuthRequest {
  final String idToken;

  GoogleAuthRequest({
    required this.idToken,
  });

  Map<String, dynamic> toJson() => {
    'idToken': idToken,
  };
}

class LinkGoogleRequest {
  final String idToken;

  LinkGoogleRequest({
    required this.idToken,
  });

  Map<String, dynamic> toJson() => {
    'idToken': idToken,
  };
}

// Updated AuthResponse to include Apple-specific fields
class AuthResponse {
  final bool success;
  final String message;
  final String? token;
  final String? refreshToken;
  final Buyer? buyer;
  final List<String>? errors;
  final bool? isValid;
  final int? expiresIn;
  final bool? isAboutToExpire;
  final bool? isNewUser;
  final bool? useGoogleAuth;
  final bool? useAppleAuth;

  AuthResponse({
    required this.success,
    required this.message,
    this.token,
    this.refreshToken,
    this.buyer,
    this.errors,
    this.isValid,
    this.expiresIn,
    this.isAboutToExpire,
    this.isNewUser,
    this.useGoogleAuth,
    this.useAppleAuth,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
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
      refreshToken: json['refreshToken'],
      buyer: json['buyer'] != null ? Buyer.fromJson(json['buyer']) : null,
      errors: errorList,
      isValid: json['isValid'],
      expiresIn: json['expiresIn'],
      isAboutToExpire: json['isAboutToExpire'],
      isNewUser: json['isNewUser'],
      useGoogleAuth: json['useGoogleAuth'],
      useAppleAuth: json['useAppleAuth'],
    );
  }

  String getFormattedErrorMessage() {
    if (errors != null && errors!.isNotEmpty) {
      return errors!.join('\n');
    }
    return message;
  }
}

// Updated Buyer model with Apple fields
class Buyer {
  final String id;
  final String email;
  final String? fullName;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final Address? address;
  final ProfilePicture? profilePicture;
  final String registrationStep;
  final bool isEmailVerified;
  final String status;
  final Map<String, dynamic>? preferences;
  final DateTime? completedAt;
  final String? avatar; // Profile picture from Google/Apple
  final String? googleId; // Google user ID
  final String? appleId; // Apple user ID

  Buyer({
    required this.id,
    required this.email,
    this.fullName,
    this.phoneNumber,
    this.dateOfBirth,
    this.address,
    this.profilePicture,
    required this.registrationStep,
    required this.isEmailVerified,
    required this.status,
    this.preferences,
    this.completedAt,
    this.avatar,
    this.googleId,
    this.appleId,
  });

  factory Buyer.fromJson(Map<String, dynamic> json) {
    return Buyer(
      id: json['id'] ?? json['_id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      address: json['address'] != null
          ? Address.fromJson(json['address'])
          : null,
      profilePicture: json['profilePicture'] != null
          ? ProfilePicture.fromJson(json['profilePicture'])
          : null,
      registrationStep: json['registrationStep'] ?? 'wallet_creation',
      isEmailVerified: json['isEmailVerified'] ?? false,
      status: json['status'] ?? 'active',
      preferences: json['preferences'],
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      avatar: json['avatar'],
      googleId: json['googleId'],
      appleId: json['appleId'],
    );
  }

  bool get isRegistrationComplete => registrationStep == 'completed';
  bool get needsProfileDetails => registrationStep == 'profile_details';
  bool get needsWalletCreation => registrationStep == 'wallet_creation';
  bool get isGoogleUser => googleId != null && googleId!.isNotEmpty;
  bool get isAppleUser => appleId != null && appleId!.isNotEmpty;

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'fullName': fullName,
    'phoneNumber': phoneNumber,
    'dateOfBirth': dateOfBirth?.toIso8601String(),
    'address': address?.toJson(),
    'profilePicture': profilePicture?.toJson(),
    'registrationStep': registrationStep,
    'isEmailVerified': isEmailVerified,
    'status': status,
    'preferences': preferences,
    'completedAt': completedAt?.toIso8601String(),
    'avatar': avatar,
    'googleId': googleId,
    'appleId': appleId,
  };
}

// Rest of your existing models remain the same...
class CreateWalletRequest {
  final String email;
  final String password;

  CreateWalletRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
}

class VerifyEmailRequest {
  final String email;
  final String otp;

  VerifyEmailRequest({
    required this.email,
    required this.otp,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'otp': otp,
  };
}

class ResendOTPRequest {
  final String email;

  ResendOTPRequest({
    required this.email,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
  };
}

class SubmitProfileRequest {
  final String fullName;
  final String phoneNumber;
  final DateTime? dateOfBirth;
  final Map<String, dynamic>? address;

  SubmitProfileRequest({
    required this.fullName,
    required this.phoneNumber,
    this.dateOfBirth,
    this.address,
  });

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'phoneNumber': phoneNumber,
    if (dateOfBirth != null) 'dateOfBirth': dateOfBirth!.toIso8601String(),
    if (address != null) 'address': address,
  };
}

class Address {
  final String? street;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;

  Address({
    this.street,
    this.city,
    this.state,
    this.country,
    this.postalCode,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      postalCode: json['postalCode'],
    );
  }

  Map<String, dynamic> toJson() => {
    if (street != null) 'street': street,
    if (city != null) 'city': city,
    if (state != null) 'state': state,
    if (country != null) 'country': country,
    if (postalCode != null) 'postalCode': postalCode,
  };
}

class ProfilePicture {
  final String? url;
  final String? publicId;

  ProfilePicture({
    this.url,
    this.publicId,
  });

  factory ProfilePicture.fromJson(Map<String, dynamic> json) {
    return ProfilePicture(
      url: json['url'],
      publicId: json['publicId'],
    );
  }

  Map<String, dynamic> toJson() => {
    'url': url,
    'publicId': publicId,
  };
}

class CreateWalletErrorResponse {
  final bool success;
  final String message;
  final List<PasswordValidationError>? errors;

  CreateWalletErrorResponse({
    required this.success,
    required this.message,
    this.errors,
  });

  factory CreateWalletErrorResponse.fromJson(Map<String, dynamic> json) {
    return CreateWalletErrorResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      errors: json['errors'] != null
          ? (json['errors'] as List)
          .map((e) => PasswordValidationError.fromJson(e))
          .toList()
          : null,
    );
  }
}

class PasswordValidationError {
  final String message;
  final String? field;

  PasswordValidationError({
    required this.message,
    this.field,
  });

  factory PasswordValidationError.fromJson(Map<String, dynamic> json) {
    return PasswordValidationError(
      message: json['message'] ?? '',
      field: json['field'],
    );
  }
}

class BuyerRegistrationStepResponse {
  final bool success;
  final String message;
  final String registrationStep;
  final bool isEmailVerified;
  final bool hasProfileDetails;
  final bool isGoogleUser;
  final bool isAppleUser;

  BuyerRegistrationStepResponse({
    required this.success,
    required this.message,
    required this.registrationStep,
    required this.isEmailVerified,
    required this.hasProfileDetails,
    this.isGoogleUser = false,
    this.isAppleUser = false,
  });

  factory BuyerRegistrationStepResponse.fromJson(Map<String, dynamic> json) {
    return BuyerRegistrationStepResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      registrationStep: json['registrationStep'] ?? '',
      isEmailVerified: json['isEmailVerified'] ?? false,
      hasProfileDetails: json['hasProfileDetails'] ?? false,
      isGoogleUser: json['isGoogleUser'] ?? false,
      isAppleUser: json['isAppleUser'] ?? false,
    );
  }
}