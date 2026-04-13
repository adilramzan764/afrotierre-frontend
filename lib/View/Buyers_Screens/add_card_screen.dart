import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../../Repository/BuyerRepository/BuyerPaymentRepository.dart';
import '../../Services/AppSession.dart';
import '../../res/Widgets/CustomSnackbar.dart';
import '../../res/Widgets/SuccessDialog.dart';

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
    // UNCOMMENT THIS LINE - This was causing the issue
    _initializeStripe();
  }

  Future<void> _initializeStripe() async {
    try {
      // Check if Stripe is already initialized
      await Future.delayed(const Duration(milliseconds: 100));
      setState(() {
        _isInitializing = false;
      });
      print('✅ Stripe ready');
    } catch (e) {
      print('Error initializing Stripe: $e');
      if (mounted) {
        CustomSnackbar.showError(
          context,
          'Failed to initialize payment: ${e.toString()}',
        );
      }
      setState(() {
        _isInitializing = false;
      });
    }
  }

  Future<void> _addCard() async {
    if (_cardDetails == null || !(_cardDetails!.complete)) {
      CustomSnackbar.showError(context, 'Please enter complete card details');
      return;
    }

    if (!AppSession.instance.isLoggedIn) {
      CustomSnackbar.showError(context, 'Please login first');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Setup customer
      await BuyerPaymentRepository.setupCustomer();

      // Create payment method
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      // Add to backend
      await BuyerPaymentRepository.addPaymentMethod(
        paymentMethodId: paymentMethod.id,
        setAsDefault: true,
      );

      if (mounted) {
        showSuccessDialog(
          context,
          title: 'Card Added!',
          message: 'Your payment method has been added successfully.',
          buttonText: 'Done',
          onPressed: () => Navigator.pop(context, true),
        );
      }
    } catch (e) {
      print('Error adding card: $e');
      if (mounted) {
        CustomSnackbar.showError(context, 'Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
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