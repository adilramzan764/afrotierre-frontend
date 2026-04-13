import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _generalNotification = true;
  bool _sound = false;
  bool _vibrate = true;

  bool _appUpdates = false;
  bool _billReminder = true;
  bool _promotion = true;
  bool _discountAvailable = false;
  bool _paymentRequest = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.transparent),
          onPressed: () {},
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Common'),
            _buildSwitchTile(
              title: 'General Notification',
              value: _generalNotification,
              onChanged: (value) =>
                  setState(() => _generalNotification = value),
            ),
            _buildSwitchTile(
              title: 'Sound',
              value: _sound,
              onChanged: (value) => setState(() => _sound = value),
            ),
            _buildSwitchTile(
              title: 'Vibrate',
              value: _vibrate,
              onChanged: (value) => setState(() => _vibrate = value),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('System & services update'),
            _buildSwitchTile(
              title: 'App updates',
              value: _appUpdates,
              onChanged: (value) => setState(() => _appUpdates = value),
            ),
            _buildSwitchTile(
              title: 'Bill Reminder',
              value: _billReminder,
              onChanged: (value) => setState(() => _billReminder = value),
            ),
            _buildSwitchTile(
              title: 'Promotion',
              value: _promotion,
              onChanged: (value) => setState(() => _promotion = value),
            ),
            _buildSwitchTile(
              title: 'Discount Available',
              value: _discountAvailable,
              onChanged: (value) => setState(() => _discountAvailable = value),
            ),
            _buildSwitchTile(
              title: 'Payment Request',
              value: _paymentRequest,
              onChanged: (value) => setState(() => _paymentRequest = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile.adaptive(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.black,
      contentPadding: EdgeInsets.zero,
    );
  }
}
