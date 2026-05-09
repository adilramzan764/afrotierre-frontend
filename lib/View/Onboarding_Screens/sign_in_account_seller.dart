import 'package:afrotierre/View/Onboarding_Screens/create_account_seller.dart';
import 'package:afrotierre/View/Vendor_Screens/ForgotPasswordScreen.dart';
import 'package:afrotierre/View/Vendor_Screens/VendorStoreSignupScreen.dart';
import 'package:afrotierre/View/Vendor_Screens/vendor_bottom_navigation_screen.dart';
import 'package:afrotierre/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../Models/SellerModels/SellerAuthModels.dart';
import '../../Repository/SellerRepository/SellerLoginandProfileRepo.dart';
import '../../Services/AppSession.dart';
import '../../Services/GoogleSignInService.dart';
import '../../Services/AppleSignInService.dart';
import '../../res/Widgets/CustomSnackbar.dart';
import 'onboarding_screen.dart';

class SignInAccountSellerScreen extends StatefulWidget {
  final bool isOnboarding;
  const SignInAccountSellerScreen({super.key,this.isOnboarding = false});

  @override
  State<SignInAccountSellerScreen> createState() =>
      _SignInAccountSellerScreenState();
}

class _SignInAccountSellerScreenState extends State<SignInAccountSellerScreen> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;
  bool _rememberMe = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final SellerLoginandProfileRepo _repo = SellerLoginandProfileRepo();
  final AppSession _session = AppSession.instance;

  @override
  void initState() {
    super.initState();
    _loadRememberMePreference();
  }

  Future<void> _loadRememberMePreference() async {
    final isEnabled = await _session.isRememberMeEnabled();
    setState(() {
      _rememberMe = isEnabled;
    });

    // Load saved credentials if Remember Me is enabled
    if (isEnabled) {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('saved_email');
      final savedPassword = prefs.getString('saved_password');
      if (savedEmail != null && savedPassword != null) {
        _emailController.text = savedEmail;
        _passwordController.text = savedPassword;
      }
    }
  }

  Future<void> _saveCredentialsIfNeeded() async {
    if (_rememberMe) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_email', _emailController.text.trim());
      await prefs.setString('saved_password', _passwordController.text);
    }
  }

  // ==================== GOOGLE SIGN-IN METHOD ====================

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      print("🟢 Google Sign-In: Getting ID token...");
      final String? idToken = await GoogleSignInService.signIn();

      if (idToken == null) {
        print("🔴 Google Sign-In: User cancelled");
        setState(() {
          _isGoogleLoading = false;
        });
        return;
      }

      print("🟢 Google Sign-In: Sending to backend...");
      final response = await _repo.googleAuth(idToken: idToken);

      print("=== GOOGLE LOGIN RESPONSE ===");
      print("Success: ${response.success}");
      print("Message: ${response.message}");
      print("Token: ${response.token}");
      print("IsNewUser: ${response.isNewUser}");
      print("RegistrationStep: ${response.seller?.registrationStep}");
      print("=============================");

      if (!mounted) return;

      if (response.success &&
          response.token != null &&
          response.seller != null) {
        print("🟢 Google Sign-In: Authentication successful");

        // Save session
        await _session.setSellerSession(response.token!, response.seller!);

        _fetchAndStoreCompleteProfile(response.token!);

        // Save Remember Me preference
        await _session.setRememberMe(_rememberMe);

        // CustomSnackbar.showSuccess(context, response.message);

        // Navigate based on registration step
        final step = response.seller?.registrationStep;

        if (step == 'completed') {
          // User has completed registration, go to dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const VendorBottomNavigationScreen(),
            ),
          );
        } else {
          // User needs to complete store details
          CustomSnackbar.showError(
            context,
            'User not registered as a seller. Please Sign up to continue.',
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                  // VendorStoreSignupScreen(token: response.token!,
                  CreateAccountSellerScreen(
                    // You'll need to pass parameters if needed
                  ),
            ),
          );
        }
      } else {
        // Check if user exists but needs to use email/password
        if (response.useGoogleAuth == false) {
          CustomSnackbar.showError(
            context,
            'This account uses email/password. Please sign in with your password.',
          );
        } else {
          CustomSnackbar.showError(
            context,
            response.message.isNotEmpty
                ? response.message
                : 'Google Sign-In failed',
          );
        }
        setState(() {
          _isGoogleLoading = false;
        });
      }
    } catch (e) {
      print("❌ Google Sign-In error: $e");
      CustomSnackbar.showError(
        context,
        'Google Sign-In failed: ${e.toString()}',
      );
      setState(() {
        _isGoogleLoading = false;
      });
    }
  }

  // ==================== APPLE SIGN-IN METHOD ====================

  Future<void> _handleAppleSignIn() async {
    setState(() {
      _isAppleLoading = true;
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
      final response = await _repo.appleAuth(
        identityToken: identityToken,
        email: email,
        fullName: fullName,
      );

      print("=== APPLE LOGIN RESPONSE ===");
      print("Success: ${response.success}");
      print("Message: ${response.message}");
      print("Token: ${response.token}");
      print("=============================");

      if (!mounted) return;

      if (response.success &&
          response.token != null &&
          response.seller != null) {
        print("🟢 Apple Sign-In: Authentication successful");

        // Save session
        await _session.setSellerSession(response.token!, response.seller!);

        _fetchAndStoreCompleteProfile(response.token!);

        // Save Remember Me preference
        await _session.setRememberMe(_rememberMe);

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
          CustomSnackbar.showError(
            context,
            'User not registered as a seller. Please Sign up to continue.',
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateAccountSellerScreen(),
            ),
          );
        }
      } else {
        if (response.useAppleAuth == false) {
          CustomSnackbar.showError(
            context,
            'This account uses email/password. Please sign in with your password.',
          );
        } else {
          CustomSnackbar.showError(
            context,
            response.message.isNotEmpty
                ? response.message
                : 'Apple Sign-In failed',
          );
        }
        setState(() {
          _isAppleLoading = false;
        });
      }
    } catch (e) {
      print("❌ Apple Sign-In error: $e");
      CustomSnackbar.showError(
        context,
        'Apple Sign-In failed: ${e.toString()}',
      );
      setState(() {
        _isAppleLoading = false;
      });
    }
  }

  // ==================== EMAIL/PASSWORD LOGIN ====================

  Future<void> _handleLogin() async {
    // Validate inputs
    if (_emailController.text.trim().isEmpty) {
      CustomSnackbar.showError(context, 'Please enter your email');
      return;
    }

    if (_passwordController.text.isEmpty) {
      CustomSnackbar.showError(context, 'Please enter your password');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _repo.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (response.success &&
          response.token != null &&
          response.seller != null) {
        // Save Remember Me preference
        await _session.setRememberMe(_rememberMe);

        // Save credentials if Remember Me is enabled
        await _saveCredentialsIfNeeded();

        // Set basic session data from login response
        await _session.setSellerSession(response.token!, response.seller!);

        CustomSnackbar.showSuccess(context, response.message);

        // Navigate to vendor dashboard immediately
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const VendorBottomNavigationScreen(),
          ),
        );

        // Fetch complete profile in the background
        _fetchAndStoreCompleteProfile(response.token!);
      } else {
        // Check if user should use Google Sign-In
        if (response.useGoogleAuth == true) {
          CustomSnackbar.showError(
            context,
            'This account uses Google Sign-In. Please use the "Continue with Google" button.',
          );
        } else if (response.errors != null && response.errors!.isNotEmpty) {
          final errorMessage = response.errors!.join('\n');
          CustomSnackbar.showError(context, errorMessage);
        } else {
          CustomSnackbar.showError(context, response.message);
        }
      }
    } catch (e) {
      CustomSnackbar.showError(
        context,
        'An unexpected error occurred: ${e.toString()}',
      );
      print('Error during login: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchAndStoreCompleteProfile(String token) async {
    try {
      // Small delay to ensure navigation is complete
      await Future.delayed(const Duration(milliseconds: 500));

      final profileResponse = await _repo.getProfile(token);

      if (profileResponse.success && profileResponse.seller != null) {
        await _session.updateSellerProfile(profileResponse.seller!);
        print('✅ Complete profile stored successfully');
        print('Seller Profile: ${profileResponse.seller!.toJson()}');
      } else {
        print(
          '⚠️ Failed to fetch complete profile: ${profileResponse.message}',
        );
      }
    } catch (e) {
      print('❌ Error fetching complete profile: $e');
    }
  }

  Future<void> _openTermsAndConditions() async {
    // FIX: Use the complete UUID from your original working code
    const url = 'https://app.termly.io/policy-viewer/policy.html?policyUUID=1c207878-1a91-4f28-b5a8-1c979b8af6dc';

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading indicator
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {
            if (mounted) {
              CustomSnackbar.showError(context, 'Failed to load Terms & Conditions');
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(url));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Terms & Conditions'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: WebViewWidget(controller: controller),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.isOnboarding) {
          // If coming from onboarding, allow normal back navigation
          return true;
        } else {
          // If after logout, close the app
          SystemNavigator.pop();
          return false;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const OnboardingScreen(),
                ),
                    (route) => false, // This removes all previous routes
              );

            },
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
                    Icon(Icons.shopping_cart_outlined, color: primaryColor),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Login your wallet as a seller',
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
                  'Password',
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
                const SizedBox(height: 7),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Remember Me checkbox
                    Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _rememberMe,
                            onChanged: (_isLoading || _isGoogleLoading || _isAppleLoading) ? null : (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                            activeColor: primaryColor,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        const Text(
                          'Remember me',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Forgot password?',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Sign In Button
                ElevatedButton(
                  onPressed: (_isLoading || _isGoogleLoading || _isAppleLoading) ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.black,
                              ),
                            ),
                          )
                          : Text(
                            'Sign in',
                            style: TextStyle(fontSize: 16, color: primaryColor),
                          ),
                ),

                SizedBox(height: 20,),

                // ── Terms & Conditions ──
                Center(
                  child: GestureDetector(
                    onTap: _openTermsAndConditions,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey),
                        children: [
                          const TextSpan(
                              text: 'By signing in, you agree to our '),
                          TextSpan(
                            text: 'Terms & Conditions',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => const CreateAccountSellerScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Sign up',
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
      child:
          isLoading
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
