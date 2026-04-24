import 'package:afrotierre/Models/BuyerModels/BuyerOrderModels.dart';
import 'package:afrotierre/Repository/BuyerRepository/BuyerOrderRepository.dart';
import 'package:afrotierre/View/Buyers_Screens/refund_screen.dart';
import 'package:afrotierre/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../res/Widgets/ShimmerBox.dart';

// ─── Data Models ─────────────────────────────────────────────────────────────

class TrackingStep {
  final String status;
  final String detail;
  final bool isCompleted;
  final DateTime? timestamp;

  const TrackingStep({
    required this.status,
    required this.detail,
    required this.isCompleted,
    this.timestamp,
  });
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class TrackOrderScreen extends StatefulWidget {
  final String orderId;

  const TrackOrderScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {
  final BuyerOrderRepository _orderRepository = BuyerOrderRepository();

  bool _isLoading = true;
  String? _error;
  MainOrder? _order;
  Map<String, TrackingInfoResponse?> _trackingInfo = {};
  String? _selectedSubOrderId;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final order = await _orderRepository.getOrderDetails(widget.orderId);
      setState(() {
        _order = order;
        // Select first sub-order by default
        if (order.subOrders.isNotEmpty) {
          _selectedSubOrderId = order.subOrders.first.id;
        }
      });

      // Load tracking info for all sub-orders
      await _loadAllTrackingInfo(order.subOrders);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAllTrackingInfo(List<SubOrder> subOrders) async {
    for (var subOrder in subOrders) {
      try {
        final trackingInfo = await _orderRepository.getTrackingInfo(subOrder.id);
        setState(() {
          _trackingInfo[subOrder.id] = trackingInfo;
        });
      } catch (e) {
        print('Failed to load tracking for ${subOrder.id}: $e');
        setState(() {
          _trackingInfo[subOrder.id] = null;
        });
      }
    }
  }

  List<SubOrder> get _subOrdersWithTracking {
    if (_order == null) return [];
    return _order!.subOrders.where((subOrder) =>
    subOrder.trackingNumber != null && subOrder.trackingNumber!.isNotEmpty
    ).toList();
  }

  SubOrder? get _selectedSubOrder {
    if (_order == null || _selectedSubOrderId == null) return null;
    try {
      return _order!.subOrders.firstWhere((so) => so.id == _selectedSubOrderId);
    } catch (e) {
      return null;
    }
  }

  List<TrackingStep> _buildTrackingSteps(SubOrder subOrder, TrackingInfoResponse? trackingInfo) {
    final steps = <TrackingStep>[];

    // Step 1: Order Confirmed
    steps.add(TrackingStep(
      status: 'Order Confirmed',
      detail: _order!.createdAt != null
          ? _formatDateTime(_order!.createdAt!)
          : 'Order placed',
      isCompleted: true,
      timestamp: _order!.createdAt,
    ));

    // Step 2: Stock Reserved / Payment Confirmed
    steps.add(TrackingStep(
      status: 'Payment Confirmed',
      detail: _order!.paidAt != null
          ? _formatDateTime(_order!.paidAt!)
          : 'Payment processed',
      isCompleted: _order!.paidAt != null,
      timestamp: _order!.paidAt,
    ));

    // Step 3: Stock Deducted
    steps.add(TrackingStep(
      status: 'Stock Reserved',
      detail: subOrder.stockDeductedAt != null
          ? _formatDateTime(subOrder.stockDeductedAt!)
          : 'Stock not yet reserved',
      isCompleted: subOrder.stockDeducted,
      timestamp: subOrder.stockDeductedAt,
    ));

    // Step 4: Shipped
    steps.add(TrackingStep(
      status: 'Shipped',
      detail: subOrder.shippedAt != null
          ? _formatDateTime(subOrder.shippedAt!)
          : 'Not yet shipped',
      isCompleted: subOrder.shippedAt != null,
      timestamp: subOrder.shippedAt,
    ));

    // Step 5: In Transit (if tracking info is available)
    if (trackingInfo != null && trackingInfo.status != null) {
      steps.add(TrackingStep(
        status: 'In Transit',
        detail: trackingInfo.status ?? 'Package in transit',
        isCompleted: trackingInfo.status != null && trackingInfo.status != 'pending',
        timestamp: trackingInfo.shippedAt,
      ));
    } else if (subOrder.shippedAt != null) {
      steps.add(TrackingStep(
        status: 'In Transit',
        detail: 'Package is on its way',
        isCompleted: true,
        timestamp: subOrder.shippedAt,
      ));
    } else {
      steps.add(TrackingStep(
        status: 'In Transit',
        detail: 'Awaiting shipment',
        isCompleted: false,
      ));
    }

    // Step 6: Delivered
    steps.add(TrackingStep(
      status: 'Delivered',
      detail: subOrder.deliveredAt != null
          ? _formatDateTime(subOrder.deliveredAt!)
          : trackingInfo?.estimatedDelivery != null
          ? 'Expected: ${_formatDate(trackingInfo!.estimatedDelivery!)}'
          : subOrder.estimatedDeliveryDate,
      isCompleted: subOrder.deliveredAt != null,
      timestamp: subOrder.deliveredAt,
    ));

    return steps;
  }

  String _formatDateTime(DateTime date) {
    return '${_getMonthAbbreviation(date.month)} ${date.day}, ${date.year} | ${_formatTime(date)}';
  }

  String _formatDate(DateTime date) {
    return '${_getMonthAbbreviation(date.month)} ${date.day}, ${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final ampm = date.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $ampm';
  }

  String _getMonthAbbreviation(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
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
          'Track Order',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildShimmerContent();
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading tracking information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadOrderDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_order == null) {
      return const Center(
        child: Text('Order not found'),
      );
    }

    final shipmentsWithTracking = _subOrdersWithTracking;

    if (shipmentsWithTracking.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_shipping_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No tracking information available',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Order #${_order!.orderNumber}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order-level header
          _buildOrderHeader(),
          const SizedBox(height: 24),

          // Sub-order selector (if multiple shipments)
          if (shipmentsWithTracking.length > 1)
            _buildSubOrderSelector(shipmentsWithTracking),

          if (shipmentsWithTracking.length > 1)
            const SizedBox(height: 16),

          // Selected shipment card
          if (_selectedSubOrder != null)
            _buildShipmentCard(_selectedSubOrder!, _trackingInfo[_selectedSubOrder!.id]),

          const SizedBox(height: 16),
          _buildContactSupport(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Shimmer Loading Widgets ────────────────────────────────────────────────

  Widget _buildShimmerContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order header shimmer
          _buildShimmerOrderHeader(),
          const SizedBox(height: 24),

          // Shipment card shimmer
          _buildShimmerShipmentCard(),
          const SizedBox(height: 16),

          // Contact support shimmer
          _buildShimmerContactSupport(),
        ],
      ),
    );
  }

