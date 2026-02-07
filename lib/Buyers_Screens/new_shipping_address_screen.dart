import 'package:flutter/material.dart';

class NewShippingAddressScreen extends StatefulWidget {
  const NewShippingAddressScreen({super.key});

  @override
  State<NewShippingAddressScreen> createState() =>
      _NewShippingAddressScreenState();
}

class _NewShippingAddressScreenState extends State<NewShippingAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedState;

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
          'Shipping Address',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.delete_outline, color: Colors.black),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                label: 'Address',
                hint: '1224 University Drive',
                prefixIcon: Icons.search,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Apartment, suite, etc. (optional)',
                hint: '2nd floor B1',
              ),
              const SizedBox(height: 16),
              _buildTextField(label: 'Company (optional)'),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Phone (optional)',
                hint: '+1 6503137379',
                // Placeholder for country picker
                suffixIconWidget: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🇺🇸'), // Placeholder for flag
                    Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(label: 'City', hint: 'Menlo Park'),
              const SizedBox(height: 16),
              _buildStateDropdown(),
              const SizedBox(height: 16),
              _buildTextField(label: 'Zip code', hint: '94025'),
              const SizedBox(height: 16),
              const Text(
                'This is your default address',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ElevatedButton(
          onPressed: () {
            // if (_formKey.currentState!.validate()) {
            //   // Process data
            // }
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            'Save address',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    String? hint,
    IconData? prefixIcon,
    Widget? suffixIconWidget,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: hint,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: Colors.grey)
                : null,
            suffixIcon: suffixIconWidget,
          ),
        ),
      ],
    );
  }

  Widget _buildStateDropdown() {
    // Placeholder states
    final states = ['New Jersey', 'California', 'Texas', 'Florida'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('State', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: _selectedState,
          hint: const Text('New Jersey'),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          items: states.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedState = newValue;
            });
          },
        ),
      ],
    );
  }
}
