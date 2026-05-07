import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../../Repository/BuyerRepository/BuyerPaymentRepository.dart';
import '../../Services/AppSession.dart';
import '../../res/Widgets/CustomSnackbar.dart';
import '../../res/Widgets/SuccessDialog.dart';
import '../../res/Widgets/ErrorDialog.dart'; // Import your error dialog

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  bool _isLoading = false;
  bool _isInitializing = true;
  CardFieldInputDetails? _cardDetails;

  @override
  void initState() {
    super.initState();
    _initializeStripe();
  }

  Future<void> _initializeStripe() async {
    try {
      // Add a small delay for smooth initialization
      await Future.delayed(const Duration(milliseconds: 100));

      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
      print('✅ Stripe ready');
    } catch (e) {
      print('Error initializing Stripe: $e');
      if (mounted) {
        _showErrorDialog(
          title: 'Initialization Failed',
          message: 'Failed to initialize payment system: ${_extractErrorMessage(e)}',
          buttonText: 'Retry',
          onPressed: () {
            Navigator.pop(context);
            _initializeStripe();
          },
        );
      }
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  Future<void> _addCard() async {
    // Validate card details
    if (_cardDetails == null || !(_cardDetails!.complete)) {
      _showErrorDialog(
        title: 'Incomplete Card Details',
        message: 'Please enter complete card information including card number, expiry date, and CVC.',
        buttonText: 'OK',
      );
      return;
    }

    // Validate login status
    if (!AppSession.instance.isLoggedIn) {
      _showErrorDialog(
        title: 'Login Required',
        message: 'Please login to add a payment method.',
        buttonText: 'Login',
        onPressed: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/login');
        },
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Step 1: Setup customer
      try {
        await BuyerPaymentRepository.setupCustomer();
      } catch (e) {
        String errorMsg = e.toString();
        // If customer already exists, continue (this is fine)
        if (!errorMsg.contains('already exists')) {
          throw 'Failed to setup payment: ${_extractErrorMessage(e)}';
        }
      }

      // Step 2: Create payment method with Stripe
      dynamic paymentMethod;
      try {
        paymentMethod = await Stripe.instance.createPaymentMethod(
          params: PaymentMethodParams.card(
            paymentMethodData: PaymentMethodData(),
          ),
        );
      } catch (e) {
        throw _extractStripeErrorMessage(e);
      }

      // Step 3: Add to backend
      try {
        await BuyerPaymentRepository.addPaymentMethod(
          paymentMethodId: paymentMethod.id,
          setAsDefault: true,
        );
      } catch (e) {
        // This is where "Your card was declined" will come from
        throw _extractErrorMessage(e);
      }

      // Success
      if (mounted) {
        showSuccessDialog(
          context,
          title: 'Card Added! 💳',
          message: 'Your payment method has been added successfully.',
          buttonText: 'Done',
          onPressed: () => Navigator.pop(context, true),
        );
      }
    } catch (e) {
      print('Error adding card: $e');
      if (mounted) {
        String errorMessage = e.toString();
        _handleAddCardError(errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleAddCardError(String errorMessage) {
    String title = 'Failed to Add Card';
    String displayMessage = errorMessage;
    String buttonText = 'Try Again';
    VoidCallback? onPressed;

    // Clean up the error message
    displayMessage = displayMessage
        .replaceAll('Exception:', '')
        .replaceAll('Failed to save payment method:', '')
        .replaceAll('Failed to add payment method:', '')
        .trim();

    // Specific error handling based on the message
    if (displayMessage.toLowerCase().contains('declined')) {
      title = 'Card Declined';
      displayMessage = 'Your card was declined by the bank. Please try a different card or contact your bank.';
      buttonText = 'Try Different Card';
      onPressed = () {
        Navigator.pop(context);
        // Stay on the same screen to try another card
      };
    }
    else if (displayMessage.toLowerCase().contains('insufficient funds')) {
      title = 'Insufficient Funds';
      displayMessage = 'Your card has insufficient funds. Please use a different payment method.';
      buttonText = 'OK';
    }
    else if (displayMessage.toLowerCase().contains('invalid') &&
        displayMessage.toLowerCase().contains('number')) {
      title = 'Invalid Card Number';
      displayMessage = 'The card number you entered is invalid. Please check and try again.';
      buttonText = 'OK';
    }
    else if (displayMessage.toLowerCase().contains('expired')) {
      title = 'Card Expired';
      displayMessage = 'Your card has expired. Please use a valid card.';
      buttonText = 'OK';
    }
    else if (displayMessage.toLowerCase().contains('cvc') ||
        displayMessage.toLowerCase().contains('security code')) {
      title = 'Invalid Security Code';
      displayMessage = 'The CVC/Security code you entered is invalid.';
      buttonText = 'OK';
    }
    else if (displayMessage.toLowerCase().contains('network') ||
        displayMessage.toLowerCase().contains('connection')) {
      title = 'Network Error';
      displayMessage = 'Unable to connect to server. Please check your internet connection and try again.';
      buttonText = 'Retry';
      onPressed = () => _addCard();
    }
    else if (displayMessage.toLowerCase().contains('authentication') ||
        displayMessage.toLowerCase().contains('login')) {
      title = 'Session Expired';
      displayMessage = 'Your session has expired. Please login again.';
      buttonText = 'Login';
      onPressed = () {
        Navigator.pop(context);
        Navigator.pushNamed(context, '/login');
      };
    }
    else if (displayMessage.toLowerCase().contains('3d secure')) {
      title = '3D Secure Required';
      displayMessage = 'This card requires 3D Secure authentication. Please try again or use a different card.';
      buttonText = 'Try Again';
      onPressed = () => _addCard();
    }

    _showErrorDialog(
      title: title,
      message: displayMessage,
      buttonText: buttonText,
      onPressed: onPressed,
    );
  }

  String _extractErrorMessage(dynamic error) {
    String errorString = error.toString();

    // Remove common prefixes
    errorString = errorString
        .replaceAll('Exception:', '')
        .replaceAll('Error:', '')
        .replaceAll('Failed to add payment method:', '')
        .replaceAll('Failed to save payment method:', '')
        .trim();

    // If the error contains the backend message format
    if (errorString.contains('Your card was declined')) {
      return 'Your card was declined';
    }

    // If the error contains the full "Failed to attach payment method" message
    if (errorString.contains('Failed to attach payment method:')) {
      // Extract the part after the colon
      final parts = errorString.split(':');
      if (parts.length > 1) {
        return parts.last.trim();
      }
    }

    return errorString.isEmpty ? 'An unknown error occurred' : errorString;
  }

  String _extractStripeErrorMessage(dynamic error) {
    String errorString = error.toString();

    // Common Stripe error patterns
    if (errorString.contains('Your card has insufficient funds')) {
      return 'Insufficient funds on card';
    }
    if (errorString.contains('Your card was declined')) {
      return 'Card was declined';
    }
    if (errorString.contains('Invalid card number')) {
      return 'Invalid card number';
    }
    if (errorString.contains('Card expired')) {
      return 'Card has expired';
    }
    if (errorString.contains('Incorrect CVC')) {
      return 'Incorrect security code (CVC)';
    }

    // Remove Stripe-specific prefixes
    errorString = errorString
        .replaceAll('StripeException:', '')
        .replaceAll('Exception:', '')
        .trim();

    return errorString.isEmpty ? 'Payment method creation failed' : errorString;
  }

  void _showErrorDialog({
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  color: Colors.red.shade700,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onPressed ?? () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(buttonText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Add Card',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade100, height: 1),
        ),
      ),
      body: _isInitializing
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Visual card preview header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black,
                    Colors.grey.shade900,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'New Card',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(
                        Icons.credit_card_rounded,
                        color: Colors.white.withOpacity(0.7),
                        size: 28,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    '**** **** **** ****',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'CARD HOLDER',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 9,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'YOUR NAME',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'EXPIRES',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 9,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'MM / YY',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Card Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Enter your card information below',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 20),
            // Stripe unified card field
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: CardField(
                onCardChanged: (details) {
                  setState(() => _cardDetails = details);
                },
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  fillColor: Colors.transparent,
                  filled: true,
                  hintStyle: TextStyle(color: Colors.grey[400]),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Security note
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 15,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your card details are encrypted and never stored on our servers.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.grey[500],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButtons(),
    );
  }

  Widget _buildBottomButtons() {
    final bool cardComplete = _cardDetails?.complete ?? false;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: (_isLoading || !cardComplete) ? null : _addCard,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                disabledBackgroundColor: Colors.grey[200],
                minimumSize: const Size(0, 52),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : Text(
                'Add Card',
                style: TextStyle(
                  color: cardComplete ? Colors.white : Colors.grey[400],
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}