  Widget _buildShimmerOrderHeader() {
    return Row(
      children: [
        ShimmerBox(width: 20, height: 20),
        const SizedBox(width: 8),
        ShimmerBox(width: 180, height: 16),
        const Spacer(),
        ShimmerBox(width: 80, height: 24, borderRadius: BorderRadius.circular(16)),
      ],
    );
  }

  Widget _buildShimmerShipmentCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header shimmer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                ShimmerBox(width: 16, height: 16),
                const SizedBox(width: 6),
                ShimmerBox(width: 100, height: 13),
                const Spacer(),
                ShimmerBox(width: 60, height: 20, borderRadius: BorderRadius.circular(12)),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product row shimmer
                _buildShimmerProductRow(),
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 14),

                // Tracking number row shimmer
                _buildShimmerTrackingNumberRow(),
                const SizedBox(height: 14),

                // Timeline title shimmer
                const Row(
                  children: [
                    Icon(Icons.timeline, size: 16, color: Colors.grey),
                    SizedBox(width: 6),
                    Text(
                      'Tracking History',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Timeline steps shimmer
                _buildShimmerTrackingStep(),
                _buildShimmerTrackingStep(),
                _buildShimmerTrackingStep(),
                _buildShimmerTrackingStep(),

                // Estimated delivery shimmer
                const SizedBox(height: 16),
                _buildShimmerEstimatedDelivery(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerProductRow() {
    return Row(
      children: [
        ShimmerBox(width: 64, height: 64, borderRadius: BorderRadius.circular(10)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(width: double.infinity, height: 14),
              const SizedBox(height: 4),
              ShimmerBox(width: 100, height: 11),
              const SizedBox(height: 6),
              ShimmerBox(width: 80, height: 14),
            ],
          ),
        ),
        ShimmerBox(width: 70, height: 26, borderRadius: BorderRadius.circular(12)),
      ],
    );
  }

  Widget _buildShimmerTrackingNumberRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          ShimmerBox(width: 16, height: 16),
          const SizedBox(width: 8),
          ShimmerBox(width: 80, height: 12),
          const SizedBox(width: 8),
          Expanded(child: ShimmerBox(width: double.infinity, height: 12)),
        ],
      ),
    );
  }

  Widget _buildShimmerTrackingStep() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              ShimmerBox(width: 22, height: 22, borderRadius: BorderRadius.circular(11)),
              ShimmerBox(width: 1, height: 36),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 120, height: 13),
                const SizedBox(height: 4),
                ShimmerBox(width: 180, height: 11),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerEstimatedDelivery() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Row(
        children: [
          ShimmerBox(width: 20, height: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 100, height: 11),
                const SizedBox(height: 4),
                ShimmerBox(width: 120, height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerContactSupport() {
    return Center(
      child: Column(
        children: [
          ShimmerBox(width: 150, height: 14),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShimmerBox(width: 20, height: 20),
              const SizedBox(width: 8),
              ShimmerBox(width: 100, height: 14),
            ],
          ),
        ],
      ),
    );
  }

  // ── Actual Content Widgets ─────────────────────────────────────────────────

  Widget _buildOrderHeader() {
    return Row(
      children: [
        const Icon(Icons.receipt_long_outlined, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          'Order #${_order!.orderNumber}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const Spacer(),
        Chip(
          label: Text('${_order!.subOrders.length} Shipment${_order!.subOrders.length > 1 ? 's' : ''}'),
          backgroundColor: Colors.grey[200],
          labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 6),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  Widget _buildSubOrderSelector(List<SubOrder> shipments) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Shipment',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          ...shipments.map((subOrder) {
            final isSelected = _selectedSubOrderId == subOrder.id;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSubOrderId = subOrder.id;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black.withOpacity(0.05) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.grey[300]!,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_shipping,
                      size: 20,
                      color: isSelected ? Colors.black : Colors.grey[600],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subOrder.seller?.storeName ?? 'Seller',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.black : Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${subOrder.products.length} item(s) • ${subOrder.status.displayValue}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle, size: 20, color: Colors.green),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildShipmentCard(SubOrder subOrder, TrackingInfoResponse? trackingInfo) {
    final trackingSteps = _buildTrackingSteps(subOrder, trackingInfo);

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header: Seller
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(Icons.storefront_outlined, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  subOrder.seller?.storeName ?? 'Unknown Store',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                _buildStatusChip(subOrder.status.displayValue),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Row (show first product)
                _buildProductRow(subOrder),
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 14),

                // Tracking Number Row
                _buildTrackingNumberRow(subOrder),
                const SizedBox(height: 14),

                // Tracking Timeline
                const Row(
                  children: [
                    Icon(Icons.timeline, size: 16, color: Colors.grey),
                    SizedBox(width: 6),
                    Text(
                      'Tracking History',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...List.generate(trackingSteps.length, (i) {
                  return _buildTrackingStep(
                    step: trackingSteps[i],
                    isLast: i == trackingSteps.length - 1,
                  );
                }),

                // Estimated Delivery Info
                if (trackingInfo?.estimatedDelivery != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[100]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.blue[700], size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Estimated Delivery',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatDate(trackingInfo!.estimatedDelivery!),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[900],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductRow(SubOrder subOrder) {
    final product = subOrder.products.first;

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: product.image != null && product.image!.startsWith('http')
              ? Image.network(
            product.image!,
            width: 64,
            height: 64,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 64,
                height: 64,
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported),
              );
            },
          )
              : Container(
            width: 64,
            height: 64,
            color: Colors.grey[200],
            child: const Icon(Icons.image),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                'Ordered: ${_order!.formattedOrderDate}',
                style: TextStyle(color: Colors.grey[600], fontSize: 11),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              if (product.quantity > 1)
                Text(
                  'Qty: ${product.quantity}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 11),
                ),
            ],
          ),
        ),
        _buildStatusChip(subOrder.status.displayValue),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color bg;
    Color fg;
    switch (status.toLowerCase()) {
      case 'delivered':
        bg = Colors.green[100]!;
        fg = Colors.green[800]!;
        break;
      case 'shipped':
      case 'in transit':
        bg = Colors.blue[100]!;
        fg = Colors.blue[800]!;
        break;
      case 'processing':
        bg = Colors.orange[100]!;
        fg = Colors.orange[800]!;
        break;
      default:
        bg = Colors.grey[200]!;
        fg = Colors.grey[700]!;
    }
    return Chip(
      label: Text(status),
      backgroundColor: bg,
      labelStyle: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 10),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildTrackingNumberRow(SubOrder subOrder) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_shipping_outlined, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            'Tracking No: ',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          Expanded(
            child: Text(
              subOrder.trackingNumber ?? 'Not Available',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: subOrder.trackingNumber != null ? Colors.black : Colors.grey,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (subOrder.trackingNumber != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: subOrder.trackingNumber!));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tracking number copied'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Icon(Icons.copy_outlined, size: 14, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTrackingStep({
    required TrackingStep step,
    required bool isLast,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: step.isCompleted ? Colors.black : Colors.grey[300],
                ),
                child: Icon(
                  step.isCompleted ? Icons.check : Icons.access_time,
                  color: Colors.white,
                  size: 13,
                ),
              ),
              if (!isLast)
                Container(
                  width: 1,
                  height: 36,
                  color: Colors.grey[300],
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.status,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: step.isCompleted ? Colors.black : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.detail,
                    style: TextStyle(color: Colors.grey[500], fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSupport() {
    return Center(
      child: Column(
        children: [
          Text(
            'Need help with your order?',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RefundScreen()),
              );
            },
            child: const Row(
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