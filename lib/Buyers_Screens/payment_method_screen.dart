import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../constants.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String _selectedMethod = 'Debit or Credit Card';

  final List<Map<String, dynamic>> _paymentMethods = [
    {'name': 'Debit or Credit Card', 'icon': FontAwesomeIcons.creditCard},
    {'name': 'Paypal', 'icon': FontAwesomeIcons.paypal},
    {'name': 'Bank Transfer', 'icon': FontAwesomeIcons.buildingColumns},
    {'name': 'Cash on Delivery', 'icon': FontAwesomeIcons.wallet},
  ];

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
          'Choose Payment Method',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: _paymentMethods.length,
        itemBuilder: (context, index) {
          final method = _paymentMethods[index];
          final isSelected = _selectedMethod == method['name'];

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedMethod = method['name'];
              });
            },
            child: Container(
              color: isSelected ? Colors.yellow[50] : Colors.transparent,
              child: ListTile(
                leading: FaIcon(method['icon'], color: Colors.orange[400]),
                title: Text(
                  method['name'],
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, addCardScreen);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            'Add Payment Method',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
