import 'package:flutter/material.dart';
import '../../Repository/BuyerRepository/BuyerPasswordResetRepo.dart';
import '../../Models/BuyerModels/BuyerPasswordResetModels.dart';
import '../../res/Widgets/CustomSnackbar.dart';

class BuyerForgotPasswordScreen extends StatefulWidget {
  const BuyerForgotPasswordScreen({super.key});

  @override
  State<BuyerForgotPasswordScreen> createState() => _BuyerForgotPasswordScreenState();
}

class _BuyerForgotPasswordScreenState extends State<BuyerForgotPasswordScreen> {
  // Steps: 0 = enter email, 1 = enter OTP, 2 = new password, 3 = success
  int _step = 0;

  final _emailFormKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final List<TextEditingController> _otpControllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
  List.generate(6, (_) => FocusNode());
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;
  int _resendSeconds = 30;
  bool _canResend = false;
  bool _isLoading = false;

  // Repository instance
  late final BuyerPasswordResetRepo _passwordResetRepo;

  // Store email and OTP for later use
  String _verifiedEmail = '';
  String _verifiedOtp = '';

  @override
  void initState() {
    super.initState();
    _passwordResetRepo = BuyerPasswordResetRepo();
  }

  @override
  void dispose() {
    _emailController.dispose();
    for (final c in _otpControllers) c.dispose();
    for (final f in _otpFocusNodes) f.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _resendSeconds = 30;
    _canResend = false;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        if (_resendSeconds > 0) {
          _resendSeconds--;
        } else {
          _canResend = true;
        }
      });
      return _resendSeconds > 0;
    });
  }

  void _nextStep() => setState(() => _step++);

  // API Methods
  Future<void> _sendOTP() async {
    if (!_emailFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final request = SendOTPRequest(email: _emailController.text.trim());
      final response = await _passwordResetRepo.sendPasswordResetOTP(
        request,
        context: context,
      );

      if (response.success) {
        _verifiedEmail = _emailController.text.trim();
        _startResendTimer();
        _nextStep();
      }
    } catch (e) {
      CustomSnackbar.showError(context, 'Error: ${e.toString().replaceFirst('Exception: ', '')}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOTP() async {
    final otp = _otpControllers.map((c) => c.text).join();

    if (otp.length < 4) {
      CustomSnackbar.showError(context, 'Please enter the 6-digit code');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final request = VerifyOTPRequest(
        email: _verifiedEmail,
        otp: otp,
      );
      final response = await _passwordResetRepo.verifyPasswordResetOTP(
        request,
        context: context,
      );

      if (response.success) {
        _verifiedOtp = otp;
        _nextStep();
      }
    } catch (e) {
      CustomSnackbar.showError(context, 'Error: ${e.toString().replaceFirst('Exception: ', '')}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOTP() async {
    setState(() => _isLoading = true);

    try {
      final request = ResendOTPRequest(email: _verifiedEmail);
      final response = await _passwordResetRepo.resendPasswordResetOTP(
        request,
        context: context,
      );

      if (response.success) {
        // Clear OTP fields
        for (final c in _otpControllers) c.clear();
        _otpFocusNodes[0].requestFocus();
        _startResendTimer();
      }
    } catch (e) {
      CustomSnackbar.showError(context, 'Error: ${e.toString().replaceFirst('Exception: ', '')}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final request = ResetPasswordRequest(
        email: _verifiedEmail,
        otp: _verifiedOtp,
        newPassword: _newPasswordController.text.trim(),
        confirmPassword: _confirmPasswordController.text.trim(),
      );
      final response = await _passwordResetRepo.resetPassword(
        request,
        context: context,
      );

      if (response.success) {
        _nextStep();
      }
    } catch (e) {
      CustomSnackbar.showError(context, 'Error: ${e.toString().replaceFirst('Exception: ', '')}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F6F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Header
              Stack(
                alignment: Alignment.center,
                children: [
                  if (_step < 3)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () {
                          if (_step == 0) {
                            Navigator.pop(context);
                          } else {
                            setState(() => _step--);
                          }
                        },
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  Text(
                    _stepTitle(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              // Step indicator
              if (_step < 3) ...[
                const SizedBox(height: 24),
                _buildStepIndicator(),
              ],

              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, animation) {
                    final slide = Tween<Offset>(
                      begin: const Offset(0.08, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                        parent: animation, curve: Curves.easeOut));
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(position: slide, child: child),
                    );
                  },
                  child: _buildStep(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _stepTitle() {
    switch (_step) {
      case 0:
        return 'Forgot Password';
      case 1:
        return 'Verify OTP';
      case 2:
        return 'New Password';
      default:
        return '';
    }
  }

  // ── Step Indicator ──────────────────────────────────────────────────────────
  Widget _buildStepIndicator() {
    return Row(
      children: List.generate(3, (i) {
        final isActive = i == _step;
        final isDone = i < _step;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDone || isActive
                        ? Colors.black
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              if (i < 2) const SizedBox(width: 6),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _buildEmailStep();
      case 1:
        return _buildOtpStep();
      case 2:
        return _buildNewPasswordStep();
      default:
        return _buildSuccessStep();
    }
  }

  // ── Step 0: Email ───────────────────────────────────────────────────────────
  Widget _buildEmailStep() {
    return Form(
      key: _emailFormKey,
      child: Column(
        key: const ValueKey(0),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 36),
          _buildIconBox(Icons.lock_reset_rounded, Colors.black),
          const SizedBox(height: 24),
          const Text(
            'Reset your\npassword',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Enter your email and we'll send you a\n6-digit OTP to reset your password.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 36),
          _buildLabel('Email Address'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            enabled: !_isLoading,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email is required';
              if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(v)) {
                return 'Enter a valid email';
              }
              return null;
            },
            decoration: _inputDecoration(
              hint: 'Enter your email...',
              prefixIcon: Icons.mail_outline_rounded,
            ),
          ),
          const Spacer(),
          _buildPrimaryButton(
            label: _isLoading ? 'Sending...' : 'Send OTP',
            onTap: _isLoading ? null : _sendOTP,
          ),
          const SizedBox(height: 16),
          _buildFooterText(
            prefix: 'Remember your password? ',
            action: 'Log in',
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Step 1: OTP ─────────────────────────────────────────────────────────────
  Widget _buildOtpStep() {
    return Form(
      key: _otpFormKey,
      child: Column(
        key: const ValueKey(1),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 36),
          _buildIconBox(Icons.pin_outlined, Colors.black),
          const SizedBox(height: 24),
          const Text(
            'Enter the\n6-digit code',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              text: 'We sent a code to ',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                height: 1.6,
              ),
              children: [
                TextSpan(
                  text: _verifiedEmail,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),

          // OTP boxes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (i) => _buildOtpBox(i)),
          ),

          const SizedBox(height: 24),

          // Resend row
          Center(
            child: _isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : _canResend
                ? GestureDetector(
              onTap: _resendOTP,
              child: RichText(
                text: TextSpan(
                  text: "Didn't receive it? ",
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 13,
                  ),
                  children: const [
                    TextSpan(
                      text: 'Resend OTP',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            )
                : RichText(
              text: TextSpan(
                text: 'Resend code in ',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 13,
                ),
                children: [
                  TextSpan(
                    text: '0:${_resendSeconds.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          _buildPrimaryButton(
            label: _isLoading ? 'Verifying...' : 'Verify Code',
            onTap: _isLoading ? null : _verifyOTP,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 50,
      height: 72,
      child: TextFormField(
        controller: _otpControllers[index],
        focusNode: _otpFocusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        enabled: !_isLoading,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.black, width: 2),
          ),
        ),
        onChanged: (v) {
          if (v.isNotEmpty && index < 5) {
            _otpFocusNodes[index + 1].requestFocus();
          } else if (v.isEmpty && index > 0) {
            _otpFocusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }

  // ── Step 2: New Password ────────────────────────────────────────────────────
  Widget _buildNewPasswordStep() {
    return Form(
      key: _passwordFormKey,
      child: Column(
        key: const ValueKey(2),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 36),
          _buildIconBox(Icons.lock_outline_rounded, Colors.black),
          const SizedBox(height: 24),
          const Text(
            'Create new\npassword',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Your new password must be different\nfrom your previous password.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 36),

          _buildLabel('New Password'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _newPasswordController,
            obscureText: !_newPasswordVisible,
            enabled: !_isLoading,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              if (v.length < 6) return 'At least 6 characters';
              return null;
            },
            decoration: _inputDecoration(
              hint: 'Enter new password...',
              prefixIcon: Icons.lock_outline_rounded,
              suffixIcon: GestureDetector(
                onTap: () =>
                    setState(() => _newPasswordVisible = !_newPasswordVisible),
                child: Icon(
                  _newPasswordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          _buildLabel('Confirm Password'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: !_confirmPasswordVisible,
            enabled: !_isLoading,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please confirm your password';
              if (v != _newPasswordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
            decoration: _inputDecoration(
              hint: 'Confirm new password...',
              prefixIcon: Icons.lock_outline_rounded,
              suffixIcon: GestureDetector(
                onTap: () => setState(
                        () => _confirmPasswordVisible = !_confirmPasswordVisible),
                child: Icon(
                  _confirmPasswordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Password strength hints
          _buildPasswordHints(),

          const Spacer(),

          _buildPrimaryButton(
            label: _isLoading ? 'Resetting...' : 'Reset Password',
            onTap: _isLoading ? null : _resetPassword,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPasswordHints() {
    final password = _newPasswordController.text;
    return ValueListenableBuilder(
      valueListenable: _newPasswordController,
      builder: (_, __, ___) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildHintRow('At least 6 characters',
                  _newPasswordController.text.length >= 6),
              const SizedBox(height: 8),
              _buildHintRow('Contains a number',
                  RegExp(r'\d').hasMatch(password)),
              const SizedBox(height: 8),
              _buildHintRow('Contains uppercase letter',
                  RegExp(r'[A-Z]').hasMatch(password)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHintRow(String text, bool met) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: met ? Colors.black : Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          child: Icon(
            met ? Icons.check : Icons.close,
            size: 11,
            color: met ? Colors.white : Colors.grey.shade400,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: met ? Colors.black : Colors.grey.shade500,
            fontWeight: met ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // ── Step 3: Success ─────────────────────────────────────────────────────────
  Widget _buildSuccessStep() {
    return Column(
      key: const ValueKey(3),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.15),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Icon(
            Icons.check_rounded,
            size: 40,
            color: Colors.green.shade600,
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'Password Reset!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Your password has been successfully\nreset. You can now log in.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade500,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 48),
        _buildPrimaryButton(
          label: 'Back to Login',
          onTap: () => Navigator.pop(context),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ── Shared Helpers ──────────────────────────────────────────────────────────
  Widget _buildIconBox(IconData icon, Color color) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, size: 30, color: color),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      prefixIcon:
      Icon(prefixIcon, color: Colors.grey.shade400, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.black, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback? onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildFooterText({
    required String prefix,
    required String action,
    required VoidCallback onTap,
  }) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: RichText(
          text: TextSpan(
            text: prefix,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            children: [
              TextSpan(
                text: action,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}