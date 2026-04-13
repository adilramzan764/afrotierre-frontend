import 'package:afrotierre/View/Buyers_Screens/bottom_navigation_screen.dart';
import 'package:afrotierre/View/Vendor_Screens/vendor_subcription_plan_screen.dart';
import 'package:afrotierre/constants.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'dart:async';

import '../../Repository/BuyerRepository/BuyerAuthRepository.dart';
import '../../Repository/SellerRepository/SellerAuthRepository.dart';
import '../../res/Widgets/CustomSnackbar.dart';
import '../Buyers_Screens/BuyerPersonalInfoSignup.dart';
import '../Vendor_Screens/VendorStoreSignupScreen.dart';

class VerifyEmailScreen extends StatefulWidget {
  final bool isSeller;
  final String email;
  final String token;

  const VerifyEmailScreen({
    super.key,
    required this.isSeller,
    required this.email,
    required this.token,
  });

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  late Timer _timer;
  int _start = 59;
  String _otpCode = '';
  bool _isLoading = false;
  String? _errorMessage;

  late SellerAuthRepository _sellerAuthRepository;
  late BuyerAuthRepo _buyerAuthRepo;

  @override
  void initState() {
    super.initState();
    _sellerAuthRepository = SellerAuthRepository();
    _buyerAuthRepo = BuyerAuthRepo();
    _startTimer();
  }

