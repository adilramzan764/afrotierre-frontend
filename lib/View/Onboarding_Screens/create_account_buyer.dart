import 'package:afrotierre/View/Onboarding_Screens/verify_email_screen.dart';
import 'package:afrotierre/constants.dart';

import 'package:flutter/material.dart';

import '../../Repository/BuyerRepository/BuyerAuthRepository.dart';
import '../../res/Widgets/CustomSnackbar.dart';

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

  final BuyerAuthRepo _authRepo = BuyerAuthRepo();

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

      if (response.success) {
        // Save token if needed for future requests
        if (response.token != null) {
          // TODO: Save token to secure storage
          // For now, we'll pass it to the next screen
        }

        CustomSnackbar.showSuccess(
          context,
          response.message,
        );

        // Navigate to OTP verification screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyEmailScreen(
              email: email,
              token: response.token ?? '', isSeller: false,
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
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:  BorderSide(color: primaryColor, width: 1.5),
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
                enabled: !_isLoading,
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
                    borderSide:  BorderSide(color: primaryColor, width: 1.5),
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
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : _createWallet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: secondaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isLoading
                    ?  SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: primaryColor,
                  ),
                )
                    : Text(
                  'Sign up',
                  style: TextStyle(fontSize: 16, color: primaryColor),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account? ",
                    style: TextStyle(color: Colors.grey),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to Sign In
                      // TODO: Navigate to sign in screen
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
                  // TODO: Implement Google Sign In
                  CustomSnackbar.showInfo(context, 'Google Sign In coming soon');
                },
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),
              _buildSocialButton(
                'Continue with Apple',
                Image.asset('assets/apple.png', height: 20),
                    () {
                  // TODO: Implement Apple Sign In
                  CustomSnackbar.showInfo(context, 'Apple Sign In coming soon');
                },
                isLoading: _isLoading,
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
      VoidCallback onPressed, {
        required bool isLoading,
      }) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Row(
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