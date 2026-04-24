// lib/View/Buyers_Screens/checkout_screen.dart

import 'dart:async';
import 'package:afrotierre/Models/BuyerModels/BuyerOrderModels.dart';
import 'package:afrotierre/Models/BuyerModels/CheckoutModels.dart';
import 'package:afrotierre/View/Buyers_Screens/payment_method_screen.dart';
import 'package:afrotierre/View/Buyers_Screens/payment_successful_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import '../../Constants/ApiConstants.dart';
import '../../Models/BuyerModels/BuyerLoginandProfileModels.dart'
    show BuyerData, PaymentMethod;
import '../../Repository/BuyerRepository/BuyerOrderRepository.dart';
import '../../Repository/BuyerRepository/CheckoutRepository.dart';
import '../../Services/AppSession.dart';
import '../../res/Widgets/ShimmerBox.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _processingPayment = false;
  bool _isLoading = true;
  String? _errorMessage;

  final CheckoutRepository _checkoutRepository = CheckoutRepository();
  final BuyerOrderRepository _orderRepository = BuyerOrderRepository();

  CheckoutData? _checkoutData;
  Map<String, dynamic>? _selectedCard;
  ShippingAddress? _shippingAddressFromProfile;

  @override
  void initState() {
    super.initState();
    _loadCheckoutData();
  }

  Future<void> _loadCheckoutData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AppSession.ensureInitialized();
      final buyerProfile = AppSession.instance.buyerProfile;

      if (buyerProfile != null) {
        _shippingAddressFromProfile =
            _getShippingAddressFromProfile(buyerProfile);
        _selectedCard = _getDefaultPaymentMethodFromProfile(buyerProfile);
      }

      final checkoutData = await _checkoutRepository.getCheckoutData();

      setState(() {
        _checkoutData = checkoutData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load checkout: ${e.toString()}')),
      );
    }
  }

  ShippingAddress? _getShippingAddressFromProfile(BuyerData buyerProfile) {
    if (buyerProfile.address != null && buyerProfile.address!.isNotEmpty) {
      final address = buyerProfile.address!;
      final Map<String, dynamic> typedAddress = {};
      address.forEach((key, value) {
        typedAddress[key.toString()] = value;
      });

      return ShippingAddress(
        fullName: buyerProfile.fullName ?? '',
        street: typedAddress['street']?.toString() ?? '',
        apartment: typedAddress['apartment']?.toString(),
        city: typedAddress['city']?.toString() ?? '',
        state: typedAddress['state']?.toString() ?? '',
        zipCode: typedAddress['zipCode']?.toString() ?? '',
        country: typedAddress['country']?.toString() ?? 'United States',
        phoneNumber: buyerProfile.phoneNumber ?? '',
        email: buyerProfile.email,
      );
    }
    return null;
  }

  Map<String, dynamic>? _getDefaultPaymentMethodFromProfile(
      BuyerData buyerProfile) {
    if (buyerProfile.paymentMethods != null &&
        buyerProfile.paymentMethods!.isNotEmpty) {
      final defaultMethod = buyerProfile.paymentMethods!.firstWhere(
            (pm) => pm.isDefault,
        orElse: () => buyerProfile.paymentMethods!.first,
      );

      return {
        'cardId': defaultMethod.paymentMethodId,
        'last4': defaultMethod.last4,
        'brand': defaultMethod.brand,
        'expMonth': defaultMethod.expMonth.toString(),
        'expYear': defaultMethod.expYear.toString(),
        'isDefault': defaultMethod.isDefault,
      };
    }
    return null;
  }

  double get _subtotal => _checkoutData?.summary.subtotal ?? 0;
  double get _totalShipping => _checkoutData?.summary.shippingTotal ?? 0;
  double get _tax => _checkoutData?.summary.taxAmount ?? 0;
  double get _total => _checkoutData?.summary.total ?? 0;
  List<SellerCheckoutGroup> get _sellerGroups =>
      _checkoutData?.sellers ?? [];
  ShippingAddress? get _shippingAddress => _shippingAddressFromProfile;

  Future<void> _placeOrder() async {
    if (_selectedCard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please add a payment method in your profile')),
      );
      return;
    }

    if (_shippingAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please add a delivery address in your profile')),
      );
      return;
    }

    setState(() => _processingPayment = true);

    try {
      final orderResponse = await _orderRepository.createOrder(
        CreateOrderRequest(
          products: _getOrderItems(),
          shippingAddress: _shippingAddress!,
          paymentMethodId: _selectedCard!['cardId'],
          idempotencyKey: _checkoutData?.checkoutId,
        ),
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentSuccessfulScreen(
              orderNumber: orderResponse.mainOrder.orderNumber,
              orderId: orderResponse.mainOrder.id,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _processingPayment = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<OrderItemRequest> _getOrderItems() {
    final List<OrderItemRequest> items = [];
    for (final seller in _sellerGroups) {
      for (final item in seller.items) {
        items.add(OrderItemRequest(
          productId: item.productId,
          quantity: item.quantity,
        ));
      }
    }
    return items;
  }

  Future<void> _changeCard() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PaymentMethodScreen()),
    );

    if (result != null && result is Map) {
      final Map<String, dynamic> typedResult = {};
      result.forEach((key, value) {
        typedResult[key.toString()] = value;
      });

      try {
        final paymentMethodId = typedResult['cardId']?.toString() ?? '';
        await _setDefaultPaymentMethod(paymentMethodId);

        setState(() {
          _selectedCard = {
            'last4': typedResult['last4'] ?? '••••',
            'brand': typedResult['brand'] ?? 'visa',
            'cardId': paymentMethodId,
            'expMonth': typedResult['expMonth']?.toString() ?? '',
            'expYear': typedResult['expYear']?.toString() ?? '',
            'isDefault': true,
          };
        });

        await _updateBuyerProfilePaymentMethod(paymentMethodId, typedResult);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to update payment method: ${e.toString()}'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _updateBuyerProfilePaymentMethod(
      String paymentMethodId, Map<String, dynamic> cardInfo) async {
    try {
      final buyerProfile = AppSession.instance.buyerProfile;
      if (buyerProfile != null) {
        final List<PaymentMethod> updatedPaymentMethods = [];

        if (buyerProfile.paymentMethods != null) {
          for (final pm in buyerProfile.paymentMethods!) {
            updatedPaymentMethods.add(PaymentMethod(
              paymentMethodId: pm.paymentMethodId,
              brand: pm.brand,
              last4: pm.last4,
              expMonth: pm.expMonth,
              expYear: pm.expYear,
              isDefault: pm.paymentMethodId == paymentMethodId,
              createdAt: pm.createdAt,
            ));
          }
        }

        final existing = updatedPaymentMethods
            .any((pm) => pm.paymentMethodId == paymentMethodId);
        if (!existing) {
          updatedPaymentMethods.add(PaymentMethod(
            paymentMethodId: paymentMethodId,
            brand: cardInfo['brand']?.toString() ?? 'visa',
            last4: cardInfo['last4']?.toString() ?? '••••',
            expMonth:
            int.tryParse(cardInfo['expMonth']?.toString() ?? '0') ?? 0,
            expYear: int.tryParse(cardInfo['expYear']?.toString() ?? '0') ?? 0,
            isDefault: true,
            createdAt: DateTime.now(),
          ));
        }

        final updatedProfile = buyerProfile.copyWith(
          paymentMethods: updatedPaymentMethods,
        );

        await AppSession.instance.updateBuyerProfile(updatedProfile);
      }
    } catch (e) {
      print('Error updating buyer profile: $e');
    }
  }

  Future<void> _setDefaultPaymentMethod(String paymentMethodId) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse(
          '${ApiConstants.baseUrlBuyer}/payment/payment-methods/$paymentMethodId/default');
      final response = await http.put(url, headers: headers);
      if (response.statusCode != 200) {
        throw Exception('Failed to set default payment method');
      }
    } catch (e) {
      print('Error setting default payment method: $e');
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<String?> _getAuthToken() async {
    await AppSession.ensureInitialized();
    return AppSession.instance.authToken;
  }

  Future<void> _refreshCheckout() async {
    await _loadCheckoutData();
  }

  // ─────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────

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
          'Checkout',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          if (!_isLoading && _checkoutData != null)
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              onPressed: _refreshCheckout,
            ),
        ],
      ),
      body: _isLoading
          ? _buildShimmerSkeleton()           // ← shimmer while loading
          : _errorMessage != null
          ? _buildErrorWidget()
          : _processingPayment
          ? _buildProcessingOverlay()
          : RefreshIndicator(
        onRefresh: _refreshCheckout,
        child: SingleChildScrollView(
          padding:
          const EdgeInsets.fromLTRB(16, 12, 16, 32),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_checkoutData != null &&
                  _checkoutData!.isExpired)
                _buildExpiryWarning(),
              ..._sellerGroups.map(_buildSellerGroup),
              const SizedBox(height: 16),
              _buildDeliveryAddress(),
              const SizedBox(height: 16),
              _buildShippingBreakdown(),
              const SizedBox(height: 16),
              _buildPaymentCard(),
              const SizedBox(height: 16),
              _buildOrderSummary(),
              const SizedBox(height: 12),
              _buildTermsText(),
            ],
          ),
        ),
      ),
      bottomNavigationBar:
      (!_isLoading && !_processingPayment) ? _buildBottomBar() : null,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SHIMMER SKELETON
  // ─────────────────────────────────────────────────────────────

  /// Full-page shimmer skeleton that mirrors the real layout.
  Widget _buildShimmerSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Seller / items card ──────────────────────────────
          _shimmerCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerRow(labelWidth: 100, valueWidth: 50),
                const SizedBox(height: 16),
                _shimmerProductRow(),
                const SizedBox(height: 14),
                _shimmerProductRow(),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Delivery address card ────────────────────────────
          _shimmerCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerRow(labelWidth: 120, valueWidth: 0),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(
                      width: 36,
                      height: 36,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerBox(width: 130, height: 14),
                          const SizedBox(height: 6),
                          ShimmerBox(width: double.infinity, height: 12),
                          const SizedBox(height: 5),
                          ShimmerBox(width: 160, height: 12),
                          const SizedBox(height: 5),
                          ShimmerBox(width: 100, height: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Shipping card ────────────────────────────────────
          _shimmerCard(
            child: Column(
              children: [
                _shimmerRow(labelWidth: 140, valueWidth: 0),
                const SizedBox(height: 16),
                _shimmerShippingRow(),
                const SizedBox(height: 12),
                _shimmerShippingRow(),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(thickness: 1),
                ),
                _shimmerRow(labelWidth: 100, valueWidth: 60),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Payment card ─────────────────────────────────────
          _shimmerCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerRow(labelWidth: 80, valueWidth: 60),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ShimmerBox(
                      width: 52,
                      height: 36,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(width: 160, height: 14),
                        const SizedBox(height: 6),
                        ShimmerBox(width: 100, height: 12),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Order summary card ───────────────────────────────
          _shimmerCard(
            child: Column(
              children: [
                _shimmerRow(labelWidth: 120, valueWidth: 0),
                const SizedBox(height: 16),
                _shimmerRow(labelWidth: 70, valueWidth: 60),
                const SizedBox(height: 10),
                _shimmerRow(labelWidth: 70, valueWidth: 60),
                const SizedBox(height: 10),
                _shimmerRow(labelWidth: 70, valueWidth: 60),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(thickness: 1),
                ),
                _shimmerRow(labelWidth: 50, valueWidth: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// White card wrapper used in the shimmer skeleton.
  Widget _shimmerCard({required Widget child}) {
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
      child: child,
    );
  }

  /// A label + optional value shimmer pair in a row.
  Widget _shimmerRow({required double labelWidth, required double valueWidth}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ShimmerBox(width: labelWidth, height: 13),
        if (valueWidth > 0) ShimmerBox(width: valueWidth, height: 13),
      ],
    );
  }

  /// Shimmer placeholder that looks like a product row.
  Widget _shimmerProductRow() {
    return Row(
      children: [
        ShimmerBox(
          width: 58,
          height: 58,
          borderRadius: BorderRadius.circular(12),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(width: double.infinity, height: 14),
              const SizedBox(height: 6),
              ShimmerBox(width: 80, height: 12),
              const SizedBox(height: 6),
              ShimmerBox(width: 50, height: 12),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ShimmerBox(width: 50, height: 14),
            const SizedBox(height: 5),
            ShimmerBox(width: 40, height: 11),
          ],
        ),
      ],
    );
  }

  /// Shimmer placeholder that looks like a shipping row.
  Widget _shimmerShippingRow() {
    return Row(
      children: [
        ShimmerBox(
          width: 36,
          height: 36,
          borderRadius: BorderRadius.circular(10),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(width: 120, height: 13),
              const SizedBox(height: 5),
              ShimmerBox(width: 90, height: 12),
            ],
          ),
        ),
        ShimmerBox(width: 40, height: 13),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // EXISTING WIDGETS (unchanged logic, kept intact)
  // ─────────────────────────────────────────────────────────────

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Failed to load checkout',
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _refreshCheckout,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiryWarning() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Your checkout session will expire in ${_checkoutData?.formattedTimeRemaining ?? 'a few minutes'}. Please complete your purchase soon.',
              style: TextStyle(color: Colors.red.shade700, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 56,
            height: 56,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Processing payment…',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Please do not close the app',
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerGroup(SellerCheckoutGroup group) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _buildSection(
        title: group.storeName,
        titleIcon: Icons.storefront_outlined,
        trailing: Text(
          '${group.itemCount} ${group.itemCount == 1 ? 'item' : 'items'}',
          style: TextStyle(color: Colors.grey[500], fontSize: 13),
        ),
        child: Column(
          children:
          group.items.map((item) => _buildProductRow(item)).toList(),
        ),
      ),
    );
  }

  Widget _buildProductRow(CheckoutItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: item.image != null
                ? Image.network(
              item.image!,
              width: 58,
              height: 58,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 58,
                height: 58,
                color: Colors.grey[200],
                child:
                const Icon(Icons.image, color: Colors.grey),
              ),
            )
                : Container(
              width: 58,
              height: 58,
              color: Colors.grey[200],
              child: const Icon(Icons.image, color: Colors.grey),
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
                      fontWeight: FontWeight.w600, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                if (item.discountPercent > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.formattedDiscount,
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(height: 2),
                Text(
                  'Qty: ${item.quantity}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${item.price.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 14),
              ),
              if (item.discountPercent > 0)
                Text(
                  '\$${item.originalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey[400],
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddress() {
    if (_shippingAddress == null) {
      return _buildSection(
        title: 'Delivery Address',
        child: Column(
          children: [
            const Icon(Icons.location_off_outlined,
                size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            const Text('No delivery address found in your profile'),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Please add an address in your profile settings')),
                );
              },
              child: const Text('Add Address'),
            ),
          ],
        ),
      );
    }

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
            child: Icon(Icons.location_on_outlined,
                size: 18, color: Colors.grey[600]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_shippingAddress!.fullName != null &&
                    _shippingAddress!.fullName!.isNotEmpty)
                  Text(
                    _shippingAddress!.fullName!,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                Text(
                  _shippingAddress!.street,
                  style:
                  TextStyle(color: Colors.grey[500], fontSize: 12.5),
                ),
                if (_shippingAddress!.apartment != null &&
                    _shippingAddress!.apartment!.isNotEmpty)
                  Text(
                    _shippingAddress!.apartment!,
                    style:
                    TextStyle(color: Colors.grey[500], fontSize: 12.5),
                  ),
                Text(
                  '${_shippingAddress!.city}, ${_shippingAddress!.state} ${_shippingAddress!.zipCode}',
                  style:
                  TextStyle(color: Colors.grey[500], fontSize: 12.5),
                ),
                Text(
                  _shippingAddress!.country ?? 'United States',
                  style:
                  TextStyle(color: Colors.grey[500], fontSize: 12.5),
                ),
                if (_shippingAddress!.phoneNumber != null &&
                    _shippingAddress!.phoneNumber!.isNotEmpty)
                  Text(
                    _shippingAddress!.phoneNumber!,
                    style:
                    TextStyle(color: Colors.grey[500], fontSize: 12.5),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingBreakdown() {
    return _buildSection(
      title: 'Shipping & Delivery',
      child: Column(
        children: [
          ..._sellerGroups.map((g) => _buildSellerShippingRow(g)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: Colors.grey[200], thickness: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Shipping',
                style: TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13.5),
              ),
              Text(
                '\$${_totalShipping.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13.5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSellerShippingRow(SellerCheckoutGroup group) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.local_shipping_outlined,
                size: 18, color: Colors.grey[600]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.storeName,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13.5),
                ),
                const SizedBox(height: 2),
                Text(
                  group.hasFreeShipping
                      ? 'Free shipping'
                      : 'Est. ${group.estimatedDeliveryDays} days delivery',
                  style:
                  TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            group.hasFreeShipping
                ? 'Free'
                : '\$${group.shippingCost.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
              color: group.hasFreeShipping ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard() {
    final card = _selectedCard;
    final brand = (card?['brand'] ?? '').toString().toLowerCase();

    return _buildSection(
      title: 'Payment',
      trailing: GestureDetector(
        onTap: _changeCard,
        child: Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Change',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black),
          ),
        ),
      ),
      child: card == null
          ? GestureDetector(
        onTap: _changeCard,
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.add_rounded,
                  size: 18, color: Colors.grey[500]),
            ),
            const SizedBox(width: 12),
            Text(
              'Add a payment method',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      )
          : Row(
        children: [
          Container(
            width: 52,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: FaIcon(_getCardIcon(brand),
                  size: 18, color: Colors.black87),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '•••• •••• •••• ${card['last4']}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  letterSpacing: 0.5,
                ),
              ),
              if (card['expMonth'] != null)
                Text(
                  'Expires ${card['expMonth']}/${card['expYear']}',
                  style: TextStyle(
                      color: Colors.grey[500], fontSize: 12),
                ),
            ],
          ),
          const Spacer(),
          if (card['isDefault'] == true)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Default',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return _buildSection(
      title: 'Order Summary',
      child: Column(
        children: [
          _summaryRow('Subtotal', '\$${_subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 10),
          _summaryRow('Shipping', '\$${_totalShipping.toStringAsFixed(2)}'),
          const SizedBox(height: 10),
          if (_tax > 0)
            _summaryRow(
              'Tax (${(_checkoutData?.summary.taxRate ?? 0 * 100).toStringAsFixed(0)}%)',
              '\$${_tax.toStringAsFixed(2)}',
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.grey[200], thickness: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Text(
                '\$${_total.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(color: Colors.grey[500], fontSize: 13.5)),
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

  Widget _buildTermsText() {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 11.5,
            height: 1.5,
          ),
          children: const [
            TextSpan(text: 'By placing your order you agree to our '),
            TextSpan(
              text: 'Terms of Use',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Payment',
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                '\$${_total.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 22),
              ),
            ],
          ),
          SizedBox(
            width: 180,
            height: 54,
            child: ElevatedButton(
              onPressed:
              _checkoutData?.isExpired == true ? null : _placeOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: _checkoutData?.isExpired == true
                    ? Colors.grey
                    : Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Pay Now',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded,
                      color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
    Widget? trailing,
    IconData? titleIcon,
  }) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (titleIcon != null) ...[
                    Icon(titleIcon, size: 14, color: Colors.black54),
                    const SizedBox(width: 5),
                  ],
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.black54,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  IconData _getCardIcon(String brand) {
    switch (brand.toLowerCase()) {
      case 'visa':
        return FontAwesomeIcons.ccVisa;
      case 'mastercard':
        return FontAwesomeIcons.ccMastercard;
      case 'amex':
        return FontAwesomeIcons.ccAmex;
      case 'discover':
        return FontAwesomeIcons.ccDiscover;
      default:
        return FontAwesomeIcons.creditCard;
    }
  }
}