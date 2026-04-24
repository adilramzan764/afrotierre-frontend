import 'package:afrotierre/View/Buyers_Screens/bottom_navigation_screen.dart';
import 'package:afrotierre/View/Onboarding_Screens/create_account_buyer.dart';
import 'package:afrotierre/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../Models/BuyerModels/BuyerAuthModels.dart';
import '../../Models/BuyerModels/BuyerLoginandProfileModels.dart';
import '../../Repository/BuyerRepository/BuyerLoginProfileRepo.dart';
import '../../Services/AppSession.dart';
import '../../Services/GoogleSignInService.dart';
import '../../res/Widgets/CustomSnackbar.dart';
import '../Buyers_Screens/BuyerForgotPasswordScreen.dart';
import '../Buyers_Screens/BuyerPersonalInfoSignup.dart';
import 'onboarding_screen.dart';

class SignInAccountBuyerScreen extends StatefulWidget {
  final bool isOnboarding;

  const SignInAccountBuyerScreen({super.key, this.isOnboarding = false});

  @override
  State<SignInAccountBuyerScreen> createState() =>
      _SignInAccountBuyerScreenState();
}

class _SignInAccountBuyerScreenState extends State<SignInAccountBuyerScreen> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _rememberMe = true;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repo = BuyerLoginProfileRepo();
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

    if (isEnabled) {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('buyer_saved_email');
      final savedPassword = prefs.getString('buyer_saved_password');
      if (savedEmail != null && savedPassword != null) {
        _emailController.text = savedEmail;
        _passwordController.text = savedPassword;
      }
    }
  }

  Future<void> _saveCredentialsIfNeeded() async {
    if (_rememberMe) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('buyer_saved_email', _emailController.text.trim());
      await prefs.setString('buyer_saved_password', _passwordController.text);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('buyer_saved_email');
      await prefs.remove('buyer_saved_password');
    }
  }

  Future<void> _saveGoogleUserInfo(String email) async {
    if (_rememberMe) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('buyer_saved_email', email);
      await prefs.remove('buyer_saved_password');
      print('✅ Saved Google user email for Remember Me: $email');
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
      print("RefreshToken: ${response.refreshToken}");
      print("IsNewUser: ${response.isNewUser}");
      print("RegistrationStep: ${response.buyer?.registrationStep}");
      print("Email: ${response.buyer?.email}");
      print("=============================");

      if (!mounted) return;

      if (response.success &&
          response.token != null &&
          response.buyer != null) {
        print("🟢 Google Sign-In: Authentication successful");

        print("🟢 Fetching complete buyer profile...");
        BuyerData? completeBuyerProfile;

        try {
          final profileResponse = await _repo.getProfile(
            response.token!,
            context: context,
          );

          if (profileResponse.success && profileResponse.buyer.id.isNotEmpty) {
            completeBuyerProfile = profileResponse.buyer;
            print("✅ Complete buyer profile fetched successfully");
          } else {
            print("⚠️ Could not fetch complete profile, using basic profile");
            completeBuyerProfile = _convertToBuyerData(response.buyer!);
          }
        } catch (profileError) {
          print("❌ Error fetching complete profile: $profileError");
          completeBuyerProfile = _convertToBuyerData(response.buyer!);
        }

        await _session.setRememberMe(_rememberMe);

        if (_rememberMe && response.buyer!.email.isNotEmpty) {
          await _saveGoogleUserInfo(response.buyer!.email);
        }

        await _session.setBuyerSession(
          token: response.token!,
          refreshToken: response.refreshToken ?? '',
          buyer: completeBuyerProfile,
        );

        final step = completeBuyerProfile.registrationStep;

        if (step == 'completed') {
          print("✅ Registration completed, navigating to dashboard");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const BottomNavigationScreen(),
            ),
          );
        } else {
          print("⚠️ Registration incomplete, navigating to profile completion");
          CustomSnackbar.showError(
            context,
            'User registration incomplete. Please complete your profile information.',
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BuyerPersonalInfoSignup(
                token: response.token!,
                refreshToken: response.refreshToken ?? '',
                isGoogleUser: true,
                googleEmail: response.buyer?.email,
                googleName: response.buyer?.fullName,
              ),
            ),
          );
        }
      } else {
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
    );
  }

  // ==================== EMAIL/PASSWORD LOGIN ====================

  Future<void> _handleLogin() async {
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
      final request = LoginRequest(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final loginResponse = await _repo.login(request, context: context);

      if (loginResponse.success && loginResponse.token.isNotEmpty) {
        await _session.setRememberMe(_rememberMe);
        await _saveCredentialsIfNeeded();

        final profileResponse = await _repo.getProfile(
          loginResponse.token,
          context: context,
        );

        if (profileResponse.success && profileResponse.buyer.id.isNotEmpty) {
          await _session.setBuyerSession(
            token: loginResponse.token,
            refreshToken: loginResponse.refreshToken,
            buyer: profileResponse.buyer,
          );

          print('✅ Profile saved with full data:');
          print('   Full Name: ${profileResponse.buyer.fullName}');
          print('   Phone: ${profileResponse.buyer.phoneNumber}');
          print('   Registration Step: ${profileResponse.buyer.registrationStep}');

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const BottomNavigationScreen(),
              ),
            );
          }
        } else {
          print('⚠️ Profile fetch failed, using login response data');
          await _session.setBuyerSession(
            token: loginResponse.token,
            refreshToken: loginResponse.refreshToken,
            buyer: loginResponse.buyer,
          );

          if (mounted) {
            CustomSnackbar.showWarning(
              context,
              'Profile loaded with limited information. Some features may be restricted.',
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const BottomNavigationScreen(),
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Login error: $e');
      if (mounted) {
        CustomSnackbar.showError(
          context,
          'Login failed. Please check your credentials and try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
          return true;
        } else {
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
                    (route) => false,
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

                // ── Title ──
                const Text(
                  'Welcome back',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to your account',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 40),

                // ── Email ──
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
                  enabled: !_isLoading && !_isGoogleLoading,
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

                // ── Password ──
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
                  enabled: !_isLoading && !_isGoogleLoading,
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

                // ── Remember Me & Forgot Password ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _rememberMe,
                            onChanged: (_isLoading || _isGoogleLoading)
                                ? null
                                : (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                            activeColor: primaryColor,
                            materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        const SizedBox(width: 6),
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
                            builder: (context) =>
                            const BuyerForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // ── Sign In Button ──
                ElevatedButton(
                  onPressed:
                  (_isLoading || _isGoogleLoading) ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  )
                      : Text(
                    'Sign in',
                    style:
                    TextStyle(fontSize: 16, color: primaryColor),
                  ),
                ),
                const SizedBox(height: 16),

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

                // ── Sign Up Link ──
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
                            builder: (context) =>
                            const CreateAccountBuyerScreen(),
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

                // ── Divider ──
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child:
                      Text('or', style: TextStyle(color: Colors.grey)),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 32),

                // ── Google Sign In ──
                _buildSocialButton(
                  'Continue with Google',
                  Image.asset('assets/google.png', height: 20),
                  _handleGoogleSignIn,
                  isLoading: _isGoogleLoading,
                ),
                const SizedBox(height: 16),

                // ── Apple Sign In ──
                _buildSocialButton(
                  'Continue with Apple',
                  Image.asset('assets/apple.png', height: 20),
                      () {
                    CustomSnackbar.showInfo(
                        context, 'Apple sign in coming soon');
                  },
                  isLoading: false,
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
      VoidCallback onPressed, {
        required bool isLoading,
      }) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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