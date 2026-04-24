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
  static const String _keyLastUserType = 'last_user_type'; // NEW: Always saved
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

  Future<bool> isRememberMeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRememberMe) ?? false;
  }

  Future<void> setRememberMe(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRememberMe, enabled);
  }

  // Save ONLY the last user type (always saved, regardless of Remember Me)
  Future<void> _saveLastUserType(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastUserType, type);
    print('💾 Saved last_user_type: $type');
  }

  // Get last user type (always available)
  Future<String?> getLastUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastUserType);
  }

  // Save session data to SharedPreferences (only if Remember Me is enabled)
  Future<void> saveSessionData() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(_keyRememberMe) ?? false;

    if (!rememberMe) {
      print('📝 Remember Me disabled, not saving full session');
      return;
    }

    await prefs.setString(_keyAuthToken, authToken ?? '');
    await prefs.setString(_keyRefreshToken, refreshToken ?? '');
    await prefs.setString(_keyUserId, userId ?? '');
    await prefs.setString(_keyUserType, userType ?? '');
    await prefs.setString(_keyRegistrationStep, registrationStep ?? '');
    await prefs.setBool(_keyIsEmailVerified, isEmailVerified ?? false);

    if (sellerProfile != null) {
      final profileJson = json.encode(sellerProfile!.toJson());
      await prefs.setString(_keySellerProfile, profileJson);
    } else {
      await prefs.remove(_keySellerProfile);
    }

    if (buyerProfile != null) {
      final profileJson = json.encode(buyerProfile!.toJson());
      await prefs.setString(_keyBuyerProfile, profileJson);
    } else {
      await prefs.remove(_keyBuyerProfile);
    }

    print('💾 Session data saved to SharedPreferences (Remember Me ON)');
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
      final savedUserId = prefs.getString(_keyUserId);
      final savedUserType = prefs.getString(_keyUserType);

      if (savedToken == null || savedUserId == null || savedUserType == null) {
        print('📝 No saved session data found');
        return false;
      }

      authToken = savedToken;
      refreshToken = prefs.getString(_keyRefreshToken);
      userId = savedUserId;
      userType = savedUserType;
      registrationStep = prefs.getString(_keyRegistrationStep);
      isEmailVerified = prefs.getBool(_keyIsEmailVerified);

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

      print('📝 Session data loaded');
      print('   User Type: $userType');
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
    // NOTE: Do NOT clear _keyLastUserType and _keyRememberMe here
    print('🗑️ Cleared saved session data (kept last_user_type)');
  }

  // Clear all data (including Remember Me setting and last user type)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('🗑️ Cleared all SharedPreferences data');
  }

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

  static Future<void> ensureInitialized() async {
    if (instance.authToken == null) {
      await instance.loadSavedSessionData();
    }
  }

  Future<void> updateSellerProfile(SellerModel profile) async {
    sellerProfile = profile;
    registrationStep = profile.registrationStep;
    isEmailVerified = profile.isEmailVerified;
    await saveSessionData();
  }

  Future<void> updateBuyerProfile(BuyerData profile) async {
    buyerProfile = profile;
    registrationStep = profile.registrationStep;
    isEmailVerified = profile.isEmailVerified;
    await saveSessionData();
  }

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

  Future<void> saveCurrentState() async {
    await saveSessionData();
  }

  // Set session after seller login
  Future<void> setSellerSession(String token, SellerModel seller) async {
    print('🟢 Setting seller session...');

    this.authToken = token;
    this.userId = seller.id;
    this.userType = 'seller';
    this.sellerProfile = seller;
    this.registrationStep = seller.registrationStep;
    this.isEmailVerified = seller.isEmailVerified;

    // ALWAYS save last user type (even if Remember Me is off)
    await _saveLastUserType('seller');

    // Save full session only if Remember Me is enabled
    await saveSessionData();

    print('✅ Seller session set successfully');
    print('   UserType: $userType');
    print('   Last user type saved: seller');
  }

  // Set session after buyer login
  Future<void> setBuyerSession({
    required String token,
    required String refreshToken,
    required BuyerData buyer,
  }) async {
    print('🟢 Setting buyer session...');

    this.authToken = token;
    this.refreshToken = refreshToken;
    this.userId = buyer.id;
    this.userType = 'buyer';
    this.buyerProfile = buyer;
    this.registrationStep = buyer.registrationStep;
    this.isEmailVerified = buyer.isEmailVerified;

    // ALWAYS save last user type (even if Remember Me is off)
    await _saveLastUserType('buyer');

    // Save full session only if Remember Me is enabled
    await saveSessionData();

    print('✅ Buyer session set successfully');
    print('   UserType: $userType');
    print('   Last user type saved: buyer');
  }

  Future<String?> getValidToken() async {
    if (authToken == null || refreshToken == null) {
      return null;
    }
    return authToken;
  }

  Future<void> logout() async {
    clearSession();
    await clearSavedData();
    // Note: last_user_type is NOT cleared on logout
    print('✅ Logout complete');
  }
}