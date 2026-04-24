import 'package:afrotierre/Models/SellerModels/SellerOrderModels.dart';
import 'package:afrotierre/Repository/SellerRepository/SellerOrderRepository.dart';
import 'package:afrotierre/View/Vendor_Screens/vendor_order_details_screen.dart';
import 'package:afrotierre/View/Vendor_Screens/vendor_order_refund_screen.dart';
import 'package:flutter/material.dart';
import '../../res/Widgets/ShimmerBox.dart';

class VendorOrdersScreen extends StatefulWidget {
  const VendorOrdersScreen({super.key});

  @override
  State<VendorOrdersScreen> createState() => _VendorOrdersScreenState();
}

class _VendorOrdersScreenState extends State<VendorOrdersScreen> {
  final SellerOrderRepository _orderRepository = SellerOrderRepository();

  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<SellerSubOrder> _orders = [];
  bool _isLoading = true;
  String? _error;

  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders({bool loadMore = false}) async {
    if (loadMore) {
      if (!_hasMore || _isLoadingMore) return;
      setState(() => _isLoadingMore = true);
    } else {
      setState(() {
        _isLoading = true;
        _error = null;
        _orders = [];
        _currentPage = 1;
        _hasMore = true;
      });
    }

    try {
      final status = _selectedFilter == 'All' ? null : _selectedFilter.toLowerCase();

      final response = await _orderRepository.getSellerOrders(
        page: loadMore ? _currentPage + 1 : 1,
        limit: 10,
        status: status,
      );

      setState(() {
        if (loadMore) {
          _orders.addAll(response.orders);
          _currentPage++;
        } else {
          _orders = response.orders;
          _currentPage = response.pagination.page;
        }
        _totalPages = response.pagination.pages;
        _hasMore = response.pagination.hasNextPage;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  List<SellerSubOrder> get _filteredOrders {
    if (_searchQuery.isEmpty) return _orders;

    final q = _searchQuery.toLowerCase();
    return _orders.where((order) {
      final productName = order.products.isNotEmpty ? order.products.first.name.toLowerCase() : '';
      final subOrderNumber = order.subOrderNumber.toLowerCase();
      final buyerName = order.mainOrder?.shippingAddress?.fullName.toLowerCase() ?? '';

      return productName.contains(q) ||
          subOrderNumber.contains(q) ||
          buyerName.contains(q);
    }).toList();
  }

  String _getDisplayStatus(SubOrderStatus status) {
    switch (status) {
      case SubOrderStatus.pending:
        return 'Pending';
      case SubOrderStatus.paid:
        return 'Paid';
      case SubOrderStatus.processing:
        return 'Processing';
      case SubOrderStatus.shipped:
        return 'Shipped';
      case SubOrderStatus.delivered:
        return 'Delivered';
      case SubOrderStatus.cancelled:
        return 'Cancelled';
      case SubOrderStatus.refunded:
        return 'Refunded';
    }
  }

  Map<String, Color> _getStatusColors(SubOrderStatus status) {
    switch (status) {
      case SubOrderStatus.processing:
        return {'bg': const Color(0xFFFEF3C7), 'text': const Color(0xFF92400E)};
      case SubOrderStatus.paid:
        return {'bg': const Color(0xFFEDE9FE), 'text': const Color(0xFF5B21B6)};
      case SubOrderStatus.shipped:
        return {'bg': const Color(0xFFDBEAFE), 'text': const Color(0xFF1E40AF)};
      case SubOrderStatus.delivered:
        return {'bg': const Color(0xFFD1FAE5), 'text': const Color(0xFF065F46)};
      case SubOrderStatus.cancelled:
      case SubOrderStatus.refunded:
        return {'bg': const Color(0xFFFEE2E2), 'text': const Color(0xFF991B1B)};
      default:
        return {'bg': const Color(0xFFF3F4F6), 'text': const Color(0xFF6B7280)};
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,

        title: const Text(
          'Order List',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.w600, fontSize: 17),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          const SizedBox(height: 4),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildShimmerList();
    }

    if (_error != null) {
      print('Error loading orders: $_error');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading orders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadOrders(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredOrders.isEmpty) {
      return _buildEmptyState();
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (!_isLoadingMore &&
            _hasMore &&
            scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
          _loadOrders(loadMore: true);
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        itemCount: _filteredOrders.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _filteredOrders.length && _isLoadingMore) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
          return _buildOrderCard(_filteredOrders[index]);
        },
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      itemCount: 5,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row shimmer
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 56, height: 56, borderRadius: BorderRadius.circular(12)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(width: 100, height: 14),
                      const SizedBox(height: 6),
                      ShimmerBox(width: 120, height: 12),
                      const SizedBox(height: 4),
                      ShimmerBox(width: 150, height: 12),
                    ],
                  ),
                ),
                ShimmerBox(width: 60, height: 15),
              ],
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: Colors.grey.shade100),
            const SizedBox(height: 12),
            // Bottom row shimmer
            Row(
              children: [
                ShimmerBox(width: 80, height: 26, borderRadius: BorderRadius.circular(20)),
                const SizedBox(width: 8),
                ShimmerBox(width: 100, height: 26, borderRadius: BorderRadius.circular(8)),
                const Spacer(),
                ShimmerBox(width: 90, height: 28, borderRadius: BorderRadius.circular(20)),
              ],
            ),
            const SizedBox(height: 10),
            ShimmerBox(width: 100, height: 11),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'No orders found',
            style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 15,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search by name, buyer or order ID',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.close, color: Colors.grey.shade400, size: 18),
            onPressed: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
          )
              : null,
          filled: true,
          fillColor: const Color(0xFFF2F2F2),
          contentPadding:
          const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      'All',
      'Processing',
      'Ready to Ship',
      'Shipped',
      'Delivered',
      'Refunded',
    ];
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  if (filter == 'Refunded') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const VendorOrderRefundScreen()),
                    );
                  } else {
                    setState(() {
                      _selectedFilter = filter;
                      _loadOrders(); // Reload with new filter
                    });
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.black : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? Colors.black
                          : Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    filter,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildOrderCard(SellerSubOrder order) {
    final status = _getDisplayStatus(order.status);
    final colors = _getStatusColors(order.status);
    final product = order.products.isNotEmpty ? order.products.first : null;
    final productName = product?.name ?? 'Unknown Product';
    final price = order.totalAmount;
    final itemsCount = order.totalItems;
    final buyerName = order.mainOrder?.shippingAddress?.fullName ?? 'Unknown Buyer';
    final orderId = order.subOrderNumber;
    final trackingNumber = order.trackingNumber;
    final timeAgo = _getTimeAgo(order.createdAt);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VendorOrderDetailsScreen(
            subOrderId: order.id,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: image + info + price
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: product?.image != null && product!.image!.startsWith('http')
                        ? Image.network(
                      product.image!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 56,
                          height: 56,
                          color: Colors.black,
                          child: const Icon(Icons.image_outlined,
                              color: Colors.white54, size: 26),
                        );
                      },
                    )
                        : Container(
                      width: 56,
                      height: 56,
                      color: Colors.black,
                      child: const Center(
                        child: Icon(Icons.image_outlined,
                            color: Colors.white54, size: 26),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Order info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          orderId,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.black87),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Buyer: $buyerName',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$productName · $itemsCount item${itemsCount > 1 ? 's' : ''}',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                  // Price
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.black87),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              Divider(height: 1, color: Colors.grey.shade100),
              const SizedBox(height: 12),

              // Bottom row: status + tracking + view button
              Row(
                children: [
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors['bg'],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colors['text']),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Tracking pill (if exists)
                  if (trackingNumber != null && trackingNumber.isNotEmpty)
                    _buildTrackingPill(trackingNumber),
                  const Spacer(),
                  // View details button
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'View Details',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              Text(
                timeAgo,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrackingPill(String tracking) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F0FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDDD6FE)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF7C3AED),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            tracking.length > 12 ? '${tracking.substring(0, 12)}...' : tracking,
            style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF6D28D9),
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown date';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}