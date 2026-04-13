import 'package:flutter/material.dart';


class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
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
          'Order detail',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),

        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(right: 16.0),
        //     child: GestureDetector(
        //       onTap: () {
        //         Navigator.pushNamed(context, refundScreen);
        //       },
        //       child: const Center(
        //         child: Text(
        //           'Refund',
        //           style: TextStyle(
        //             color: Colors.black,
        //             fontSize: 16,
        //             fontWeight: FontWeight.w500,
        //           ),
        //         ),
        //       ),
        //     ),
        //   ),
        // ],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShippedStatusCard(),
            const SizedBox(height: 24),
            _buildProductDetailsCard(),
            const SizedBox(height: 32),
            _buildDeliveryInformation(),
            const SizedBox(height: 32),
            _buildPaymentSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildShippedStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_shipping_outlined,
            color: Colors.blue[800],
            size: 40,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shipped',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue[800],
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Your order is on its way.',
                  style: TextStyle(color: Colors.grey),
                ),
                const Text(
                  'Estimated delivery by March 15th, 2026',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              image: const DecorationImage(
                image: AssetImage(
                  'assets/stock_image.png',
                ), // Placeholder image
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Adidas Shoe',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text('Quantity: 1', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const Text(
            '\$100',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Delivery Information',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 16),
        _buildInfoRow(
          Icons.location_on_outlined,
          '123 Main St, Los Angeles, CA 90001, USA',
        ),
        const SizedBox(height: 12),
        _buildInfoRow(Icons.track_changes_outlined, 'Tracking: 1Z999AA10123456784'),
        const SizedBox(height: 12),
        _buildInfoRow(Icons.local_shipping_outlined, 'Standard Shipping (3-5 business days)'),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(text, style: TextStyle(color: Colors.grey[800])),
      ],
    );
  }

  Widget _buildPaymentSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Summary',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 16),
        _buildSummaryRow('Item Total', '\$1,200'),
        const SizedBox(height: 8),
        _buildSummaryRow('Shipping Fee', '\$200'),
        const SizedBox(height: 8),
        _buildSummaryRow('Tax', '\$100'),
        const Divider(height: 32),
        _buildSummaryRow('Total Paid', '\$1,500', isBold: true),
        const SizedBox(height: 8),
        Text(
          'Paid with: Mastercard',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String title, String amount, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: Colors.grey[600])),
        Text(
          amount,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
