import 'package:afrotierre/View/Buyers_Screens/TrackOrder.dart';
import 'package:afrotierre/View/Buyers_Screens/order_detail_screen.dart';
import 'package:flutter/material.dart';
import '../../Models/BuyerModels/BuyerOrderModels.dart';
import '../../Repository/BuyerRepository/BuyerOrderRepository.dart';
import '../../res/Widgets/ShimmerBox.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final BuyerOrderRepository _orderRepository = BuyerOrderRepository();

  String _selectedFilter = 'All';
  List<MainOrder> _orders = [];
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
      final response = await _orderRepository.getBuyerOrders(
        page: loadMore ? _currentPage + 1 : 1,
        limit: 10,
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

  // Filter orders based on status
  List<MainOrder> get _filteredOrders {
    if (_selectedFilter == 'All') return _orders;

    return _orders.where((order) {
      final status = _getOrderStatusCategory(order);
      return status == _selectedFilter;
    }).toList();
  }

  String _getOrderStatusCategory(MainOrder order) {
    switch (order.status) {
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
      case OrderStatus.refunded:
      case OrderStatus.partially_refunded:
        return 'Refunded';
      default:
        return 'In progress';
    }
  }

  String _getDisplayStatus(MainOrder order) {
    switch (order.status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.paid:
        return 'Paid';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.partially_shipped:
        return 'Partially Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.refunded:
        return 'Refunded';
      case OrderStatus.partially_refunded:
        return 'Partially Refunded';
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.shipped:
        return Colors.blue;
      case OrderStatus.partially_shipped:
        return Colors.orange;
      case OrderStatus.processing:
        return const Color(0xFFEA580C);
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
      case OrderStatus.refunded:
      case OrderStatus.partially_refunded:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  bool _canTrack(MainOrder order) {
    return order.status == OrderStatus.shipped ||
        order.status == OrderStatus.partially_shipped;
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
          'My orders',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [_buildFilterChips(), Expanded(child: _buildBody())],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildShimmerList();
    }

    if (_error != null) {
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
            ElevatedButton(onPressed: _loadOrders, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_filteredOrders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No orders found',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (!_isLoadingMore &&
            _hasMore &&
            scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent - 200) {
          _loadOrders(loadMore: true);
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: 5,
      itemBuilder:
          (context, index) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order ID and status shimmer
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerBox(width: 120, height: 16),
                          const SizedBox(height: 8),
                          ShimmerBox(width: 150, height: 12),
                        ],
                      ),
                    ),
                    ShimmerBox(
                      width: 80,
                      height: 24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Product images shimmer
                Row(
                  children: [
                    ShimmerBox(
                      width: 52,
                      height: 52,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    const SizedBox(width: 8),
                    ShimmerBox(
                      width: 52,
                      height: 52,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Price and date shimmer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerBox(width: 80, height: 16),
                    ShimmerBox(width: 60, height: 12),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: Colors.grey[200], height: 1),
                const SizedBox(height: 12),
                // Buttons shimmer
                Row(
                  children: [
                    Expanded(
                      child: ShimmerBox(width: double.infinity, height: 40),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ShimmerBox(width: double.infinity, height: 40),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'In progress', 'Delivered', 'Refunded'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children:
              filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedFilter = filter);
                    },
                    backgroundColor: Colors.transparent,
                    selectedColor: Colors.grey[100],
                    labelStyle: TextStyle(
                      fontSize: 13,
                      color: isSelected ? Colors.black : Colors.grey[600],
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color:
                            isSelected ? Colors.grey[400]! : Colors.grey[300]!,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildOrderCard(MainOrder order) {
    final status = _getDisplayStatus(order);
    final statusColor = _getStatusColor(order.status);
    final trackable = _canTrack(order);

    // Get unique sellers count
    final uniqueSellers =
        order.subOrders.map((so) => so.sellerId).toSet().length;

    // Get total items count
    final totalItems = order.totalItems;

    // Get product images (max 2 for preview)
    final List<String> productImages = [];
    for (var subOrder in order.subOrders) {
      for (var product in subOrder.products) {
        if (product.image != null && productImages.length < 3) {
          productImages.add(product.image!);
        }
      }
    }
    final previewImages = productImages.take(2).toList();
    final extraCount = totalItems - previewImages.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: order id + status pill
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order ${order.orderNumber}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            '$uniqueSellers seller${uniqueSellers > 1 ? 's' : ''}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$totalItems item${totalItems > 1 ? 's' : ''}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(status, statusColor),
              ],
            ),

            const SizedBox(height: 12),

            // Item thumbnails (max 2 + overflow badge)
            if (previewImages.isNotEmpty)
              Row(
                children: [
                  ...previewImages.map(
                    (imageUrl) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[100],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 24,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (extraCount > 0)
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Center(
                        child: Text(
                          '+$extraCount',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

            const SizedBox(height: 12),

            // Price + date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  order.formattedOrderDate,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Divider(color: Colors.grey[200], height: 1),
            const SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    label: 'Track order',
                    icon: Icons.location_on_outlined,
                    filled: false,
                    enabled: trackable,
                    onTap:
                        trackable
                            ? () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => TrackOrderScreen(
                                      orderId: order.id,
                                    ),
                              ),
                            )
                            : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildActionButton(
                    label: 'Order details',
                    icon: Icons.receipt_long_outlined,
                    filled: true,
                    enabled: true,
                    onTap: () {
                      print('Navigating to details of order ${order.id}');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderDetailScreen(orderId: order.id),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required bool filled,
    required bool enabled,
    VoidCallback? onTap,
  }) {
    final bg =
        !enabled
            ? Colors.grey[100]!
            : filled
            ? Colors.black
            : Colors.white;
    final fg =
        !enabled
            ? Colors.grey[400]!
            : filled
            ? Colors.white
            : Colors.black;
    final borderColor =
        !enabled
            ? Colors.grey[300]!
            : filled
            ? Colors.black
            : Colors.grey[300]!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: fg),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
