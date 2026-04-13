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
  final String? logoPath; // For file upload

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

class AuthResponse {
  final bool success;
  final String message;
  final String? token;
  final SellerModel? seller;
  final List<String>? errors;

  AuthResponse({
    required this.success,
    required this.message,
    this.token,
    this.seller,
    this.errors,
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
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'storeName': storeName,
    'businessEmail': businessEmail,
    'phoneNumber': phoneNumber,
    'category': category,
    'storeDescription': storeDescription,
    'logo': logo?.toJson(), // Fixed: Convert Logo to Map
    'registrationStep': registrationStep,
    'isRegistrationComplete': isRegistrationComplete,
    'isEmailVerified': isEmailVerified,
    'status': status,
    'completedAt': completedAt?.toIso8601String(),
  };
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

// Available categories constant
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