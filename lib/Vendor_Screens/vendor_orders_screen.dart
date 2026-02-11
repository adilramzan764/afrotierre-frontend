import 'package:afrotierre/Vendor_Screens/vendor_order_refund_screen.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class VendorOrdersScreen extends StatefulWidget {
  const VendorOrdersScreen({super.key});

  @override
  State<VendorOrdersScreen> createState() => _VendorOrdersScreenState();
}

class _VendorOrdersScreenState extends State<VendorOrdersScreen> {
  String _selectedFilter = 'All';

  // Placeholder data
  final List<Map<String, dynamic>> _allOrders = [
    {
      'name': 'Gucci Bag',
      'orderId': '#88120',
      'price': 2400.0,
      'status': 'Rejected',
      'requestTime': 'Requested 3 days ago',
      'image': null,
    },
    {
      'name': 'Gucci Bag',
      'orderId': '#88120',
      'price': 2400.0,
      'status': 'Under Review',
      'requestTime': 'Requested 2 hours ago',
      'image': null,
    },
    {
      'name': 'Gucci Bag',
      'orderId': '#88120',
      'price': 2400.0,
      'status': 'Approved',
      'requestTime': 'Requested yesterday',
      'image': null,
    },
    {
      'name': 'Nike Air',
      'orderId': '#88129',
      'price': 2400.0,
      'status': 'Pending',
      'buyer': 'Sarah Onel',
      'items': 2,
      'earn': 21.35,
      'image': null,
    },
  ];

  List<Map<String, dynamic>> get _filteredOrders {
    if (_selectedFilter == 'All') {
      return _allOrders;
    }
    return _allOrders
        .where((order) => order['status'] == _selectedFilter)
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
          icon: const Icon(Icons.arrow_back, color: Colors.transparent),
          onPressed: () {},
        ),
        title: const Text(
          'Order List',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _filteredOrders.length,
              itemBuilder: (context, index) {
                if (_filteredOrders[index]['status'] == 'Pending') {
                  return _buildPendingOrderCard(_filteredOrders[index]);
                }
                return _buildOrderCard(_filteredOrders[index]);
              },
            ),
          ),
        ],
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

  Widget _buildFilterChips() {
    final filters = ['All', 'Pending', 'Processing', 'Shipped', 'Refunded'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  if (filter == 'Refunded') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VendorOrderRefundScreen(),
                      ),
                    );
                  } else {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  }
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

  Widget _buildPendingOrderCard(Map<String, dynamic> order) {
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
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                        order['orderId'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Buyer: ${order['buyer'] ?? 'N/A'}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${order['name']} ~ ${order['items'] ?? 0} items',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'EARN \$${order['earn'] ?? 0.0}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${(order['price'] as double).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Icon(
                      Icons.info_outline,
                      color: Colors.grey,
                      size: 16,
                    ),
                    const SizedBox(height: 8),
                    Chip(
                      label: const Text('Urgent Action'),
                      backgroundColor: Colors.red[100],
                      labelStyle: TextStyle(
                        color: Colors.red[800],
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Confirm Order',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
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
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, vendorOrderDetailsScreen);
              },
              child: Container(
                color: Colors.transparent,
                child: Row(
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
                            order['name'] ?? 'N/A',
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
                        order['status'],
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: _getStatusColor(
                        order['status'],
                      ).withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: _getStatusColor(order['status']),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                order['requestTime'] ?? '',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Approved':
      case 'Shipped':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      case 'Under Review':
      case 'Processing':
      case 'Pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
