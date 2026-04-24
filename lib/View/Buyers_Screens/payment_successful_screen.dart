import 'package:afrotierre/View/Buyers_Screens/TrackOrder.dart';
import 'package:afrotierre/View/Buyers_Screens/order_detail_screen.dart';
import 'package:flutter/material.dart';
import '../../Services/AppSession.dart';

class PaymentSuccessfulScreen extends StatelessWidget {
  final String orderNumber;
  final String orderId;

  const PaymentSuccessfulScreen({
    super.key,
    required this.orderNumber,
    required this.orderId,
  });

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
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSuccessBadge(),
                    const SizedBox(height: 16),
                    _buildEmailRow(),
                  ],
                ),
              ),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),    );
  }

  Widget _buildSuccessBadge() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: Color(0xFFDCFCE7),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Color(0xFF16A34A),
            size: 44,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Payment Successful',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Order #$orderNumber has been placed successfully.\nYou will receive a confirmation email shortly.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 13.5,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailRow() {
    final buyerEmail = AppSession.instance.buyerEmail;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.email_outlined, color: Colors.grey[400], size: 16),
        const SizedBox(width: 6),
        Text(
          buyerEmail.isNotEmpty ? buyerEmail : 'customer@example.com',
          style: TextStyle(color: Colors.grey[500], fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OrderDetailScreen(orderId: orderId),
              ),
            );
          },
          icon: const Icon(Icons.receipt_long_outlined, color: Colors.white, size: 18),
          label: const Text(
            'View Order Details',
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
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) =>  TrackOrderScreen(orderId: orderId,)),
            );
          },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
          ),
          child: const Text(
            'Track Your Order',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}