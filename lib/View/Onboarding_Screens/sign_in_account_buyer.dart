import 'package:afrotierre/View/Buyers_Screens/bottom_navigation_screen.dart';
import 'package:afrotierre/View/Onboarding_Screens/create_account_buyer.dart';
import 'package:afrotierre/constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Models/BuyerModels/BuyerLoginandProfileModels.dart';
import '../../Repository/BuyerRepository/BuyerLoginProfileRepo.dart';
import '../../Services/AppSession.dart';
import '../../res/Widgets/CustomSnackbar.dart';
import '../Buyers_Screens/BuyerForgotPasswordScreen.dart';

class SignInAccountBuyerScreen extends StatefulWidget {
  const SignInAccountBuyerScreen({super.key});

  @override
  State<SignInAccountBuyerScreen> createState() =>
      _SignInAccountBuyerScreenState();
}

class _SignInAccountBuyerScreenState extends State<SignInAccountBuyerScreen> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = false;

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

    // Load saved credentials if Remember Me is enabled
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
      // Clear saved credentials if Remember Me is unchecked
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('buyer_saved_email');
      await prefs.remove('buyer_saved_password');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
      final request = LoginRequest(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final loginResponse = await _repo.login(request, context: context);

      if (loginResponse.success && loginResponse.token.isNotEmpty) {
        // Save Remember Me preference
        await _session.setRememberMe(_rememberMe);

        // Save credentials if Remember Me is enabled
        await _saveCredentialsIfNeeded();

        // Fetch complete buyer profile from getProfile API
        final profileResponse = await _repo.getProfile(
          loginResponse.token,
          context: context,
        );

        if (profileResponse.success && profileResponse.buyer.id.isNotEmpty) {
          // Save complete buyer profile to AppSession
          await _session.setBuyerSession(
            token: loginResponse.token,
            refreshToken: loginResponse.refreshToken,
            buyer: profileResponse.buyer,
          );

          print('✅ Profile saved with full data:');
          print('   Full Name: ${profileResponse.buyer.fullName}');
          print('   Phone: ${profileResponse.buyer.phoneNumber}');
          print('   Address: ${profileResponse.buyer.preferences}');
          print(
            '   Registration Step: ${profileResponse.buyer.registrationStep}',
          );

          // Navigate to home screen
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const BottomNavigationScreen(),
              ),
            );
          }
        } else {
          // Fallback: Use buyer data from login response if profile fetch fails
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
      // Error already handled by repository snackbar
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
                    ' Buyer',
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
                'Login your wallet as a buyer',
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
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                          activeColor: primaryColor,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const Text('Remember me', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: Navigate to forgot password screen

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => const BuyerForgotPasswordScreen(),
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

              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: secondaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child:
                    _isLoading
                        ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              primaryColor,
                            ),
                          ),
                        )
                        : Text(
                          'Sign in',
                          style: TextStyle(fontSize: 16, color: primaryColor),
                        ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don’t have an account? ",
                    style: TextStyle(color: Colors.grey),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => const CreateAccountBuyerScreen(),
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
              _buildSocialButton(
                'Continue with Google',
                Image.asset('assets/google.png', height: 20),
                () {
                  CustomSnackbar.showInfo(
                    context,
                    'Google sign in coming soon',
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildSocialButton(
                'Continue with Apple',
                Image.asset('assets/apple.png', height: 20),
                () {
                  CustomSnackbar.showInfo(context, 'Apple sign in coming soon');
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(String text, Widget icon, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Row(
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
