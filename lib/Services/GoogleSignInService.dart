// lib/services/GoogleSignInService.dart
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/SellerModels/SellerAuthModels.dart';
import 'AppSession.dart';

class GoogleSignInService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
      'openid',  // ← ADD THIS - crucial for getting ID token
    ],    // ✅ CORRECT: Use WEB Client ID here (not Android Client ID)
    // Get this from Google Cloud Console → Credentials → Web application
    serverClientId: '190758022037-h9dnpdptm2mfoe41hn1oqufq89nioa01.apps.googleusercontent.com',

  );

  /// Sign in with Google and return ID token
  static Future<String?> signIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      // 🔥 IMPORTANT: force refresh authentication
      final idToken = googleAuth.idToken;

      if (idToken != null) {
        print("ID Token: ${googleAuth.idToken}");
        print("Access Token: ${googleAuth.accessToken}");
        return idToken;
      }

      // 🧠 fallback: retry authentication once
      final freshAuth = await googleUser.authentication;
      return freshAuth.idToken;

    } catch (e) {
      print("Google Sign-In error: $e");
      return null;
    }
  }

  /// Save session to AppSession (NOT separate storage)
  static Future<void> saveSellerSession(String token, SellerModel seller) async {
    await AppSession.instance.setSellerSession(token, seller);
    debugPrint('✅ Seller session saved to AppSession');
  }

  /// Sign out from Google and clear session
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await AppSession.instance.logout();
      debugPrint('✅ Google Sign-Out successful');
    } catch (error) {
      debugPrint('❌ Google Sign-Out error: $error');
    }
  }



  /// Check if user is signed in with Google
  static Future<bool> isSignedIn() async {
    try {
      return await _googleSignIn.isSignedIn();
    } catch (error) {
      debugPrint('Error checking Google sign-in status: $error');
      return false;
    }
  }

  /// Get current Google user info
  static Future<GoogleSignInAccount?> getCurrentUser() async {
    try {
      return await _googleSignIn.currentUser;
    } catch (error) {
      debugPrint('Error getting current Google user: $error');
      return null;
    }
  }

  /// Get current Google user's ID token (useful for refreshing)
  static Future<String?> getCurrentIdToken() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.currentUser;
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      return googleAuth.idToken;
    } catch (error) {
      debugPrint('Error getting current ID token: $error');
      return null;
    }
  }

  /// Save token to shared preferences
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    debugPrint('✅ Auth token saved to shared preferences');
  }

  /// Get saved token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Clear saved token
  static Future<void> clearToken() async {
    // Clear local session
    await AppSession.instance.logout();
    print('✅ Cleared local session');

    // Also clear any other Google-related stored data
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('google_user_email');
    await prefs.remove('google_user_name');
    debugPrint('✅ Auth token cleared from shared preferences');
  }

  /// Silently sign in (for automatic login)
  static Future<String?> silentSignIn() async {
    try {
      final bool isSignedIn = await _googleSignIn.isSignedIn();
      if (!isSignedIn) {
        debugPrint('Silent sign-in: No existing Google session');
        return null;
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();
      if (googleUser == null) {
        debugPrint('Silent sign-in: Failed to get user');
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final String? idToken = googleAuth.idToken;

      if (idToken != null) {
        debugPrint('✅ Silent sign-in successful');
      }

      return idToken;
    } catch (error) {
      debugPrint('❌ Silent Google Sign-In error: $error');
      return null;
    }
  }

  /// Complete sign out (Google + clear local token)
  static Future<void> completeSignOut() async {
    await signOut();
    await clearToken();
    debugPrint('✅ Complete sign out done');
  }
}