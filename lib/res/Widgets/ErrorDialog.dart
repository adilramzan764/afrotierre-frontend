import 'package:flutter/material.dart';

/// A reusable error dialog matching the app's black & white theme.
void showErrorDialog(
    BuildContext context, {
      required String title,
      required String message,
      String buttonText = 'Try Again',
      VoidCallback? onPressed,
      bool barrierDismissible = false,
    }) {
  showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (_) => ErrorDialog(
      title: title,
      message: message,
      buttonText: buttonText,
      onPressed: onPressed,
    ),
  );
}

class ErrorDialog extends StatefulWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onPressed;

  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.buttonText = 'Try Again',
    this.onPressed,
  });

  @override
  State<ErrorDialog> createState() => _ErrorDialogState();
}

class _ErrorDialogState extends State<ErrorDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePressed() {
    // Navigator.of(context).pop();
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated error icon
              ScaleTransition(
                scale: _controller.drive(
                  Tween<double>(begin: 0.8, end: 1.0).chain(
                    CurveTween(curve: Curves.elasticOut),
                  ),
                ),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    color: Colors.red.shade700,
                    size: 44,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Title
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Message
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Divider
              Divider(color: Colors.grey[200], height: 1),

              const SizedBox(height: 20),

              // Primary button
              FadeTransition(
                opacity: _fadeAnimation,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handlePressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      widget.buttonText,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper function to parse payment error messages
String parsePaymentErrorMessage(dynamic error) {
  final errorMessage = error.toString().toLowerCase();

  if (errorMessage.contains('insufficient funds')) {
    return 'Your card has insufficient funds to complete this payment.';
  } else if (errorMessage.contains('card declined')) {
    return 'Your card was declined. Please try a different payment method.';
  } else if (errorMessage.contains('expired')) {
    return 'Your card has expired. Please update your payment method.';
  } else if (errorMessage.contains('cvv')) {
    return 'Invalid CVV code. Please check your card details.';
  } else if (errorMessage.contains('no payment method')) {
    return 'Please add a payment method in your profile first.';
  } else if (errorMessage.contains('stripe')) {
    return 'Payment processing failed. Please try again or use a different card.';
  }

  // Return generic message for unknown errors
  return 'Payment failed. Please check your payment method and try again.';
}