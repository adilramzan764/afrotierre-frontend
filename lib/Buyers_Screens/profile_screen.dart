import 'package:flutter/material.dart';

import '../constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage(
                  'assets/stock_image.png',
                ), // Add your avatar image
                backgroundColor: Colors.grey,
              ),
              const SizedBox(height: 12),
              const Text(
                'Marcuson1@gmail.com',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, personalInformationScreen);
                },
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    color: Colors.black,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Account settings'),
              const SizedBox(height: 8),
              _buildProfileMenuItem(
                icon: Icons.person_outline,
                title: 'Personal information',
                onTap: () {
                  Navigator.pushNamed(context, personalInformationScreen);
                },
              ),
              _buildProfileMenuItem(
                icon: Icons.local_shipping_outlined,
                title: 'Shipping Address',
                onTap: () {
                  Navigator.pushNamed(context, shippingAddressScreen);
                },
              ),
              _buildProfileMenuItem(
                icon: Icons.payment_outlined,
                title: 'Payment method',
                onTap: () {
                  Navigator.pushNamed(context, paymentMethodScreen);
                },
              ),
              _buildProfileMenuItem(
                icon: Icons.lock_outline,
                title: 'Change password',
                onTap: () {
                  Navigator.pushNamed(context, changePasswordScreen);
                },
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Preference'),
              const SizedBox(height: 8),
              _buildProfileMenuItem(
                icon: Icons.notifications_outlined,
                title: 'Notification',
                onTap: () {
                  Navigator.pushNamed(context, notificationScreen);
                },
              ),
              _buildProfileMenuItem(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy settings',
                onTap: () {},
              ),
              _buildProfileMenuItem(
                icon: Icons.language_outlined,
                title: 'Language',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[800]),
      title: Text(title),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,

        color: Colors.grey,
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
