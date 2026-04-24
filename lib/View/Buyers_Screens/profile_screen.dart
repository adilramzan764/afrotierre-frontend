import 'package:afrotierre/View/Vendor_Screens/change_password_screen.dart';
import 'package:afrotierre/View/Buyers_Screens/notification_screen.dart';
import 'package:afrotierre/View/Buyers_Screens/payment_method_screen.dart';
import 'package:afrotierre/View/Buyers_Screens/personal_information_screen.dart';
import 'package:afrotierre/View/Vendor_Screens/PickupAddressListScreen.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import '../../Services/AppSession.dart';
import '../../Services/GoogleSignInService.dart';
import '../../constants.dart';
import '../Onboarding_Screens/sign_in_account_buyer.dart';
import '../Vendor_Screens/AboutUsScreen.dart';
import '../Vendor_Screens/HelpCenterScreen.dart';
import 'BuyerChangePasswordScreen.dart';
import 'NotificationSettingsScreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AppSession _session = AppSession.instance;
  String _userEmail = '';
  String _userName = '';
  String? _profilePictureUrl;
  bool _isLoading = true;
  bool _isGoogleUser = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // Load buyer profile from session
    final buyerProfile = _session.buyerProfile;
    if (mounted) {
      setState(() {
        _userEmail = buyerProfile?.email ?? 'No email found';
        _userName = buyerProfile?.fullName ?? 'Buyer';

        // Check if this is a Google user using the isGoogleUser flag
        _isGoogleUser = buyerProfile?.isGoogleUser ?? false;

        // Handle profile picture - prioritize Google avatar first, then profilePicture
        if (buyerProfile?.avatar != null && buyerProfile!.avatar!.isNotEmpty) {
          _profilePictureUrl = buyerProfile.avatar;
        } else if (buyerProfile?.profilePicture != null) {
          if (buyerProfile!.profilePicture is String) {
            _profilePictureUrl = buyerProfile.profilePicture as String;
          } else if (buyerProfile.profilePicture is Map) {
            _profilePictureUrl = (buyerProfile.profilePicture as Map)['url'];
          }
        }

        _isLoading = false;
      });
    }
  }

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

              // Profile Picture with loading state
              _buildProfilePicture(),

              const SizedBox(height: 12),
              Text(
                _userName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                _userEmail,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),

              // Show Google user badge
              if (_isGoogleUser) ...[
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

              const SizedBox(height: 32),
              _buildSectionTitle('Account settings'),
              const SizedBox(height: 8),
              _buildProfileMenuItem(
                icon: Icons.person_outline,
                title: 'Personal information',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PersonalInformationScreen(),
                    ),
                  ).then((_) {
                    if (mounted) {
                      _loadUserData();
                    }
                  });
                },
              ),
              _buildProfileMenuItem(
                icon: Icons.payment_outlined,
                title: 'Payment method',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PaymentMethodScreen(),
                    ),
                  );
                },
              ),
              // Only show change password for non-Google users
              if (!_isGoogleUser)
                _buildProfileMenuItem(
                  icon: Icons.lock_outline,
                  title: 'Change password',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BuyerChangePasswordScreen(),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 32),
              _buildSectionTitle('Preference'),
              const SizedBox(height: 8),
              _buildProfileMenuItem(
                icon: Icons.notifications_outlined,
                title: 'Notification',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationSettingsScreen(),
                    ),
                  );
                },
              ),
              // _buildProfileMenuItem(
              //   icon: Icons.privacy_tip_outlined,
              //   title: 'Privacy settings',
              //   onTap: () {},
              // ),
              // _buildProfileMenuItem(
              //   icon: Icons.language_outlined,
              //   title: 'Language',
              //   onTap: () {},
              // ),
              const SizedBox(height: 32),

              _buildSectionTitle('Support'),
              const SizedBox(height: 8),
              _buildProfileMenuItem(
                icon: Icons.info_outline,
                title: 'About Us',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AboutUsScreen(),
                    ),
                  );
                },
              ),
              _buildProfileMenuItem(
                icon: Icons.help_outline_rounded,
                title: 'Help Center',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HelpCenterScreen(),
                    ),
                  );
                },
              ),
              // _buildProfileMenuItem(
              //   icon: Icons.chat_bubble_outline_rounded,
              //   title: 'Contact support',
              //   onTap: () {
              //     // Navigator.push(
              //     //   context,
              //     //   MaterialPageRoute(
              //     //     builder: (context) => const AboutUsScreen(),
              //     //   ),
              //     // );
              //   },
              // ),

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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    if (_isLoading) {
      return const CircleAvatar(
        radius: 40,
        backgroundColor: Colors.grey,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (_profilePictureUrl != null && _profilePictureUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 40,
        backgroundImage: NetworkImage(_profilePictureUrl!),
        backgroundColor: Colors.grey[200],
        onBackgroundImageError: (_, __) {
          print('Failed to load profile picture from: $_profilePictureUrl');
        },
        child: const Icon(
          Icons.person_outline,
          size: 40,
          color: Colors.grey,
        ),
      );
    }

    return CircleAvatar(
      radius: 40,
      backgroundColor: primaryColor.withOpacity(0.2),
      child: Text(
        _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: primaryColor,
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
              const Text(
                'Log Out',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isGoogleUser
                    ? 'Are you sure you want to log out?\nYou will need to sign in with Google again.'
                    : 'Are you sure you want to log out\nof your account?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        if (mounted) {
                          Navigator.pop(dialogContext);
                        }
                      },
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
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        // Close the dialog first
                        if (mounted) {
                          Navigator.pop(dialogContext);
                        }

                        // Show loading indicator
                        if (!mounted) return;

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (loadingDialogContext) => const Center(
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(color: Colors.black,),
                                    SizedBox(height: 16),
                                    Text('Logging out...'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );

                        try {
                          // Perform logout
                          await _logoutBuyer();

                          // Close loading dialog
                          if (mounted && Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }

                          // IMPORTANT: Clear all routes and navigate to login
                          if (mounted) {
                            // Use pushNamedAndRemoveUntil with a clean route
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const SignInAccountBuyerScreen(),
                              ),
                                  (route) => false,
                            );
                          }
                        } catch (e) {
                          // Close loading dialog if error occurs
                          if (mounted && Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
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

  Future<void> _logoutBuyer() async {
    print('🚪 Starting buyer logout process...');
    print('   Is Google User: $_isGoogleUser');

    if (_isGoogleUser) {
      // Complete Google sign out (sign out from Google + clear session)
      await GoogleSignInService.completeSignOut();
      print('✅ Google user signed out completely');
    } else {
      // Regular email/password user - just clear session
      _session.clearSession();
      await _session.clearSavedData();
      await _session.clearAllData();
      print('✅ Email user signed out');
    }

    // Double-check session is cleared
    await Future.delayed(const Duration(milliseconds: 500));

    print('Session cleared - Token: ${_session.authToken}');
    print('Buyer Profile: ${_session.buyerProfile}');
    print('🎉 Buyer logout completed successfully');
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