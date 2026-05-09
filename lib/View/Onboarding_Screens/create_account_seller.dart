import 'package:afrotierre/View/Onboarding_Screens/verify_email_screen.dart';
import 'package:afrotierre/View/Vendor_Screens/VendorStoreSignupScreen.dart';
import 'package:afrotierre/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../Models/SellerModels/SellerAuthModels.dart';
import '../../Repository/SellerRepository/SellerAuthRepository.dart';
import '../../Services/AppSession.dart';
import '../../Services/GoogleSignInService.dart';
import '../../Services/AppleSignInService.dart';
import '../Vendor_Screens/vendor_bottom_navigation_screen.dart';


class CreateAccountSellerScreen extends StatefulWidget {
  const CreateAccountSellerScreen({super.key});

  @override
  State<CreateAccountSellerScreen> createState() =>
      _CreateAccountSellerScreenState();
}

class _CreateAccountSellerScreenState extends State<CreateAccountSellerScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;
  String? _errorMessage;
  final _session = AppSession.instance;

  // Password validation states
  bool _hasMinLength = false;
  bool _hasUpperCase = false;
  bool _hasLowerCase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  late SellerAuthRepository _authRepository;

  @override
  void initState() {
    super.initState();
    _authRepository = SellerAuthRepository();
    _passwordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordController.removeListener(_validatePassword);
    _authRepository.dispose();
    super.dispose();
  }

  void _validatePassword() {
    final password = _passwordController.text;

    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUpperCase = password.contains(RegExp(r'[A-Z]'));
      _hasLowerCase = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  bool get _isPasswordValid {
    return _hasMinLength &&
        _hasUpperCase &&
        _hasLowerCase &&
        _hasNumber &&
        _hasSpecialChar;
  }

  // ==================== GOOGLE SIGN-IN METHOD ====================

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });

    try {
      print("🟢 Step 1: Getting ID token...");
      final String? idToken = await GoogleSignInService.signIn();

      if (idToken == null) {
        print("🔴 Step 2: ID token is null - user cancelled");
        setState(() {
          _isGoogleLoading = false;
        });
        return;
      }

      print("🟢 Step 2: ID token obtained, length: ${idToken.length}");
      print("🟢 Step 3: Sending to backend...");

      final response = await _authRepository.googleAuth(idToken: idToken);

      print("🟢 Step 4: Backend response received");
      print("=== BACKEND RESPONSE ===");
      print("Success: ${response.success}");
      print("Message: ${response.message}");
      print("Token: ${response.token}");
      print("IsNewUser: ${response.isNewUser}");
      print("RegistrationStep: ${response.seller?.registrationStep}");
      print("Seller exists: ${response.seller != null}");
      print("========================");

      if (!mounted) return;

// In _handleGoogleSignIn method, replace the navigation section:

      if (response.success && response.token != null) {
        print("🟢 Step 5: Saving token to AppSession...");

        // Save to AppSession instead of separate storage
        if (response.seller != null) {
          await GoogleSignInService.saveSellerSession(response.token!, response.seller!);
        } else {
          // If seller is null, create a basic seller object
          final basicSeller = SellerModel(
            id: '', // Will be updated from backend
            email: response.seller?.email ?? '',
            registrationStep: response.seller?.registrationStep ?? 'store_details',
            isEmailVerified: response.seller?.isEmailVerified ?? false,
          );
          await GoogleSignInService.saveSellerSession(response.token!, basicSeller);
        }

        print("🟢 Step 6: Token saved, checking AppSession...");
        print("AppSession token: ${_session.authToken}");
        print("AppSession userId: ${_session.userId}");

        // Navigate based on registration step
        if (mounted) {
          final step = response.seller?.registrationStep;

          if (step == 'completed') {
            // User already has store, go to dashboard
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const VendorBottomNavigationScreen(),
              ),
            );
          } else {
            // User needs to complete store details
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => VendorStoreSignupScreen(
                  token: response.token!,
                  isGoogleUser: true,
                  googleEmail: response.seller?.email,
                  googleStoreName: response.seller?.storeName,
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      print("🔴 ERROR: $e");
      setState(() {
        _errorMessage = 'Google Sign-In failed: ${e.toString()}';
        _isGoogleLoading = false;
      });
    }
  }

  // ==================== APPLE SIGN-IN METHOD ====================

  Future<void> _handleAppleSignIn() async {
    setState(() {
      _isAppleLoading = true;
      _errorMessage = null;
    });

    try {
      print("🟢 Apple Sign-In: Starting...");
      final appleResult = await AppleSignInService.signIn();

      if (appleResult == null) {
        print("🔴 Apple Sign-In: User cancelled or failed");
        setState(() {
          _isAppleLoading = false;
        });
        return;
      }

      final String identityToken = appleResult['identityToken'];
      final String? email = appleResult['email'];
      final String? givenName = appleResult['givenName'];
      final String? familyName = appleResult['familyName'];

      Map<String, String>? fullName;
      if (givenName != null || familyName != null) {
        fullName = {
          'firstName': givenName ?? '',
          'lastName': familyName ?? '',
        };
      }

      print("🟢 Apple Sign-In: Sending to backend...");
      final response = await _authRepository.appleAuth(
        identityToken: identityToken,
        email: email,
        fullName: fullName,
      );

      print("=== APPLE SIGNUP RESPONSE ===");
      print("Success: ${response.success}");
      print("Message: ${response.message}");
      print("Token: ${response.token}");
      print("=============================");

      if (!mounted) return;

      if (response.success && response.token != null) {
        // Save to AppSession
        if (response.seller != null) {
          await AppleSignInService.saveSellerSession(response.token!, response.seller!);
        } else {
          final basicSeller = SellerModel(
            id: '',
            email: response.seller?.email ?? '',
            registrationStep: response.seller?.registrationStep ?? 'store_details',
            isEmailVerified: response.seller?.isEmailVerified ?? false,
          );
          await AppleSignInService.saveSellerSession(response.token!, basicSeller);
        }

        // Navigate based on registration step
        final step = response.seller?.registrationStep;

        if (step == 'completed') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const VendorBottomNavigationScreen(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => VendorStoreSignupScreen(
                token: response.token!,
                isAppleUser: true,
                appleEmail: response.seller?.email,
                appleStoreName: response.seller?.storeName,
              ),
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = response.message;
          _isAppleLoading = false;
        });
      }
    } catch (e) {
      print("❌ Apple Sign-In error: $e");
      setState(() {
        _errorMessage = 'Apple Sign-Up failed: ${e.toString()}';
        _isAppleLoading = false;
      });
    }
  }

  void _handleGoogleUserNavigation(AuthResponse response) {
    // Safely check if we have a valid token
    if (response.token == null || response.token!.isEmpty) {
      _showErrorSnackbar('Authentication error. Please try again.');
      return;
    }

    // Based on registration step, navigate appropriately
    final step = response.seller?.registrationStep;
    final hasStoreName = response.seller?.storeName != null &&
        response.seller!.storeName!.isNotEmpty;

    switch (step) {
      case 'store_details':
      // User needs to complete store details
        _navigateToStoreDetails(response);
        break;

      case 'completed':
      // User has completed registration, go to dashboard
        _navigateToDashboard();
        break;

      default:
      // Handle edge cases
        if (hasStoreName) {
          // User has store name but step is wrong - treat as completed
          _navigateToDashboard();
        } else {
          // Default to store details screen
          _navigateToStoreDetails(response);
        }
    }
  }

