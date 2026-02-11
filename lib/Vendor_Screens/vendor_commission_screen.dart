import 'package:flutter/material.dart';

class VendorCommissionScreen extends StatefulWidget {
  const VendorCommissionScreen({super.key});

  @override
  State<VendorCommissionScreen> createState() => _VendorCommissionScreenState();
}

class _VendorCommissionScreenState extends State<VendorCommissionScreen> {
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
          'Commission',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Colors.yellow[100],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                  ],
                ),

                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Color(0xFFFBE692),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Icon(Icons.bar_chart, color: Colors.orange[800]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
