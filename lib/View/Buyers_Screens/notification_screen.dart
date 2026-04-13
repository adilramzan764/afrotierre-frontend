import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _allowAllNotifications = true;
  bool _orderConfirmation = true;
  bool _shippingUpdates = false;
  bool _deliveryNotifications = true;
  bool _orderIssues = true;
  bool _newArrivals = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAllowAllCard(),
            const SizedBox(height: 32),
            _buildSectionTitle('Order Updates'),
            _buildNotificationSwitch(
              title: 'Order Confirmation',
              subtitle: 'Get notified when your order is confirmed',
              value: _orderConfirmation,
              onChanged: (value) => setState(() => _orderConfirmation = value),
            ),
            _buildNotificationSwitch(
              title: 'Shipping Updates',
              subtitle: 'Track your packages from warehouse to doorstep',
              value: _shippingUpdates,
              onChanged: (value) => setState(() => _shippingUpdates = value),
            ),
            _buildNotificationSwitch(
              title: 'Delivery Notifications',
              subtitle: 'Know exactly when your order arrives',
              value: _deliveryNotifications,
              onChanged: (value) =>
                  setState(() => _deliveryNotifications = value),
            ),
            _buildNotificationSwitch(
              title: 'Order Issues',
              subtitle: 'Important updates about delays or problems',
              value: _orderIssues,
              onChanged: (value) => setState(() => _orderIssues = value),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('New Arrivals'),
            _buildNotificationSwitch(
              title: 'New Arrivals',
              subtitle: 'Be the first to know about new products',
              value: _newArrivals,
              onChanged: (value) => setState(() => _newArrivals = value),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: Padding(
      //   padding: const EdgeInsets.all(24.0),
      //   child: ElevatedButton(
      //     onPressed: () {},
      //     style: ElevatedButton.styleFrom(
      //       backgroundColor: Colors.black,
      //       minimumSize: const Size(double.infinity, 50),
      //       shape: RoundedRectangleBorder(
      //         borderRadius: BorderRadius.circular(30),
      //       ),
      //     ),
      //     child: const Row(
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       children: [
      //         Icon(Icons.add, color: Colors.white),
      //         SizedBox(width: 8),
      //         Text(
      //           'Add New Address',
      //           style: TextStyle(color: Colors.white, fontSize: 16),
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }

  Widget _buildAllowAllCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: SwitchListTile.adaptive(
        title: const Text(
          'Allow All Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text(
          'Receive updates about orders, offers and more',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        value: _allowAllNotifications,
        onChanged: (value) {
          setState(() {
            _allowAllNotifications = value;
            // Optionally, toggle all other notifications based on this one
            _orderConfirmation = value;
            _shippingUpdates = value;
            _deliveryNotifications = value;
            _orderIssues = value;
            _newArrivals = value;
          });
        },
        activeColor: Colors.orange[300],
        activeTrackColor: Colors.orange[100],
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }

  Widget _buildNotificationSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile.adaptive(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.orange[300],
      activeTrackColor: Colors.orange[100],
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
    );
  }
}
