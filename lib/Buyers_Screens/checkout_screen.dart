import 'dart:async';

import 'package:afrotierre/Buyers_Screens/payment_successful_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPaymentMethod = 'Credit card';
  bool _isAddingCard = false;
  bool _rememberCard = false;
  bool _processingPayment = false;

  void _startPaymentProcess() {
    setState(() {
      _processingPayment = true;
    });

    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const PaymentSuccessfulScreen(),
        ),
      );
    });
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
          onPressed: () {
            if (_isAddingCard) {
              setState(() {
                _isAddingCard = false;
              });
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          _isAddingCard ? 'Payment' : 'Checkout',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isAddingCard) ...[
                  _buildCardInformationSection(),
                  const SizedBox(height: 24),
                ],
                _buildProductSummary(),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'No charges until order confirmation!',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 24),
                _buildDeliveryAddress(),
                const SizedBox(height: 24),
                _buildShipping(),
                const SizedBox(height: 24),
                if (!_isAddingCard) ...[
                  _buildPaymentMethod(),
                  const SizedBox(height: 24),
                ],
                _buildOrderSummary(),
                const SizedBox(height: 16),
                Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                      children: [
                        TextSpan(
                          text: 'By Submitting Your Order, You Agree To Our ',
                        ),
                        TextSpan(
                          text: 'Terms Of Use',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_processingPayment)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Image.asset(
                  'assets/processing_payment.png',
                ), // Make sure you have this asset
              ),
            ),
        ],
      ),
      bottomNavigationBar: _processingPayment
          ? const SizedBox.shrink()
          : _buildBottomCheckout(),
    );
  }

  Widget _buildCardInformationSection() {
    return _buildInfoCard(
      icon: Icons.credit_card_outlined,
      title: 'Card Information',
      topTrailing: TextButton(
        onPressed: () {
          setState(() {
            _isAddingCard = false;
          });
        },
        child: const Text('Pay with Registered Card'),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: 'Card number',
              hintText: '1234 5678 5987 6545',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock_outline, size: 20),
              suffixIcon: SizedBox(
                width: 24,
                child: Center(
                  child: Image.asset(
                    'assets/mastercard.png',
                    height: 24,
                  ), // Placeholder
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Expiry Date',
                    hintText: '02/28',
                    border: const OutlineInputBorder(),
                    suffixIcon: const Icon(
                      Icons.calendar_today_outlined,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'CVC/CVV',
                    hintText: '356',
                    border: const OutlineInputBorder(),
                    suffixIcon: const Icon(Icons.info_outline, size: 20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.shield_outlined, color: Colors.green[700], size: 20),
              const SizedBox(width: 8),
              const Text(
                'Payment is secure and encrypted',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Remember this card for future use'),
            value: _rememberCard,
            onChanged: (value) {
              setState(() {
                _rememberCard = value;
              });
            },
            activeColor: Colors.black,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildProductSummary() {
    // Placeholder data
    final products = [
      {
        'name': 'Unisex black duffle bag',
        'size': 'S - Large',
        'quantity': 1,
        'price': 1200.00,
        'image': 'assets/stock_image.png', // placeholder
        'color': Colors.grey[200],
      },
      {
        'name': 'Unisex black duffle bag',
        'size': 'S - Large',
        'quantity': 1,
        'price': 1200.00,
        'image': 'assets/stock_image.png', // placeholder
        'color': Colors.red[100],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Product Summary (${products.length})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'View all',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final product = products[index];
            return Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: product['color'] as Color?,
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: AssetImage(product['image'] as String),
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
                        product['name'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product['size'] as String,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Quantity: ${product['quantity']}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${(product['price'] as double).toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.grey,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildDeliveryAddress() {
    return _buildInfoCard(
      icon: Icons.location_on_outlined,
      title: 'Delivery Address',
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Marcus oris(+123 000 2122 3434)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            '301 grass avenue block 4, opp lopmart Illinois-postal 2231',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }

  Widget _buildShipping() {
    return _buildInfoCard(
      icon: Icons.local_shipping_outlined,
      title: 'Shipping',
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Standard', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text(
            '14days delivery from date of order',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return _buildInfoCard(
      icon: Icons.payment_outlined,
      title: 'Payment method',
      child: Column(
        children: [
          _buildPaymentOption('Credit card', const Icon(Icons.credit_card)),
          _buildPaymentOption(
            'Paypal',
            const FaIcon(FontAwesomeIcons.paypal, color: Colors.blueAccent),
          ),
          _buildPaymentOption(
            'Apple Pay',
            Image.asset('assets/apple.png', height: 24),
          ),
          const Divider(),
          TextButton(
            onPressed: () {
              setState(() {
                _isAddingCard = true;
              });
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: Colors.black),
                SizedBox(width: 8),
                Text('Add a new card', style: TextStyle(color: Colors.black)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String method, Widget icon) {
    return RadioListTile<String>(
      value: method,
      groupValue: _selectedPaymentMethod,
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedPaymentMethod = value;
          });
        }
      },
      title: Row(
        children: [
          SizedBox(width: 24, height: 24, child: icon),
          const SizedBox(width: 16),
          Text(method),
        ],
      ),
      controlAffinity: ListTileControlAffinity.trailing,
      activeColor: Colors.black,
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required Widget child,
    Widget? trailing,
    Widget? topTrailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.grey[600]),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              if (topTrailing != null) topTrailing,
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 40), // Align with title
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Summary (2)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 16),
        _buildSummaryRow('Items-total', '\$2,400'),
        _buildSummaryRow('Shipping Fee', '\$20'),
        _buildSummaryRow('Admin Fee', 'Free'),
        _buildSummaryRow('items discount', '-\$10', isDiscount: true),
      ],
    );
  }

  Widget _buildSummaryRow(
    String title,
    String amount, {
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[600])),
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDiscount ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCheckout() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total payment',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                '\$2,410',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'You saved \$10 with this discount',
                style: TextStyle(color: Colors.grey),
              ),
              Text(
                '\$2,420',
                style: TextStyle(
                  color: Colors.grey,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isAddingCard ? null : _startPaymentProcess,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isAddingCard ? Colors.grey : Colors.black,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Checkout',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
