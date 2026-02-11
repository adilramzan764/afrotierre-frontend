import 'package:flutter/material.dart';

import '../constants.dart';

class VendorSubcriptionPlanScreen extends StatefulWidget {
  const VendorSubcriptionPlanScreen({super.key});

  @override
  State<VendorSubcriptionPlanScreen> createState() =>
      _VendorSubcriptionPlanScreenState();
}

class _VendorSubcriptionPlanScreenState
    extends State<VendorSubcriptionPlanScreen> {
  String _selectedPlan = 'year';

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
          'Subscription',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildFeatureList(),
            const SizedBox(height: 40),
            _buildPlanOption(
              planId: 'year',
              price: '39,999 \$ per year, auto-renewable',
              duration: '1 year Access',
            ),
            const SizedBox(height: 16),
            _buildPlanOption(
              planId: 'month',
              price: '5,99 \$ per month, auto-renewable',
              duration: '1 Month Access',
            ),
            const Spacer(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomSection(),
    );
  }

  Widget _buildFeatureList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.star_outline, color: Colors.black, size: 28),
            SizedBox(width: 12),
            Text(
              'Upgrade to Pro',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildFeatureItem('Unlimited access'),
        _buildFeatureItem('Free Shipping'),
        _buildFeatureItem('Shopping Vouchers'),
        _buildFeatureItem('Ad free'),
      ],
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 12,
            backgroundColor: Colors.black,
            child: Icon(Icons.check, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildPlanOption({
    required String planId,
    required String price,
    required String duration,
  }) {
    final isSelected = _selectedPlan == planId;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlan = planId;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.black : Colors.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Center(
                      child: CircleAvatar(
                        radius: 8,
                        backgroundColor: Colors.black,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  price,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  duration,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Cancel in the App Store Any time',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, vendorProductDetailsScreen);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Subscribe & Start Free Trial',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Your subscription will automatically renew unless you cancelled at least 24 hours prior to the end of your trial.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
