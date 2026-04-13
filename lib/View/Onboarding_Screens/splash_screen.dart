import 'dart:async';

import 'package:afrotierre/View/Buyers_Screens/bottom_navigation_screen.dart';
import 'package:afrotierre/View/Onboarding_Screens/onboarding_screen.dart';
import 'package:afrotierre/View/Onboarding_Screens/sign_in_account_buyer.dart';
import 'package:afrotierre/View/Onboarding_Screens/sign_in_account_seller.dart';
import 'package:afrotierre/View/Vendor_Screens/vendor_bottom_navigation_screen.dart';
import 'package:flutter/material.dart';

import '../../Repository/BuyerRepository/BuyerLoginProfileRepo.dart';
import '../../Repository/SellerRepository/SellerLoginandProfileRepo.dart';
import '../../Services/AppSession.dart';
import '../../constants.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AppSession _session = AppSession.instance;
  final SellerLoginandProfileRepo _sellerRepo = SellerLoginandProfileRepo();
  final BuyerLoginProfileRepo _buyerRepo = BuyerLoginProfileRepo();

  @override
  void initState() {
    super.initState();
    _checkSessionAndNavigate();
  }

  Future<void> _checkSessionAndNavigate() async {
    // Wait for 2 seconds to show splash screen
    await Future.delayed(const Duration(seconds: 2));

    // Check session status
    final sessionStatus = await _getSessionStatus();

    if (mounted) {
      switch (sessionStatus) {
        case SessionStatus.validSeller:
        // Seller has valid session, go to seller home screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const VendorBottomNavigationScreen(),
            ),
          );
          break;

        case SessionStatus.validBuyer:
        // Buyer has valid session, go to buyer home screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const BottomNavigationScreen(),
            ),
          );
          break;

        case SessionStatus.expired:
        // User had session but it expired, go to appropriate sign in screen
          final userType = _session.userType;
          if (userType == 'seller') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const SignInAccountSellerScreen(),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const SignInAccountBuyerScreen(),
              ),
            );
          }
          break;

        case SessionStatus.noSession:
        // New user, no session exists, go to onboarding screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const OnboardingScreen(),
            ),
          );
          break;
      }
    }
  }

  Future<SessionStatus> _getSessionStatus() async {
    try {
      // First check if we have saved session data
      final hasSavedSession = await _session.loadSavedSessionData();

      // No saved session at all - new user
      if (!hasSavedSession) {
        print('📝 No saved session found - New user');
        return SessionStatus.noSession;
      }

      // Has saved session but not logged in - should not happen, but handle it
      if (!_session.isLoggedIn) {
        print('⚠️ Saved session exists but not logged in - Clearing');
        await _clearInvalidSession();
        return SessionStatus.noSession;
      }

      // Get the token
      final token = _session.authToken;
      if (token == null) {
        print('❌ No token found in session');
        await _clearInvalidSession();
        return SessionStatus.noSession;
      }

      // Validate token based on user type
      final userType = _session.userType;
      print('🔍 User Type: $userType');
      print('Profile Data: ${_session.buyerProfile!.toJson()}');
      print('🔍 Validating token with backend...');

      bool isValid = false;
      String? validationMessage;

      if (userType == 'seller') {
        final tokenCheck = await _sellerRepo.checkTokenValidity(token);
        isValid = tokenCheck.success && tokenCheck.isValid;
        validationMessage = tokenCheck.message;

        if (isValid) {
          print('✅ Seller token is valid');
          // Refresh seller profile if needed
          await _refreshSellerProfileIfNeeded(token);
        }
      } else if (userType == 'buyer') {
        final tokenCheck = await _buyerRepo.checkTokenValidity(token);
        isValid = tokenCheck.success && tokenCheck.isValid;
        validationMessage = tokenCheck.message;

        if (isValid) {
          print('✅ Buyer token is valid');
          // Refresh buyer profile if needed
          await _refreshBuyerProfileIfNeeded(token);
        }
      } else {
        print('❌ Unknown user type: $userType');
        await _clearInvalidSession();
        return SessionStatus.noSession;
      }

      if (isValid) {
        // Show warning if token is about to expire
        _checkTokenExpiry();

        // Return appropriate session status based on user type
        return userType == 'seller'
            ? SessionStatus.validSeller
            : SessionStatus.validBuyer;
      } else {
        // Token is invalid or expired - previously logged in user
        print('❌ Token is invalid or expired: $validationMessage');
        print('   User was previously logged in but session expired');
        await _clearInvalidSession();
        return SessionStatus.expired;
      }
    } catch (e) {
      print('Error validating session: $e');
      await _clearInvalidSession();
      return SessionStatus.noSession;
    }
  }

  Future<void> _refreshSellerProfileIfNeeded(String token) async {
    try {
      // Check if we have a profile or if it's outdated
      if (!_session.hasSellerProfile) {
        print('🔄 Fetching fresh seller profile data...');
        final profileResponse = await _sellerRepo.getProfile(token);

        if (profileResponse.success && profileResponse.seller != null) {
          await _session.updateSellerProfile(profileResponse.seller!);
          print('✅ Seller profile data refreshed');
        } else {
          print('⚠️ Could not refresh seller profile: ${profileResponse.message}');
        }
      } else {
        print('✅ Seller profile already exists in session');
      }
    } catch (e) {
      print('Failed to refresh seller profile: $e');
    }
  }

  Future<void> _refreshBuyerProfileIfNeeded(String token) async {
    try {
      // Check if we have a profile or if it's outdated
      if (!_session.hasBuyerProfile) {
        print('🔄 Fetching fresh buyer profile data...');
        final profileResponse = await _buyerRepo.getProfile(token);

        if (profileResponse.success && profileResponse.buyer != null) {
          await _session.updateBuyerProfile(profileResponse.buyer!);
          print('✅ Buyer profile data refreshed');
        } else {
          print('⚠️ Could not refresh buyer profile: ${profileResponse.success}');
        }
      } else {
        print('✅ Buyer profile already exists in session');
      }
    } catch (e) {
      print('Failed to refresh buyer profile: $e');
    }
  }

  void _checkTokenExpiry() {
    // You can implement token expiry warning logic here
    // For now, just log a message
    print('⚠️ Check token expiry status');
  }

  Future<void> _clearInvalidSession() async {
    print('🧹 Clearing invalid session...');
    _session.clearSession();
    await _session.clearSavedData();
    print('✅ Invalid session cleared');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/splash_logo.png',
                  width: constraints.maxWidth * 0.7,
                ),
                const SizedBox(height: 20),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

enum SessionStatus {
  validSeller,    // Seller has valid session
  validBuyer,     // Buyer has valid session
  expired,        // User had session but it expired (needs to sign in)
  noSession,      // New user (no session exists)
}