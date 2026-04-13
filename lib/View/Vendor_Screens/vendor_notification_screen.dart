import 'package:flutter/material.dart';

class VendorNotificationScreen extends StatefulWidget {
  const VendorNotificationScreen({super.key});

  @override
  State<VendorNotificationScreen> createState() =>
      _VendorNotificationScreenState();
}

class _VendorNotificationScreenState extends State<VendorNotificationScreen> {
  // Placeholder data for notifications
  final List<Map<String, dynamic>> _notifications = [
    {
      'order': 'Order #1010',
      'time': '1h ago',
      'details': '\$2,400, 1 item from Buy Button',
      'image': 'assets/stock_image.png', // Placeholder
      'imageBg': Colors.black,
    },
    {
      'order': 'Order #1010',
      'time': 'Yesterday, 8:00 PM',
      'details': '\$2,400, 1 item from Buy Button',
      'image': 'assets/stock_image.png', // Placeholder
      'imageBg': Colors.grey[200],
    },
    {
      'order': 'Order #1010',
      'time': 'Yesterday, 7:15 PM',
      'details': '\$2,400, 1 item from Buy Button',
      'image': 'assets/stock_image.png', // Placeholder
      'imageBg': Colors.grey[200],
    },
    {
      'order': 'Order #1010',
      'time': 'Yesterday, 10:30 AM',
      'details': '\$2,400, 1 item from Buy Button',
      'image': 'assets/stock_image.png', // Placeholder
      'imageBg': Colors.grey[200],
    },
    {
      'order': 'Order #1010',
      'time': 'Sun, 10:30 AM',
      'details': '\$2,400, 1 item from Buy Button',
      'image': 'assets/stock_image.png', // Placeholder
      'imageBg': Colors.black,
    },
    {
      'order': 'Order #1010',
      'time': 'Sat, 6:30 PM',
      'details': '\$2,400, 1 item from Buy Button',
      'image': 'assets/stock_image.png', // Placeholder
      'imageBg': Colors.grey[200],
    },
  ];

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
          'Notification',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          return _buildNotificationCard(_notifications[index]);
        },
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: notification['imageBg'],
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage(notification['image'] as String),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        notification['order'],
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        notification['time'],
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notification['details'],
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
