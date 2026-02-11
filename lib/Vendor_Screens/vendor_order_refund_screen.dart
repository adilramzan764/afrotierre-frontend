import 'package:flutter/material.dart';

class VendorOrderRefundScreen extends StatefulWidget {
  const VendorOrderRefundScreen({super.key});

  @override
  State<VendorOrderRefundScreen> createState() =>
      _VendorOrderRefundScreenState();
}

class _VendorOrderRefundScreenState extends State<VendorOrderRefundScreen> {
  String _selectedRefundFilter = 'All';

  // Placeholder data
  final List<Map<String, dynamic>> _refundOrders = [
    {
      'name': 'Gucci Bag',
      'orderId': '#88120',
      'price': 2400.0,
      'refundStatus': 'Rejected',
      'reason': 'Wrong Product- customer requested refund',
      'refundAmount': 260.0,
      'commissionImpact': 0.0,
      'requestDate': 'Jan 18, 2026, 6:00PM',
      'processedDate': 'Jan 19, 2026, 10:00AM',
      'refundProgress': 4,
      'image': null,
    },
    {
      'name': 'Gucci Bag',
      'orderId': '#88120',
      'price': 2400.0,
      'refundStatus': 'Under Review',
      'reason': 'Item damaged- customer requested refund',
      'refundAmount': 665.0,
      'commissionImpact': -19.01,
      'requestDate': 'Jan 21, 2026, 1:00AM',
      'processedDate': '-',
      'refundProgress': 2,
      'image': null,
    },
    {
      'name': 'Gucci Bag',
      'orderId': '#88120',
      'price': 2400.0,
      'refundStatus': 'Approved',
      'reason': 'Delivery delay- customer requested refund',
      'refundAmount': 216.0,
      'commissionImpact': -29.01,
      'requestDate': 'Jan 13, 2026, 5:56PM',
      'processedDate': 'Jan 15, 2026, 12:00PM',
      'refundProgress': 4,
      'image': null,
    },
  ];

  List<Map<String, dynamic>> get _filteredRefundOrders {
    if (_selectedRefundFilter == 'All') {
      return _refundOrders;
    }
    return _refundOrders
        .where((order) => order['refundStatus'] == _selectedRefundFilter)
        .toList();
  }

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
          'Refunds',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildRefundStats(),
          _buildSearchBar(),
          _buildRefundFilterChips(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _filteredRefundOrders.length,
              itemBuilder: (context, index) {
                return _buildRefundOrderCard(_filteredRefundOrders[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefundStats() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          _buildStatCard('Total Refunds', '1', Colors.black),
          const SizedBox(width: 12),
          _buildStatCard('Comm. Lost', '\$19.01', Colors.red),
          const SizedBox(width: 12),
          _buildStatCard('Refunded', '\$665.00', Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color valueColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search by name or Order ID',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildRefundFilterChips() {
    final filters = ['All', 'Pending', 'Approved', 'Rejected'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedRefundFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedRefundFilter = filter;
                  });
                }
              },
              backgroundColor: isSelected ? Colors.black : Colors.grey[200],
              selectedColor: Colors.black,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide.none,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRefundOrderCard(Map<String, dynamic> order) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.image, color: Colors.white, size: 30),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order['orderId'],
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${(order['price'] as double).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(
                    order['refundStatus'],
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: _getStatusColor(
                    order['refundStatus'],
                  ).withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: _getStatusColor(order['refundStatus']),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Text(
                    'Reason',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const Spacer(),
                  Text(
                    order['reason'],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildRefundDetailRow(
              'Refund Amount',
              '\$${order['refundAmount'].toStringAsFixed(2)}',
              Colors.red,
            ),
            _buildRefundDetailRow(
              'Commission Impact',
              '\$${order['commissionImpact'].toStringAsFixed(2)}',
              Colors.green,
            ),
            const Divider(height: 24),
            _buildRefundDetailRow(
              'Request Date',
              order['requestDate'],
              Colors.black,
            ),
            _buildRefundDetailRow(
              'Processed Date',
              order['processedDate'],
              Colors.black,
            ),
            const SizedBox(height: 12),
            _buildRefundProgressTracker(order['refundProgress']),
          ],
        ),
      ),
    );
  }

  Widget _buildRefundDetailRow(String title, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefundProgressTracker(int progress) {
    final steps = ['Submitted', 'processing', 'In Review', 'Completed'];
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(steps.length, (index) {
            final isCompleted = index < progress;
            return Column(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted ? Colors.black : Colors.grey[300],
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 10)
                      : null,
                ),
              ],
            );
          }),
        ),
        Row(
          children: steps.asMap().entries.map((entry) {
            int idx = entry.key;
            String val = entry.value;
            return Expanded(
              child: Text(
                val,
                style: const TextStyle(fontSize: 8),
                textAlign: idx == 0
                    ? TextAlign.left
                    : idx == steps.length - 1
                    ? TextAlign.right
                    : TextAlign.center,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      case 'Under Review':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
