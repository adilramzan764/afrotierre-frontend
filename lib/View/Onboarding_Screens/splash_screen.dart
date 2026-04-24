import 'dart:async';

import 'package:afrotierre/View/Buyers_Screens/bottom_navigation_screen.dart';
import 'package:afrotierre/View/Onboarding_Screens/onboarding_screen.dart';
import 'package:afrotierre/View/Onboarding_Screens/sign_in_account_buyer.dart';
import 'package:afrotierre/View/Onboarding_Screens/sign_in_account_seller.dart';
import 'package:afrotierre/View/Vendor_Screens/vendor_bottom_navigation_screen.dart';
import 'package:flutter/material.dart';

import '../../Models/BuyerModels/BuyerAuthModels.dart';
import '../../Models/BuyerModels/BuyerLoginandProfileModels.dart';
import '../../Models/SellerModels/SellerAuthModels.dart';
import '../../Repository/BuyerRepository/BuyerLoginProfileRepo.dart';
import '../../Repository/SellerRepository/SellerLoginandProfileRepo.dart';
import '../../Services/AppSession.dart';
import '../../Services/GoogleSignInService.dart';
import '../../constants.dart';
import '../Buyers_Screens/BuyerPersonalInfoSignup.dart';
import '../Vendor_Screens/VendorSignUpAddressScreen.dart';
import '../Vendor_Screens/VendorStoreSignupScreen.dart';

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
    await Future.delayed(const Duration(milliseconds: 800));

    final sessionStatus = await _getSessionStatus();

    if (mounted) {
      switch (sessionStatus) {
        case SessionStatus.validSeller:
          print('✅ Valid Seller session found');
          await _navigateBasedOnSellerRegistrationStep();
          break;

        case SessionStatus.validBuyer:
          print('✅ Valid Buyer session found');
          await _navigateBasedOnBuyerRegistrationStep();
          break;

        case SessionStatus.expired:
          final userType = _session.userType;
          print('⚠️ Session expired for user type: $userType');
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
          print('📝 No session - New user');
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

  /// Navigate based on seller's registration step
  Future<void> _navigateBasedOnSellerRegistrationStep() async {
    final token = _session.authToken;
    if (token == null) {
      _navigateToSellerLogin();
      return;
    }

    // Fetch latest registration step from backend
    try {
      final stepResponse = await _sellerRepo.getRegistrationStep(token);

      if (!stepResponse.success) {
        print('⚠️ Failed to get registration step: ${stepResponse.message}');
        _navigateToSellerDashboard(); // Default to dashboard
        return;
      }

      final registrationStep = stepResponse.registrationStep;
      final isEmailVerified = stepResponse.isEmailVerified;
      final hasStoreDetails = stepResponse.hasStoreDetails;
      final hasPickupAddress = stepResponse.hasPickupAddress ?? false;
      final isGoogleUser = stepResponse.isGoogleUser;

      print('🔍 Seller Registration Step: $registrationStep');
      print('   Is Email Verified: $isEmailVerified');
      print('   Has Store Details: $hasStoreDetails');
      print('   Has Pickup Address: $hasPickupAddress');
      print('   Is Google User: $isGoogleUser');

      // Update session with latest registration step
      await _session.updateRegistrationStep(registrationStep);
      await _refreshSellerProfileIfNeeded(token);

      // Navigate based on registration step
      switch (registrationStep) {
        case 'store_details':
          print('📍 Navigating to VendorStoreSignupScreen');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => VendorStoreSignupScreen(
                isGoogleUser: isGoogleUser,
                googleEmail: _session.sellerProfile?.email,
                token: token,
              ),
            ),
          );
          break;

        case 'pickup_address':
          print('📍 Navigating to VendorSignUpAddressScreen');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => VendorSignUpAddressScreen(
                isGoogleUser: isGoogleUser,
                googleEmail: _session.sellerProfile?.email,
                storeName: _session.sellerProfile?.storeName ?? '',
                token: token,
              ),
            ),
          );
          break;

        case 'completed':
          print('📍 Navigating to Seller Dashboard (Registration Complete)');
          _navigateToSellerDashboard();
          break;

        case 'wallet_creation':
        case 'email_verification':
        default:
          print('📍 Incomplete registration, navigating to Seller Login');
          _navigateToSellerLogin();
          break;
      }
    } catch (e) {
      print('❌ Error checking seller registration step: $e');
      _navigateToSellerDashboard(); // Default to dashboard on error
    }
  }

  /// Navigate based on buyer's registration step
  Future<void> _navigateBasedOnBuyerRegistrationStep() async {
    final token = _session.authToken;
    if (token == null) {
      _navigateToBuyerLogin();
      return;
    }

    // Fetch latest registration step from backend
    try {
      final stepResponse = await _buyerRepo.getRegistrationStep(token);

      if (!stepResponse.success) {
        print('⚠️ Failed to get buyer registration step: ${stepResponse.message}');
        _navigateToBuyerDashboard(); // Default to dashboard
        return;
      }

      final registrationStep = stepResponse.registrationStep;
      final isEmailVerified = stepResponse.isEmailVerified;
      final hasProfileDetails = stepResponse.hasProfileDetails ?? false;
      final isGoogleUser = stepResponse.isGoogleUser;

      print('🔍 Buyer Registration Step: $registrationStep');
      print('   Is Email Verified: $isEmailVerified');
      print('   Has Profile Details: $hasProfileDetails');
      print('   Is Google User: $isGoogleUser');

      // Update session with latest registration step
      await _session.updateRegistrationStep(registrationStep);
      await _refreshBuyerProfileIfNeeded(token);

      // Navigate based on registration step
      switch (registrationStep) {
        case 'profile_details':
          print('📍 Navigating to BuyerPersonalInfoSignup');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BuyerPersonalInfoSignup(
                isGoogleUser: isGoogleUser,
                googleEmail: _session.buyerProfile?.email,
                token: token,
              ),
            ),
          );
          break;

        case 'completed':
          print('📍 Navigating to Buyer Dashboard (Registration Complete)');
          _navigateToBuyerDashboard();
          break;

        case 'wallet_creation':
        case 'email_verification':
        default:
          print('📍 Incomplete registration, navigating to Buyer Login');
          _navigateToBuyerLogin();
          break;
      }
    } catch (e) {
      print('❌ Error checking buyer registration step: $e');
      _navigateToBuyerDashboard(); // Default to dashboard on error
    }
  }

  void _navigateToSellerDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const VendorBottomNavigationScreen(),
      ),
    );
  }

  void _navigateToBuyerDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const BottomNavigationScreen(),
      ),
    );
  }

  void _navigateToSellerLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const SignInAccountSellerScreen(),
      ),
    );
  }

  void _navigateToBuyerLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const SignInAccountBuyerScreen(),
      ),
    );
  }

  Future<SessionStatus> _getSessionStatus() async {
    try {
      // ========== STEP 1: Load saved session data ==========
      print('🔍 Loading saved session data...');
      final hasSavedSession = await _session.loadSavedSessionData();

      // Get saved userType (from Remember Me session)
      final savedUserType = _session.userType;

      // Get last user type (ALWAYS saved, even with Remember Me off)
      final lastUserType = await _session.getLastUserType();

      // Determine preferred type: saved session type > last user type > null
      final preferredType = savedUserType ?? lastUserType;

      print('📌 Saved userType (from session): $savedUserType');
      print('📌 Last userType (always saved): $lastUserType');
      print('📌 Preferred type: $preferredType');
      print('📌 Has saved session: $hasSavedSession');

      // ========== STEP 2: Try Google Silent Sign-In ==========
      print('🔍 Checking for existing Google session...');
      final googleToken = await GoogleSignInService.silentSignIn();

      if (googleToken != null) {
        print('🔄 Silent Google Sign-In detected!');

        // 🔥 CRITICAL: Try the PREFERRED type FIRST
        if (preferredType == 'buyer') {
          print('📡 Trying Buyer Google Auth FIRST (preferred role)...');
          final buyerResponse = await _buyerRepo.googleAuth(idToken: googleToken);

          if (buyerResponse.success &&
              buyerResponse.token != null &&
              buyerResponse.buyer != null) {
            print('✅ Google session restored for BUYER');

            await _session.setBuyerSession(
              token: buyerResponse.token!,
              refreshToken: buyerResponse.refreshToken ?? '',
              buyer: _convertToBuyerData(buyerResponse.buyer!),
            );
            await _refreshBuyerProfileIfNeeded(buyerResponse.token!);

            return SessionStatus.validBuyer;
          }
          print('⚠️ Buyer auth failed, falling back to Seller...');
        } else if (preferredType == 'seller') {
          print('📡 Trying Seller Google Auth FIRST (preferred role)...');
          final sellerResponse = await _sellerRepo.googleAuth(idToken: googleToken);

          if (sellerResponse.success &&
              sellerResponse.token != null &&
              sellerResponse.seller != null) {
            print('✅ Google session restored for SELLER');

            await _session.setSellerSession(sellerResponse.token!, sellerResponse.seller!);
            await _refreshSellerProfileIfNeeded(sellerResponse.token!);

            return SessionStatus.validSeller;
          }
          print('⚠️ Seller auth failed, falling back to Buyer...');
        }

        // ========== If no preferred type or preferred role failed, try Buyer first then Seller ==========
        print('📡 No preferred type or preferred role failed, trying Buyer first then Seller...');

        // Try Buyer first (better UX for most users)
        print('📡 Trying Buyer Google Auth...');
        final buyerResponse = await _buyerRepo.googleAuth(idToken: googleToken);

        if (buyerResponse.success &&
            buyerResponse.token != null &&
            buyerResponse.buyer != null) {
          print('✅ Google session restored for BUYER');

          await _session.setBuyerSession(
            token: buyerResponse.token!,
            refreshToken: buyerResponse.refreshToken ?? '',
            buyer: _convertToBuyerData(buyerResponse.buyer!),
          );
          await _refreshBuyerProfileIfNeeded(buyerResponse.token!);

          return SessionStatus.validBuyer;
        }

        // Try Seller
        print('📡 Trying Seller Google Auth...');
        final sellerResponse = await _sellerRepo.googleAuth(idToken: googleToken);

        if (sellerResponse.success &&
            sellerResponse.token != null &&
            sellerResponse.seller != null) {
          print('✅ Google session restored for SELLER');

          await _session.setSellerSession(sellerResponse.token!, sellerResponse.seller!);
          await _refreshSellerProfileIfNeeded(sellerResponse.token!);

          return SessionStatus.validSeller;
        }

        print('⚠️ Google token valid but no matching user found');
      } else {
        print('📝 No silent Google session found');
      }

      // ========== STEP 3: Check Normal Saved Session ==========
      if (!hasSavedSession) {
        print('📝 No saved session found - New user');
        return SessionStatus.noSession;
      }

      if (!_session.isLoggedIn) {
        print('⚠️ Saved session exists but not logged in - Clearing');
        await _clearInvalidSession();
        return SessionStatus.noSession;
      }

      final token = _session.authToken;
      if (token == null) {
        print('❌ No token found in session');
        await _clearInvalidSession();
        return SessionStatus.noSession;
      }

      final userType = _session.userType;
      print('🔍 User Type: $userType');
      print('🔍 Validating token with backend...');

      bool isValid = false;
      String? validationMessage;

      if (userType == 'seller') {
        final tokenCheck = await _sellerRepo.checkTokenValidity(token);
        isValid = tokenCheck.success && tokenCheck.isValid;
        validationMessage = tokenCheck.message;

        if (isValid) {
          print('✅ Seller token is valid');
          await _refreshSellerProfileIfNeeded(token);
        } else {
          print('❌ Seller token invalid: $validationMessage');
        }
      } else if (userType == 'buyer') {
        final tokenCheck = await _buyerRepo.checkTokenValidity(token);
        isValid = tokenCheck.success && tokenCheck.isValid;
        validationMessage = tokenCheck.message;

        if (isValid) {
          print('✅ Buyer token is valid');
          await _refreshBuyerProfileIfNeeded(token);
        } else {
          print('❌ Buyer token invalid: $validationMessage');
        }
      } else {
        print('❌ Unknown user type: $userType');
        await _clearInvalidSession();
        return SessionStatus.noSession;
      }

      if (isValid) {
        return userType == 'seller' ? SessionStatus.validSeller : SessionStatus.validBuyer;
      } else {
        print('❌ Token is invalid or expired: $validationMessage');
        await _clearInvalidSession();
        return SessionStatus.expired;
      }
    } catch (e) {
      print('❌ Error validating session: $e');
      await _clearInvalidSession();
      return SessionStatus.noSession;
    }
  }

  BuyerData _convertToBuyerData(Buyer buyer) {
    return BuyerData(
      id: buyer.id,
      email: buyer.email,
      fullName: buyer.fullName,
      phoneNumber: buyer.phoneNumber,
      registrationStep: buyer.registrationStep,
      isEmailVerified: buyer.isEmailVerified,
      status: buyer.status,
      profilePicture: buyer.profilePicture?.toJson(),
      preferences: buyer.preferences,
      dateOfBirth: buyer.dateOfBirth,
      address: buyer.address?.toJson(),
      completedAt: buyer.completedAt,
      avatar: buyer.avatar,
      googleId: buyer.googleId,
      isGoogleUser: buyer.isGoogleUser,
    );
  }

  Future<void> _refreshSellerProfileIfNeeded(String token) async {
    try {
      print('🔄 Fetching fresh seller profile data...');
      final profileResponse = await _sellerRepo.getProfile(token);

      if (profileResponse.success && profileResponse.seller != null) {
        await _session.updateSellerProfile(profileResponse.seller!);
        print('✅ Seller profile refreshed successfully');
        print('   Store Name: ${profileResponse.seller!.storeName}');
        print('   Registration Step: ${profileResponse.seller!.registrationStep}');
      } else {
        print('⚠️ Could not refresh seller profile: ${profileResponse.message}');
      }
    } catch (e) {
      print('❌ Failed to refresh seller profile: $e');
    }
  }

  Future<void> _refreshBuyerProfileIfNeeded(String token) async {
    try {
      print('🔄 Fetching fresh buyer profile data...');
      final profileResponse = await _buyerRepo.getProfile(token);

      if (profileResponse.success && profileResponse.buyer != null) {
        await _session.updateBuyerProfile(profileResponse.buyer);
        print('✅ Buyer profile refreshed successfully');
        print('   Name: ${profileResponse.buyer.fullName}');
        print('   Registration Step: ${profileResponse.buyer.registrationStep}');
      } else {
        print('⚠️ Could not refresh buyer profile: ${profileResponse.success}');
      }
    } catch (e) {
      print('❌ Failed to refresh buyer profile: $e');
    }
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
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/splash_logo.png',
              width: MediaQuery.of(context).size.width * 0.7,
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

enum SessionStatus {
  validSeller,
  validBuyer,
  expired,
  noSession,
}