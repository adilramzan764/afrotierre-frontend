// lib/services/app_session.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/BuyerModels/BuyerLoginandProfileModels.dart';
import '../Models/SellerModels/SellerAuthModels.dart';

class AppSession {
  AppSession._privateConstructor();

  static final AppSession instance = AppSession._privateConstructor();

  // Keys for SharedPreferences
  static const String _keyRememberMe = 'remember_me';
  static const String _keyAuthToken = 'auth_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserType = 'user_type';
  static const String _keySellerProfile = 'seller_profile';
  static const String _keyBuyerProfile = 'buyer_profile';
  static const String _keyRegistrationStep = 'registration_step';
  static const String _keyIsEmailVerified = 'is_email_verified';

  // Session data
  String? authToken;
  String? refreshToken;
  String? userId;
  String? userType;
  SellerModel? sellerProfile;
  BuyerData? buyerProfile;
  String? registrationStep;
  bool? isEmailVerified;

  // Helper getters
  bool get hasSellerProfile => sellerProfile != null;
  bool get hasBuyerProfile => buyerProfile != null;
  bool get isSellerProfileComplete => sellerProfile?.isRegistrationComplete ?? false;
  bool get isBuyerProfileComplete => buyerProfile?.registrationStep == 'completed';
  String get currentRegistrationStep => registrationStep ??
      (sellerProfile?.registrationStep ?? buyerProfile?.registrationStep ?? 'wallet_creation');
  String get businessName => sellerProfile?.storeName ?? '';
  String get businessEmail => sellerProfile?.businessEmail ?? '';
  String get buyerName => buyerProfile?.fullName ?? '';
  String get buyerEmail => buyerProfile?.email ?? '';
  String get userStatus => sellerProfile?.status ?? buyerProfile?.status ?? 'pending';
  bool get isLoggedIn => authToken != null && userId != null;
  bool get needsProfileCompletion => isLoggedIn &&
      ((userType == 'seller' && !isSellerProfileComplete) ||
          (userType == 'buyer' && !isBuyerProfileComplete));
  bool get needsEmailVerification => !(isEmailVerified ??
      (sellerProfile?.isEmailVerified ?? buyerProfile?.isEmailVerified ?? false));
  bool get isRegistrationComplete => currentRegistrationStep == 'completed';
  bool get isActive => userStatus == 'active';
  bool get isSuspended => userStatus == 'suspended';
  bool get isBuyer => userType == 'buyer';
  bool get isSeller => userType == 'seller';

  // ========== REMEMBER ME FUNCTIONALITY ==========

