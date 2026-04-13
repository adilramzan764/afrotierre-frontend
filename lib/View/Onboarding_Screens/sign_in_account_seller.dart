import 'package:afrotierre/View/Onboarding_Screens/create_account_seller.dart';
import 'package:afrotierre/View/Vendor_Screens/ForgotPasswordScreen.dart';
import 'package:afrotierre/View/Vendor_Screens/vendor_bottom_navigation_screen.dart';
import 'package:afrotierre/constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Repository/SellerRepository/SellerLoginandProfileRepo.dart';
import '../../Services/AppSession.dart';
import '../../res/Widgets/CustomSnackbar.dart';

class SignInAccountSellerScreen extends StatefulWidget {
  const SignInAccountSellerScreen({super.key});

  @override
  State<SignInAccountSellerScreen> createState() =>
      _SignInAccountSellerScreenState();
}

class _SignInAccountSellerScreenState extends State<SignInAccountSellerScreen> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = false;

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

      if (response.success && response.token != null && response.seller != null) {
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
        // Handle validation errors
        if (response.errors != null && response.errors!.isNotEmpty) {
          final errorMessage = response.errors!.join('\n');
          CustomSnackbar.showError(context, errorMessage);
        } else {
          CustomSnackbar.showError(context, response.message);
        }
      }
    } catch (e) {
      CustomSnackbar.showError(context, 'An unexpected error occurred: ${e.toString()}');
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
        print('⚠️ Failed to fetch complete profile: ${profileResponse.message}');
      }
    } catch (e) {
      print('❌ Error fetching complete profile: $e');
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
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                          activeColor: primaryColor,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
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
                  'Sign in',
                  style: TextStyle(fontSize: 16, color: primaryColor),
                ),
              ),
              const SizedBox(height: 24),
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
                          builder: (context) => const CreateAccountSellerScreen(),
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
                  // TODO: Implement Google sign in
                  CustomSnackbar.showInfo(context, 'Google sign in coming soon');
                },
              ),
              const SizedBox(height: 16),
              _buildSocialButton(
                'Continue with Apple',
                Image.asset('assets/apple.png', height: 20),
                    () {
                  // TODO: Implement Apple sign in
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