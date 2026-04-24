// lib/Models/SellerModels/SellerAuthModels.dart

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

// Pickup Address Request Model
class PickupAddressRequest {
  final String addressLabel;
  final String street;
  final String? apartment;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final String phoneNumber;
  final String? company;
  final String? email;
  final bool isDefault;

  PickupAddressRequest({
    required this.addressLabel,
    required this.street,
    this.apartment,
    required this.city,
    required this.state,
    required this.zipCode,
    this.country = 'United States',
    required this.phoneNumber,
    this.company,
    this.email,
    this.isDefault = true,
  });

  Map<String, dynamic> toJson() => {
    'addressLabel': addressLabel,
    'street': street,
    'apartment': apartment,
    'city': city,
    'state': state,
    'zipCode': zipCode,
    'country': country,
    'phoneNumber': phoneNumber,
    'company': company,
    'email': email,
    'isDefault': isDefault,
  };
}

// Pickup Address Response Model
class PickupAddressModel {
  final String id;
  final String sellerId;
  final String addressLabel;
  final bool isDefault;
  final String street;
  final String? apartment;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final String phoneNumber;
  final String? company;
  final String? email;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  PickupAddressModel({
    required this.id,
    required this.sellerId,
    required this.addressLabel,
    required this.isDefault,
    required this.street,
    this.apartment,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    required this.phoneNumber,
    this.company,
    this.email,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PickupAddressModel.fromJson(Map<String, dynamic> json) {
    return PickupAddressModel(
      id: json['_id'] ?? json['id'] ?? '',
      sellerId: json['sellerId'] ?? '',
      addressLabel: json['addressLabel'] ?? '',
      isDefault: json['isDefault'] ?? false,
      street: json['street'] ?? '',
      apartment: json['apartment'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zipCode: json['zipCode'] ?? '',
      country: json['country'] ?? 'United States',
      phoneNumber: json['phoneNumber'] ?? '',
      company: json['company'],
      email: json['email'],
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'sellerId': sellerId,
    'addressLabel': addressLabel,
    'isDefault': isDefault,
    'street': street,
    'apartment': apartment,
    'city': city,
    'state': state,
    'zipCode': zipCode,
    'country': country,
    'phoneNumber': phoneNumber,
    'company': company,
    'email': email,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}

// Updated AuthResponse in SellerAuthModels.dart
class AuthResponse {
  final bool success;
  final String message;
  final String? token;
  final String? refreshToken;
  final SellerModel? seller;
  final List<String>? errors;
  final bool? isValid;
  final int? expiresIn;
  final bool? isAboutToExpire;
  final bool? isNewUser;
  final bool? useGoogleAuth;
  final bool? useAppleAuth;
  final PickupAddressModel? pickupAddress;

  // Address validation specific fields
  final String? validationSource; // 'local', 'fake-check', 'shippo'
  final bool? needsCorrection;
  final Map<String, dynamic>? suggestedAddress;
  final Map<String, dynamic>? originalAddress;

  AuthResponse({
    required this.success,
    required this.message,
    this.token,
    this.refreshToken,
    this.seller,
    this.errors,
    this.isValid,
    this.expiresIn,
    this.isAboutToExpire,
    this.isNewUser,
    this.useGoogleAuth,
    this.useAppleAuth,
    this.pickupAddress,
    this.validationSource,
    this.needsCorrection,
    this.suggestedAddress,
    this.originalAddress,
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
      seller: json['seller'] != null
          ? SellerModel.fromJson(json['seller'])
          : null,
      errors: errorList,
      isValid: json['isValid'],
      expiresIn: json['expiresIn'],
      isAboutToExpire: json['isAboutToExpire'],
      isNewUser: json['isNewUser'],
      useGoogleAuth: json['useGoogleAuth'],
      useAppleAuth: json['useAppleAuth'],
      pickupAddress: json['pickupAddress'] != null
          ? PickupAddressModel.fromJson(json['pickupAddress'])
          : null,
      validationSource: json['validationSource'],
      needsCorrection: json['needsCorrection'],
      suggestedAddress: json['suggestedAddress'] ?? json['validatedAddress'],
      originalAddress: json['address'],
    );
  }

  String getFormattedErrorMessage() {
    if (errors != null && errors!.isNotEmpty) {
      return errors!.join('\n');
    }
    return message;
  }

  // Helper to get user-friendly error messages based on validation source
  String getUserFriendlyErrorMessage() {
    if (errors == null || errors!.isEmpty) {
      return message;
    }

    switch (validationSource) {
      case 'local':
        return '⚠️ Missing Information:\n${errors!.join('\n')}';
      case 'fake-check':
        return '⚠️ Invalid Address Detected:\n${errors!.join('\n')}\n\nPlease enter a real physical address.';
      case 'shippo':
        return '📍 Address Verification Failed:\n${errors!.join('\n')}\n\nPlease check and correct your address.';
      default:
        return errors!.join('\n');
    }
  }

  // Check if there's a suggested correction
  bool get hasSuggestedAddress => suggestedAddress != null && suggestedAddress!.isNotEmpty;

  // Get suggested address as PickupAddressRequest for easy correction
  PickupAddressRequest? getSuggestedAddressRequest() {
    if (suggestedAddress == null) return null;

    return PickupAddressRequest(
      addressLabel: suggestedAddress!['addressLabel'] ?? '',
      street: suggestedAddress!['street'] ?? '',
      apartment: suggestedAddress!['apartment'],
      city: suggestedAddress!['city'] ?? '',
      state: suggestedAddress!['state'] ?? '',
      zipCode: suggestedAddress!['zipCode'] ?? '',
      country: suggestedAddress!['country'] ?? 'United States',
      phoneNumber: suggestedAddress!['phoneNumber'] ?? '',
      company: suggestedAddress!['company'],
      email: suggestedAddress!['email'],
      isDefault: suggestedAddress!['isDefault'] ?? true,
    );
  }
}

// Updated RegistrationStepResponse with pickup address info and Apple user flag
class RegistrationStepResponse {
  final bool success;
  final String message;
  final String registrationStep;
  final bool isEmailVerified;
  final bool hasStoreDetails;
  final bool isGoogleUser;
  final bool isAppleUser;
  final bool hasPickupAddress;
  final bool isFullyCompleted;
  final String? nextStep;
  final Map<String, bool>? canProceed;

  RegistrationStepResponse({
    required this.success,
    required this.message,
    required this.registrationStep,
    required this.isEmailVerified,
    required this.hasStoreDetails,
    this.isGoogleUser = false,
    this.isAppleUser = false,
    this.hasPickupAddress = false,
    this.isFullyCompleted = false,
    this.nextStep,
    this.canProceed,
  });

  factory RegistrationStepResponse.fromJson(Map<String, dynamic> json) {
    return RegistrationStepResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      registrationStep: json['registrationStep'] ?? '',
      isEmailVerified: json['isEmailVerified'] ?? false,
      hasStoreDetails: json['hasStoreDetails'] ?? false,
      isGoogleUser: json['isGoogleUser'] ?? false,
      isAppleUser: json['isAppleUser'] ?? false,
      hasPickupAddress: json['hasPickupAddress'] ?? false,
      isFullyCompleted: json['isFullyCompleted'] ?? false,
      nextStep: json['nextStep'],
      canProceed: json['canProceed'] != null
          ? Map<String, bool>.from(json['canProceed'])
          : null,
    );
  }
}

// Updated SellerModel with Google and Apple fields
class SellerModel {
  final String id;
  final String email;
  final String? storeName;
  final String? businessEmail;
  final String? phoneNumber;
  final List<String>? category;
  final String? storeDescription;
  final Logo? logo;
  final String registrationStep;
  final bool? isRegistrationComplete;
  final bool isEmailVerified;
  final String? status;
  final DateTime? completedAt;
  final String? avatar;
  final String? googleId;
  final String? appleId;
  final bool? isGoogleUser;
  final bool? isAppleUser;

  SellerModel({
    required this.id,
    required this.email,
    this.storeName,
    this.businessEmail,
    this.phoneNumber,
    this.category,
    this.storeDescription,
    this.logo,
    required this.registrationStep,
    this.isRegistrationComplete,
    required this.isEmailVerified,
    this.status,
    this.completedAt,
    this.avatar,
    this.googleId,
    this.appleId,
    this.isGoogleUser,
    this.isAppleUser,
  });

  factory SellerModel.fromJson(Map<String, dynamic> json) {
    return SellerModel(
      id: json['id'] ?? json['_id'] ?? '',
      email: json['email'] ?? '',
      storeName: json['storeName'],
      businessEmail: json['businessEmail'],
      phoneNumber: json['phoneNumber'],
      category: json['category'] != null
          ? List<String>.from(json['category'])
          : null,
      storeDescription: json['storeDescription'],
      logo: json['logo'] != null ? Logo.fromJson(json['logo']) : null,
      registrationStep: json['registrationStep'] ?? '',
      isRegistrationComplete: json['isRegistrationComplete'],
      isEmailVerified: json['isEmailVerified'] ?? false,
      status: json['status'],
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      avatar: json['avatar'],
      googleId: json['googleId'],
      appleId: json['appleId'],
      isGoogleUser: json['isGoogleUser'] ?? (json['googleId'] != null),
      isAppleUser: json['isAppleUser'] ?? (json['appleId'] != null),
    );
  }

  bool get isGoogleUserFlag => googleId != null && googleId!.isNotEmpty;
  bool get isAppleUserFlag => appleId != null && appleId!.isNotEmpty;

  bool get needsPickupAddress => registrationStep == 'pickup_address';
  bool get isFullyCompleted => registrationStep == 'completed';

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'storeName': storeName,
    'businessEmail': businessEmail,
    'phoneNumber': phoneNumber,
    'category': category,
    'storeDescription': storeDescription,
    'logo': logo?.toJson(),
    'registrationStep': registrationStep,
    'isRegistrationComplete': isRegistrationComplete,
    'isEmailVerified': isEmailVerified,
    'status': status,
    'completedAt': completedAt?.toIso8601String(),
    'avatar': avatar,
    'googleId': googleId,
    'appleId': appleId,
    'isGoogleUser': isGoogleUserFlag,
    'isAppleUser': isAppleUserFlag,
  };
}

// Existing models below
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

class StoreDetailsRequest {
  final String storeName;
  final String phoneNumber;
  final String businessEmail;
  final List<String> category;
  final String storeDescription;
  final String? logoPath;

  StoreDetailsRequest({
    required this.storeName,
    required this.phoneNumber,
    required this.businessEmail,
    required this.category,
    required this.storeDescription,
    this.logoPath,
  });

  Map<String, dynamic> toJson() => {
    'storeName': storeName,
    'phoneNumber': phoneNumber,
    'businessEmail': businessEmail,
    'category': category,
    'storeDescription': storeDescription,
  };
}

class Logo {
  final String? url;
  final String? publicId;

  Logo({this.url, this.publicId});

  factory Logo.fromJson(Map<String, dynamic> json) {
    return Logo(
      url: json['url'],
      publicId: json['publicId'],
    );
  }

  Map<String, dynamic> toJson() => {
    'url': url,
    'publicId': publicId,
  };
}

class StoreCategories {
  static const List<String> allCategories = [
    'Anniversary & Holiday Gifts',
    'Odds & Ends',
    'Oral Care',
    'Scarf',
    'Socks',
    'Adventure/Outdoor',
    'Mind-Body',
    'Team Sports',
    'Vehicles',
    'Ethnic Toys',
    'Stuffed Animals',
    'Educational Toys',
    'Arts & Crafts',
    'Dolls & Accessories',
    'Games & Puzzles',
    'Sensors',
    'Audio',
    'Home Devices',
    'Mobile Devices',
    'Computer',
    'Shoes',
    'Health & Beauty',
    'Clothing & Fashion',
    'Technology & Device',
  ];
}