// lib/Providers/NotificationProvider.dart
import 'package:flutter/material.dart';

import '../Models/CombineModels/NotificationModels.dart';
import '../Repository/CombineRepo/NotificationRepository.dart';


class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _error;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;

  // Fetch notifications
  Future<void> fetchNotifications({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 1;
      _notifications.clear();
      _hasMore = true;
      _error = null;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await NotificationRepository.getNotifications(
        page: _currentPage,
        limit: 20,
      );

      if (response.success) {
        if (refresh) {
          _notifications = response.data.notifications;
        } else {
          _notifications.addAll(response.data.notifications);
        }

        _unreadCount = response.data.unreadCount;
        _hasMore = response.data.pagination.page < response.data.pagination.pages;

        if (_hasMore) _currentPage++;
      } else {
        _error = 'Failed to load notifications';
      }
    } catch (e) {
      _error = e.toString();
      print('Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    final success = await NotificationRepository.markAsRead(notificationId);

    if (success) {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _unreadCount--;
        notifyListeners();
      }
    }

    return success;
  }

  // Mark all as read
  Future<bool> markAllAsRead() async {
    final success = await NotificationRepository.markAllAsRead();

    if (success) {
      for (var i = 0; i < _notifications.length; i++) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
      _unreadCount = 0;
      notifyListeners();
    }

    return success;
  }

  // Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    final success = await NotificationRepository.deleteNotification(notificationId);

    if (success) {
      _notifications.removeWhere((n) => n.id == notificationId);
      // Recalculate unread count
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      notifyListeners();
    }

    return success;
  }

  // Clear all notifications (local)
  void clearAll() {
    _notifications.clear();
    _unreadCount = 0;
    _currentPage = 1;
    _hasMore = true;
    _error = null;
    notifyListeners();
  }

  // Refresh notifications
  Future<void> refresh() async {
    await fetchNotifications(refresh: true);
  }

  // Load more notifications
  Future<void> loadMore() async {
    if (_hasMore && !_isLoading) {
      await fetchNotifications();
    }
  }
}