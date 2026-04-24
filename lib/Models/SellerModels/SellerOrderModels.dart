// lib/Models/SellerModels/SellerOrderModels.dart

import 'package:flutter/material.dart';

// ============================================
// ENUMS
// ============================================

enum SubOrderStatus {
  pending,
  paid,
  processing,
  shipped,
  delivered,
  cancelled,
  refunded;

  String get displayValue {
    switch (this) {
      case SubOrderStatus.pending:
        return 'Pending';
      case SubOrderStatus.paid:
        return 'Paid';
      case SubOrderStatus.processing:
        return 'Processing';
      case SubOrderStatus.shipped:
        return 'Shipped';
      case SubOrderStatus.delivered:
        return 'Delivered';
      case SubOrderStatus.cancelled:
        return 'Cancelled';
      case SubOrderStatus.refunded:
        return 'Refunded';
    }
  }

  Color get color {
    switch (this) {
      case SubOrderStatus.pending:
        return Colors.orange;
      case SubOrderStatus.paid:
        return Colors.blue;
      case SubOrderStatus.processing:
        return Colors.purple;
      case SubOrderStatus.shipped:
        return Colors.cyan;
      case SubOrderStatus.delivered:
        return Colors.green;
      case SubOrderStatus.cancelled:
        return Colors.red;
      case SubOrderStatus.refunded:
        return Colors.brown;
    }
  }
}

enum ShippingStatus {
  pending,
  parcel_building,
  parcel_validated,
  shipment_created,
  rates_fetched,
  label_purchased,
  failed,
  retry_scheduled;

  String get displayValue {
    switch (this) {
      case ShippingStatus.pending:
        return 'Pending';
      case ShippingStatus.parcel_building:
        return 'Building Parcel';
      case ShippingStatus.parcel_validated:
        return 'Validating Parcel';
      case ShippingStatus.shipment_created:
        return 'Creating Shipment';
      case ShippingStatus.rates_fetched:
        return 'Fetching Rates';
      case ShippingStatus.label_purchased:
        return 'Label Purchased';
      case ShippingStatus.failed:
        return 'Failed';
      case ShippingStatus.retry_scheduled:
        return 'Retry Scheduled';
    }
  }
}

enum RefundStatus {
  none,
  pending,
  processed,
  failed;

  String get displayValue {
    switch (this) {
      case RefundStatus.none:
        return 'None';
      case RefundStatus.pending:
        return 'Pending';
      case RefundStatus.processed:
        return 'Processed';
      case RefundStatus.failed:
        return 'Failed';
    }
  }
}

// ============================================
// MODELS
// ============================================

class ShippingAddress {
  final String fullName;
  final String? country;
  final String street;
  final String? apartment;
  final String city;
  final String state;
  final String zipCode;
  final String phoneNumber;
  final String? email;

