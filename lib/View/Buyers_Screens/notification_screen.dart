import 'package:flutter/material.dart';
import '../../Models/CombineModels/NotificationModels.dart';
import '../../Repository/CombineRepo/NotificationRepository.dart';
import '../../Services/AppSession.dart';
import '../../res/Widgets/CustomSnackbar.dart';
import '../../res/Widgets/ShimmerBox.dart';
import 'NotificationSettingsScreen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadNotifications() async {
    if (_currentPage == 1) setState(() => _isLoading = true);
    try {
      final response = await NotificationRepository.getNotifications(
        page: _currentPage,
        limit: 20,
      );
      if (response.success) {
        setState(() {
          if (_currentPage == 1) {
            _notifications = response.data.notifications;
          } else {
            _notifications.addAll(response.data.notifications);
          }
          _unreadCount = response.data.unreadCount;
          _hasMore = response.data.pagination.page < response.data.pagination.pages;
          if (_hasMore) _currentPage++;
          _error = null;
        });
      } else {
        setState(() => _error = 'Failed to load notifications');
      }
    } catch (e) {
      setState(() => _error = e.toString());
      if (mounted) CustomSnackbar.showError(context, 'Failed to load notifications');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_hasMore && !_isLoading) _loadNotifications();
    }
  }

  Future<void> _refreshNotifications() async {
    _currentPage = 1;
    await _loadNotifications();
  }

  Future<void> _markAllAsRead() async {
    final success = await NotificationRepository.markAllAsRead();
    if (success && mounted) {
      setState(() {
        for (var i = 0; i < _notifications.length; i++) {
          _notifications[i] = _notifications[i].copyWith(isRead: true);
        }
        _unreadCount = 0;
      });
      CustomSnackbar.showSuccess(context, 'All notifications marked as read');
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    final success = await NotificationRepository.markAsRead(notificationId);
    if (success && mounted) {
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(isRead: true);
          if (_unreadCount > 0) _unreadCount--;
        }
      });
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    final success = await NotificationRepository.deleteNotification(notificationId);
    if (success && mounted) {
      setState(() {
        _notifications.removeWhere((n) => n.id == notificationId);
        _unreadCount = _notifications.where((n) => !n.isRead).length;
      });
      CustomSnackbar.showSuccess(context, 'Notification deleted');
    }
  }

  void _handleNotificationTap(NotificationModel notification) async {
    if (!notification.isRead) await _markAsRead(notification.id);
    final userType = AppSession.instance.userType ?? 'buyer';
    switch (notification.type) {
      case 'order_placed':
      case 'order_shipped':
      case 'order_delivered':
      case 'order_cancelled':
        if (notification.relatedId != null && mounted) {
          // Navigate to order details
        }
        break;
      case 'payout_available':
      case 'withdrawal_processed':
        if (mounted && userType == 'seller') {
          // Navigate to payouts
        }
        break;
      default:
        break;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 7) return '${diff.inDays ~/ 7}w ago';
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isBuyer = (AppSession.instance.userType ?? 'buyer') == 'buyer';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          children: [
            const Text(
              'Notifications',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 18,
                letterSpacing: -0.3,
              ),
            ),
            if (_unreadCount > 0)
              Text(
                '$_unreadCount unread',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black45,
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),
        centerTitle: true,
        actions: [
          // Mark all read — only when there are unread items
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Read all',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          // Settings gear — only for buyers
          if (isBuyer)
            IconButton(
              icon: const Icon(Icons.tune_rounded, color: Colors.black, size: 22),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationSettingsScreen(),
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _notifications.isEmpty) return _buildShimmerList();

    if (_error != null && _notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.wifi_off_rounded, size: 32, color: Colors.grey[350]),
            ),
            const SizedBox(height: 16),
            const Text(
              'Could not load notifications',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Check your connection and try again',
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refreshNotifications,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 38,
                color: Colors.grey[350],
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No notifications yet',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              "You're all caught up",
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshNotifications,
      color: Colors.black,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _notifications.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _notifications.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                ),
              ),
            );
          }
          return _buildNotificationTile(_notifications[index]);
        },
      ),
    );
  }

  // ─── Shimmer ────────────────────────────────────────────────────────────────

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: 7,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ShimmerBox(
              width: 44,
              height: 44,
              borderRadius: BorderRadius.circular(12),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShimmerBox(
                        width: 130,
                        height: 13,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      ShimmerBox(
                        width: 40,
                        height: 10,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ShimmerBox(
                    width: double.infinity,
                    height: 11,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  const SizedBox(height: 4),
                  ShimmerBox(
                    width: 100,
                    height: 11,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Notification tile ─────────────────────────────────────────────────────

  Widget _buildNotificationTile(NotificationModel notification) {
    final isRead = notification.isRead;
    final icon = _getNotificationIcon(notification.type);
    final iconColor = _getNotificationColor(notification.type);
    final iconBg = _getNotificationBg(notification.type);
    final timeAgo = _getTimeAgo(notification.createdAt);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFBE123C),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 22),
      ),
      onDismissed: (_) => _deleteNotification(notification.id),
      child: GestureDetector(
        onTap: () => _handleNotificationTap(notification),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isRead
                  ? Colors.transparent
                  : Colors.black.withOpacity(0.07),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight:
                              isRead ? FontWeight.w500 : FontWeight.w700,
                              fontSize: 13.5,
                              color: Colors.black,
                              letterSpacing: -0.1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          timeAgo,
                          style: const TextStyle(
                            color: Colors.black38,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notification.body,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Unread dot
              if (!isRead) ...[
                const SizedBox(width: 8),
                Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'order_placed': return Icons.shopping_bag_outlined;
      case 'order_shipped': return Icons.local_shipping_outlined;
      case 'order_delivered': return Icons.check_circle_outline_rounded;
      case 'order_cancelled': return Icons.cancel_outlined;
      case 'payment_received': return Icons.payments_outlined;
      case 'payout_available': return Icons.account_balance_wallet_outlined;
      case 'withdrawal_processed': return Icons.arrow_upward_rounded;
      case 'refund_issued': return Icons.replay_rounded;
      default: return Icons.notifications_outlined;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'order_placed': return const Color(0xFF1D4ED8);
      case 'order_shipped': return const Color(0xFFC2570A);
      case 'order_delivered': return const Color(0xFF15803D);
      case 'order_cancelled': return const Color(0xFFBE123C);
      case 'payment_received': return const Color(0xFF0F766E);
      case 'payout_available': return const Color(0xFF7C3AED);
      case 'withdrawal_processed': return const Color(0xFF15803D);
      case 'refund_issued': return const Color(0xFFC2570A);
      default: return Colors.black54;
    }
  }

  Color _getNotificationBg(String type) {
    switch (type) {
      case 'order_placed': return const Color(0xFFEFF6FF);
      case 'order_shipped': return const Color(0xFFFFF7ED);
      case 'order_delivered': return const Color(0xFFF0FDF4);
      case 'order_cancelled': return const Color(0xFFFFF1F2);
      case 'payment_received': return const Color(0xFFF0FDFA);
      case 'payout_available': return const Color(0xFFF5F3FF);
      case 'withdrawal_processed': return const Color(0xFFF0FDF4);
      case 'refund_issued': return const Color(0xFFFFF7ED);
      default: return const Color(0xFFF3F4F6);
    }
  }
}