import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../res/Widgets/CustomSnackbar.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _isLoading = true;
  bool _isSaving = false;

  bool _allowAllNotifications = true;
  bool _orderConfirmation = true;
  bool _shippingUpdates = false;
  bool _deliveryNotifications = true;
  bool _orderIssues = true;
  bool _newArrivals = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _allowAllNotifications =
            prefs.getBool('allow_all_notifications') ?? true;
        _orderConfirmation = prefs.getBool('order_confirmation') ?? true;
        _shippingUpdates = prefs.getBool('shipping_updates') ?? false;
        _deliveryNotifications =
            prefs.getBool('delivery_notifications') ?? true;
        _orderIssues = prefs.getBool('order_issues') ?? true;
        _newArrivals = prefs.getBool('new_arrivals') ?? true;
      });
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('allow_all_notifications', _allowAllNotifications);
      await prefs.setBool('order_confirmation', _orderConfirmation);
      await prefs.setBool('shipping_updates', _shippingUpdates);
      await prefs.setBool('delivery_notifications', _deliveryNotifications);
      await prefs.setBool('order_issues', _orderIssues);
      await prefs.setBool('new_arrivals', _newArrivals);
      // TODO: sync to backend
      if (mounted) {
        CustomSnackbar.showSuccess(context, 'Settings saved');
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) CustomSnackbar.showError(context, 'Failed to save settings');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _toggleAll(bool value) {
    setState(() {
      _allowAllNotifications = value;
      _orderConfirmation = value;
      _shippingUpdates = value;
      _deliveryNotifications = value;
      _orderIssues = value;
      _newArrivals = value;
    });
  }

  // Recompute master toggle: true only if every sub-toggle is on
  bool get _masterValue =>
      _orderConfirmation &&
          _shippingUpdates &&
          _deliveryNotifications &&
          _orderIssues &&
          _newArrivals;

  @override
  Widget build(BuildContext context) {
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
        title: const Text(
          'Notification Settings',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? _buildSkeleton()
          : Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Master toggle card ─────────────────────────────
                _buildMasterToggle(),

                const SizedBox(height: 28),

                // ── Order Updates ──────────────────────────────────
                _buildSectionLabel('Order Updates'),
                const SizedBox(height: 10),
                _buildGroup([
                  _SettingItem(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Order Confirmation',
                    subtitle: 'When your order is confirmed',
                    value: _orderConfirmation,
                    onChanged: (v) =>
                        setState(() => _orderConfirmation = v),
                  ),
                  _SettingItem(
                    icon: Icons.local_shipping_outlined,
                    title: 'Shipping Updates',
                    subtitle: 'Track packages from warehouse to door',
                    value: _shippingUpdates,
                    onChanged: (v) =>
                        setState(() => _shippingUpdates = v),
                  ),
                  _SettingItem(
                    icon: Icons.check_circle_outline_rounded,
                    title: 'Delivery Notifications',
                    subtitle: 'Know exactly when your order arrives',
                    value: _deliveryNotifications,
                    onChanged: (v) =>
                        setState(() => _deliveryNotifications = v),
                  ),
                  _SettingItem(
                    icon: Icons.warning_amber_rounded,
                    title: 'Order Issues',
                    subtitle: 'Delays or problems with your order',
                    value: _orderIssues,
                    onChanged: (v) => setState(() => _orderIssues = v),
                  ),
                ]),

                const SizedBox(height: 24),

                // ── Marketing ──────────────────────────────────────
                _buildSectionLabel('Marketing'),
                const SizedBox(height: 10),
                _buildGroup([
                  _SettingItem(
                    icon: Icons.new_releases_outlined,
                    title: 'New Arrivals',
                    subtitle: 'Be first to know about new products',
                    value: _newArrivals,
                    onChanged: (v) => setState(() => _newArrivals = v),
                  ),
                ]),
              ],
            ),
          ),

          // ── Fixed save button ──────────────────────────────────
          Positioned(
            left: 16,
            right: 16,
            bottom: 32,
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  disabledBackgroundColor: Colors.grey[300],
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Save Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Master toggle ──────────────────────────────────────────────────────────

  Widget _buildMasterToggle() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 12, 16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: Colors.white70,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Allow All Notifications',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Receive updates about orders, offers and more',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: _masterValue,
            onChanged: _toggleAll,
            activeColor: const Color(0xFF4ADE80),
            activeTrackColor: const Color(0xFF4ADE80).withOpacity(0.28),
            inactiveThumbColor: Colors.white38,
            inactiveTrackColor: Colors.white12,
          ),
        ],
      ),
    );
  }

  // ── Settings group ─────────────────────────────────────────────────────────

  Widget _buildGroup(List<_SettingItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isLast = i == items.length - 1;
          return Column(
            children: [
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.icon, size: 18, color: Colors.black54),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13.5,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            item.subtitle,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Colors.black38,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: item.value,
                      onChanged: item.onChanged,
                      activeColor: const Color(0xFF4ADE80),
                      activeTrackColor:
                      const Color(0xFF4ADE80).withOpacity(0.25),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 66,
                  endIndent: 16,
                  color: Colors.grey[100],
                ),
            ],
          );
        }),
      ),
    );
  }

  // ── Section label ──────────────────────────────────────────────────────────

  Widget _buildSectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: Colors.black38,
        letterSpacing: 1.4,
      ),
    );
  }

  // ── Skeleton ───────────────────────────────────────────────────────────────

  Widget _buildSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Master card skeleton
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 28),
          _skeletonLabel(),
          const SizedBox(height: 10),
          _skeletonGroup(4),
          const SizedBox(height: 24),
          _skeletonLabel(),
          const SizedBox(height: 10),
          _skeletonGroup(1),
        ],
      ),
    );
  }

  Widget _skeletonLabel() {
    return Container(
      width: 100,
      height: 10,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  Widget _skeletonGroup(int count) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: List.generate(count, (i) {
          final isLast = i == count - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 120,
                            height: 13,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            width: 180,
                            height: 11,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 26,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(height: 1, indent: 66, endIndent: 16, color: Colors.grey[100]),
            ],
          );
        }),
      ),
    );
  }
}

// ── Data class ─────────────────────────────────────────────────────────────────

class _SettingItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
}