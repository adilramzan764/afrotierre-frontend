// lib/models/buyer_auth_models.dart

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
}

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
  });

  factory Buyer.fromJson(Map<String, dynamic> json) {
    return Buyer(
      id: json['id'] ?? json['_id'],
      email: json['email'],
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
    );
  }

  bool get isRegistrationComplete => registrationStep == 'completed';
  bool get needsProfileDetails => registrationStep == 'profile_details';
  bool get needsWalletCreation => registrationStep == 'wallet_creation';
}

class AuthResponse {
  final bool success;
  final String message;
  final String? token;
  final Buyer? buyer;

  AuthResponse({
    required this.success,
    required this.message,
    this.token,
    this.buyer,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      token: json['token'],
      buyer: json['buyer'] != null ? Buyer.fromJson(json['buyer']) : null,
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