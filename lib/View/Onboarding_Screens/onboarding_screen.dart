import 'package:afrotierre/View/Onboarding_Screens/create_account_buyer.dart';
import 'package:afrotierre/View/Onboarding_Screens/create_account_seller.dart';
import 'package:afrotierre/View/Onboarding_Screens/sign_in_account_buyer.dart';
import 'package:afrotierre/View/Onboarding_Screens/sign_in_account_seller.dart';
import 'package:afrotierre/constants.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String? selectedWalletType;

  void _onGetStarted() {
    if (selectedWalletType == 'Seller') {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => CreateAccountSellerScreen()));
    } else if (selectedWalletType == 'Buyer') {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => CreateAccountBuyerScreen()));
    }
  }

  void _onSignIn() {
    if (selectedWalletType == 'Seller') {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => SignInAccountSellerScreen(isOnboarding: true,)));
    } else if (selectedWalletType == 'Buyer') {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => SignInAccountBuyerScreen(isOnboarding: true,)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),

              // Logo — cropped to hide the "Wallet" subtitle in the asset
              ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: 0.72, // crops bottom ~28% which is the "Wallet" text
                  child: Image.asset(
                    'assets/splash_logo.png',
                    height: 130,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Welcome to Afrotierre',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose how you want to join us',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),

              const SizedBox(height: 60),

              // Selector cards
              _buildWalletTypeSelector(
                title: 'Buyer',
                subtitle: 'Shop and discover products',
                icon: Icons.shopping_cart_outlined,
                type: 'Buyer',
              ),
              const SizedBox(height: 14),
              _buildWalletTypeSelector(
                title: 'Seller',
                subtitle: 'List and sell your products',
                icon: Icons.storefront_outlined,
                type: 'Seller',
              ),

              const Spacer(),

              // Get Started
              ElevatedButton(
                onPressed: selectedWalletType != null ? _onGetStarted : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: secondaryColor,
                  disabledBackgroundColor: Colors.grey[200],
                  minimumSize: const Size(double.infinity, 56),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: selectedWalletType != null
                        ? primaryColor
                        : Colors.grey[400],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Sign In — text style, not a full outlined button
              OutlinedButton(
                onPressed: selectedWalletType != null ? _onSignIn : null,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  side: BorderSide(
                    color: selectedWalletType != null
                        ? Colors.black
                        : Colors.grey[300]!,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: selectedWalletType != null
                        ? Colors.black
                        : Colors.grey[400],
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletTypeSelector({
    required String title,
    required String subtitle,
    required IconData icon,
    required String type,
  }) {
    final bool isSelected = selectedWalletType == type;

    return GestureDetector(
      onTap: () => setState(() => selectedWalletType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? secondaryColor.withOpacity(0.06) : Colors.white,
          border: Border.all(
            color: isSelected ? secondaryColor : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected ? secondaryColor : Colors.grey[100],
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                size: 24,
                color: isSelected ? primaryColor : Colors.grey[500],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? secondaryColor : Colors.transparent,
                border: Border.all(
                  color: isSelected ? secondaryColor : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check_rounded, size: 13, color: primaryColor)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}