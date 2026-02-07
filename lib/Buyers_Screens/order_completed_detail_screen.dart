import 'package:afrotierre/constants.dart';
import 'package:flutter/material.dart';

class OrderCompletedDetailScreen extends StatefulWidget {
  const OrderCompletedDetailScreen({super.key});

  @override
  State<OrderCompletedDetailScreen> createState() =>
      _OrderCompletedDetailScreenState();
}

class _OrderCompletedDetailScreenState
    extends State<OrderCompletedDetailScreen> {
  final List<Map<String, dynamic>> _trackingHistory = [
    {
      'status': 'Order Confirmed',
      'detail': 'Jan 18, 2026 | 12:03 AM',
      'isCompleted': true,
    },
    {
      'status': 'Preparing Shipment',
      'detail': 'Processing at warehouse',
      'isCompleted': true,
    },
    {'status': 'Out for delivery', 'detail': 'Pending', 'isCompleted': false},
    {
      'status': 'Delivered',
      'detail': 'Expected on Jan 22, 2026',
      'isCompleted': false,
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
          'Track Order',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductSummaryCard(),
            const SizedBox(height: 32),
            _buildTrackingHistory(),
            const SizedBox(height: 40),
            _buildContactSupport(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSummaryCard() {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  image: AssetImage('assets/stock_image.png'), // Placeholder
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Addidas Shoe',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Ordered: 3 Dec, 2025',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '\$1,200.00',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
            Chip(
              label: const Text('Completed'),
              backgroundColor: Colors.green[100],
              labelStyle: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.track_changes_outlined, color: Colors.grey),
            SizedBox(width: 8),
            Text(
              'Tracking History',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _trackingHistory.length,
          itemBuilder: (context, index) {
            final item = _trackingHistory[index];
            return _buildTrackingStep(
              status: item['status'],
              detail: item['detail'],
              isCompleted: item['isCompleted'],
              isLast: index == _trackingHistory.length - 1,
            );
          },
        ),
      ],
    );
  }

  Widget _buildTrackingStep({
    required String status,
    required String detail,
    required bool isCompleted,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? Colors.black : Colors.grey[300],
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 16),
            ),
            if (!isLast)
              Container(width: 1, height: 40, color: Colors.grey[300]),
          ],
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              status,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isCompleted ? Colors.black : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              detail,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactSupport() {
    return Center(
      child: Column(
        children: [
          Text(
            'Need help with your order?',
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, refundScreen);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.support_agent, color: Colors.black),
                SizedBox(width: 8),
                Text(
                  'Contact Support',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
