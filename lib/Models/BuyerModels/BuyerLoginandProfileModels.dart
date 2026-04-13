// lib/Models/BuyerModels/BuyerLoginandProfileModels.dart
class BuyerLoginResponse {
  final bool success;
  final String message;
  final String token;
  final String refreshToken;
  final BuyerData buyer;

  BuyerLoginResponse({
    required this.success,
    required this.message,
    required this.token,
    required this.refreshToken,
    required this.buyer,
  });

  factory BuyerLoginResponse.fromJson(Map<String, dynamic> json) {
    return BuyerLoginResponse(
      success: json['success'] ?? false,
      message: json['message']?.toString() ?? '',
      // Ensure token and refreshToken are treated as strings
      token: json['token']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString() ?? '',
      buyer: json['buyer'] != null
          ? BuyerData.fromJson(json['buyer'] as Map<String, dynamic>)
          : BuyerData.empty(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'token': token,
      'refreshToken': refreshToken,
      'buyer': buyer.toJson(),
    };
  }
}

class BuyerData {
  final String id;
  final String email;
  final String? fullName;
  final String? phoneNumber;
  final String registrationStep;
  final bool isEmailVerified;
  final String status;
  final Map<String, dynamic>? profilePicture;
  final Map<String, dynamic>? preferences;
  final DateTime? dateOfBirth;
  final Map<String, dynamic>? address;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLogin;
  final List<String>? wishlist;
  final List<CartItem>? cart;
  final DateTime? completedAt;
  final String? stripeCustomerId;
  final List<PaymentMethod>? paymentMethods;

  BuyerData({
    required this.id,
    required this.email,
    this.fullName,
    this.phoneNumber,
    required this.registrationStep,
    required this.isEmailVerified,
    required this.status,
    this.profilePicture,
    this.preferences,
    this.dateOfBirth,
    this.address,
    this.createdAt,
    this.updatedAt,
    this.lastLogin,
    this.wishlist,
    this.cart,
    this.completedAt,
    this.stripeCustomerId,
    this.paymentMethods,
  });

  factory BuyerData.empty() {
    return BuyerData(
      id: '',
      email: '',
      registrationStep: 'wallet_creation',
      isEmailVerified: false,
      status: 'active',
    );
  }

  factory BuyerData.fromJson(Map<String, dynamic> json) {
    return BuyerData(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['fullName']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      registrationStep: json['registrationStep']?.toString() ?? 'wallet_creation',
      isEmailVerified: json['isEmailVerified'] ?? false,
      status: json['status']?.toString() ?? 'active',
      profilePicture: json['profilePicture'] != null
          ? Map<String, dynamic>.from(json['profilePicture'])
          : null,
      preferences: json['preferences'] != null
          ? Map<String, dynamic>.from(json['preferences'])
          : null,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'].toString())
          : null,
      address: json['address'] != null
          ? Map<String, dynamic>.from(json['address'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      lastLogin: json['lastLogin'] != null
          ? DateTime.tryParse(json['lastLogin'].toString())
          : null,
      wishlist: json['wishlist'] != null
          ? List<String>.from(json['wishlist'])
          : null,
      cart: json['cart'] != null
          ? (json['cart'] as List).map((item) => CartItem.fromJson(item)).toList()
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'].toString())
          : null,
      stripeCustomerId: json['stripeCustomerId']?.toString(),
      paymentMethods: json['paymentMethods'] != null
          ? (json['paymentMethods'] as List).map((item) => PaymentMethod.fromJson(item)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'registrationStep': registrationStep,
      'isEmailVerified': isEmailVerified,
      'status': status,
      'profilePicture': profilePicture,
      'preferences': preferences,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'address': address,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'wishlist': wishlist,
      'cart': cart?.map((item) => item.toJson()).toList(),
      'completedAt': completedAt?.toIso8601String(),
      'stripeCustomerId': stripeCustomerId,
      'paymentMethods': paymentMethods?.map((item) => item.toJson()).toList(),
    };
  }

  BuyerData copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? registrationStep,
    bool? isEmailVerified,
    String? status,
    Map<String, dynamic>? profilePicture,
    Map<String, dynamic>? preferences,
    DateTime? dateOfBirth,
    Map<String, dynamic>? address,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLogin,
    List<String>? wishlist,
    List<CartItem>? cart,
    DateTime? completedAt,
    String? stripeCustomerId,
    List<PaymentMethod>? paymentMethods,
  }) {
    return BuyerData(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      registrationStep: registrationStep ?? this.registrationStep,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      status: status ?? this.status,
      profilePicture: profilePicture ?? this.profilePicture,
      preferences: preferences ?? this.preferences,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLogin: lastLogin ?? this.lastLogin,
      wishlist: wishlist ?? this.wishlist,
      cart: cart ?? this.cart,
      completedAt: completedAt ?? this.completedAt,
      stripeCustomerId: stripeCustomerId ?? this.stripeCustomerId,
      paymentMethods: paymentMethods ?? this.paymentMethods,
    );
  }
}

class CartItem {
  final String productId;
  final int quantity;
  final DateTime addedAt;
  final dynamic product; // Populated product details

