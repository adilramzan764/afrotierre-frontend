import 'package:afrotierre/View/Vendor_Screens/change_password_screen.dart';
import 'package:afrotierre/View/Buyers_Screens/notification_screen.dart';
import 'package:afrotierre/View/Buyers_Screens/payment_method_screen.dart';
import 'package:afrotierre/View/Buyers_Screens/personal_information_screen.dart';
import 'package:afrotierre/View/Vendor_Screens/StoreInformationScreen.dart';
import 'package:afrotierre/View/Vendor_Screens/vendor_subcription_plan_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../Services/AppSession.dart';
import '../../Services/GoogleSignInService.dart';
import '../../Services/AppleSignInService.dart';
import '../../constants.dart';
import '../Buyers_Screens/NotificationSettingsScreen.dart';
import 'AboutUsScreen.dart';
import 'HelpCenterScreen.dart';
import 'PickupAddressListScreen.dart';
import '../Onboarding_Screens/sign_in_account_seller.dart';
import 'VendorPayoutSetupScreen.dart';

class VendorProfileScreen extends StatefulWidget {
  const VendorProfileScreen({super.key});

  @override
  State<VendorProfileScreen> createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  final AppSession _session = AppSession.instance;

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
           Text(
            _session.sellerProfile?.storeName ?? 'Vendor',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          if (_session.sellerProfile?.isGoogleUser == true) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.g_mobiledata, size: 14, color: Colors.blue.shade700),
                  const SizedBox(width: 4),
                  Text(
                    'Google Account',
                    style: TextStyle(fontSize: 11, color: Colors.blue.shade700),
                  ),
                ],
              ),
            ),
          ],
          if (_session.sellerProfile?.isAppleUser == true) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.apple, size: 14, color: Colors.black),
                  const SizedBox(width: 4),
                  const Text(
                    'Apple Account',
                    style: TextStyle(fontSize: 11, color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
          // const SizedBox(height: 6),
          // Row(
          //   mainAxisSize: MainAxisSize.min,
          //   children: [
          //     const Icon(Icons.star_rounded,
          //         size: 16, color: Colors.amber),
          //     const SizedBox(width: 4),
          //     const Text(
          //       '4.8',
          //       style: TextStyle(
          //         fontSize: 14,
          //         fontWeight: FontWeight.w600,
          //       ),
          //     ),
          //     const SizedBox(width: 4),
          //     Text(
          //       '(214 reviews)',
          //       style: TextStyle(
          //         fontSize: 14,
          //         color: Colors.grey.shade500,
          //       ),
          //     ),
          //   ],
          // ),
          // const SizedBox(height: 8),
          //
          // // Products count badge
          // Container(
          //   padding:
          //   const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          //   decoration: BoxDecoration(
          //     color: Colors.grey.shade100,
          //     borderRadius: BorderRadius.circular(20),
          //   ),
          //   child: Text(
          //     '38 products listed',
          //     style: TextStyle(
          //       fontSize: 12,
          //       color: Colors.grey.shade600,
          //       fontWeight: FontWeight.w500,
          //     ),
          //   ),
          // ),

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
            _menuItem(
              icon: Icons.local_shipping_outlined,
              title: 'Pickup Addresses',
              subtitle: 'Warehouse and pickup locations',
              onTap: () =>
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PickupAddressListScreen(),
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
              title: 'Payout Setup',
              subtitle: 'Payout methods and bank details',
              onTap: () =>
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PayoutSetupScreen(),
                    ),
                  ),
              isLast: true,
            ),
          ]),
          // const SizedBox(height: 8),
          // _menuCard([
          //   _menuItem(
          //     icon: Icons.workspace_premium_outlined,
          //     title: 'Subscription Plan',
          //     subtitle: 'Billing and plan details',
          //     onTap: () =>
          //         Navigator.push(
          //           context,
          //           MaterialPageRoute(
          //             builder: (context) => VendorSubcriptionPlanScreen(),
          //           ),
          //         ),
          //     isLast: true,
          //   ),
          // ]),

          const SizedBox(height: 20),

          // ── Account ─────────────────────────────────────────────────────
          _sectionTitle('Account'),
          const SizedBox(height: 8),
          _menuCard([
            // Only show change password for non-Google/Apple users
            if (_session.sellerProfile?.isGoogleUser != true && _session.sellerProfile?.isAppleUser != true)
              _menuItem(
                icon: Icons.lock_outline,
                title: 'Change password',
                onTap: () =>
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChangePasswordScreen(isSeller: true,),
                      ),
                    ),
                isLast: true,
              ),
            // _menuItem(
            //   icon: Icons.notifications_outlined,
            //   title: 'Notifications',
            //   onTap: () =>
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) => NotificationSettingsScreen(),
            //         ),
            //       ),
            // ),
            // _menuItem(
            //   icon: Icons.language_outlined,
            //   title: 'Language',
            //   onTap: () {},
            //   isLast: true,
            // ),
          ]),

          const SizedBox(height: 20),

          // ── Support ─────────────────────────────────────────────────────
          _sectionTitle('Support'),
          const SizedBox(height: 8),
          _menuCard([
            _menuItem(
              icon:  Icons.info_outline,
              title: 'About Us',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AboutUsScreen(),
                  ),
                );
              },
            ),

            _menuCard([
              _menuItem(
                icon: Icons.help_outline_rounded,
                title: 'Help center',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HelpCenterScreen(),
                    ),
                  );
                },
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
        ]),
      ),
    ));
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (dialogContext) =>
          Dialog(
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
                    _session.sellerProfile?.isGoogleUser == true
                        ? 'Are you sure you want to log out?\nYou will need to sign in with Google again.'
                        : _session.sellerProfile?.isAppleUser == true
                            ? 'Are you sure you want to log out?\nYou will need to sign in with Apple again.'
                            : 'Are you sure you want to log out\nof your account?',
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

                            // Show loading indicator
                            _showLoadingDialog(context);

                            try {
                              final session = AppSession.instance;
                              final isGoogleUser = session.sellerProfile
                                  ?.isGoogleUser ?? false;

                              if (isGoogleUser) {
                                // Complete Google sign out (sign out from Google + clear session)
                                await GoogleSignInService.completeSignOut();
                                print("✅ Google user signed out completely");
                              } else if (session.sellerProfile?.isAppleUser == true) {
                                // Complete Apple sign out
                                await AppleSignInService.completeSignOut();
                                print("✅ Apple user signed out completely");
                              } else {
                                // Regular email/password user - just clear session
                                session.clearSession();
                                await session.clearSavedData();
                                await session.clearAllData();
                                print("✅ Email user signed out");
                              }

                              // Navigate to login screen and remove all previous routes
                              if (context.mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (
                                        context) => const SignInAccountSellerScreen(),
                                  ),
                                      (route) => false,
                                );
                              }
                            } catch (e) {
                              // Hide loading dialog if showing
                              if (context.mounted) {
                                Navigator.pop(
                                    context); // Close loading dialog if open
                              }

                              // Show error message
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Error logging out: ${e.toString()}'),
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

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
      const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Logging out...'),
              ],
            ),
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