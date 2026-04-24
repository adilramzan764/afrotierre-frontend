// lib/Models/NotificationModels.dart

import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String userType;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  final String? relatedId;
  final String? relatedModel;
  final String? actionUrl;
  final Map<String, dynamic>? actionData;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.userType,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.readAt,
    this.relatedId,
    this.relatedModel,
    this.actionUrl,
    this.actionData,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      userType: json['userType'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? '',
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'])
          : null,
      relatedId: json['relatedId'],
      relatedModel: json['relatedModel'],
      actionUrl: json['actionUrl'],
      actionData: json['actionData'] != null
          ? Map<String, dynamic>.from(json['actionData'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'userType': userType,
      'title': title,
      'body': body,
      'type': type,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'relatedId': relatedId,
      'relatedModel': relatedModel,
      'actionUrl': actionUrl,
      'actionData': actionData,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? userType,
    String? title,
    String? body,
    String? type,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
    String? relatedId,
    String? relatedModel,
    String? actionUrl,
    Map<String, dynamic>? actionData,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userType: userType ?? this.userType,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      relatedId: relatedId ?? this.relatedId,
      relatedModel: relatedModel ?? this.relatedModel,
      actionUrl: actionUrl ?? this.actionUrl,
      actionData: actionData ?? this.actionData,
    );
  }
}

class NotificationsResponse {
  final bool success;
  final NotificationsData data;

  NotificationsResponse({
    required this.success,
    required this.data,
  });

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    return NotificationsResponse(
      success: json['success'] ?? false,
      data: NotificationsData.fromJson(json['data'] ?? {}),
    );
  }
}

class NotificationsData {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final PaginationInfo pagination;

  NotificationsData({
    required this.notifications,
    required this.unreadCount,
    required this.pagination,
  });

  factory NotificationsData.fromJson(Map<String, dynamic> json) {
    return NotificationsData(
      notifications: (json['notifications'] as List?)
          ?.map((item) => NotificationModel.fromJson(item))
          .toList() ?? [],
      unreadCount: json['unreadCount'] ?? 0,
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
      limit: json['limit'] ?? 20,
      total: json['total'] ?? 0,
      pages: json['pages'] ?? 0,
    );
  }
}

class UnreadCountResponse {
  final bool success;
  final int unreadCount;

  UnreadCountResponse({
    required this.success,
    required this.unreadCount,
  });

  factory UnreadCountResponse.fromJson(Map<String, dynamic> json) {
    return UnreadCountResponse(
      success: json['success'] ?? false,
      unreadCount: json['data']?['unreadCount'] ?? 0,
    );
  }
}

class SimpleResponse {
  final bool success;
  final String message;

  SimpleResponse({
    required this.success,
    required this.message,
  });

  factory SimpleResponse.fromJson(Map<String, dynamic> json) {
    return SimpleResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}

// Notification type helper
class NotificationType {
  static const String orderPlaced = 'order_placed';
  static const String orderShipped = 'order_shipped';
  static const String orderDelivered = 'order_delivered';
  static const String orderCancelled = 'order_cancelled';
  static const String paymentReceived = 'payment_received';
  static const String payoutAvailable = 'payout_available';
  static const String withdrawalProcessed = 'withdrawal_processed';
  static const String refundIssued = 'refund_issued';
  static const String newMessage = 'new_message';
  static const String priceDrop = 'price_drop';
  static const String backInStock = 'back_in_stock';
  static const String promotion = 'promotion';
  static const String systemAlert = 'system_alert';

  static String getDisplayName(String type) {
    switch (type) {
      case orderPlaced:
        return 'Order Placed';
      case orderShipped:
        return 'Order Shipped';
      case orderDelivered:
        return 'Order Delivered';
      case orderCancelled:
        return 'Order Cancelled';
      case paymentReceived:
        return 'Payment Received';
      case payoutAvailable:
        return 'Payout Available';
      case withdrawalProcessed:
        return 'Withdrawal Processed';
      case refundIssued:
        return 'Refund Issued';
      case newMessage:
        return 'New Message';
      case priceDrop:
        return 'Price Drop';
      case backInStock:
        return 'Back in Stock';
      case promotion:
        return 'Promotion';
      case systemAlert:
        return 'System Alert';
      default:
        return 'Notification';
    }
  }

  static IconData getIcon(String type) {
    switch (type) {
      case orderPlaced:
        return Icons.shopping_cart_outlined;
      case orderShipped:
        return Icons.local_shipping_outlined;
      case orderDelivered:
        return Icons.check_circle_outline;
      case orderCancelled:
        return Icons.cancel_outlined;
      case paymentReceived:
        return Icons.payment_outlined;
      case payoutAvailable:
        return Icons.account_balance_wallet_outlined;
      case withdrawalProcessed:
        return Icons.arrow_upward_outlined;
      case refundIssued:
        return Icons.replay_outlined;
      case newMessage:
        return Icons.message_outlined;
      case priceDrop:
        return Icons.trending_down_outlined;
      case backInStock:
        return Icons.inventory_2_outlined;
      case promotion:
        return Icons.local_offer_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  static Color getColor(String type) {
    switch (type) {
      case orderPlaced:
        return Colors.blue;
      case orderShipped:
        return Colors.orange;
      case orderDelivered:
        return Colors.green;
      case orderCancelled:
        return Colors.red;
      case paymentReceived:
        return Colors.teal;
      case payoutAvailable:
        return Colors.purple;
      case withdrawalProcessed:
        return Colors.indigo;
      case refundIssued:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}