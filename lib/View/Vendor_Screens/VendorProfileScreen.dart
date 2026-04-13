import 'package:afrotierre/View/Vendor_Screens/change_password_screen.dart';
import 'package:afrotierre/View/Buyers_Screens/notification_screen.dart';
import 'package:afrotierre/View/Buyers_Screens/payment_method_screen.dart';
import 'package:afrotierre/View/Buyers_Screens/personal_information_screen.dart';
import 'package:afrotierre/View/Vendor_Screens/StoreInformationScreen.dart';
import 'package:flutter/material.dart';

import '../../Services/AppSession.dart';
import '../../constants.dart';
import '../Buyers_Screens/shipping_address_screen.dart';
import '../Onboarding_Screens/sign_in_account_seller.dart';

class VendorProfileScreen extends StatelessWidget {
  const VendorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F6F6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),

              // ── Store name + rating ─────────────────────────────────────────
              const Text(
                'Marcus Store',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded,
                      size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  const Text(
                    '4.8',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(214 reviews)',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Products count badge
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '38 products listed',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ── Store Settings ──────────────────────────────────────────────
              _sectionTitle('Store'),
              const SizedBox(height: 8),
              _menuCard([
                _menuItem(
                  icon: Icons.storefront_outlined,
                  title: 'Store information',
                  subtitle: 'Name, description, contact',
                  onTap: () =>
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StoreInformationScreen(),
                        ),
                      ),
                ),
                // _menuItem(
                //   icon: Icons.category_outlined,
                //   title: 'Store categories',
                //   subtitle: 'Footwear, Bags, Electronics...',
                //   onTap: () =>
                //       Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //           builder: (context) => PersonalInformationScreen(),
                //         ),
                //       ),
                //   isLast: true,
                // ),
                _menuItem(
                  icon: Icons.local_shipping_outlined,
                  title: 'Shipping Address',
                  subtitle: 'Warehouse, pickup points',
                  onTap: () =>
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShippingAddressScreen(),
                        ),
                      ),
                  isLast: true,
                ),
              ]),

              const SizedBox(height: 20),

              // ── Finance ─────────────────────────────────────────────────────
              _sectionTitle('Finance'),
              const SizedBox(height: 8),
              _menuCard([
                _menuItem(
                  icon: Icons.account_balance_outlined,
                  title: 'Payout method',
                  subtitle: 'Bank account, PayPal',
                  onTap: () =>
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentMethodScreen(),
                        ),
                      ),
                  isLast: true,
                ),
              ]),

              const SizedBox(height: 20),

              // ── Account ─────────────────────────────────────────────────────
              _sectionTitle('Account'),
              const SizedBox(height: 8),
              _menuCard([
                _menuItem(
                  icon: Icons.lock_outline,
                  title: 'Change password',
                  onTap: () =>
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangePasswordScreen(isSeller: true,),
                        ),
                      ),
                ),
                _menuItem(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  onTap: () =>
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationScreen(),
                        ),
                      ),
                ),
                _menuItem(
                  icon: Icons.language_outlined,
                  title: 'Language',
                  onTap: () {},
                  isLast: true,
                ),
              ]),

              const SizedBox(height: 20),

              // ── Support ─────────────────────────────────────────────────────
              _sectionTitle('Support'),
              const SizedBox(height: 8),
              _menuCard([
                _menuItem(
                  icon: Icons.help_outline_rounded,
                  title: 'Help center',
                  onTap: () {},
                ),
                _menuItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'Contact support',
                  onTap: () {},
                  isLast: true,
                ),
              ]),

              const SizedBox(height: 20),

              // ── Logout ──────────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showLogoutDialog(context),
                  icon: const Icon(Icons.logout_rounded,
                      size: 18, color: Colors.red),
                  label: const Text(
                    'Log out',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Colors.red.shade200),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon container
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: Colors.black87,
                  size: 30,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                'Log Out',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Are you sure you want to log out\nof your account?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),

              // Buttons
              Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.grey.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Logout button
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        // Close the dialog first
                        Navigator.pop(dialogContext);

                        // Show loading indicator using a different context
                        final scaffoldMessenger = ScaffoldMessenger.of(context);

                        try {
                          final session = AppSession.instance;

                          // Clear in-memory session data
                           session.clearSession();

                          // Clear saved data from SharedPreferences
                          await session.clearSavedData();

                          // Optional: Clear all data including Remember Me
                          await session.clearAllData();

                          // Navigate to login screen and remove all previous routes
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignInAccountSellerScreen(),
                              ),
                                  (route) => false,
                            );
                          }
                        } catch (e) {
                          // Show error message
                          if (context.mounted) {
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text('Error logging out: ${e.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Log Out',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }

  Widget _menuCard(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(children: items),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: isLast
              ? const BorderRadius.vertical(bottom: Radius.circular(20))
              : BorderRadius.zero,
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: Colors.black87),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    size: 14, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 0,
            thickness: 0.5,
            indent: 64,
            color: Colors.grey.shade100,
          ),
      ],
    );
  }
}