  // Check if Remember Me is enabled
  Future<bool> isRememberMeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRememberMe) ?? false;
  }

  // Enable/Disable Remember Me
  Future<void> setRememberMe(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRememberMe, enabled);

    if (!enabled) {
      // Clear saved data if Remember Me is disabled
      await clearSavedData();
    }
  }

  // Save session data to SharedPreferences
  Future<void> saveSessionData() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(_keyRememberMe) ?? false;

    if (!rememberMe) return; // Only save if Remember Me is enabled

    await prefs.setString(_keyAuthToken, authToken ?? '');
    await prefs.setString(_keyRefreshToken, refreshToken ?? '');
    await prefs.setString(_keyUserId, userId ?? '');
    await prefs.setString(_keyUserType, userType ?? '');
    await prefs.setString(_keyRegistrationStep, registrationStep ?? '');
    await prefs.setBool(_keyIsEmailVerified, isEmailVerified ?? false);

    // Save seller profile as JSON string
    if (sellerProfile != null) {
      final profileJson = json.encode(sellerProfile!.toJson());
      await prefs.setString(_keySellerProfile, profileJson);
    } else {
      await prefs.remove(_keySellerProfile);
    }

    // Save buyer profile as JSON string
    if (buyerProfile != null) {
      final profileJson = json.encode(buyerProfile!.toJson());
      await prefs.setString(_keyBuyerProfile, profileJson);
    } else {
      await prefs.remove(_keyBuyerProfile);
    }

    print('💾 Session data saved to SharedPreferences');
    print('Saved Profile: ${sellerProfile != null ? 'Seller' : buyerProfile != null ? 'Buyer' : 'No profile'}');
    print('Profile Data: ${sellerProfile != null ? sellerProfile!.toJson() : buyerProfile != null ? buyerProfile!.toJson() : 'N/A'}');
  }

  // Load session data from SharedPreferences
  Future<bool> loadSavedSessionData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool(_keyRememberMe) ?? false;

      if (!rememberMe) {
        print('📝 Remember Me is disabled, not loading saved data');
        return false;
      }

      final savedToken = prefs.getString(_keyAuthToken);
      final savedRefreshToken = prefs.getString(_keyRefreshToken);
      final savedUserId = prefs.getString(_keyUserId);
      final savedUserType = prefs.getString(_keyUserType);

      if (savedToken == null || savedUserId == null || savedUserType == null) {
        print('📝 No saved session data found');
        return false;
      }

      // Load basic session data
      authToken = savedToken;
      refreshToken = savedRefreshToken;
      userId = savedUserId;
      userType = savedUserType;
      registrationStep = prefs.getString(_keyRegistrationStep);
      isEmailVerified = prefs.getBool(_keyIsEmailVerified);

      // Load seller profile if exists
      final savedSellerProfileJson = prefs.getString(_keySellerProfile);
      if (savedSellerProfileJson != null && savedSellerProfileJson.isNotEmpty) {
        try {
          final profileMap = json.decode(savedSellerProfileJson) as Map<String, dynamic>;
          sellerProfile = SellerModel.fromJson(profileMap);
          print('📝 Loaded seller profile from saved data');
        } catch (e) {
          print('❌ Error loading saved seller profile: $e');
        }
      }

      // Load buyer profile if exists
      final savedBuyerProfileJson = prefs.getString(_keyBuyerProfile);
      if (savedBuyerProfileJson != null && savedBuyerProfileJson.isNotEmpty) {
        try {
          final profileMap = json.decode(savedBuyerProfileJson) as Map<String, dynamic>;
          buyerProfile = BuyerData.fromJson(profileMap);
          print('📝 Loaded buyer profile from saved data');
        } catch (e) {
          print('❌ Error loading saved buyer profile: $e');
        }
      }

      print('📝 Session data loaded from SharedPreferences');
      print('   Token: ${authToken?.substring(0, authToken!.length > 20 ? 20 : authToken!.length)}...');
      print('   User ID: $userId');
      print('   User Type: $userType');
      print('   Registration Step: $registrationStep');
      print('   Has Profile: ${sellerProfile != null || buyerProfile != null}');

      return true;
    } catch (e) {
      print('❌ Error loading saved session data: $e');
      return false;
    }
  }

  // Clear saved data from SharedPreferences
  Future<void> clearSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAuthToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserType);
    await prefs.remove(_keySellerProfile);
    await prefs.remove(_keyBuyerProfile);
    await prefs.remove(_keyRegistrationStep);
    await prefs.remove(_keyIsEmailVerified);
    print('🗑️ Cleared saved session data');
  }

  // Clear all data (including Remember Me setting)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('🗑️ Cleared all SharedPreferences data');
  }

  // Clear session data in memory
  void clearSession() {
    authToken = null;
    refreshToken = null;
    userId = null;
    userType = null;
    sellerProfile = null;
    buyerProfile = null;
    registrationStep = null;
    isEmailVerified = null;
    print('🧹 Cleared in-memory session data');
  }

  // Add this method to your AppSession class
  static Future<void> ensureInitialized() async {
    if (instance.authToken == null) {
      await instance.loadSavedSessionData();
    }
  }
  // Update seller profile and save to SharedPreferences
  Future<void> updateSellerProfile(SellerModel profile) async {
    sellerProfile = profile;
    registrationStep = profile.registrationStep;
    isEmailVerified = profile.isEmailVerified;
    await saveSessionData();
  }

  // Update buyer profile and save to SharedPreferences
  Future<void> updateBuyerProfile(BuyerData profile) async {
    buyerProfile = profile;
    registrationStep = profile.registrationStep;
    isEmailVerified = profile.isEmailVerified;
    await saveSessionData();
  }

  // Update registration step
  Future<void> updateRegistrationStep(String step) async {
    registrationStep = step;
    if (sellerProfile != null) {
      sellerProfile = SellerModel(
        id: sellerProfile!.id,
        email: sellerProfile!.email,
        storeName: sellerProfile!.storeName,
        businessEmail: sellerProfile!.businessEmail,
        phoneNumber: sellerProfile!.phoneNumber,
        category: sellerProfile!.category,
        storeDescription: sellerProfile!.storeDescription,
        logo: sellerProfile!.logo,
        registrationStep: step,
        isEmailVerified: sellerProfile!.isEmailVerified,
        status: sellerProfile!.status,
        completedAt: sellerProfile!.completedAt,
      );
    }
    if (buyerProfile != null) {
      buyerProfile = buyerProfile!.copyWith(registrationStep: step);
    }
    await saveSessionData();
  }

  // Save current state to SharedPreferences
  Future<void> saveCurrentState() async {
    await saveSessionData();
  }

  // Set session after seller login
  Future<void> setSellerSession(String token, SellerModel seller) async {
    authToken = token;
    userId = seller.id;
    userType = 'seller';
    sellerProfile = seller;
    registrationStep = seller.registrationStep;
    isEmailVerified = seller.isEmailVerified;
    await saveSessionData();
  }

  // Set session after buyer login
  Future<void> setBuyerSession({
    required String token,
    required String refreshToken,
    required BuyerData buyer,
  }) async {
    this.authToken = token;
    this.refreshToken = refreshToken;
    userId = buyer.id;
    userType = 'buyer';
    buyerProfile = buyer;
    registrationStep = buyer.registrationStep;
    isEmailVerified = buyer.isEmailVerified;
    await saveSessionData();
  }

  // Get valid token (checks and auto-refreshes if needed)
  Future<String?> getValidToken() async {
    if (authToken == null || refreshToken == null) {
      return null;
    }

    // You can implement token validation and refresh logic here
    // For now, just return the current token
    return authToken;
  }

  // Logout
  Future<void> logout() async {
    clearSession();
    await clearSavedData();
  }
}