// lib/Models/BuyerModels/BuyerOrderModels.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// ============================================
// ENUMS
// ============================================

enum OrderStatus {
  pending,
  paid,
  processing,
  shipped,
  partially_shipped,
  delivered,
  cancelled,
  refunded,
  partially_refunded;

  String get displayValue {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.paid:
        return 'Paid';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.partially_shipped:
        return 'Partially Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.refunded:
        return 'Refunded';
      case OrderStatus.partially_refunded:
        return 'Partially Refunded';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.paid:
        return Colors.blue;
      case OrderStatus.processing:
        return Colors.purple;
      case OrderStatus.shipped:
        return Colors.cyan;
      case OrderStatus.partially_shipped:
        return Colors.teal;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.refunded:
        return Colors.brown;
      case OrderStatus.partially_refunded:
        return Colors.amber;
    }
  }
}

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

  OrderProduct({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.image,
    this.attributes,
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
    };
  }

  double get totalPrice => price * quantity;
}

class PickupAddressDetails {
  final String addressLabel;
  final String street;
  final String apartment;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final String phoneNumber;

  PickupAddressDetails({
    required this.addressLabel,
    required this.street,
    required this.apartment,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    required this.phoneNumber,
  });

  factory PickupAddressDetails.fromJson(Map<String, dynamic> json) {
    return PickupAddressDetails(
      addressLabel: json['addressLabel'] ?? '',
      street: json['street'] ?? '',
      apartment: json['apartment'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zipCode: json['zipCode'] ?? '',
      country: json['country'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
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

class SellerInfo {
  final String id;
  final String storeName;
  final String? email;
  final String? phoneNumber;

  SellerInfo({
    required this.id,
    required this.storeName,
    this.email,
    this.phoneNumber,
  });

  factory SellerInfo.fromJson(Map<String, dynamic> json) {
    return SellerInfo(
      id: json['_id'] ?? '',
      storeName: json['storeName'] ?? '',
      email: json['email'],
      phoneNumber: json['phoneNumber'],
    );
  }
}

class SubOrder {
  final String id;
  final String subOrderNumber;
  final String mainOrderId;
  final String sellerId;
  final SellerInfo? seller;
  final List<OrderProduct> products;
  final double subtotal;
  final double shippingCost;
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

  SubOrder({
    required this.id,
    required this.subOrderNumber,
    required this.mainOrderId,
    required this.sellerId,
    this.seller,
    required this.products,
    required this.subtotal,
    required this.shippingCost,
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
  });

  factory SubOrder.fromJson(Map<String, dynamic> json) {
    // Handle sellerId - it could be a String OR an Object
    String sellerIdValue = '';
    SellerInfo? sellerInfo;

    final sellerIdRaw = json['sellerId'];

    if (sellerIdRaw is String) {
      // If it's a string, use it directly
      sellerIdValue = sellerIdRaw;
    } else if (sellerIdRaw is Map<String, dynamic>) {
      // If it's an object, extract the ID and create SellerInfo
      sellerIdValue = sellerIdRaw['_id'] ?? '';
      sellerInfo = SellerInfo.fromJson(sellerIdRaw);
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

    return SubOrder(
      id: json['_id'] ?? '',
      subOrderNumber: json['subOrderNumber'] ?? '',
      mainOrderId: json['mainOrderId'] ?? '',
      sellerId: sellerIdValue,
      seller: sellerInfo,
      products: (json['products'] as List?)
          ?.map((e) => OrderProduct.fromJson(e))
          .toList() ??
          [],
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      shippingCost: (json['shippingCost'] ?? 0).toDouble(),
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
      trackingNumber: json['trackingNumber'] ?? (json['shipment'] != null ? json['shipment']['trackingNumber'] : null),
      trackingUrl: json['trackingUrl'] ?? (json['shipment'] != null ? json['shipment']['trackingUrl'] : null),
      labelUrl: json['labelUrl'] ?? (json['shipment'] != null ? json['shipment']['labelUrl'] : null),
      carrier: json['carrier'] ?? (json['shipment'] != null ? json['shipment']['carrier'] : null),
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
}

class MainOrder {
  final String id;
  final String orderNumber;
  final String userId;
  final double totalAmount;
  final OrderStatus status;
  final String paymentIntentId;
  final String paymentMethod;
  final ShippingAddress shippingAddress;
  final DateTime? paidAt;
  final double totalRefundedAmount;
  final RefundStatus refundStatus;
  final List<SubOrder> subOrders;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double discountAmount;
  final double taxAmount;

  MainOrder({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.totalAmount,
    required this.status,
    required this.paymentIntentId,
    required this.paymentMethod,
    required this.shippingAddress,
    this.paidAt,
    required this.totalRefundedAmount,
    required this.refundStatus,
    required this.subOrders,
    this.createdAt,
    this.updatedAt,
    this.discountAmount = 0,
    this.taxAmount = 0,
  });

  factory MainOrder.fromJson(Map<String, dynamic> json) {
    // Parse main order status
    OrderStatus orderStatus;
    switch (json['status']) {
      case 'shipped':
        orderStatus = OrderStatus.shipped;
        break;
      case 'delivered':
        orderStatus = OrderStatus.delivered;
        break;
      case 'cancelled':
        orderStatus = OrderStatus.cancelled;
        break;
      case 'refunded':
        orderStatus = OrderStatus.refunded;
        break;
      case 'paid':
        orderStatus = OrderStatus.paid;
        break;
      case 'processing':
        orderStatus = OrderStatus.processing;
        break;
      case 'partially_shipped':
        orderStatus = OrderStatus.partially_shipped;
        break;
      case 'partially_refunded':
        orderStatus = OrderStatus.partially_refunded;
        break;
      default:
        orderStatus = OrderStatus.pending;
    }

    // Parse refund status
    RefundStatus refundStatusEnum;
    switch (json['refundStatus']) {
      case 'pending':
        refundStatusEnum = RefundStatus.pending;
        break;
      case 'processed':
        refundStatusEnum = RefundStatus.processed;
        break;
      case 'failed':
        refundStatusEnum = RefundStatus.failed;
        break;
      default:
        refundStatusEnum = RefundStatus.none;
    }

    return MainOrder(
      id: json['_id'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      userId: json['userId'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: orderStatus,
      paymentIntentId: json['paymentIntentId'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      shippingAddress: ShippingAddress.fromJson(json['shippingAddress'] ?? {}),
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
      totalRefundedAmount: (json['totalRefundedAmount'] ?? 0).toDouble(),
      refundStatus: refundStatusEnum,
      subOrders: (json['subOrders'] as List?)
          ?.map((e) => SubOrder.fromJson(e))
          .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      taxAmount: (json['taxAmount'] ?? 0).toDouble(),
    );
  }

  int get totalItems {
    return subOrders.fold(
        0, (sum, subOrder) => sum + subOrder.products.fold(0, (sum, p) => sum + p.quantity));
  }

  String get formattedOrderDate {
    if (createdAt == null) return 'N/A';
    return '${createdAt!.month}/${createdAt!.day}/${createdAt!.year}';
  }
}

// ============================================
// REQUEST MODELS
// ============================================

class CreateOrderRequest {
  final List<OrderItemRequest> products;
  final ShippingAddress shippingAddress;
  final String paymentMethodId;
  final String? idempotencyKey;

  CreateOrderRequest({
    required this.products,
    required this.shippingAddress,
    required this.paymentMethodId,
    this.idempotencyKey,
  });

  Map<String, dynamic> toJson() {
    return {
      'products': products.map((e) => e.toJson()).toList(),
      'shippingAddress': shippingAddress.toJson(),
      'paymentMethodId': paymentMethodId,
      if (idempotencyKey != null) 'idempotencyKey': idempotencyKey,
    };
  }
}

class OrderItemRequest {
  final String productId;
  final int quantity;

  OrderItemRequest({
    required this.productId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
    };
  }
}

// ============================================
// RESPONSE MODELS
// ============================================

class CreateOrderResponse {
  final MainOrder mainOrder;
  final List<SubOrder> subOrders;
  final PaymentIntentInfo paymentIntent;

  CreateOrderResponse({
    required this.mainOrder,
    required this.subOrders,
    required this.paymentIntent,
  });

  factory CreateOrderResponse.fromJson(Map<String, dynamic> json) {
    return CreateOrderResponse(
      mainOrder: MainOrder.fromJson(json['mainOrder'] ?? {}),
      subOrders: (json['subOrders'] as List?)
          ?.map((e) => SubOrder.fromJson(e))
          .toList() ??
          [],
      paymentIntent: PaymentIntentInfo.fromJson(json['paymentIntent'] ?? {}),
    );
  }
}

class PaymentIntentInfo {
  final String id;
  final String status;
  final String? clientSecret;

  PaymentIntentInfo({
    required this.id,
    required this.status,
    this.clientSecret,
  });

  factory PaymentIntentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentIntentInfo(
      id: json['id'] ?? '',
      status: json['status'] ?? '',
      clientSecret: json['clientSecret'],
    );
  }
}

class OrdersListResponse {
  final List<MainOrder> orders;
  final PaginationInfo pagination;

  OrdersListResponse({
    required this.orders,
    required this.pagination,
  });

  factory OrdersListResponse.fromJson(Map<String, dynamic> json) {
    return OrdersListResponse(
      orders: (json['orders'] as List?)
          ?.map((e) => MainOrder.fromJson(e))
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

class TrackingInfoResponse {
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

  TrackingInfoResponse({
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

  factory TrackingInfoResponse.fromJson(Map<String, dynamic> json) {
    return TrackingInfoResponse(
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