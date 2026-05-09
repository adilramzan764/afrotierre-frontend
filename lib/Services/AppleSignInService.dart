// lib/Services/AppleSignInService.dart
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/foundation.dart';
import 'AppSession.dart';
import '../Models/SellerModels/SellerAuthModels.dart';
import '../Models/BuyerModels/BuyerLoginandProfileModels.dart';

class AppleSignInService {
  /// Sign in with Apple and return identity token and user info
  static Future<Map<String, dynamic>?> signIn() async {
    try {
      final rawNonce = _generateNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      return {
        'identityToken': credential.identityToken,
        'email': credential.email,
        'givenName': credential.givenName,
        'familyName': credential.familyName,
        'userIdentifier': credential.userIdentifier,
      };
    } catch (e) {
      debugPrint("Apple Sign-In error: $e");
      return null;
    }
  }

  /// Save seller session to AppSession
  static Future<void> saveSellerSession(String token, SellerModel seller) async {
    await AppSession.instance.setSellerSession(token, seller);
    debugPrint('✅ Apple Seller session saved to AppSession');
  }

  /// Save buyer session to AppSession
  static Future<void> saveBuyerSession({
    required String token,
    required String refreshToken,
    required BuyerData buyer,
  }) async {
    await AppSession.instance.setBuyerSession(
      token: token,
      refreshToken: refreshToken,
      buyer: buyer,
    );
    debugPrint('✅ Apple Buyer session saved to AppSession');
  }

  /// Sign out from Apple (mostly clears local session)
  static Future<void> completeSignOut() async {
    try {
      await AppSession.instance.logout();
      debugPrint('✅ Apple Sign-Out successful (local session cleared)');
    } catch (error) {
      debugPrint('❌ Apple Sign-Out error: $error');
    }
  }

  static String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = List.generate(
      length,
          (_) => charset[(DateTime.now().microsecondsSinceEpoch % charset.length)],
    );
    return random.join();
  }

  /// Placeholder for silent sign-in check
  static Future<String?> silentSignIn() async {
    // Apple doesn't have a direct equivalent to Google's silent sign-in
    // that returns a token without UI, but we can return null to signify 
    // we need to use the stored token in AppSession instead.
    return null;
  }
}