  CartItem({
    required this.productId,
    required this.quantity,
    required this.addedAt,
    this.product,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId']?.toString() ?? '',
      quantity: json['quantity'] ?? 1,
      addedAt: json['addedAt'] != null
          ? DateTime.tryParse(json['addedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      product: json['productId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
      'addedAt': addedAt.toIso8601String(),
    };
  }
}

class PaymentMethod {
  final String paymentMethodId;
  final String brand;
  final String last4;
  final int expMonth;
  final int expYear;
  final bool isDefault;
  final DateTime createdAt;

  PaymentMethod({
    required this.paymentMethodId,
    required this.brand,
    required this.last4,
    required this.expMonth,
    required this.expYear,
    required this.isDefault,
    required this.createdAt,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      paymentMethodId: json['paymentMethodId']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      last4: json['last4']?.toString() ?? '',
      expMonth: json['expMonth'] ?? 0,
      expYear: json['expYear'] ?? 0,
      isDefault: json['isDefault'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentMethodId': paymentMethodId,
      'brand': brand,
      'last4': last4,
      'expMonth': expMonth,
      'expYear': expYear,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class BuyerProfile {
  final bool success;
  final BuyerData buyer;

  BuyerProfile({
    required this.success,
    required this.buyer,
  });

  factory BuyerProfile.fromJson(Map<String, dynamic> json) {
    return BuyerProfile(
      success: json['success'] ?? false,
      buyer: json['buyer'] != null
          ? BuyerData.fromJson(json['buyer'] as Map<String, dynamic>)
          : BuyerData.empty(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'buyer': buyer.toJson(),
    };
  }
}

class TokenValidityResponse {
  final bool success;
  final bool isValid;
  final bool needsRefresh;
  final String? message;
  final BuyerInfo? buyer;

  TokenValidityResponse({
    required this.success,
    required this.isValid,
    required this.needsRefresh,
    this.message,
    this.buyer,
  });

  factory TokenValidityResponse.fromJson(Map<String, dynamic> json) {
    return TokenValidityResponse(
      success: json['success'] ?? false,
      isValid: json['isValid'] ?? false,
      needsRefresh: json['needsRefresh'] ?? false,
      message: json['message']?.toString(),
      buyer: json['buyer'] != null
          ? BuyerInfo.fromJson(json['buyer'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'isValid': isValid,
      'needsRefresh': needsRefresh,
      'message': message,
      'buyer': buyer?.toJson(),
    };
  }
}

class BuyerInfo {
  final String id;
  final String email;
  final String fullName;
  final String role;

  BuyerInfo({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
  });

  factory BuyerInfo.fromJson(Map<String, dynamic> json) {
    return BuyerInfo(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'role': role,
    };
  }
}

class RefreshTokenResponse {
  final bool success;
  final String message;
  final String token;
  final String refreshToken;
  final BuyerSimpleInfo? buyer;

  RefreshTokenResponse({
    required this.success,
    required this.message,
    required this.token,
    required this.refreshToken,
    this.buyer,
  });

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponse(
      success: json['success'] ?? false,
      message: json['message']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString() ?? '',
      buyer: json['buyer'] != null
          ? BuyerSimpleInfo.fromJson(json['buyer'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'token': token,
      'refreshToken': refreshToken,
      'buyer': buyer?.toJson(),
    };
  }
}

class BuyerSimpleInfo {
  final String id;
  final String email;
  final String fullName;
  final String registrationStep;
  final bool isEmailVerified;

  BuyerSimpleInfo({
    required this.id,
    required this.email,
    required this.fullName,
    required this.registrationStep,
    required this.isEmailVerified,
  });

  factory BuyerSimpleInfo.fromJson(Map<String, dynamic> json) {
    return BuyerSimpleInfo(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      registrationStep: json['registrationStep']?.toString() ?? '',
      isEmailVerified: json['isEmailVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'registrationStep': registrationStep,
      'isEmailVerified': isEmailVerified,
    };
  }
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class RefreshTokenRequest {
  final String refreshToken;

  RefreshTokenRequest({
    required this.refreshToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'refreshToken': refreshToken,
    };
  }
}