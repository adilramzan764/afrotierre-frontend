// lib/Models/BuyerModels/CheckoutModels.dart

import 'package:flutter/material.dart';
import 'BuyerLoginandProfileModels.dart';
import 'BuyerOrderModels.dart';

// ============================================
// CHECKOUT MODELS
// ============================================

class CheckoutData {
  final String checkoutId;
  final BuyerInfo buyer;
  final ShippingAddress? shippingAddress;
  final PaymentMethod? paymentMethod;
  final List<SellerCheckoutGroup> sellers;
  final CheckoutSummary summary;
  final int itemCount;
  final DateTime createdAt;
  final DateTime expiresAt;

  CheckoutData({
    required this.checkoutId,
    required this.buyer,
    this.shippingAddress,
    this.paymentMethod,
    required this.sellers,
    required this.summary,
    required this.itemCount,
    required this.createdAt,
    required this.expiresAt,
  });

  factory CheckoutData.fromJson(Map<String, dynamic> json) {
    return CheckoutData(
      checkoutId: json['checkoutId'] ?? '',
      buyer: BuyerInfo.fromJson(json['buyer'] ?? {}),
      shippingAddress: json['shippingAddress'] != null
          ? ShippingAddress.fromJson(json['shippingAddress'])
          : null,
      paymentMethod: json['paymentMethod'] != null
          ? PaymentMethod.fromJson(json['paymentMethod'])
          : null,
      sellers: (json['sellers'] as List?)
          ?.map((e) => SellerCheckoutGroup.fromJson(e))
          .toList() ??
          [],
      summary: CheckoutSummary.fromJson(json['summary'] ?? {}),
      itemCount: json['itemCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: DateTime.parse(json['expiresAt']),
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  Duration get timeRemaining => expiresAt.difference(DateTime.now());
  String get formattedTimeRemaining {
    if (isExpired) return 'Expired';
    final hours = timeRemaining.inHours;
    final minutes = timeRemaining.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }
}

class BuyerInfo {
  final String id;
  final String email;
  final String fullName;
  final String phoneNumber;

  BuyerInfo({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
  });

  factory BuyerInfo.fromJson(Map<String, dynamic> json) {
    return BuyerInfo(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? 'Guest',
      phoneNumber: json['phoneNumber'] ?? '',
    );
  }
}

class SellerCheckoutGroup {
  final String sellerId;
  final String storeName;
  final String? sellerEmail;
  final String? sellerPhone;
  final List<CheckoutItem> items;
  final double subtotal;
  final double shippingCost;
  final int itemCount;
  final int estimatedDeliveryDays;
  final double weight;

  SellerCheckoutGroup({
    required this.sellerId,
    required this.storeName,
    this.sellerEmail,
    this.sellerPhone,
    required this.items,
    required this.subtotal,
    required this.shippingCost,
    required this.itemCount,
    required this.estimatedDeliveryDays,
    required this.weight,
  });

  factory SellerCheckoutGroup.fromJson(Map<String, dynamic> json) {
    return SellerCheckoutGroup(
      sellerId: json['sellerId'] ?? '',
      storeName: json['sellerName'] ?? '',
      sellerEmail: json['sellerEmail'],
      sellerPhone: json['sellerPhone'],
      items: (json['items'] as List?)
          ?.map((e) => CheckoutItem.fromJson(e))
          .toList() ??
          [],
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      shippingCost: (json['shippingCost'] ?? 0).toDouble(),
      itemCount: json['itemCount'] ?? 0,
      estimatedDeliveryDays: json['estimatedDeliveryDays'] ?? 7,
      weight: (json['weight'] ?? 0).toDouble(),
    );
  }

  double get totalAmount => subtotal + shippingCost;
  bool get hasFreeShipping => shippingCost == 0;
}

class CheckoutItem {
  final String productId;
  final String name;
  final double price;
  final double originalPrice;
  final int quantity;
  final String? image;
  final double itemTotal;
  final double shippingCost;
  final int estimatedDeliveryDays;
  final double weight;
  final double? length;
  final double? width;
  final double? height;
  final Map<String, dynamic>? attributes;
  final bool inStock;
  final double discountPercent;

  CheckoutItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.originalPrice,
    required this.quantity,
    this.image,
    required this.itemTotal,
    required this.shippingCost,
    required this.estimatedDeliveryDays,
    required this.weight,
    this.length,
    this.width,
    this.height,
    this.attributes,
    required this.inStock,
    required this.discountPercent,
  });

  factory CheckoutItem.fromJson(Map<String, dynamic> json) {
    return CheckoutItem(
      productId: json['productId'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      originalPrice: (json['originalPrice'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      image: json['image'],
      itemTotal: (json['itemTotal'] ?? 0).toDouble(),
      shippingCost: (json['shippingCost'] ?? 0).toDouble(),
      estimatedDeliveryDays: json['estimatedDeliveryDays'] ?? 7,
      weight: (json['weight'] ?? 0).toDouble(),
      length: json['length']?.toDouble(),
      width: json['width']?.toDouble(),
      height: json['height']?.toDouble(),
      attributes: json['attributes'],
      inStock: json['inStock'] ?? false,
      discountPercent: (json['discountPercent'] ?? 0).toDouble(),
    );
  }

  double get totalPrice => price * quantity;
  double get discountAmount => originalPrice - price;
  String get formattedDiscount => '${discountPercent.toStringAsFixed(0)}% OFF';
}

class CheckoutSummary {
  final double subtotal;
  final double shippingTotal;
  final double taxAmount;
  final double taxRate;
  final double total;
  final int itemCount;
  final int sellerCount;

  CheckoutSummary({
    required this.subtotal,
    required this.shippingTotal,
    required this.taxAmount,
    required this.taxRate,
    required this.total,
    required this.itemCount,
    required this.sellerCount,
  });

  factory CheckoutSummary.fromJson(Map<String, dynamic> json) {
    return CheckoutSummary(
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      shippingTotal: (json['shippingTotal'] ?? 0).toDouble(),
      taxAmount: (json['taxAmount'] ?? 0).toDouble(),
      taxRate: (json['taxRate'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      itemCount: json['itemCount'] ?? 0,
      sellerCount: json['sellerCount'] ?? 0,
    );
  }
}


// ============================================
// SHIPPING ADDRESS MODEL
// ============================================


// ============================================
// REQUEST MODELS
// ============================================

class UpdateShippingAddressRequest {
  final ShippingAddress shippingAddress;

  UpdateShippingAddressRequest({
    required this.shippingAddress,
  });

  Map<String, dynamic> toJson() {
    return {
      'shippingAddress': shippingAddress.toJson(),
    };
  }
}

class SelectPaymentMethodRequest {
  final String paymentMethodId;

  SelectPaymentMethodRequest({
    required this.paymentMethodId,
  });

  Map<String, dynamic> toJson() {
    return {
      'paymentMethodId': paymentMethodId,
    };
  }
}

// ============================================
// CHECKOUT RESPONSE
// ============================================

class CheckoutResponse {
  final bool success;
  final String message;
  final CheckoutData? data;

  CheckoutResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory CheckoutResponse.fromJson(Map<String, dynamic> json) {
    return CheckoutResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? CheckoutData.fromJson(json['data']) : null,
    );
  }
}