  void _startTimer() {
    _start = 59;
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (timer) {
      if (_start == 0) {
        setState(() => timer.cancel());
      } else {
        setState(() => _start--);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _sellerAuthRepository.dispose();
    super.dispose();
  }

  Future<void> _handleResendOTP() async {
    if (_start > 0) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      dynamic response;

      if (widget.isSeller) {
        response = await _sellerAuthRepository.resendOTP(email: widget.email);
      } else {
        response = await _buyerAuthRepo.resendOTP(email: widget.email);
      }

      if (response.success) {
        _startTimer();
        if (mounted) {
          CustomSnackbar.showSuccess(context, response.message);
        }
      } else {
        setState(() => _errorMessage = response.message);
        if (mounted) {
          CustomSnackbar.showError(context, response.message);
        }
      }
    } catch (e) {
      final errorMsg =
          'Failed to resend OTP: ${e.toString().replaceAll('Exception: ', '')}';
      setState(() => _errorMessage = errorMsg);
      if (mounted) {
        CustomSnackbar.showError(context, errorMsg);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleVerifyOTP() async {
    if (_otpCode.length != 6) {
      setState(
        () => _errorMessage = 'Please enter the 6-digit verification code',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      dynamic response;

      if (widget.isSeller) {
        // Seller verification
        response = await _sellerAuthRepository.verifyEmail(
          email: widget.email,
          otp: _otpCode,
        );

        if (response.success && response.seller != null) {
          if (response.seller!.registrationStep == 'store_details') {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => VendorStoreSignupScreen(
                        token: response.token ?? widget.token,
                      ),
                ),
              );
            }
          } else if (response.seller!.registrationStep == 'completed') {
            if (mounted) {
              if (selectedWalletType == 'Seller') {
                Navigator.pushReplacementNamed(
                  context,
                  vendorBottomNavigationScreen,
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => BottomNavigationScreen()),
                );
              }
            }
          }
        } else {
          setState(() => _errorMessage = response.message);
          if (mounted) {
            CustomSnackbar.showError(context, response.message);
          }
        }
      } else {
        // Buyer verification
        response = await _buyerAuthRepo.verifyEmail(
          email: widget.email,
          otp: _otpCode,
        );

        if (response.success && response.buyer != null) {
          if (response.buyer!.registrationStep == 'profile_details') {
            if (mounted) {
              CustomSnackbar.showSuccess(context, response.message);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => BuyerPersonalInfoSignup(
                        token: response.token ?? widget.token,
                        email: widget.email,
                      ),
                ),
              );
            }
          } else if (response.buyer!.registrationStep == 'completed') {
            if (mounted) {
              CustomSnackbar.showSuccess(
                context,
                'Email verified successfully!',
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => BottomNavigationScreen()),
              );
            }
          }
        } else {
          setState(() => _errorMessage = response.message);
          if (mounted) {
            CustomSnackbar.showError(context, response.message);
          }
        }
      }
    } catch (e) {
      final errorMsg =
          'Verification failed: ${e.toString().replaceAll('Exception: ', '')}';
      setState(() => _errorMessage = errorMsg);
      if (mounted) {
        CustomSnackbar.showError(context, errorMsg);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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

              // ── Header ──────────────────────────────────────────────────
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, size: 18),
                      ),
                    ),
                  ),
                  Text(
                    widget.isSeller
                        ? 'Verify Seller Email'
                        : 'Verify Buyer Email',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),

                      // ── Icon ──────────────────────────────────────────────
                      Container(
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
                        child: const Icon(
                          Icons.mark_email_unread_outlined,
                          size: 30,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        widget.isSeller
                            ? 'Verify your\nseller account'
                            : 'Verify your\nbuyer account',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 10),

                      RichText(
                        text: TextSpan(
                          text: 'We sent a 6-digit verification code to\n',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                            height: 1.6,
                          ),
                          children: [
                            TextSpan(
                              text: widget.email,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 36),

                      // ── OTP Pinput ────────────────────────────────────────
                      _buildPinput(),

                      // ── Error Message ─────────────────────────────────────
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.red.shade100),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red.shade400,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 28),

                      // ── Resend row ────────────────────────────────────────
                      Center(
                        child:
                            _start == 0
                                ? GestureDetector(
                                  onTap: _isLoading ? null : _handleResendOTP,
                                  child: RichText(
                                    text: TextSpan(
                                      text: "Didn't receive it? ",
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 13,
                                      ),
                                      children: const [
                                        TextSpan(
                                          text: 'Resend Code',
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
                                        text:
                                            '0:${_start.toString().padLeft(2, '0')}',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                      ),

                      const SizedBox(height: 32),

                      // ── Info card ─────────────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              icon: Icons.schedule_rounded,
                              text: 'The code expires in 10 minutes',
                            ),
                            Divider(
                              height: 20,
                              thickness: 1,
                              color: Colors.grey.shade100,
                            ),
                            _buildInfoRow(
                              icon: Icons.folder_outlined,
                              text:
                                  'Check your spam folder if you don\'t see it',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // ── Verify Button ───────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed:
                      (_isLoading || _otpCode.length != 6)
                          ? null
                          : _handleVerifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _otpCode.length == 6
                            ? Colors.black
                            : Colors.grey.shade300,
                    elevation: 0,
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
                                Colors.white,
                              ),
                            ),
                          )
                          : const Text(
                            'Verify Email',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Pinput ──────────────────────────────────────────────────────────────────
  Widget _buildPinput() {
    final defaultTheme = PinTheme(
      width: 52,
      height: 58,
      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
    );

    final focusedTheme = defaultTheme.copyDecorationWith(
      border: const Border.fromBorderSide(
        BorderSide(color: Colors.black, width: 2),
      ),
      borderRadius: BorderRadius.circular(16),
    );

    final submittedTheme = defaultTheme.copyDecorationWith(
      color: Colors.black,
      border: Border.all(color: Colors.black),
      borderRadius: BorderRadius.circular(16),
    );

    // Override text color for submitted state
    final submittedPinTheme = PinTheme(
      width: 52,
      height: 58,
      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black),
      ),
    );

    return Center(
      child: Pinput(
        length: 6,
        defaultPinTheme: defaultTheme,
        focusedPinTheme: focusedTheme,
        submittedPinTheme: submittedPinTheme,
        pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
        showCursor: true,
        cursor: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              width: 20,
              height: 2,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
        onCompleted: (pin) => setState(() => _otpCode = pin),
        onChanged: (pin) => setState(() => _otpCode = pin),
      ),
    );
  }

  // ── Info row ────────────────────────────────────────────────────────────────
  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: Colors.grey.shade600),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ),
      ],
    );
  }
}
