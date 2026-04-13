import 'package:afrotierre/View/Vendor_Screens/vendor_commission_screen.dart';
import 'package:afrotierre/View/Vendor_Screens/vendor_notification_screen.dart';
import 'package:afrotierre/View/Vendor_Screens/vendor_sales_statistics_screen.dart';
import 'package:afrotierre/View/Vendor_Screens/vendor_transaction_history_screen.dart';
import 'package:afrotierre/View/Vendor_Screens/vendor_withdrawal_screen.dart';
import 'package:afrotierre/constants.dart';
import 'package:flutter/material.dart';

class VendorHomeScreen extends StatefulWidget {
  const VendorHomeScreen({super.key});

  @override
  State<VendorHomeScreen> createState() => _VendorHomeScreenState();
}

class _VendorHomeScreenState extends State<VendorHomeScreen> {
  String _selectedTimeframe = 'This week';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildTotalSalesCard(),
                const SizedBox(height: 24),
                _buildStatsCards(),
                const SizedBox(height: 24),
                _buildActionButtons(),
                const SizedBox(height: 32),
                _buildRecentOrders(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundImage: AssetImage(
            'assets/stock_image.png',
          ), // Add your avatar image
          backgroundColor: Colors.grey,
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello', style: TextStyle(color: Colors.grey)),
            Text(
              'Marcus Oris!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.chat_bubble_outline, size: 28),
        ),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VendorNotificationScreen(),
              ),
            );
          },
          icon: const Icon(Icons.notifications_outlined, size: 28),
        ),
      ],
    );
  }

  Widget _buildTotalSalesCard() {
    return Card(
      color: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Sales',
                  style: TextStyle(color: Colors.white70),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VendorSalesStatisticsScreen(),
                      ),
                    );

                  },
                  child: const Text(
                    'View Analysis',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '\$20,783.63',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.visibility_off_outlined,
                    color: Colors.white70,
                    size: 16,
                  ),
                  label: const Text(
                    'Hide balance',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedTimeframe,
                      focusColor: Colors.green,

                      isDense: true,
                      items: ['This week', 'This month', 'This year']
                          .map(
                            (label) => DropdownMenuItem(
                              value: label,
                              child: Text(
                                label,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedTimeframe = value);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Active Orders',
            value: '100',
            icon: Icons.list_alt,
            color: Colors.blue[50]!,
            iconColor: Colors.blue[800]!,
            check: false,
            onTap: () {},
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Total commission',
            value: '\$2,481.09',
            icon: Icons.bar_chart,
            color: Colors.yellow[100]!,
            iconColor: Colors.orange[800]!,
            check: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VendorCommissionScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required bool check,
    required GestureTapCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(color: Colors.black54)),
                check
                    ? Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Color(0xFFFBE692),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Icon(icon, color: iconColor),
                      )
                    : Icon(icon, color: iconColor),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionButton(
          icon: Icons.add_box_outlined,
          label: 'Create Post',
          onTap: () {},
        ),
        _buildActionButton(
          icon: Icons.article_outlined,
          label: 'Catalogue',
          onTap: () {},
        ),
        _buildActionButton(
          icon: Icons.insights_outlined,
          label: 'Transactions',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VendorTransactionHistoryScreen(),
              ),
            );
          },
        ),
        _buildActionButton(
          icon: Icons.download_outlined,
          label: 'Withdraw',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VendorWithdrawalScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        IconButton.filled(
          style: IconButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          icon: Icon(icon),
          onPressed: onTap,
          iconSize: 28,
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildRecentOrders() {
    // Placeholder data
    final orders = [
      {
        'id': '#10101',
        'product': 'Adidas Shoe',
        'items': 2,
        'price': 1200.00,
        'customer': 'Marcus Oris!',
        'date': '3 Feb, 2026',
        'status': 'In Progress',
        'image': 'assets/stock_image.png',
      },
      {
        'id': '#10101',
        'product': 'Adidas Shoe',
        'items': 2,
        'price': 1200.00,
        'customer': 'Marcus Oris!',
        'date': '3 Feb, 2026',
        'status': 'Shipped',
        'image': 'assets/stock_image.png',
      },
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Order',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'See all',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey[200]!),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: AssetImage(order['image'] as String),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order['id'] as String,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                order['product'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Chip(
                          label: Text(
                            order['status'] as String,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: (order['status'] == 'In Progress'
                              ? Colors.orange[100]
                              : Colors.blue[100])!,
                          labelStyle: TextStyle(
                            color: order['status'] == 'In Progress'
                                ? Colors.orange[800]
                                : Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 12,
                              backgroundImage: AssetImage(
                                'assets/stock_image.png',
                              ),
                              backgroundColor: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              order['customer'] as String,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        Text(
                          order['date'] as String,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
