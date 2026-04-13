import 'package:afrotierre/View/Vendor_Screens/vendor_withdrawal_confirm_screen.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';


class VendorWithdrawalScreen extends StatefulWidget {
  const VendorWithdrawalScreen({super.key});

  @override
  State<VendorWithdrawalScreen> createState() => _VendorWithdrawalScreenState();
}

class _VendorWithdrawalScreenState extends State<VendorWithdrawalScreen> {
  final TextEditingController _amountController = TextEditingController();
  String? _selectedBank;
  bool _saveAsBeneficiary = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _showWithdrawalConfirmationSheet() {
    final double amount = double.tryParse(_amountController.text) ?? 0.0;
    const double processingFee = 0.19;
    final double netPayout = amount - processingFee;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Withdrawal amount',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '\$${amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                _buildDetailRow('Bank', _selectedBank ?? 'N/A'),
                _buildDetailRow('Account name', 'John Okafor'), // Placeholder
                _buildDetailRow(
                  'Processing Fee',
                  '\$${processingFee.toStringAsFixed(2)}',
                ),
                const Divider(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Net payout',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        '\$${netPayout.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VendorWithdrawalConfirmScreen(),
                      ),
                    );

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Withdraw',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.timer_outlined, size: 14, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      'Transfers are processed within a minute',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
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
          'Withdrawal',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCommissionCard(),
            const SizedBox(height: 32),
            _buildWithdrawalAmountSection(),
            const SizedBox(height: 24),
            _buildBankSelectionSection(),
            const SizedBox(height: 24),
            _buildAccountNumberSection(),
            const SizedBox(height: 16),
            _buildSaveBeneficiaryCheckbox(),
          ],
        ),
      ),
      bottomNavigationBar: _buildConfirmButton(),
    );
  }

  Widget _buildCommissionCard() {
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
                  'Total commission',
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  '\$2,481.09',
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

  Widget _buildWithdrawalAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Withdrawal Amount',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text('Enter amount', style: TextStyle(color: Colors.grey)),
            const Spacer(),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Withdraw all',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            prefixText: '\$ ',
            hintText: '0.00',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBankSelectionSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Select bank', style: TextStyle(color: Colors.grey)),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Beneficiaries',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: _selectedBank,
          hint: const Text('Choose your bank'),
          decoration: const InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
          items: ['Goldman Sachs', 'TD Bank', 'Capital One']
              .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              })
              .toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedBank = newValue;
            });
          },
        ),
      ],
    );
  }

  Widget _buildAccountNumberSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Account number', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey[400]!,
              style: BorderStyle.solid,
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Serah Collins',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              CircleAvatar(
                radius: 10,
                backgroundColor: Colors.black,
                child: CircleAvatar(radius: 4, backgroundColor: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSaveBeneficiaryCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _saveAsBeneficiary,
          onChanged: (value) {
            setState(() {
              _saveAsBeneficiary = value!;
            });
          },
          shape: const CircleBorder(),
          activeColor: Colors.black,
        ),
        const Text('Save this bank as beneficiary'),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: _showWithdrawalConfirmationSheet,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Confirm',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 14, color: Colors.grey),
              SizedBox(width: 4),
              Text(
                'Secure & Encrypted Transaction',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
