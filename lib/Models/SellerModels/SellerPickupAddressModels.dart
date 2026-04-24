// lib/Models/SellerModels/SellerPickupAddressModels.dart

class PickupAddress {
  final String id;
  final String sellerId;
  final String addressLabel;
  final String street;
  final String apartment;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final String phoneNumber;
  final String company;
  final String email;
  final bool isDefault;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  PickupAddress({
    required this.id,
    required this.sellerId,
    required this.addressLabel,
    required this.street,
    required this.apartment,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    required this.phoneNumber,
    required this.company,
    required this.email,
    required this.isDefault,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PickupAddress.fromJson(Map<String, dynamic> json) {
    return PickupAddress(
      id: json['_id'] ?? json['id'] ?? '',
      sellerId: json['sellerId'] ?? '',
      addressLabel: json['addressLabel'] ?? '',
      street: json['street'] ?? '',
      apartment: json['apartment'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zipCode: json['zipCode'] ?? '',
      country: json['country'] ?? 'United States',
      phoneNumber: json['phoneNumber'] ?? '',
      company: json['company'] ?? '',
      email: json['email'] ?? '',
      isDefault: json['isDefault'] ?? false,
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'sellerId': sellerId,
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
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  PickupAddress copyWith({
    String? id,
    String? sellerId,
    String? addressLabel,
    String? street,
    String? apartment,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    String? phoneNumber,
    String? company,
    String? email,
    bool? isDefault,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PickupAddress(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      addressLabel: addressLabel ?? this.addressLabel,
      street: street ?? this.street,
      apartment: apartment ?? this.apartment,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      company: company ?? this.company,
      email: email ?? this.email,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Address Validation Response Model
class AddressValidationResponse {
  final bool success;
  final String message;
  final String? validationSource;
  final List<String>? errors;
  final bool needsCorrection;
  final Map<String, dynamic>? originalAddress;
  final Map<String, dynamic>? normalizedAddress;
  final Map<String, dynamic>? suggestedAddress;

  AddressValidationResponse({
    required this.success,
    required this.message,
    this.validationSource,
    this.errors,
    this.needsCorrection = false,
    this.originalAddress,
    this.normalizedAddress,
    this.suggestedAddress,
  });

  factory AddressValidationResponse.fromJson(Map<String, dynamic> json) {
    List<String>? errorList;
    if (json['errors'] != null) {
      if (json['errors'] is List) {
        errorList = List<String>.from(json['errors']);
      } else if (json['errors'] is String) {
        errorList = [json['errors']];
      }
    }

    return AddressValidationResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      validationSource: json['validationSource'],
      errors: errorList,
      needsCorrection: json['needsCorrection'] ?? false,
      originalAddress: json['originalAddress'],
      normalizedAddress: json['normalizedAddress'],
      suggestedAddress: json['suggestedAddress'] ?? json['normalizedAddress'],
    );
  }

  bool get hasSuggestedAddress => suggestedAddress != null && suggestedAddress!.isNotEmpty;

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
}

class CreatePickupAddressRequest {
  final String addressLabel;
  final String street;
  final String? apartment;
  final String city;
  final String state;
  final String zipCode;
  final String? country;
  final String phoneNumber;
  final String? company;
  final String? email;
  final bool? isDefault;
  final bool? skipValidation;

  CreatePickupAddressRequest({
    required this.addressLabel,
    required this.street,
    this.apartment,
    required this.city,
    required this.state,
    required this.zipCode,
    this.country,
    required this.phoneNumber,
    this.company,
    this.email,
    this.isDefault,
    this.skipValidation,
  });

  Map<String, dynamic> toJson() {
    return {
      'addressLabel': addressLabel,
      'street': street,
      if (apartment != null) 'apartment': apartment,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      if (country != null) 'country': country,
      'phoneNumber': phoneNumber,
      if (company != null) 'company': company,
      if (email != null) 'email': email,
      if (isDefault != null) 'isDefault': isDefault,
      if (skipValidation != null) 'skipValidation': skipValidation,
    };
  }
}

class UpdatePickupAddressRequest {
  final String? addressLabel;
  final String? street;
  final String? apartment;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;
  final String? phoneNumber;
  final String? company;
  final String? email;
  final bool? isDefault;
  final bool? isActive;
  final bool? skipValidation;

  UpdatePickupAddressRequest({
    this.addressLabel,
    this.street,
    this.apartment,
    this.city,
    this.state,
    this.zipCode,
    this.country,
    this.phoneNumber,
    this.company,
    this.email,
    this.isDefault,
    this.isActive,
    this.skipValidation,
  });

  Map<String, dynamic> toJson() {
    return {
      if (addressLabel != null) 'addressLabel': addressLabel,
      if (street != null) 'street': street,
      if (apartment != null) 'apartment': apartment,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (zipCode != null) 'zipCode': zipCode,
      if (country != null) 'country': country,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (company != null) 'company': company,
      if (email != null) 'email': email,
      if (isDefault != null) 'isDefault': isDefault,
      if (isActive != null) 'isActive': isActive,
      if (skipValidation != null) 'skipValidation': skipValidation,
    };
  }
}

class BulkAddressUpdateRequest {
  final List<BulkAddressItem> addresses;
  final bool? skipValidation;

  BulkAddressUpdateRequest({required this.addresses, this.skipValidation});

  Map<String, dynamic> toJson() {
    return {
      'addresses': addresses.map((e) => e.toJson()).toList(),
      if (skipValidation != null) 'skipValidation': skipValidation,
    };
  }
}

class BulkAddressItem {
  final String? id;
  final String addressLabel;
  final String street;
  final String? apartment;
  final String city;
  final String state;
  final String zipCode;
  final String? country;
  final String phoneNumber;
  final String? company;
  final String? email;
  final bool? isDefault;
  final bool? isActive;

  BulkAddressItem({
    this.id,
    required this.addressLabel,
    required this.street,
    this.apartment,
    required this.city,
    required this.state,
    required this.zipCode,
    this.country,
    required this.phoneNumber,
    this.company,
    this.email,
    this.isDefault,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'addressLabel': addressLabel,
      'street': street,
      if (apartment != null) 'apartment': apartment,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      if (country != null) 'country': country,
      'phoneNumber': phoneNumber,
      if (company != null) 'company': company,
      if (email != null) 'email': email,
      if (isDefault != null) 'isDefault': isDefault,
      if (isActive != null) 'isActive': isActive,
    };
  }
}

class BulkUpdateResponse {
  final List<PickupAddress> created;
  final List<PickupAddress> updated;
  final List<BulkError> errors;

  BulkUpdateResponse({
    required this.created,
    required this.updated,
    required this.errors,
  });

  factory BulkUpdateResponse.fromJson(Map<String, dynamic> json) {
    return BulkUpdateResponse(
      created: (json['created'] as List?)
          ?.map((e) => PickupAddress.fromJson(e))
          .toList() ??
          [],
      updated: (json['updated'] as List?)
          ?.map((e) => PickupAddress.fromJson(e))
          .toList() ??
          [],
      errors: (json['errors'] as List?)
          ?.map((e) => BulkError.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class BulkError {
  final String? id;
  final dynamic data;
  final String error;
  final List<String>? validationErrors;

  BulkError({this.id, this.data, required this.error, this.validationErrors});

  factory BulkError.fromJson(Map<String, dynamic> json) {
    return BulkError(
      id: json['id'],
      data: json['data'],
      error: json['error'] ?? 'Unknown error',
      validationErrors: json['validationErrors'] != null
          ? List<String>.from(json['validationErrors'])
          : null,
    );
  }
}