import 'dart:async';

import 'package:afrotierre/View/Buyers_Screens/payment_method_screen.dart';
import 'package:afrotierre/View/Buyers_Screens/payment_successful_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _processingPayment = false;

  // Selected card state — populated from PaymentMethodScreen
  Map<String, dynamic>? _selectedCard = {
    'last4': '4242',
    'brand': 'visa',
    'expMonth': '12',
    'expYear': '26',
    'isDefault': true,
  };

  // Placeholder order data
  final List<Map<String, dynamic>> _products = [
    {
      'name': 'Unisex Black Duffle Bag',
      'size': 'S - Large',
      'quantity': 1,
      'price': 1200.00,
      'image': 'assets/stock_image.png',
    },
    {
      'name': 'Unisex Black Duffle Bag',
      'size': 'S - Large',
      'quantity': 1,
      'price': 1200.00,
      'image': 'assets/stock_image.png',
    },
  ];

  double get _subtotal =>
      _products.fold(0, (s, p) => s + (p['price'] as double) * (p['quantity'] as int));
  double get _shipping => 20.0;
  double get _discount => 10.0;
  double get _total => _subtotal + _shipping - _discount;

  void _startPaymentProcess() {
    if (_selectedCard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method')),
      );
      return;
    }
    setState(() => _processingPayment = true);
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PaymentSuccessfulScreen()),
        );
      }
    });
  }

  Future<void> _changeCard() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PaymentMethodScreen()),
    );
    if (result != null && result is Map) {
      // result contains cardId — find card details or just store id
      setState(() {
        _selectedCard = {
          'last4': '••••', // update from actual card data
          'brand': 'visa',
          'cardId': result['cardId'],
        };
      });
    }
  }

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
      ),
      body: _processingPayment
          ? _buildProcessingOverlay()
          : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductSummary(),
            const SizedBox(height: 16),
            _buildDeliveryAddress(),
            const SizedBox(height: 16),
            _buildShipping(),
            const SizedBox(height: 16),
            _buildPaymentCard(),
            const SizedBox(height: 16),
            _buildOrderSummary(),
            const SizedBox(height: 12),
            Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                      color: Colors.grey[400], fontSize: 11.5, height: 1.5),
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
            ),
          ],
        ),
      ),
      bottomNavigationBar:
      _processingPayment ? const SizedBox.shrink() : _buildBottomBar(),
    );
  }

  // ── Processing Overlay ────────────────────────────────────────────────────
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
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
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

  // ── Product Summary ───────────────────────────────────────────────────────
  Widget _buildProductSummary() {
    return _buildSection(
      title: 'Order Items',
      trailing: Text(
        '${_products.length} items',
        style: TextStyle(color: Colors.grey[500], fontSize: 13),
      ),
      child: Column(
        children: _products.map((p) => _buildProductRow(p)).toList(),
      ),
    );
  }

  Widget _buildProductRow(Map<String, dynamic> p) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              p['image'] as String,
              width: 58,
              height: 58,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p['name'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '${p['size']}  ·  Qty ${p['quantity']}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '\$${(p['price'] as double).toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ── Delivery Address ──────────────────────────────────────────────────────
  Widget _buildDeliveryAddress() {
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
            child: Icon(
              Icons.location_on_outlined,
              size: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Marcus Oris',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  '301 Grass Avenue Block 4, Opp Lopmart, Illinois 2231',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12.5, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Shipping ──────────────────────────────────────────────────────────────
  Widget _buildShipping() {
    return _buildSection(
      title: 'Shipping',
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.local_shipping_outlined,
              size: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Standard Delivery',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                '14 days from order date',
                style: TextStyle(color: Colors.grey[500], fontSize: 12.5),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '\$${_shipping.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ── Payment Card ──────────────────────────────────────────────────────────
  Widget _buildPaymentCard() {
    final card = _selectedCard;
    final brand = (card?['brand'] ?? '').toString().toLowerCase();

    return _buildSection(
      title: 'Payment',
      trailing: GestureDetector(
        onTap: _changeCard,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Change',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
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
              child: Icon(
                Icons.add_rounded,
                size: 18,
                color: Colors.grey[500],
              ),
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
              child: FaIcon(
                _getCardIcon(brand),
                size: 18,
                color: Colors.black87,
              ),
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
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          const Spacer(),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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

  // ── Order Summary ─────────────────────────────────────────────────────────
  Widget _buildOrderSummary() {
    return _buildSection(
      title: 'Order Summary',
      child: Column(
        children: [
          _summaryRow('Subtotal', '\$${_subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 10),
          _summaryRow('Shipping', '\$${_shipping.toStringAsFixed(2)}'),
          const SizedBox(height: 10),
          _summaryRow(
            'Discount',
            '-\$${_discount.toStringAsFixed(2)}',
            valueColor: Colors.green[600]!,
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
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                '\$${_total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
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
        Text(
          label,
          style: TextStyle(color: Colors.grey[500], fontSize: 13.5),
        ),
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

  // ── Bottom Bar ────────────────────────────────────────────────────────────
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
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
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 180,
                height: 54,
                child: ElevatedButton(
                  onPressed: _startPaymentProcess,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
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
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Section Card ──────────────────────────────────────────────────────────
  Widget _buildSection({
    required String title,
    required Widget child,
    Widget? trailing,
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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.black54,
                  letterSpacing: 0.3,
                ),
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
    switch (brand) {
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