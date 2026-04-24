import 'package:afrotierre/Models/SellerModels/SellerDashboardModels.dart';
import 'package:afrotierre/Repository/SellerRepository/SellerDashboardRepository.dart';
import 'package:afrotierre/View/Vendor_Screens/vendor_add_product_screen.dart';
import 'package:afrotierre/View/Vendor_Screens/vendor_notification_screen.dart';
import 'package:afrotierre/View/Vendor_Screens/vendor_order_details_screen.dart';
import 'package:afrotierre/View/Vendor_Screens/vendor_sales_statistics_screen.dart';
import 'package:afrotierre/View/Vendor_Screens/vendor_transaction_history_screen.dart';
import 'package:afrotierre/View/Vendor_Screens/vendor_withdrawal_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Services/NotificationProvider.dart';
import '../../Services/AppSession.dart';
import '../../res/Widgets/ShimmerBox.dart';
import '../Buyers_Screens/notification_screen.dart';

class VendorHomeScreen extends StatefulWidget {
  const VendorHomeScreen({super.key});

  @override
  State<VendorHomeScreen> createState() => _VendorHomeScreenState();
}

class _VendorHomeScreenState extends State<VendorHomeScreen> {
  final SellerDashboardRepository _dashboardRepository = SellerDashboardRepository();

  String _selectedTimeframe = 'This week';
  bool _balanceHidden = false;