  ShippingAddress({
    required this.fullName,
    this.country,
    required this.street,
    this.apartment,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.phoneNumber,
    this.email,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      fullName: json['fullName'] ?? '',
      country: json['country'],
      street: json['street'] ?? '',
      apartment: json['apartment'] == '' || json['apartment'] == null ? null : json['apartment'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zipCode: json['zipCode'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      if (country != null) 'country': country,
      'street': street,
      if (apartment != null) 'apartment': apartment,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'phoneNumber': phoneNumber,
      if (email != null) 'email': email,
    };
  }
}

class OrderProduct {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String? image;
  final Map<String, dynamic>? attributes;
  final double? weight;
  final double? length;
  final double? width;
  final double? height;

  OrderProduct({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.image,
    this.attributes,
    this.weight,
    this.length,
    this.width,
    this.height,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      productId: json['productId'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      image: json['image'],
      attributes: json['attributes'] is Map<String, dynamic>
          ? json['attributes']
          : null,
      weight: json['weight']?.toDouble(),
      length: json['length']?.toDouble(),
      width: json['width']?.toDouble(),
      height: json['height']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      if (image != null) 'image': image,
      if (attributes != null) 'attributes': attributes,
      if (weight != null) 'weight': weight,
      if (length != null) 'length': length,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
    };
  }

  double get totalPrice => price * quantity;
}

class PickupAddressDetails {
  final String? id;
  final String addressLabel;
  final String street;
  final String apartment;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final String phoneNumber;
  final bool isDefault;
  final bool isActive;

  PickupAddressDetails({
    this.id,
    required this.addressLabel,
    required this.street,
    required this.apartment,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    required this.phoneNumber,
    this.isDefault = false,
    this.isActive = true,
  });

  factory PickupAddressDetails.fromJson(Map<String, dynamic> json) {
    return PickupAddressDetails(
      id: json['_id'],
      addressLabel: json['addressLabel'] ?? '',
      street: json['street'] ?? '',
      apartment: json['apartment'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zipCode: json['zipCode'] ?? '',
      country: json['country'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      isDefault: json['isDefault'] ?? false,
      isActive: json['isActive'] ?? true,
    );
  }
}

class ShipmentInfo {
  final String? carrier;
  final String? trackingNumber;
  final String? trackingUrl;
  final String? labelUrl;
  final double? cost;
  final DateTime? purchasedAt;

  ShipmentInfo({
    this.carrier,
    this.trackingNumber,
    this.trackingUrl,
    this.labelUrl,
    this.cost,
    this.purchasedAt,
  });

  factory ShipmentInfo.fromJson(Map<String, dynamic> json) {
    return ShipmentInfo(
      carrier: json['carrier'],
      trackingNumber: json['trackingNumber'],
      trackingUrl: json['trackingUrl'],
      labelUrl: json['labelUrl'],
      cost: json['cost']?.toDouble(),
      purchasedAt: json['purchasedAt'] != null
          ? DateTime.parse(json['purchasedAt'])
          : null,
    );
  }
}

class ParcelInfo {
  final double length;
  final double width;
  final double height;
  final String distanceUnit;
  final double weight;
  final String massUnit;
  final bool isValid;
  final List<String> validationErrors;

  ParcelInfo({
    required this.length,
    required this.width,
    required this.height,
    required this.distanceUnit,
    required this.weight,
    required this.massUnit,
    this.isValid = true,
    this.validationErrors = const [],
  });

  factory ParcelInfo.fromJson(Map<String, dynamic> json) {
    return ParcelInfo(
      length: (json['length'] ?? 0).toDouble(),
      width: (json['width'] ?? 0).toDouble(),
      height: (json['height'] ?? 0).toDouble(),
      distanceUnit: json['distanceUnit'] ?? 'in',
      weight: (json['weight'] ?? 0).toDouble(),
      massUnit: json['massUnit'] ?? 'lb',
      isValid: json['isValid'] ?? true,
      validationErrors: (json['validationErrors'] as List?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
    );
  }
}

class RefundInfo {
  final RefundStatus status;
  final double amount;
  final DateTime? processedAt;
  final String? reason;

  RefundInfo({
    required this.status,
    required this.amount,
    this.processedAt,
    this.reason,
  });

  factory RefundInfo.fromJson(Map<String, dynamic> json) {
    String statusStr = json['status'] ?? 'none';
    RefundStatus refundStatus;
    switch (statusStr) {
      case 'pending':
        refundStatus = RefundStatus.pending;
        break;
      case 'processed':
        refundStatus = RefundStatus.processed;
        break;
      case 'failed':
        refundStatus = RefundStatus.failed;
        break;
      default:
        refundStatus = RefundStatus.none;
    }

    return RefundInfo(
      status: refundStatus,
      amount: (json['amount'] ?? 0).toDouble(),
      processedAt: json['processedAt'] != null
          ? DateTime.parse(json['processedAt'])
          : null,
      reason: json['reason'],
    );
  }
}

class MainOrderInfo {
  final String id;
  final String orderNumber;
  final ShippingAddress? shippingAddress;

  MainOrderInfo({
    required this.id,
    required this.orderNumber,
    this.shippingAddress,
  });

  factory MainOrderInfo.fromJson(Map<String, dynamic> json) {
    return MainOrderInfo(
      id: json['_id'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      shippingAddress: json['shippingAddress'] != null
          ? ShippingAddress.fromJson(json['shippingAddress'])
          : null,
    );
  }
}

class SellerSubOrder {
  final String id;
  final String subOrderNumber;
  final String mainOrderId;
  final MainOrderInfo? mainOrder;
  final String sellerId;
  final List<OrderProduct> products;
  final double subtotal;
  final double shippingCost;
  final double discountAmount;
  final double taxAmount;
  final double totalAmount;
  final SubOrderStatus status;
  final ShippingStatus shippingStatus;
  final int shippingAttempts;
  final int maxShippingAttempts;
  final ShippingAddress shippingAddress;
  final String pickupAddressId;
  final PickupAddressDetails? pickupAddressDetails;
  final int estimatedDeliveryDays;
  final bool isEligibleForRefund;
  final RefundInfo refund;
  final bool stockDeducted;
  final DateTime? stockDeductedAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final String? trackingNumber;
  final String? trackingUrl;
  final String? labelUrl;
  final String? carrier;
  final double? shippingCostActual;
  final String? shipmentId;
  final String? cancellationReason;
  final String? lastShippingError;
  final DateTime? lastShippingAttemptAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final ShipmentInfo? shipment;
  final ParcelInfo? parcel;
  final Map<String, dynamic>? metadata;

  SellerSubOrder({
    required this.id,
    required this.subOrderNumber,
    required this.mainOrderId,
    this.mainOrder,
    required this.sellerId,
    required this.products,
    required this.subtotal,
    required this.shippingCost,
    required this.discountAmount,
    required this.taxAmount,
    required this.totalAmount,
    required this.status,
    required this.shippingStatus,
    required this.shippingAttempts,
    required this.maxShippingAttempts,
    required this.shippingAddress,
    required this.pickupAddressId,
    this.pickupAddressDetails,
    required this.estimatedDeliveryDays,
    required this.isEligibleForRefund,
    required this.refund,
    required this.stockDeducted,
    this.stockDeductedAt,
    this.shippedAt,
    this.deliveredAt,
    this.trackingNumber,
    this.trackingUrl,
    this.labelUrl,
    this.carrier,
    this.shippingCostActual,
    this.shipmentId,
    this.cancellationReason,
    this.lastShippingError,
    this.lastShippingAttemptAt,
    this.createdAt,
    this.updatedAt,
    this.shipment,
    this.parcel,
    this.metadata,
  });

  factory SellerSubOrder.fromJson(Map<String, dynamic> json) {
    // Handle mainOrderId - it could be a String OR an Object
    String mainOrderIdValue = '';
    MainOrderInfo? mainOrderInfo;

    final mainOrderIdRaw = json['mainOrderId'];
    if (mainOrderIdRaw is String) {
      // If it's a string, use it directly
      mainOrderIdValue = mainOrderIdRaw;
    } else if (mainOrderIdRaw is Map<String, dynamic>) {
      // If it's an object, extract the ID and create MainOrderInfo
      mainOrderIdValue = mainOrderIdRaw['_id'] ?? '';
      mainOrderInfo = MainOrderInfo.fromJson(mainOrderIdRaw);
    }

    // Parse status
    SubOrderStatus orderStatus;
    switch (json['status']) {
      case 'shipped':
        orderStatus = SubOrderStatus.shipped;
        break;
      case 'delivered':
        orderStatus = SubOrderStatus.delivered;
        break;
      case 'cancelled':
        orderStatus = SubOrderStatus.cancelled;
        break;
      case 'refunded':
        orderStatus = SubOrderStatus.refunded;
        break;
      case 'paid':
        orderStatus = SubOrderStatus.paid;
        break;
      case 'processing':
        orderStatus = SubOrderStatus.processing;
        break;
      default:
        orderStatus = SubOrderStatus.pending;
    }

    // Parse shipping status
    ShippingStatus shippingStatusEnum;
    switch (json['shippingStatus']) {
      case 'label_purchased':
        shippingStatusEnum = ShippingStatus.label_purchased;
        break;
      case 'pending':
        shippingStatusEnum = ShippingStatus.pending;
        break;
      case 'parcel_building':
        shippingStatusEnum = ShippingStatus.parcel_building;
        break;
      case 'parcel_validated':
        shippingStatusEnum = ShippingStatus.parcel_validated;
        break;
      case 'shipment_created':
        shippingStatusEnum = ShippingStatus.shipment_created;
        break;
      case 'rates_fetched':
        shippingStatusEnum = ShippingStatus.rates_fetched;
        break;
      case 'failed':
        shippingStatusEnum = ShippingStatus.failed;
        break;
      case 'retry_scheduled':
        shippingStatusEnum = ShippingStatus.retry_scheduled;
        break;
      default:
        shippingStatusEnum = ShippingStatus.pending;
    }

    return SellerSubOrder(
      id: json['_id'] ?? '',
      subOrderNumber: json['subOrderNumber'] ?? '',
      mainOrderId: mainOrderIdValue,
      mainOrder: mainOrderInfo,
      sellerId: json['sellerId'] ?? '',
      products: (json['products'] as List?)
          ?.map((e) => OrderProduct.fromJson(e))
          .toList() ??
          [],
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      shippingCost: (json['shippingCost'] ?? 0).toDouble(),
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      taxAmount: (json['taxAmount'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: orderStatus,
      shippingStatus: shippingStatusEnum,
      shippingAttempts: json['shippingAttempts'] ?? 0,
      maxShippingAttempts: json['maxShippingAttempts'] ?? 3,
      shippingAddress: ShippingAddress.fromJson(json['shippingAddress'] ?? {}),
      pickupAddressId: json['pickupAddressId'] ?? '',
      pickupAddressDetails: json['pickupAddressDetails'] != null
          ? PickupAddressDetails.fromJson(json['pickupAddressDetails'])
          : null,
      estimatedDeliveryDays: json['estimatedDeliveryDays'] ?? 7,
      isEligibleForRefund: json['isEligibleForRefund'] ?? false,
      refund: RefundInfo.fromJson(json['refund'] ?? {}),
      stockDeducted: json['stockDeducted'] ?? false,
      stockDeductedAt: json['stockDeductedAt'] != null
          ? DateTime.parse(json['stockDeductedAt'])
          : null,
      shippedAt: json['shippedAt'] != null
          ? DateTime.parse(json['shippedAt'])
          : null,
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'])
          : null,
      trackingNumber: json['trackingNumber'],
      trackingUrl: json['trackingUrl'],
      labelUrl: json['labelUrl'],
      carrier: json['carrier'],
      shippingCostActual: json['shippingCostActual']?.toDouble(),
      shipmentId: json['shipmentId'],
      cancellationReason: json['cancellationReason'],
      lastShippingError: json['lastShippingError'],
      lastShippingAttemptAt: json['lastShippingAttemptAt'] != null
          ? DateTime.parse(json['lastShippingAttemptAt'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      shipment: json['shipment'] != null && json['shipment'] is Map<String, dynamic>
          ? ShipmentInfo.fromJson(json['shipment'])
          : null,
      parcel: json['parcel'] != null && json['parcel'] is Map<String, dynamic>
          ? ParcelInfo.fromJson(json['parcel'])
          : null,
      metadata: json['metadata'],
    );
  }

  String get estimatedDeliveryDate {
    if (shippedAt == null) return 'Not yet shipped';
    final estimatedDate = shippedAt!.add(Duration(days: estimatedDeliveryDays));
    return _formatDate(estimatedDate);
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  int get totalItems {
    return products.fold(0, (sum, p) => sum + p.quantity);
  }

  String get buyerName {
    return mainOrder?.shippingAddress?.fullName ??
        shippingAddress.fullName;
  }
}

// ============================================
// REQUEST MODELS
// ============================================

class UpdateOrderStatusRequest {
  final String status;
  final String? trackingNumber;
  final String? carrier;

  UpdateOrderStatusRequest({
    required this.status,
    this.trackingNumber,
    this.carrier,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      if (trackingNumber != null) 'trackingNumber': trackingNumber,
      if (carrier != null) 'carrier': carrier,
    };
  }
}

class ShippingSettings {
  final bool autoGenerateLabels;
  final String? defaultCarrier;
  final Map<String, dynamic>? preferences;

  ShippingSettings({
    this.autoGenerateLabels = false,
    this.defaultCarrier,
    this.preferences,
  });

  factory ShippingSettings.fromJson(Map<String, dynamic> json) {
    return ShippingSettings(
      autoGenerateLabels: json['autoGenerateLabels'] ?? false,
      defaultCarrier: json['defaultCarrier'],
      preferences: json['preferences'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'autoGenerateLabels': autoGenerateLabels,
      if (defaultCarrier != null) 'defaultCarrier': defaultCarrier,
      if (preferences != null) 'preferences': preferences,
    };
  }
}

class UpdateShippingSettingsRequest {
  final ShippingSettings shippingSettings;

  UpdateShippingSettingsRequest({
    required this.shippingSettings,
  });

  Map<String, dynamic> toJson() {
    return {
      'shippingSettings': shippingSettings.toJson(),
    };
  }
}

// ============================================
// RESPONSE MODELS
// ============================================

class SellerOrdersListResponse {
  final List<SellerSubOrder> orders;
  final PaginationInfo pagination;

  SellerOrdersListResponse({
    required this.orders,
    required this.pagination,
  });

  factory SellerOrdersListResponse.fromJson(Map<String, dynamic> json) {
    return SellerOrdersListResponse(
      orders: (json['orders'] as List?)
          ?.map((e) => SellerSubOrder.fromJson(e))
          .toList() ??
          [],
      pagination: PaginationInfo.fromJson(json['pagination'] ?? {}),
    );
  }
}

class PaginationInfo {
  final int page;
  final int limit;
  final int total;
  final int pages;

  PaginationInfo({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      pages: json['pages'] ?? 0,
    );
  }

  bool get hasNextPage => page < pages;
  bool get hasPreviousPage => page > 1;
}

class SellerTrackingInfoResponse {
  final String trackingNumber;
  final String? trackingUrl;
  final String? carrier;
  final String? labelUrl;
  final String? status;
  final DateTime? estimatedDelivery;
  final String? currentLocation;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final bool stockDeducted;
  final DateTime? stockDeductedAt;

  SellerTrackingInfoResponse({
    required this.trackingNumber,
    this.trackingUrl,
    this.carrier,
    this.labelUrl,
    this.status,
    this.estimatedDelivery,
    this.currentLocation,
    this.shippedAt,
    this.deliveredAt,
    required this.stockDeducted,
    this.stockDeductedAt,
  });

  factory SellerTrackingInfoResponse.fromJson(Map<String, dynamic> json) {
    return SellerTrackingInfoResponse(
      trackingNumber: json['trackingNumber'] ?? '',
      trackingUrl: json['trackingUrl'],
      carrier: json['carrier'],
      labelUrl: json['labelUrl'],
      status: json['status'],
      estimatedDelivery: json['estimatedDelivery'] != null
          ? DateTime.parse(json['estimatedDelivery'])
          : null,
      currentLocation: json['currentLocation'],
      shippedAt: json['shippedAt'] != null
          ? DateTime.parse(json['shippedAt'])
          : null,
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'])
          : null,
      stockDeducted: json['stockDeducted'] ?? false,
      stockDeductedAt: json['stockDeductedAt'] != null
          ? DateTime.parse(json['stockDeductedAt'])
          : null,
    );
  }
}

class ShippingSettingsResponse {
  final ShippingSettings settings;
  final List<PickupAddressDetails> pickupAddresses;
  final PickupAddressDetails? defaultAddress;

  ShippingSettingsResponse({
    required this.settings,
    required this.pickupAddresses,
    this.defaultAddress,
  });

  factory ShippingSettingsResponse.fromJson(Map<String, dynamic> json) {
    return ShippingSettingsResponse(
      settings: ShippingSettings.fromJson(json['settings'] ?? {}),
      pickupAddresses: (json['pickupAddresses'] as List?)
          ?.map((e) => PickupAddressDetails.fromJson(e))
          .toList() ??
          [],
      defaultAddress: json['defaultAddress'] != null
          ? PickupAddressDetails.fromJson(json['defaultAddress'])
          : null,
    );
  }
}

class GenerateLabelResponse {
  final bool success;
  final String message;
  final String? subOrderId;

  GenerateLabelResponse({
    required this.success,
    required this.message,
    this.subOrderId,
  });

  factory GenerateLabelResponse.fromJson(Map<String, dynamic> json) {
    return GenerateLabelResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      subOrderId: json['data']?['subOrderId'],
    );
  }
}