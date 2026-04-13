import 'package:afrotierre/View/Vendor_Screens/vendor_bottom_navigation_screen.dart';
import 'package:afrotierre/constants.dart';
import 'package:flutter/material.dart';

class VendorWithdrawalConfirmScreen extends StatelessWidget {
  const VendorWithdrawalConfirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.transparent),
            onPressed: () {},
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTotalTransferredCard(),
              const Spacer(),
              _buildSuccessDetails(),
              const Spacer(),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalTransferredCard() {
    return Card(
      color: Colors.yellow[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total transferred',
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  '\$499.81',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
                ),
              ],
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFFBE692),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Icon(Icons.bar_chart, color: Colors.orange[800]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessDetails() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green[50],
          ),
          child: Icon(Icons.check, color: Colors.green[700], size: 40),
        ),
        const SizedBox(height: 16),
        Chip(
          label: const Text(
            'Withdrawal Successful',
            style: TextStyle(color: Colors.green),
          ),
          backgroundColor: Colors.green[100],
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        const SizedBox(height: 16),
        const Text(
          'Your withdrawal has been processed successfully.\nThe amount of \$499.81 has been sent to the provided account.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            'View Receipt',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VendorBottomNavigationScreen(),
              ),
            );
          },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            side: BorderSide(color: Colors.grey[300]!),
          ),
          child: const Text(
            'Back to Home',
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