  bool _isLoading = true;
  String? _error;
  DashboardData? _dashboardData;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _loadNotificationCount();
  }

  final AppSession _session = AppSession.instance;

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      String timeframe = 'week';
      if (_selectedTimeframe == 'This month') timeframe = 'month';
      if (_selectedTimeframe == 'This year') timeframe = 'year';
      final data = await _dashboardRepository.getDashboardData(timeframe: timeframe);
      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) hexColor = 'FF$hexColor';
    return Color(int.parse(hexColor, radix: 16));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadNotificationCount();
    }
  }

  Future<void> _loadNotificationCount() async {
    if (_session.isLoggedIn) {
      final provider = Provider.of<NotificationProvider>(context, listen: false);
      await provider.fetchNotifications(refresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboardData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildTotalSalesCard(),
                  const SizedBox(height: 24),
                  _buildOrdersOverview(),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                  const SizedBox(height: 24),
                  _buildWeekStrip(),
                  const SizedBox(height: 32),
                  _buildRecentOrders(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    final sellerProfile = _session.sellerProfile;
    final seller = _dashboardData?.seller;
    final storeName = sellerProfile?.storeName ?? 'Vendor';
    final firstName = storeName.split(' ').first;

    // FIXED: Proper null-safe logo URL extraction
    String? logoUrl;
    if (sellerProfile != null) {
      if (sellerProfile.isGoogleUser == true || sellerProfile.isAppleUser == true) {
        logoUrl = sellerProfile.avatar;
      } else {
        logoUrl = sellerProfile.logo?.url;
      }
    }

    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey[300],
          backgroundImage: logoUrl != null && logoUrl.isNotEmpty ? NetworkImage(logoUrl) : null,
          child: logoUrl == null || logoUrl.isEmpty
              ? Text(
            storeName.isNotEmpty ? storeName[0].toUpperCase() : 'S',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
          )
              : null,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hello,', style: TextStyle(color: Colors.grey, fontSize: 13)),
            Text('$firstName!', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        const Spacer(),
        Consumer<NotificationProvider>(
          builder: (context, provider, child) {
            final unreadCount = provider.unreadCount;
            return Stack(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NotificationScreen()),
                    ).then((_) => _loadNotificationCount());
                  },
                  icon: const Icon(Icons.notifications_outlined, size: 28),
                ),
                if (unreadCount > 0)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        unreadCount > 99 ? '99+' : unreadCount.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  // ─── Total Sales Card ──────────────────────────────────────────────────────

  Widget _buildTotalSalesCard() {
    if (_isLoading) {
      return Card(
        color: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const ShimmerBox(width: 80, height: 14),
                  const ShimmerBox(width: 100, height: 14),
                ],
              ),
              const SizedBox(height: 12),
              const ShimmerBox(width: 150, height: 32),
              const SizedBox(height: 16),
              Container(
                height: 1,
                color: Colors.white12,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ShimmerBox(width: 70, height: 12),
                        const SizedBox(height: 6),
                        const ShimmerBox(width: 90, height: 18),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 36, color: Colors.white12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const ShimmerBox(width: 70, height: 12),
                          const SizedBox(height: 6),
                          const ShimmerBox(width: 90, height: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const ShimmerBox(width: 100, height: 16),
                  ShimmerBox(width: 100, height: 24, borderRadius: BorderRadius.circular(20)),
                ],
              ),
            ],
          ),
        ),
      );
    }

    final overview = _dashboardData?.overview;
    final totalSales = overview?.totalSales ?? 0;
    final availableBalance = overview?.availableBalance ?? 0;
    final pendingBalance = overview?.pendingBalance ?? 0;

    String _fmt(double value) =>
        _balanceHidden ? '••••••' : '\$${value.toStringAsFixed(2)}';

    return Card(
      color: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Sales',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const VendorSalesStatisticsScreen()),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'View Analysis',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _fmt(totalSales),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4ADE80),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              'Available',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _fmt(availableBalance),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 36,
                    color: Colors.white12,
                    margin: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: Colors.amber.shade300,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              'Pending',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _fmt(pendingBalance),
                          style: TextStyle(
                            color: Colors.amber.shade200,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () =>
                      setState(() => _balanceHidden = !_balanceHidden),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: Icon(
                    _balanceHidden
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.white54,
                    size: 15,
                  ),
                  label: Text(
                    _balanceHidden ? 'Show balance' : 'Hide balance',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.green.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedTimeframe,
                      focusColor: Colors.transparent,
                      isDense: true,
                      items: ['This week', 'This month', 'This year']
                          .map((label) => DropdownMenuItem(
                        value: label,
                        child: Text(label,
                            style: const TextStyle(fontSize: 12)),
                      ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedTimeframe = value);
                          _loadDashboardData();
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

  // ─── Orders Overview ───────────────────────────────────────────────────────

  Widget _buildOrdersOverview() {
    if (_isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(width: 150, height: 18),
          const SizedBox(height: 12),
          Row(
            children: List.generate(
              4,
                  (i) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < 3 ? 8 : 0),
                  child: ShimmerBox(
                    width: double.infinity,
                    height: 72,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    final overview = _dashboardData?.overview;

    final statuses = [
      {
        'label': 'New',
        'count': overview?.newOrders.toString() ?? '0',
        'key': 'new',
      },
      {
        'label': 'Pending',
        'count': overview?.pendingOrders.toString() ?? '0',
        'key': 'pending',
      },
      {
        'label': 'Shipped',
        'count': overview?.shippedOrders.toString() ?? '0',
        'key': 'shipped',
      },
      {
        'label': 'Delivered',
        'count': overview?.deliveredOrders.toString() ?? '0',
        'key': 'delivered',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Orders Overview',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(statuses.length, (i) {
            final s = statuses[i];
            final key = s['key']!;
            final count = int.tryParse(s['count']!) ?? 0;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  // Navigate to orders filtered by status
                },
                child: Container(
                  margin: i < statuses.length - 1
                      ? const EdgeInsets.only(right: 8)
                      : EdgeInsets.zero,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: _getStatusCardColor(key),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Text(
                        count.toString(),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _getStatusTextColor(key),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s['label']!,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: _getStatusTextColor(key).withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Color _getStatusCardColor(String status) {
    switch (status) {
      case 'new':
        return const Color(0xFFF0FDF4);
      case 'pending':
        return const Color(0xFFFFF7ED);
      case 'shipped':
        return const Color(0xFFEFF6FF);
      case 'delivered':
        return const Color(0xFFF0FDF4);
      case 'cancelled':
        return const Color(0xFFFFF1F2);
      default:
        return Colors.grey[50]!;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'new':
        return const Color(0xFF15803D);
      case 'pending':
        return const Color(0xFFC2570A);
      case 'shipped':
        return const Color(0xFF1D4ED8);
      case 'delivered':
        return const Color(0xFF15803D);
      case 'cancelled':
        return const Color(0xFFBE123C);
      default:
        return Colors.grey[700]!;
    }
  }

  // ─── Action Buttons ────────────────────────────────────────────────────────

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionButton(
          icon: Icons.add_box_outlined,
          label: 'Add Product',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VendorAddProductScreen()),
          ),
        ),
        _buildActionButton(
          icon: Icons.insights_outlined,
          label: 'Transactions',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VendorTransactionHistoryScreen()),
          ),
        ),
        _buildActionButton(
          icon: Icons.download_outlined,
          label: 'Withdraw',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EarningsWithdrawalsScreen()),
          ),
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

  // ─── This Week Strip ───────────────────────────────────────────────────────

  Widget _buildWeekStrip() {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const ShimmerBox(width: 80, height: 15),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const ShimmerBox(width: 40, height: 15),
                    const SizedBox(height: 4),
                    const ShimmerBox(width: 50, height: 11),
                  ],
                ),
                const SizedBox(width: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const ShimmerBox(width: 50, height: 15),
                    const SizedBox(height: 4),
                    const ShimmerBox(width: 60, height: 11),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    }

    final thisWeek = _dashboardData?.thisWeek;
    final totalOrders = thisWeek?.orders ?? 0;
    final totalRevenue = thisWeek?.revenue ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'This Week',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          Row(
            children: [
              _weekStat('$totalOrders', 'Orders'),
              const SizedBox(width: 24),
              _weekStat('\$${totalRevenue.toStringAsFixed(0)}', 'Revenue'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _weekStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.black45)),
      ],
    );
  }

  // ─── Recent Orders ─────────────────────────────────────────────────────────

  Widget _buildRecentOrders() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Orders',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            TextButton(
              onPressed: () {
                // Navigate to all orders screen
              },
              child: const Text('See all', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _isLoading
            ? _buildShimmerRecentOrders()
            : _error != null
            ? Center(
          child: Column(
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 8),
              Text('Failed to load orders: $_error'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _loadDashboardData,
                child: const Text('Retry'),
              ),
            ],
          ),
        )
            : _dashboardData?.recentOrders.isEmpty ?? true
            ? const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Text('No recent orders'),
          ),
        )
            : ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: (_dashboardData!.recentOrders.length).clamp(0, 3),
          itemBuilder: (context, index) {
            return _buildOrderCard(_dashboardData!.recentOrders[index]);
          },
        ),
      ],
    );
  }

  Widget _buildShimmerRecentOrders() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) => Card(
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
                  const ShimmerBox(width: 60, height: 60, borderRadius: BorderRadius.all(Radius.circular(12))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ShimmerBox(width: 80, height: 12),
                        const SizedBox(height: 4),
                        const ShimmerBox(width: 120, height: 14),
                        const SizedBox(height: 2),
                        const ShimmerBox(width: 100, height: 12),
                      ],
                    ),
                  ),
                  ShimmerBox(width: 80, height: 26, borderRadius: BorderRadius.circular(20)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const ShimmerBox(width: 120, height: 12),
                  const ShimmerBox(width: 80, height: 12),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(RecentOrder order) {
    final status = order.statusDisplay;
    final product = order.products.isNotEmpty ? order.products.first : null;
    final buyerName = order.buyerName ?? 'Guest';
    final buyerId = order.orderNumber.length >= 4
        ? order.orderNumber.substring(order.orderNumber.length - 4)
        : order.orderNumber;

    Color statusBg;
    Color statusFg;

    switch (status.toLowerCase()) {
      case 'new':
        statusBg = const Color(0xFFF0FDF4);
        statusFg = const Color(0xFF15803D);
        break;
      case 'ready to ship':
      case 'delivered':
        statusBg = const Color(0xFFF0FDF4);
        statusFg = const Color(0xFF15803D);
        break;
      case 'shipped':
        statusBg = const Color(0xFFEFF6FF);
        statusFg = const Color(0xFF1D4ED8);
        break;
      case 'pending':
        statusBg = const Color(0xFFFFF7ED);
        statusFg = const Color(0xFFC2570A);
        break;
      case 'cancelled':
        statusBg = const Color(0xFFFFF1F2);
        statusFg = const Color(0xFFBE123C);
        break;
      default:
        statusBg = Colors.grey[100]!;
        statusFg = Colors.grey[700]!;
    }

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
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: product?.image != null && product!.image!.startsWith('http')
                      ? Image.network(
                    product.image!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.black,
                      child: const Icon(Icons.image_outlined, color: Colors.white54),
                    ),
                  )
                      : Container(
                    width: 60,
                    height: 60,
                    color: Colors.black,
                    child: const Icon(Icons.image_outlined, color: Colors.white54),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.orderNumber,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product?.name ?? 'Product',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Buyer: $buyerId',
                        style: const TextStyle(fontSize: 12, color: Colors.black45),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: statusFg,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.formattedDate,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VendorOrderDetailsScreen(subOrderId: order.id),
                    ),
                  ),
                  child: const Text(
                    'View Details →',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
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
}