// Helper method for navigating to store details
  void _navigateToStoreDetails(AuthResponse response) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => VendorStoreSignupScreen(
          token: response.token!,
          isGoogleUser: true,
          googleEmail: response.seller?.email,  // Fixed: Use googleEmail
          googleStoreName: response.seller?.storeName,  // Fixed: Use googleStoreName
        ),
      ),
    );
  }

// Helper method for navigating to dashboard
  void _navigateToDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const VendorBottomNavigationScreen(),
      ),
    );
  }

// Helper method for showing errors
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  // ==================== EMAIL/PASSWORD SIGN-UP METHOD ====================

  Future<void> _handleSignUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Validate input
    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email';
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your password';
      });
      return;
    }

    // Validate password strength
    if (!_isPasswordValid) {
      setState(() {
        _errorMessage = 'Please meet all password requirements';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _authRepository.createWallet(
        email: email,
        password: password,
      );

      if (response.success && response.token != null) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerifyEmailScreen(
                isSeller: true,
                email: email,
                token: response.token!,
              ),
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = response.message;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ==================== UI HELPERS ====================

  String get _strengthLabel {
    final score = [_hasMinLength, _hasUpperCase, _hasLowerCase, _hasNumber, _hasSpecialChar]
        .where((e) => e).length;

    if (score == 0) return '';
    if (score <= 2) return 'Weak';
    if (score <= 3) return 'Fair';
    if (score <= 4) return 'Good';
    return 'Strong';
  }

  Color get _strengthColor {
    final score = [_hasMinLength, _hasUpperCase, _hasLowerCase, _hasNumber, _hasSpecialChar]
        .where((e) => e).length;

    if (score == 0) return Colors.transparent;
    if (score <= 2) return Colors.red;
    if (score <= 3) return Colors.orange;
    if (score <= 4) return Colors.green;
    return const Color(0xFF1D9E75);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Wallet Type:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    ' Seller',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.storefront_outlined, color: primaryColor),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Create your wallet as a seller',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              const Text(
                'Your email',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                enabled: !_isLoading && !_isGoogleLoading && !_isAppleLoading,
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryColor, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Create password',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                enabled: !_isLoading && !_isGoogleLoading && !_isAppleLoading,
                decoration: InputDecoration(
                  hintText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryColor, width: 1.5),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Password strength indicator
              Row(
                children: List.generate(5, (i) {
                  final checks = [_hasMinLength, _hasUpperCase, _hasLowerCase, _hasNumber, _hasSpecialChar];
                  final score = checks.where((e) => e).length;
                  final colors = [Colors.red, Colors.red, Colors.orange, Colors.green, const Color(0xFF1D9E75)];
                  final segColor = i < score ? colors[score - 1] : Colors.grey.shade200;
                  return Expanded(
                    child: Container(
                      height: 3,
                      margin: EdgeInsets.only(right: i < 4 ? 4 : 0),
                      decoration: BoxDecoration(color: segColor, borderRadius: BorderRadius.circular(2)),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  ...List.generate(5, (i) {
                    final checks = [_hasMinLength, _hasUpperCase, _hasLowerCase, _hasNumber, _hasSpecialChar];
                    final score = checks.where((e) => e).length;
                    final dotColor = checks[i]
                        ? [Colors.red, Colors.red, Colors.orange, Colors.green, const Color(0xFF1D9E75)][score - 1]
                        : Colors.grey.shade300;
                    return Container(
                      width: 7, height: 7,
                      margin: const EdgeInsets.only(right: 5),
                      decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                    );
                  }),
                  const SizedBox(width: 4),
                  if (!_isPasswordValid)
                    Text('8+ chars · A-Z · a-z · 0-9 · !@#',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                  const Spacer(),
                  Text(
                    _strengthLabel,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _strengthColor),
                  ),
                ],
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 40),

              // Sign Up Button
              ElevatedButton(
                onPressed: (_isLoading || _isGoogleLoading || _isAppleLoading) ? null : _handleSignUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: secondaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                )
                    : Text(
                  'Sign up',
                  style: TextStyle(fontSize: 16, color: primaryColor),
                ),
              ),

              const SizedBox(height: 24),

              // Sign In Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account? ",
                    style: TextStyle(color: Colors.grey),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, signInAccountSellerScreen);
                    },
                    child: Text(
                      'Sign in',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: secondaryColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Divider
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('or', style: TextStyle(color: Colors.grey)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 32),

              // Google Sign In Button
              _buildSocialButton(
                'Continue with Google',
                Image.asset('assets/google.png', height: 20),
                (_isAppleLoading || _isLoading) ? null : () => _handleGoogleSignIn(),
                isLoading: _isGoogleLoading,
              ),

              const SizedBox(height: 16),



              // Apple Sign In Button
              _buildSocialButton(
                'Continue with Apple',
                Image.asset('assets/apple.png', height: 20),
                (_isGoogleLoading || _isLoading) ? null : () => _handleAppleSignIn(),
                isLoading: _isAppleLoading,
              ),


              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(
      String text,
      Widget icon,
      VoidCallback? onPressed, {
        bool isLoading = false,
      }) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: isLoading
          ? const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
        ),
      )
          : Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          icon,
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}