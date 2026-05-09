import 'package:afrotierre/View/Onboarding_Screens/verify_email_screen.dart';
import 'package:afrotierre/View/Buyers_Screens/bottom_navigation_screen.dart';
import 'package:afrotierre/constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Models/BuyerModels/BuyerAuthModels.dart';
import '../../Models/BuyerModels/BuyerLoginandProfileModels.dart';
import '../../Repository/BuyerRepository/BuyerAuthRepository.dart';
import '../../Repository/BuyerRepository/BuyerLoginProfileRepo.dart';
import '../../Services/AppSession.dart';
import '../../Services/GoogleSignInService.dart';
import '../../Services/AppleSignInService.dart';
import '../../res/Widgets/CustomSnackbar.dart';
import '../Buyers_Screens/BuyerPersonalInfoSignup.dart';

class CreateAccountBuyerScreen extends StatefulWidget {
  const CreateAccountBuyerScreen({super.key});

  @override
  State<CreateAccountBuyerScreen> createState() =>
      _CreateAccountBuyerScreenState();
}

class _CreateAccountBuyerScreenState extends State<CreateAccountBuyerScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;
  bool _rememberMe = false;

  final BuyerAuthRepo _authRepo = BuyerAuthRepo();
  final BuyerLoginProfileRepo _profileRepo = BuyerLoginProfileRepo();
  final AppSession _session = AppSession.instance;

  // Password validation states
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePassword);
    _loadRememberMePreference();
  }

  Future<void> _loadRememberMePreference() async {
    final isEnabled = await _session.isRememberMeEnabled();
    setState(() {
      _rememberMe = isEnabled;
    });

    // Load saved email if Remember Me is enabled
    if (isEnabled) {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('saved_email');
      if (savedEmail != null && savedEmail.isNotEmpty) {
        _emailController.text = savedEmail;
      }
    }
  }

  void _validatePassword() {
    final password = _passwordController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
      _hasLowercase = RegExp(r'[a-z]').hasMatch(password);
      _hasNumber = RegExp(r'[0-9]').hasMatch(password);
      _hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    });
  }

  bool get _isPasswordValid {
    return _hasMinLength &&
        _hasUppercase &&
        _hasLowercase &&
        _hasNumber &&
        _hasSpecialChar;
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
      final response = await _profileRepo.googleAuth(idToken: idToken);

      print("=== GOOGLE SIGNUP RESPONSE ===");
      print("Success: ${response.success}");
      print("Message: ${response.message}");
      print("Token: ${response.token}");
      print("RefreshToken: ${response.refreshToken}");
      print("IsNewUser: ${response.isNewUser}");
      print("RegistrationStep: ${response.buyer?.registrationStep}");
      print("=============================");

      if (!mounted) return;

      if (response.success && response.token != null && response.buyer != null) {
        print("🟢 Google Sign-In: Authentication successful");

        // Save Remember Me preference
        await _session.setRememberMe(_rememberMe);

        // Save Google user email for auto-fill if Remember Me is enabled
        if (_rememberMe && response.buyer!.email.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('buyer_saved_email', response.buyer!.email);
          print('✅ Saved Google user email for Remember Me');
        }

        // Save session
        await _session.setBuyerSession(
          token: response.token!,
          refreshToken: response.refreshToken ?? '',
          buyer: _convertToBuyerData(response.buyer!),
        );

        CustomSnackbar.showSuccess(context, response.message);

        // Navigate based on registration step
        final step = response.buyer?.registrationStep;

        if (step == 'completed') {
          // User has completed registration, go to dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const BottomNavigationScreen(),
            ),
          );
        } else {
          // User needs to complete profile details
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
              'This email already exists. Please sign in with your password.'
          );
        } else {
          CustomSnackbar.showError(
              context,
              response.message.isNotEmpty ? response.message : 'Google Sign-Up failed'
          );
        }
        setState(() {
          _isGoogleLoading = false;
        });
      }
    } catch (e) {
      print("❌ Google Sign-In error: $e");
      CustomSnackbar.showError(context, 'Google Sign-Up failed: ${e.toString()}');
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
      final response = await _profileRepo.appleAuth(
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

      if (response.success && response.token != null && response.buyer != null) {
        print("🟢 Apple Sign-In: Authentication successful");

        await _session.setRememberMe(_rememberMe);

        // Save Apple user email for auto-fill if Remember Me is enabled
        if (_rememberMe && response.buyer!.email.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('buyer_saved_email', response.buyer!.email);
          print('✅ Saved Apple user email for Remember Me');
        }

        await _session.setBuyerSession(
          token: response.token!,
          refreshToken: response.refreshToken ?? '',
          buyer: _convertToBuyerData(response.buyer!),
        );

        CustomSnackbar.showSuccess(context, response.message);

        final step = response.buyer?.registrationStep;

        if (step == 'completed') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const BottomNavigationScreen(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BuyerPersonalInfoSignup(
                token: response.token!,
                refreshToken: response.refreshToken ?? '',
                isAppleUser: true,
                appleEmail: response.buyer?.email,
                appleName: response.buyer?.fullName,
              ),
            ),
          );
        }
      } else {
        if (response.useAppleAuth == false) {
          CustomSnackbar.showError(
              context,
              'This email already exists. Please sign in with your password.'
          );
        } else {
          CustomSnackbar.showError(
              context,
              response.message.isNotEmpty ? response.message : 'Apple Sign-Up failed'
          );
        }
        setState(() {
          _isAppleLoading = false;
        });
      }
    } catch (e) {
      print("❌ Apple Sign-In error: $e");
      CustomSnackbar.showError(context, 'Apple Sign-Up failed: ${e.toString()}');
      setState(() {
        _isAppleLoading = false;
      });
    }
  }

  // Helper method to convert Buyer to BuyerData
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
      googleId: buyer.googleId,
      isGoogleUser: buyer.isGoogleUser,
      appleId: buyer.appleId,
      isAppleUser: buyer.isAppleUser,
    );
  }

  // ==================== EMAIL/PASSWORD SIGN-UP METHOD ====================

  Future<void> _createWallet() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Validate email
    if (email.isEmpty) {
      CustomSnackbar.showError(context, 'Please enter your email');
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      CustomSnackbar.showError(context, 'Please enter a valid email address');
      return;
    }

    // Validate password
    if (password.isEmpty) {
      CustomSnackbar.showError(context, 'Please enter a password');
      return;
    }

    if (!_isPasswordValid) {
      CustomSnackbar.showError(
        context,
        'Password does not meet requirements',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _authRepo.createWallet(
        email: email,
        password: password,
      );

      if (response.success && response.token != null) {
        // Save Remember Me preference
        await _session.setRememberMe(_rememberMe);

        // Save credentials if Remember Me is enabled
        if (_rememberMe) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('saved_email', email);
          // Don't save password for security
        }


        // Navigate to OTP verification screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyEmailScreen(
              email: email,
              token: response.token!,
              isSeller: false,
            ),
          ),
        );
      } else {
        CustomSnackbar.showError(context, response.message);
      }
    } catch (e) {
      CustomSnackbar.showError(
        context,
        e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
                'Create your wallet as a buyer',
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
                textInputAction: TextInputAction.next,
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
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _createWallet(),
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
              _buildPasswordRequirement(
                'Password must be 8 characters or more',
                _hasMinLength,
              ),
              const SizedBox(height: 8),
              _buildPasswordRequirement(
                'Password must contain at least one uppercase letter',
                _hasUppercase,
              ),
              const SizedBox(height: 8),
              _buildPasswordRequirement(
                'Password must contain at least one lowercase letter',
                _hasLowercase,
              ),
              const SizedBox(height: 8),
              _buildPasswordRequirement(
                'Password must contain at least one number',
                _hasNumber,
              ),
              const SizedBox(height: 8),
              _buildPasswordRequirement(
                'Password must contain at least one special character',
                _hasSpecialChar,
              ),
              const SizedBox(height: 16),

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
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const Text(
                    'Remember me',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Sign Up Button
              ElevatedButton(
                onPressed: (_isLoading || _isGoogleLoading || _isAppleLoading) ? null : _createWallet,
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
                      Navigator.pushNamed(context, '/buyer-signin');
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

  Widget _buildPasswordRequirement(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.error_outline,
          color: isValid ? Colors.green : Colors.red,
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: isValid ? Colors.green : Colors.red,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

   Widget _buildSocialButton(
      String text,
      Widget icon,
      VoidCallback? onPressed, {
        required bool isLoading,
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