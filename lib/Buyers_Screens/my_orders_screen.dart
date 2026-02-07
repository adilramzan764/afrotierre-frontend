import 'package:afrotierre/constants.dart';
import 'package:flutter/material.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  String _selectedStatus = 'All';

  // Placeholder data for orders
  final List<Map<String, dynamic>> _allOrders = [
    {
      'name': 'Adidas Shoe',
      'orderedDate': '3 Dec, 2025',
      'price': 1200.00,
      'status': 'Shipped',
      'image': 'assets/stock_image.png', // Placeholder
    },
    {
      'name': 'PS5 Console',
      'orderedDate': '1 Feb, 2020',
      'price': 1000.00,
      'status': 'Processing',
      'image': 'assets/stock_image.png', // Placeholder
    },
    {
      'name': 'Laptop',
      'orderedDate': '3 June, 2024',
      'price': 850.00,
      'status': 'Shipped',
      'image': 'assets/stock_image.png', // Placeholder
    },
    {
      'name': 'Chelsea Boot',
      'orderedDate': '1 Nov, 2025',
      'price': 500.00,
      'status': 'Delivered',
      'image': 'assets/stock_image.png', // Placeholder
    },
    {
      'name': 'Addidas Cleat',
      'orderedDate': '25 Feb, 2025',
      'price': 340.00,
      'status': 'Processing',
      'image': 'assets/stock_image.png', // Placeholder
    },
  ];

  List<Map<String, dynamic>> get _filteredOrders {
    if (_selectedStatus == 'All') {
      return _allOrders;
    }
    return _allOrders
        .where((order) => order['status'] == _selectedStatus)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back, color: Colors.black),
        //   onPressed: () => Navigator.of(context).pop(),
        // ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.transparent),
          onPressed: () {},
        ),
        title: const Text(
          'Order',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _filteredOrders.length,
              itemBuilder: (context, index) {
                return _buildOrderCard(_filteredOrders[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final statuses = ['All', 'In progress', 'Delivered', 'Refunded'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: statuses.map((status) {
            final isSelected = _selectedStatus == status;
            return ChoiceChip(
              label: Text(status),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedStatus = status;
                  });
                }
              },
              backgroundColor: isSelected
                  ? Colors.grey[300]
                  : Colors.transparent,
              selectedColor: Colors.grey[300],
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : Colors.grey[600],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? Colors.grey[400]! : Colors.transparent,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GestureDetector(
          onTap: () {
            if (order['status'] == "Shipped") {
              Navigator.pushNamed(context, orderDetailScreen);
            } else {
              Navigator.pushNamed(context, orderCompletedDetailScreen);
            }
          },
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: AssetImage(order['image'] as String),
                    fit: BoxFit.contain,
                  ),
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
                      'Ordered: ${order['orderedDate']}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
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
                label: Text(order['status']),
                backgroundColor: _getStatusColor(
                  order['status'],
                ).withOpacity(0.2),
                labelStyle: TextStyle(
                  color: _getStatusColor(order['status']),
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Shipped':
        return Colors.blue;
      case 'Processing':
        return Colors.orange;
      case 'Delivered':
        return Colors.green;
      case 'Refunded':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
