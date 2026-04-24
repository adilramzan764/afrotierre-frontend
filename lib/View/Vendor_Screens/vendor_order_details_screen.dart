import 'package:afrotierre/Models/SellerModels/SellerOrderModels.dart';
import 'package:afrotierre/Repository/SellerRepository/SellerOrderRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../res/Widgets/ShimmerBox.dart';

class VendorOrderDetailsScreen extends StatefulWidget {
  final String subOrderId;
  const VendorOrderDetailsScreen({super.key, required this.subOrderId});

  @override
  State<VendorOrderDetailsScreen> createState() => _VendorOrderDetailsScreenState();
}

class _VendorOrderDetailsScreenState extends State<VendorOrderDetailsScreen> {
  final SellerOrderRepository _orderRepository = SellerOrderRepository();
  bool _isLoading = true;
  String? _error;
  SellerSubOrder? _order;
  bool _isUpdatingStatus = false;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final order = await _orderRepository.getSubOrderDetails(widget.subOrderId);
      setState(() { _order = order; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _updateOrderStatus(String newStatus, {String? trackingNumber, String? carrier}) async {
    setState(() => _isUpdatingStatus = true);
    try {
      await _orderRepository.updateSubOrderStatus(
        _order!.id,
        UpdateOrderStatusRequest(status: newStatus, trackingNumber: trackingNumber, carrier: carrier),
      );
      await _loadOrderDetails();
      if (mounted) _showSnack('Order status updated to $newStatus', isError: false);
    } catch (e) {
      if (mounted) _showSnack('Failed to update status: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isUpdatingStatus = false);
    }
  }

  Future<void> _downloadShippingLabel() async {
    try {
      await _orderRepository.downloadShippingLabel(_order!.id);
      if (mounted) _showSnack('Label downloaded successfully', isError: false);
    } catch (e) {
      if (mounted) _showSnack('Failed to download label: $e', isError: true);
    }
  }

  Future<void> _generateShippingLabel() async {
    setState(() => _isUpdatingStatus = true);
    try {
      final response = await _orderRepository.generateShippingLabel(_order!.id);
      await _loadOrderDetails();
      if (mounted) _showSnack(response.message, isError: !response.success);
    } catch (e) {
      if (mounted) _showSnack('Failed to generate label: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isUpdatingStatus = false);
    }
  }

  void _showSnack(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF16A34A),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  void _showStatusUpdateDialog() {
    final statusOptions = ['processing', 'shipped', 'delivered', 'cancelled'];
    String selectedStatus = _order!.status.toString().split('.').last;
    final trackingController = TextEditingController();
    final carrierController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Update status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              ...statusOptions.map((status) => _buildStatusOption(
                status, selectedStatus,
                onTap: () => setSheetState(() => selectedStatus = status),
              )),
              if (selectedStatus == 'shipped') ...[
                const SizedBox(height: 12),
                _buildTextField(trackingController, 'Tracking number'),
                const SizedBox(height: 10),
                _buildTextField(carrierController, 'Carrier'),
              ],
              const SizedBox(height: 20),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    child: const Text('Cancel', style: TextStyle(color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _updateOrderStatus(
                        selectedStatus,
                        trackingNumber: trackingController.text.isNotEmpty ? trackingController.text : null,
                        carrier: carrierController.text.isNotEmpty ? carrierController.text : null,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      minimumSize: const Size(0, 50),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Confirm', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusOption(String status, String selected, {required VoidCallback onTap}) {
    final isSelected = status == selected;
    final label = status[0].toUpperCase() + status.substring(1);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.black : const Color(0xFFE5E7EB)),
        ),
        child: Row(children: [
          Expanded(child: Text(label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isSelected ? Colors.white : Colors.black,
              ))),
          if (isSelected) const Icon(Icons.check, color: Colors.white, size: 18),
        ]),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Order details',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 17)),
        centerTitle: true,
        actions: [
          if (_order != null &&
              _order!.status != SubOrderStatus.shipped &&
              _order!.status != SubOrderStatus.delivered)
            IconButton(
              onPressed: _isUpdatingStatus ? null : _showStatusUpdateDialog,
              icon: const Icon(Icons.edit_outlined, color: Colors.black, size: 20),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return _buildShimmer();
    if (_error != null) return _buildError();
    if (_order == null) return const Center(child: Text('Order not found'));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderHeroCard(),
          const SizedBox(height: 12),
          _buildProductsCard(),
          const SizedBox(height: 12),
          _buildShippingAddressCard(),
          if (_order!.pickupAddressDetails != null) ...[
            const SizedBox(height: 12),
            _buildPickupAddressCard(),
          ],
          const SizedBox(height: 12),
          _buildPaymentSummaryCard(),
          if (_order!.shippedAt != null || _order!.deliveredAt != null) ...[
            const SizedBox(height: 12),
            _buildShippingTimelineCard(),
          ],
          const SizedBox(height: 20),
          _buildActionButtons(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Order Hero Card ─────────────────────────────────────────────────────────

  Widget _buildOrderHeroCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_order!.subOrderNumber,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(_formatDate(_order!.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ]),
              _buildStatusBadge(_order!.status),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 12),
          _buildInfoRow('Main order', _order!.mainOrder?.orderNumber ?? 'N/A'),
          const SizedBox(height: 6),
          _buildInfoRow('Shipping', _order!.shippingStatus.displayValue),
          if (_order!.trackingNumber != null) ...[
            const SizedBox(height: 6),
            _buildInfoRow('Tracking', _order!.trackingNumber!),
          ],
          if (_order!.carrier != null) ...[
            const SizedBox(height: 6),
            _buildInfoRow('Carrier', _order!.carrier!),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(SubOrderStatus status) {
    final style = _getStatusStyle(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: style.bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 6, height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: style.dotColor)),
        const SizedBox(width: 6),
        Text(style.label,
            style: TextStyle(color: style.textColor, fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  // ── Products Card ───────────────────────────────────────────────────────────

  Widget _buildProductsCard() {
    return _buildCard(
      title: 'Products',
      titleIcon: Icons.shopping_bag_outlined,
      child: Column(
        children: _order!.products.asMap().entries.map((e) {
          return Column(children: [
            if (e.key != 0) const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
            if (e.key != 0) const SizedBox(height: 10),
            _buildProductItem(e.value),
            if (e.key != _order!.products.length - 1) const SizedBox(height: 10),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildProductItem(OrderProduct product) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: product.image != null && product.image!.startsWith('http')
            ? Image.network(product.image!, width: 52, height: 52, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _imagePlaceholder())
            : _imagePlaceholder(),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(product.name,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 3),
        Text('Qty: ${product.quantity}',
            style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        if (product.attributes != null && product.attributes!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(_formatAttributes(product.attributes!),
                style: TextStyle(fontSize: 11, color: Colors.grey[400])),
          ),
      ])),
      const SizedBox(width: 8),
      Text('\$${(product.price * product.quantity).toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
    ]);
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 52, height: 52,
      color: const Color(0xFFF3F4F6),
      child: Icon(Icons.image_outlined, color: Colors.grey[400], size: 20),
    );
  }

  // ── Shipping Address Card ───────────────────────────────────────────────────

  Widget _buildShippingAddressCard() {
    final a = _order!.shippingAddress;
    return _buildCard(
      title: 'Shipping address',
      titleIcon: Icons.location_on_outlined,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(a.fullName,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 6),
        Text(
          [a.street, if (a.apartment != null) a.apartment!,
            '${a.city}, ${a.state} ${a.zipCode}',
            if (a.country != null) a.country!].join('\n'),
          style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.6),
        ),
        const SizedBox(height: 6),
        Row(children: [
          Icon(Icons.phone_outlined, size: 13, color: Colors.grey[500]),
          const SizedBox(width: 4),
          Text(a.phoneNumber,
              style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ]),
        if (a.email != null) ...[
          const SizedBox(height: 3),
          Row(children: [
            Icon(Icons.email_outlined, size: 13, color: Colors.grey[500]),
            const SizedBox(width: 4),
            Text(a.email!,
                style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          ]),
        ],
      ]),
    );
  }

  // ── Pickup Address Card ─────────────────────────────────────────────────────

  Widget _buildPickupAddressCard() {
    final a = _order!.pickupAddressDetails!;
    return _buildCard(
      title: 'Pickup address',
      titleIcon: Icons.storefront_outlined,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(a.addressLabel,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 6),
        Text(
          [a.street, if (a.apartment.isNotEmpty) a.apartment,
            '${a.city}, ${a.state} ${a.zipCode}', a.country].join('\n'),
          style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.6),
        ),
        const SizedBox(height: 6),
        Row(children: [
          Icon(Icons.phone_outlined, size: 13, color: Colors.grey[500]),
          const SizedBox(width: 4),
          Text(a.phoneNumber,
              style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ]),
      ]),
    );
  }

  // ── Payment Summary Card ────────────────────────────────────────────────────

  Widget _buildPaymentSummaryCard() {
    return _buildCard(
      title: 'Payment summary',
      titleIcon: Icons.receipt_long_outlined,
      child: Column(children: [
        _buildSummaryRow('Subtotal', '\$${_order!.subtotal.toStringAsFixed(2)}'),
        const SizedBox(height: 6),
        _buildSummaryRow('Shipping', '\$${_order!.shippingCost.toStringAsFixed(2)}'),
        if (_order!.discountAmount > 0) ...[
          const SizedBox(height: 6),
          _buildSummaryRow('Discount', '-\$${_order!.discountAmount.toStringAsFixed(2)}',
              valueColor: const Color(0xFF16A34A)),
        ],
        if (_order!.taxAmount > 0) ...[
          const SizedBox(height: 6),
          _buildSummaryRow('Tax', '\$${_order!.taxAmount.toStringAsFixed(2)}'),
        ],
        const SizedBox(height: 12),
        const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
        const SizedBox(height: 12),
        _buildSummaryRow('Total', '\$${_order!.totalAmount.toStringAsFixed(2)}',
            isBold: true, fontSize: 16),
      ]),
    );
  }

  // ── Shipping Timeline Card ──────────────────────────────────────────────────

  Widget _buildShippingTimelineCard() {
    return _buildCard(
      title: 'Shipping timeline',
      titleIcon: Icons.timeline_outlined,
      child: Column(children: [
        _buildTimelineItem('Stock deducted', _order!.stockDeductedAt, _order!.stockDeducted, isLast: false),
        _buildTimelineItem('Shipped', _order!.shippedAt, _order!.shippedAt != null, isLast: false),
        _buildTimelineItem('Delivered', _order!.deliveredAt, _order!.deliveredAt != null, isLast: true),
        if (_order!.lastShippingError != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.error_outline_rounded,
                  color: Color(0xFFDC2626), size: 16),
              const SizedBox(width: 8),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Shipping error',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                        color: Color(0xFFDC2626))),
                const SizedBox(height: 2),
                Text(_order!.lastShippingError!,
                    style: const TextStyle(fontSize: 11, color: Color(0xFFEF4444))),
              ])),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _buildTimelineItem(String title, DateTime? date, bool isCompleted, {required bool isLast}) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(children: [
        Container(
          width: 26, height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? const Color(0xFFDCFCE7) : const Color(0xFFF3F4F6),
            border: Border.all(
              color: isCompleted ? const Color(0xFF86EFAC) : const Color(0xFFE5E7EB),
            ),
          ),
          child: Icon(
            isCompleted ? Icons.check_rounded : Icons.circle_outlined,
            size: isCompleted ? 14 : 10,
            color: isCompleted ? const Color(0xFF16A34A) : Colors.grey[400],
          ),
        ),
        if (!isLast)
          Container(width: 1.5, height: 28,
              color: isCompleted ? const Color(0xFF86EFAC) : const Color(0xFFE5E7EB)),
      ]),
      const SizedBox(width: 12),
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: isCompleted ? Colors.black : Colors.grey[500],
              )),
          if (date != null) ...[
            const SizedBox(height: 2),
            Text(_formatDateTime(date),
                style: TextStyle(fontSize: 11, color: Colors.grey[400])),
          ],
          SizedBox(height: isLast ? 0 : 16),
        ]),
      ),
    ]);
  }

  // ── Action Buttons ──────────────────────────────────────────────────────────

  Widget _buildActionButtons() {
    final hasTracking = _order!.trackingNumber != null;
    final hasLabel = _order!.labelUrl != null;
    final isShipped = _order!.status == SubOrderStatus.shipped;
    final isDelivered = _order!.status == SubOrderStatus.delivered;
    final isProcessing = _order!.status == SubOrderStatus.processing;

    return Column(children: [
      if (hasTracking) ...[
        _buildOutlineButton(
          label: 'Copy tracking number',
          icon: Icons.copy_rounded,
          onTap: () {
            Clipboard.setData(ClipboardData(text: _order!.trackingNumber!));
            _showSnack('Tracking number copied', isError: false);
          },
        ),
        const SizedBox(height: 10),
      ],
      if (hasLabel) ...[
        _buildOutlineButton(
          label: 'Download shipping label',
          icon: Icons.download_rounded,
          onTap: _downloadShippingLabel,
        ),
        const SizedBox(height: 10),
      ],
      if (isProcessing && !hasLabel) ...[
        _buildPrimaryButton(
          label: 'Generate shipping label',
          icon: Icons.local_shipping_outlined,
          onTap: _isUpdatingStatus ? null : _generateShippingLabel,
        ),
        const SizedBox(height: 10),
      ],
      if ( !isDelivered)
      _buildPrimaryButton(
          label: 'Update order status',
          icon: Icons.edit_outlined,
          onTap: _isUpdatingStatus ? null : _showStatusUpdateDialog,
        ),
    ]);
  }

  Widget _buildPrimaryButton({required String label, required IconData icon, VoidCallback? onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 18),
        label: Text(label,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
    );
  }

  Widget _buildOutlineButton({required String label, required IconData icon, VoidCallback? onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.black, size: 18),
        label: Text(label,
            style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
        ),
      ),
    );
  }

  // ── Shared Card Builder ─────────────────────────────────────────────────────

  Widget _buildCard({String? title, IconData? titleIcon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
          if (title != null) ...[
            Row(children: [
              if (titleIcon != null) ...[
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(titleIcon, size: 15, color: Colors.grey[600]),
                ),
                const SizedBox(width: 8),
              ],
              Text(title,
                  style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700,
                    color: Colors.grey[500], letterSpacing: 0.2,
                  )),
            ]),
            const SizedBox(height: 14),
          ],
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        width: 100,
        child: Text(label,
            style: TextStyle(fontSize: 12, color: Colors.grey[500])),
      ),
      Expanded(
        child: Text(value,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: valueColor ?? Colors.black)),
      ),
    ]);
  }

  Widget _buildSummaryRow(String label, String value,
      {Color? valueColor, bool isBold = false, double fontSize = 13}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label,
          style: TextStyle(
              fontSize: fontSize, color: Colors.grey[500],
              fontWeight: isBold ? FontWeight.w700 : FontWeight.normal)),
      Text(value,
          style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: valueColor ?? Colors.black)),
    ]);
  }

  // ── Shimmer & Error ─────────────────────────────────────────────────────────

  Widget _buildShimmer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _shimmerCard(160),
        const SizedBox(height: 12),
        _shimmerCard(180),
        const SizedBox(height: 12),
        _shimmerCard(140),
        const SizedBox(height: 12),
        _shimmerCard(120),
      ]),
    );
  }

  Widget _shimmerCard(double height) {
    return Container(
      width: double.infinity, height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ShimmerBox(width: 100, height: 14),
        const SizedBox(height: 14),
        ShimmerBox(width: double.infinity, height: 12),
        const SizedBox(height: 8),
        ShimmerBox(width: double.infinity, height: 12),
        const SizedBox(height: 8),
        ShimmerBox(width: 160, height: 12),
      ]),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.error_outline_rounded,
                size: 32, color: Color(0xFFDC2626)),
          ),
          const SizedBox(height: 16),
          const Text('Failed to load order',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(_error!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[500])),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadOrderDetails,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text('Try again',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ]),
      ),
    );
  }

  // ── Status Styling ──────────────────────────────────────────────────────────

  _StatusStyle _getStatusStyle(SubOrderStatus status) {
    switch (status) {
      case SubOrderStatus.shipped:
        return const _StatusStyle(
            bgColor: Color(0xFFEFF6FF), dotColor: Color(0xFF3B82F6),
            textColor: Color(0xFF1D4ED8), label: 'Shipped');
      case SubOrderStatus.delivered:
        return const _StatusStyle(
            bgColor: Color(0xFFF0FDF4), dotColor: Color(0xFF22C55E),
            textColor: Color(0xFF16A34A), label: 'Delivered');
      case SubOrderStatus.cancelled:
        return const _StatusStyle(
            bgColor: Color(0xFFF9FAFB), dotColor: Color(0xFF9CA3AF),
            textColor: Color(0xFF6B7280), label: 'Cancelled');
      case SubOrderStatus.refunded:
        return const _StatusStyle(
            bgColor: Color(0xFFFEF2F2), dotColor: Color(0xFFEF4444),
            textColor: Color(0xFFDC2626), label: 'Refunded');
      case SubOrderStatus.processing:
      default:
        return const _StatusStyle(
            bgColor: Color(0xFFF5F3FF), dotColor: Color(0xFF8B5CF6),
            textColor: Color(0xFF6D28D9), label: 'Processing');
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) return 'N/A';
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final ampm = date.hour < 12 ? 'AM' : 'PM';
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[date.month - 1]} ${date.day} at $hour:$minute $ampm';
  }

  String _formatAttributes(Map<String, dynamic> attributes) {
    return attributes.entries.map((e) => '${e.key}: ${e.value}').join(' · ');
  }
}

class _StatusStyle {
  final Color bgColor;
  final Color dotColor;
  final Color textColor;
  final String label;
  const _StatusStyle({
    required this.bgColor, required this.dotColor,
    required this.textColor, required this.label,
  });
}