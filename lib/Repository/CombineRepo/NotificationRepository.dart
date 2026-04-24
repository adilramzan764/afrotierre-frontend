// lib/Repository/NotificationRepository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../Constants/ApiConstants.dart';
import '../../Models/CombineModels/NotificationModels.dart';
import '../../Services/AppSession.dart';


class NotificationRepository {
  static String get _baseUrl {
    final userType = AppSession.instance.userType ?? 'buyer';
    if (userType == 'seller') {
      return ApiConstants.baseUrlSeller;
    }
    return ApiConstants.baseUrlBuyer;
  }

  static Future<String?> _getAuthToken() async {
    return AppSession.instance.authToken;
  }

  static String _getUserType() {
    return AppSession.instance.userType ?? 'buyer';
  }

  // Get notifications with pagination
  static Future<NotificationsResponse> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final token = await _getAuthToken();
      final userType = _getUserType();

      print('🔐 Getting notifications for: $userType');
      print('📍 Base URL: $_baseUrl');

      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/notifications?page=$page&limit=$limit'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📱 Get notifications response: ${response.statusCode}');
      print('📱 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return NotificationsResponse.fromJson(data);
      } else {
        throw Exception('Failed to get notifications');
      }
    } catch (e) {
      print('❌ Get notifications error: $e');
      rethrow;
    }
  }

  // Get unread count
  static Future<int> getUnreadCount() async {
    try {
      final token = await _getAuthToken();
      final userType = _getUserType();

      if (token == null) {
        return 0;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/notifications/unread-count'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']?['unreadCount'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('❌ Get unread count error: $e');
      return 0;
    }
  }

  // Mark notification as read
  static Future<bool> markAsRead(String notificationId) async {
    try {
      final token = await _getAuthToken();
      final userType = _getUserType();

      if (token == null) {
        return false;
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/notifications/$notificationId/read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Mark as read error: $e');
      return false;
    }
  }

  // Mark all as read
  static Future<bool> markAllAsRead() async {
    try {
      final token = await _getAuthToken();
      final userType = _getUserType();

      if (token == null) {
        return false;
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/notifications/mark-all-read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Mark all as read error: $e');
      return false;
    }
  }

  // Delete notification
  static Future<bool> deleteNotification(String notificationId) async {
    try {
      final token = await _getAuthToken();
      final userType = _getUserType();

      if (token == null) {
        return false;
      }

      final response = await http.delete(
        Uri.parse('$_baseUrl/notifications/$notificationId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Delete notification error: $e');
      return false;
    }
  }

  // Register device token for push notifications
  static Future<bool> registerDeviceToken({
    required String deviceToken,
    required String deviceType,
    String? deviceId,
    String? appVersion,
    String? osVersion,
  }) async {
    try {
      final token = await _getAuthToken();
      final userType = _getUserType();

      if (token == null) {
        return false;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/notifications/device-token'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'deviceToken': deviceToken,
          'deviceType': deviceType,
          'deviceId': deviceId,
          'appVersion': appVersion,
          'osVersion': osVersion,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Register device token error: $e');
      return false;
    }
  }

  // Unregister device token
  static Future<bool> unregisterDeviceToken(String deviceToken) async {
    try {
      final token = await _getAuthToken();
      final userType = _getUserType();

      if (token == null) {
        return false;
      }

      final response = await http.delete(
        Uri.parse('$_baseUrl/notifications/device-token'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'deviceToken': deviceToken}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Unregister device token error: $e');
      return false;
    }
  }
}