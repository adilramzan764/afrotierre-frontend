import 'package:afrotierre/View/Buyers_Screens/bottom_navigation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../Models/BuyerModels/BuyerOrderModels.dart';
import '../../Repository/BuyerRepository/BuyerOrderRepository.dart';
import '../../res/Widgets/ShimmerBox.dart';

// ── Data models ───────────────────────────────────────────────────────────────

class OrderItem {
  final String name;
  final String size;
  final int quantity;
  final double price;
  final String image;

  const OrderItem({
    required this.name,
    required this.size,
    required this.quantity,
    required this.price,
    required this.image,
  });
}

class SellerShipment {
  final String sellerId;
  final String sellerName;
  final List<OrderItem> items;
  final String status;          // 'Processing' | 'Shipped' | 'Delivered'
  final String? trackingNumber; // null → "Not available"
  final String? trackingUrl;
  final String? estimatedDelivery;
  final double shipping;

  const SellerShipment({
    required this.sellerId,
    required this.sellerName,
    required this.items,
    required this.status,
    this.trackingNumber,
    this.trackingUrl,
    this.estimatedDelivery,
    required this.shipping,
  });

  double get subtotal =>
      items.fold(0, (s, i) => s + i.price * i.quantity);
}

// ── Screen ────────────────────────────────────────────────────────────────────

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final BuyerOrderRepository _orderRepository = BuyerOrderRepository();

  bool _isLoading = true;
  String? _error;
  MainOrder? _order;

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
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Convert SubOrder to SellerShipment for display
  List<SellerShipment> _convertToSellerShipments(MainOrder order) {
    return order.subOrders.map((subOrder) {
      // Convert products
      final items = subOrder.products.map((product) {
        // Extract size from attributes if available
        String size = 'Standard';
        if (product.attributes != null && product.attributes!.containsKey('Size')) {
          size = product.attributes!['Size'].toString();
        }

        return OrderItem(
          name: product.name,
          size: size,
          quantity: product.quantity,
          price: product.price,
          image: product.image ?? 'assets/stock_image.png',
        );
      }).toList();

      // Determine status string
      String statusString;
      switch (subOrder.status) {
        case SubOrderStatus.shipped:
          statusString = 'Shipped';
          break;
        case SubOrderStatus.delivered:
          statusString = 'Delivered';
          break;
        case SubOrderStatus.cancelled:
          statusString = 'Cancelled';
          break;
        case SubOrderStatus.refunded:
          statusString = 'Refunded';
          break;
        default:
          statusString = 'Processing';
      }

      // Get estimated delivery date
      String? estimatedDelivery;
      if (subOrder.shippedAt != null) {
        final estimatedDate = subOrder.shippedAt!
            .add(Duration(days: subOrder.estimatedDeliveryDays));
        estimatedDelivery = _formatDate(estimatedDate);
      }

      return SellerShipment(
        sellerId: subOrder.sellerId,
        sellerName: subOrder.seller?.storeName ?? 'Unknown Store',
        items: items,
        status: statusString,
        trackingNumber: subOrder.trackingNumber,
        trackingUrl: subOrder.trackingUrl,
        estimatedDelivery: estimatedDelivery,
        shipping: subOrder.shippingCost,
      );
    }).toList();
  }

  String _formatDate(DateTime date) {
    return _getMonthAbbreviation(date.month) + ' ${date.day}, ${date.year}';
  }

  String _getMonthAbbreviation(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Order Detail',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
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
      print('Error loading order details: $_error');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading order',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadOrderDetails,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_order == null) {
      return const Center(
        child: Text('No order found'),
      );
    }

    final shipments = _convertToSellerShipments(_order!);
    final subtotal = shipments.fold(0.0, (s, g) => s + g.subtotal);
    final totalShipping = shipments.fold(0.0, (s, g) => s + g.shipping);
    final total = subtotal + totalShipping;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderHeader(shipments),
          const SizedBox(height: 16),
          ...shipments.map(_buildSellerShipmentCard),
          const SizedBox(height: 4),
          _buildDeliveryAddress(_order!.shippingAddress),
          const SizedBox(height: 16),
          _buildPaymentSummary(
            subtotal: subtotal,
            totalShipping: totalShipping,
            total: total,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const BottomNavigationScreen(),
                ),
              );
            },
            child: const Text(
              'Go to Home',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              elevation: 0,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Shimmer Loading Widgets ────────────────────────────────────────────────

  Widget _buildShimmerContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order header shimmer
          _buildShimmerOrderHeader(),
          const SizedBox(height: 16),

          // Shipment cards shimmer (show 2-3 cards)
          _buildShimmerShipmentCard(),
          const SizedBox(height: 16),
          _buildShimmerShipmentCard(),
          const SizedBox(height: 16),

          // Delivery address shimmer
          _buildShimmerDeliveryAddress(),
          const SizedBox(height: 16),

          // Payment summary shimmer
          _buildShimmerPaymentSummary(),
          const SizedBox(height: 16),

          // Home button shimmer
          _buildShimmerHomeButton(),
        ],
      ),
    );
  }

  Widget _buildShimmerOrderHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(width: 180, height: 20),
              const SizedBox(height: 8),
              ShimmerBox(width: 150, height: 14),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerShipmentCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Seller header shimmer
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                ShimmerBox(width: 34, height: 34, borderRadius: BorderRadius.circular(10)),
                const SizedBox(width: 10),
                Expanded(
                  child: ShimmerBox(width: double.infinity, height: 16),
                ),
                ShimmerBox(width: 80, height: 28, borderRadius: BorderRadius.circular(20)),
              ],
            ),
          ),

          Divider(height: 1, thickness: 1, color: Colors.grey[100]),

          // Items section shimmer
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: ShimmerBox(width: 50, height: 14),
          ),

          // Item rows shimmer
          _buildShimmerItemRow(),
          _buildShimmerItemRow(),

          Divider(height: 1, thickness: 1, color: Colors.grey[100]),

          // Tracking section shimmer
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ShimmerBox(width: 16, height: 16),
                    const SizedBox(width: 8),
                    ShimmerBox(width: 200, height: 14),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ShimmerBox(width: 15, height: 15),
                    const SizedBox(width: 8),
                    ShimmerBox(width: 150, height: 14),
                  ],
                ),
                const SizedBox(height: 14),
                ShimmerBox(width: double.infinity, height: 44, borderRadius: BorderRadius.circular(22)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerItemRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          ShimmerBox(width: 52, height: 52, borderRadius: BorderRadius.circular(10)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: double.infinity, height: 14),
                const SizedBox(height: 6),
                ShimmerBox(width: 120, height: 12),
              ],
            ),
          ),
          ShimmerBox(width: 60, height: 14),
        ],
      ),
    );
  }

  Widget _buildShimmerDeliveryAddress() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 120, height: 14),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(width: 36, height: 36, borderRadius: BorderRadius.circular(10)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 150, height: 16),
                    const SizedBox(height: 6),
                    ShimmerBox(width: double.infinity, height: 12),
                    const SizedBox(height: 4),
                    ShimmerBox(width: 180, height: 12),
                    const SizedBox(height: 4),
                    ShimmerBox(width: 120, height: 12),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerPaymentSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 120, height: 14),
          const SizedBox(height: 12),
          _buildShimmerSummaryRow(),
          const SizedBox(height: 10),
          _buildShimmerSummaryRow(),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.grey[200], thickness: 1),
          ),
          _buildShimmerSummaryRow(isTotal: true),
          const SizedBox(height: 8),
          Row(
            children: [
              ShimmerBox(width: 15, height: 15),
              const SizedBox(width: 6),
              ShimmerBox(width: 120, height: 12),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              ShimmerBox(width: 12, height: 12),
              const SizedBox(width: 6),
              ShimmerBox(width: 100, height: 11),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerSummaryRow({bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ShimmerBox(width: 80, height: isTotal ? 16 : 14),
        ShimmerBox(width: 100, height: isTotal ? 18 : 14),
      ],
    );
  }

  Widget _buildShimmerHomeButton() {
    return ShimmerBox(
      width: double.infinity,
      height: 56,
      borderRadius: BorderRadius.circular(30),
    );
  }

  // ── Order header ──────────────────────────────────────────────────────────
  Widget _buildOrderHeader(List<SellerShipment> shipments) {
    final totalItems = shipments.fold(0, (sum, shipment) =>
    sum + shipment.items.fold(0, (s, item) => s + item.quantity));

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order ${_order!.orderNumber}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${shipments.length} shipment${shipments.length != 1 ? 's' : ''} · '
                    '$totalItems ${totalItems != 1 ? 'items' : 'item'}',
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Seller shipment card ──────────────────────────────────────────────────
  Widget _buildSellerShipmentCard(SellerShipment shipment) {
    final style = _statusStyle(shipment.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Seller header ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.storefront_outlined,
                      size: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      shipment.sellerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Status pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: style.bg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(style.icon, size: 12, color: style.color),
                        const SizedBox(width: 4),
                        Text(
                          style.label,
                          style: TextStyle(
                            color: style.color,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 1, thickness: 1, color: Colors.grey[100]),

            // ── Items ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(
                'Items',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.black54,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            ...shipment.items.map((item) => _buildItemRow(item)),

            Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey[100],
              indent: 16,
              endIndent: 16,
            ),

            // ── Tracking ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tracking number
                  Row(
                    children: [
                      Icon(Icons.track_changes_outlined,
                          size: 16, color: Colors.grey[500]),
                      const SizedBox(width: 8),
                      Text(
                        'Tracking: ',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 13,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          shipment.trackingNumber ?? 'Not available',
                          style: TextStyle(
                            fontWeight: shipment.trackingNumber != null
                                ? FontWeight.w600
                                : FontWeight.normal,
                            fontSize: 13,
                            color: shipment.trackingNumber != null
                                ? Colors.black
                                : Colors.grey[400],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (shipment.trackingNumber != null)
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(
                              ClipboardData(text: shipment.trackingNumber!),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Tracking number copied'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Icon(
                            Icons.copy_outlined,
                            size: 15,
                            color: Colors.grey[400],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Delivery estimate
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 15, color: Colors.grey[500]),
                      const SizedBox(width: 8),
                      Text(
                        'Est. delivery: ',
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      ),
                      Text(
                        shipment.estimatedDelivery ?? 'TBD',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  // Track Package button (only when shipped/delivered)
                  if (shipment.trackingNumber != null && shipment.trackingUrl != null) ...[
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Launch tracking URL
                          // You can use url_launcher package here
                        },
                        icon: const Icon(
                          Icons.open_in_new_rounded,
                          size: 15,
                          color: Colors.black,
                        ),
                        label: const Text(
                          'Track Package',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: item.image.startsWith('http')
                ? Image.network(
              item.image,
              width: 52,
              height: 52,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 52,
                  height: 52,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported),
                );
              },
            )
                : Image.asset(
              item.image,
              width: 52,
              height: 52,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 52,
                  height: 52,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.size}  ·  Qty ${item.quantity}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '\$${item.price.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
          ),
        ],
      ),
    );
  }

  // ── Delivery address ──────────────────────────────────────────────────────
  Widget _buildDeliveryAddress(ShippingAddress address) {
    return _buildSection(
      title: 'Delivery Address',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.location_on_outlined, size: 18, color: Colors.grey[600]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address.fullName,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  '${address.street}${address.apartment != null ? ', ${address.apartment}' : ''}',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${address.city}, ${address.state} ${address.zipCode}',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  address.phoneNumber,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Payment summary ───────────────────────────────────────────────────────
  Widget _buildPaymentSummary({
    required double subtotal,
    required double totalShipping,
    required double total,
  }) {
    return _buildSection(
      title: 'Payment Summary',
      child: Column(
        children: [
          _summaryRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 10),
          _summaryRow('Shipping', '\$${totalShipping.toStringAsFixed(2)}'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.grey[200], thickness: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Paid',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.credit_card_outlined, size: 15, color: Colors.grey[400]),
              const SizedBox(width: 6),
              Text(
                'Paid with ${_order!.paymentMethod.toUpperCase()}',
                style: TextStyle(color: Colors.grey[500], fontSize: 12.5),
              ),
            ],
          ),
          if (_order!.paidAt != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey[400]),
                const SizedBox(width: 6),
                Text(
                  'Paid on ${_formatDate(_order!.paidAt!)}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 13.5)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13.5,
            color: valueColor ?? Colors.black,
          ),
        ),
      ],
    );
  }

  // ── Generic section card ──────────────────────────────────────────────────
  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.black54,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  // ── Status style helper ───────────────────────────────────────────────────────
  _StatusStyle _statusStyle(String status) {
    switch (status.toLowerCase()) {
      case 'shipped':
        return const _StatusStyle(
          color: Color(0xFF1D4ED8),
          bg: Color(0xFFEFF6FF),
          icon: Icons.local_shipping_outlined,
          label: 'Shipped',
        );
      case 'delivered':
        return const _StatusStyle(
          color: Color(0xFF16A34A),
          bg: Color(0xFFDCFCE7),
          icon: Icons.check_circle_outline_rounded,
          label: 'Delivered',
        );
      case 'cancelled':
        return const _StatusStyle(
          color: Color(0xFFDC2626),
          bg: Color(0xFFFEE2E2),
          icon: Icons.cancel_outlined,
          label: 'Cancelled',
        );
      case 'refunded':
        return const _StatusStyle(
          color: Color(0xFF8B5CF6),
          bg: Color(0xFFEDE9FE),
          icon: Icons.receipt_outlined,
          label: 'Refunded',
        );
      case 'processing':
      default:
        return const _StatusStyle(
          color: Color(0xFFF59E0B),
          bg: Color(0xFFFFFBEB),
          icon: Icons.hourglass_top_rounded,
          label: 'Processing',
        );
    }
  }
}

// ── Status style helper ───────────────────────────────────────────────────────
class _StatusStyle {
  final Color color;
  final Color bg;
  final IconData icon;
  final String label;

  const _StatusStyle({
    required this.color,
    required this.bg,
    required this.icon,
    required this.label,
  });
}