import 'package:afrotierre/View/Onboarding_Screens/verify_email_screen.dart';
import 'package:afrotierre/constants.dart';
import 'package:flutter/material.dart';

import '../../Repository/SellerRepository/SellerAuthRepository.dart';

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
  String? _errorMessage;

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
  String get _strengthLabel {
    final score = [_hasMinLength, _hasUpperCase, _hasLowerCase, _hasNumber, _hasSpecialChar]
        .where((e) => e).length;

    // Fixed: Handle score 0 and 5 properly
    if (score == 0) return '';
    if (score <= 2) return 'Weak';
    if (score <= 3) return 'Fair';
    if (score <= 4) return 'Good';
    return 'Strong'; // score == 5
  }

  Color get _strengthColor {
    final score = [_hasMinLength, _hasUpperCase, _hasLowerCase, _hasNumber, _hasSpecialChar]
        .where((e) => e).length;

    // Fixed: Handle score 0 properly
    if (score == 0) return Colors.transparent;
    if (score <= 2) return Colors.red;
    if (score <= 3) return Colors.orange;
    if (score <= 4) return Colors.green;
    return const Color(0xFF1D9E75); // score == 5
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

              // Replace all 5 _buildPasswordRequirement calls with this:
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
                  // 5 dots
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
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSignUp,
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
                    () {},
              ),
              const SizedBox(height: 16),
              _buildSocialButton(
                'Continue with Apple',
                Image.asset('assets/apple.png', height: 20),
                    () {},
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