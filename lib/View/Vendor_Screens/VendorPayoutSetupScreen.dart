import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:afrotierre/Repository/SellerRepository/SellerPayoutRepository.dart';
import 'package:afrotierre/Models/SellerModels/SellerPayoutModels.dart';

import '../../res/Widgets/CustomSnackbar.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DESIGN TOKENS
// ─────────────────────────────────────────────────────────────────────────────

class AppTokens {
  // Spacing (8px grid)
  static const double s2 = 2;
  static const double s4 = 4;
  static const double s6 = 6;
  static const double s8 = 8;
  static const double s10 = 10;
  static const double s12 = 12;
  static const double s14 = 14;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s28 = 28;
  static const double s32 = 32;

  // Radii
  static const double r8 = 8;
  static const double r10 = 10;
  static const double r12 = 12;
  static const double r14 = 14;
  static const double r16 = 16;
  static const double r20 = 20;
  static const double r24 = 24;
  static const double rFull = 100;

  // Colors
  static const Color dark = Color(0xFF1A1A2E);
  static const Color darkMid = Color(0xFF16213E);
  static const Color surface = Colors.white;
  static const Color bg = Color(0xFFF5F5F7);
}

// ─────────────────────────────────────────────────────────────────────────────
// ENUMS
// ─────────────────────────────────────────────────────────────────────────────

enum ScreenState { loading, loaded, error }

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN 1: PAYOUT SETUP SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class PayoutSetupScreen extends StatefulWidget {
  const PayoutSetupScreen({super.key});

  @override
  State<PayoutSetupScreen> createState() => _PayoutSetupScreenState();
}

class _PayoutSetupScreenState extends State<PayoutSetupScreen> {
  final SellerPayoutRepository _payoutRepository = SellerPayoutRepository();

  // State variables
  StripeAccountStatus _stripeStatus = StripeAccountStatus.notConnected;
  ScreenState _screenState = ScreenState.loading;
  String? _errorMessage;
  String? _maskedBankAccount;
  String? _country;
  String _currency = 'USD';
  double _minimumWithdrawal = 10;
  double _availableBalance = 0;
  double _pendingBalance = 0;
  double _effectiveBalance = 0;

  int _expandedFaq = -1;

  // WebView controller for Stripe onboarding
  bool _isWebViewOpen = false;

  // ── FAQ content ────────────────────────────────────────────────────────────
  final List<Map<String, String>> _faqs = [
    {
      'q': 'Why do I need to connect Stripe?',
      'a': 'Stripe is our secure payment processor. Connecting your account allows us to transfer your earnings directly to your bank account with bank-grade security and compliance.',
    },
    {
      'q': 'How long does verification take?',
      'a': 'Stripe verification typically takes 1–2 business days. You may be asked to provide a government-issued ID and tax identification number.',
    },
    {
      'q': 'When do I receive my payments?',
      'a': 'Once your account is verified and active, payouts are processed within 1–3 business days after each successful order.',
    },
    {
      'q': 'Are there any fees?',
      'a': 'Our platform charges a commission per sale (visible in your dashboard). Stripe standard payout is free; instant payout may include a small Stripe fee.',
    },
    {
      'q': 'Can I change my bank account later?',
      'a': 'Yes. Tap "Manage Payout Account" to update your bank details through Stripe\'s secure dashboard at any time.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadPayoutStatus();
  }

  Future<void> _loadPayoutStatus() async {
    setState(() {
      _screenState = ScreenState.loading;
      _errorMessage = null;
    });

    try {
      final response = await _payoutRepository.getPayoutStatus();

      setState(() {
        _stripeStatus = response.stripeAccountStatus;
        _maskedBankAccount = '•••• ${response.wallet.availableBalance.toStringAsFixed(0)}';
        _country = 'United States';
        _currency = response.wallet.currency;
        _minimumWithdrawal = response.minimumWithdrawal;
        _availableBalance = response.wallet.availableBalance;
        _pendingBalance = response.wallet.pendingBalance;
        _effectiveBalance = response.wallet.effectiveAvailableBalance;
        _screenState = ScreenState.loaded;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _screenState = ScreenState.error;
      });
      CustomSnackbar.showError(context, 'Failed to load payout status: $e');
    }
  }

  Future<void> _handleConnectStripe() async {
    setState(() {
      _screenState = ScreenState.loading;
    });

    try {
      final response = await _payoutRepository.createStripeConnectAccount();

      if (response.onboardingUrl.isNotEmpty && mounted) {
        _openStripeOnboarding(response.onboardingUrl);
      }

      setState(() {
        _screenState = ScreenState.loaded;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _screenState = ScreenState.error;
      });
      CustomSnackbar.showError(context, 'Failed to connect Stripe: $e');
    }
  }

  Future<void> _handleCompleteVerification() async {
    setState(() {
      _screenState = ScreenState.loading;
    });

    try {
      final onboardingUrl = await _payoutRepository.getOnboardingLink();

      if (onboardingUrl.isNotEmpty && mounted) {
        _openStripeOnboarding(onboardingUrl);
      }

      setState(() {
        _screenState = ScreenState.loaded;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _screenState = ScreenState.error;
      });
      CustomSnackbar.showError(context, 'Failed to get onboarding link: $e');
    }
  }

  void _openStripeOnboarding(String url) {
    setState(() {
      _isWebViewOpen = true;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StripeOnboardingWebView(
          url: url,
          onComplete: () {
            _loadPayoutStatus();
            setState(() {
              _isWebViewOpen = false;
            });
          },
        ),
      ),
    ).then((_) {
      setState(() {
        _isWebViewOpen = false;
      });
      _loadPayoutStatus();
    });
  }
  void _handleManagePayoutAccount() async {
    setState(() {
      _screenState = ScreenState.loading;
    });

    try {
      // Get the onboarding link for the existing account
      final onboardingUrl = await _payoutRepository.getOnboardingLink();

      if (onboardingUrl.isNotEmpty && mounted) {
        _openStripeOnboarding(onboardingUrl);
      }

      setState(() {
        _screenState = ScreenState.loaded;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _screenState = ScreenState.error;
      });
      CustomSnackbar.showError(context, 'Failed to get account management link: $e');
    }
  }

  int get _stepIndex {
    switch (_stripeStatus) {
      case StripeAccountStatus.notConnected:
        return 0;
      case StripeAccountStatus.pending:
        return 1;
      case StripeAccountStatus.active:
        return 2;
      case StripeAccountStatus.restricted:
      case StripeAccountStatus.error:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.bg,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  // ─────────────────────────────────────────────
  // APP BAR
  // ─────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Payout Setup',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: Colors.grey.shade200),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // BODY
  // ─────────────────────────────────────────────
  Widget _buildBody() {
    if (_screenState == ScreenState.loading && !_isWebViewOpen) {
      return _buildSkeleton();
    }

    return RefreshIndicator(
      color: Colors.black,
      onRefresh: _loadPayoutStatus,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppTokens.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subtitle
            Text(
              'Complete setup before receiving earnings',
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
            const SizedBox(height: AppTokens.s20),

            // Error banner
            if (_screenState == ScreenState.error && _errorMessage != null) ...[
              _buildErrorBanner(),
              const SizedBox(height: AppTokens.s16),
            ],

            // Balance Card
            _buildBalanceCard(),
            const SizedBox(height: AppTokens.s16),

            // Step progress
            _buildStepIndicator(),
            const SizedBox(height: AppTokens.s20),

            // Stripe Status Card
            _buildStripeStatusCard(),
            const SizedBox(height: AppTokens.s16),

            // Action Buttons (conditional)
            _buildActionButtons(),
            const SizedBox(height: AppTokens.s28),

            // Info Cards
            const _SectionTitle('Payment Details'),
            const SizedBox(height: AppTokens.s12),
            _buildInfoCards(),
            const SizedBox(height: AppTokens.s28),

            // Security Notice
            _buildSecurityNotice(),
            const SizedBox(height: AppTokens.s28),

            // FAQ
            const _SectionTitle('Frequently Asked Questions'),
            const SizedBox(height: AppTokens.s12),
            _buildFaqSection(),
            const SizedBox(height: AppTokens.s32),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // BALANCE CARD
  // ─────────────────────────────────────────────
  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(AppTokens.s16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTokens.dark, AppTokens.darkMid],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTokens.r16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Available Balance',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: AppTokens.s8),
          Text(
            '\$${_effectiveBalance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTokens.s12),
          Row(
            children: [
              _buildBalanceChip('Pending', _pendingBalance, Colors.orange),
              const SizedBox(width: AppTokens.s12),
              _buildBalanceChip('Min. Withdrawal', _minimumWithdrawal, Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceChip(String label, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.s10, vertical: AppTokens.s6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppTokens.rFull),
      ),
      child: Text(
        '$label: \$${amount.toStringAsFixed(2)}',
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // SKELETON LOADER
  // ─────────────────────────────────────────────
  Widget _buildSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTokens.s16),
      child: Column(
        children: [
          const _SkeletonBox(height: 110),
          const SizedBox(height: AppTokens.s16),
          const _SkeletonBox(height: 72),
          const SizedBox(height: AppTokens.s16),
          const _SkeletonBox(height: 150),
          const SizedBox(height: AppTokens.s12),
          const _SkeletonBox(height: 52),
          const SizedBox(height: AppTokens.s12),
          const _SkeletonBox(height: 52),
          const SizedBox(height: AppTokens.s24),
          ...List.generate(4, (_) => const Padding(
            padding: EdgeInsets.only(bottom: AppTokens.s10),
            child: _SkeletonBox(height: 56),
          )),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // STEP INDICATOR
  // ─────────────────────────────────────────────
  Widget _buildStepIndicator() {
    final steps = ['Connect', 'Verify', 'Active'];
    final currentStep = _stepIndex;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppTokens.s16, horizontal: AppTokens.s20),
      decoration: BoxDecoration(
        color: AppTokens.surface,
        borderRadius: BorderRadius.circular(AppTokens.r14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final passed = (i ~/ 2) < currentStep;
            return Expanded(
              child: Container(
                height: 2,
                color: passed ? AppTokens.dark : Colors.grey.shade200,
              ),
            );
          }
          final idx = i ~/ 2;
          final done = idx < currentStep;
          final active = idx == currentStep;
          return Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done || active ? AppTokens.dark : Colors.grey.shade200,
                ),
                child: Center(
                  child: done
                      ? const Icon(Icons.check, color: Colors.white, size: 15)
                      : Text('${idx + 1}',
                      style: TextStyle(
                          color: active ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                ),
              ),
              const SizedBox(height: 5),
              Text(steps[idx],
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: active ? FontWeight.bold : FontWeight.normal,
                      color: active ? Colors.black : Colors.grey)),
            ],
          );
        }),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // STRIPE STATUS CARD
  // ─────────────────────────────────────────────
  Widget _buildStripeStatusCard() {
    final status = _stripeStatus;

    String getTitle() {
      switch (status) {
        case StripeAccountStatus.notConnected:
          return 'Not Connected';
        case StripeAccountStatus.pending:
          return 'Pending Verification';
        case StripeAccountStatus.active:
          return 'Account Active';
        case StripeAccountStatus.restricted:
          return 'Account Restricted';
        case StripeAccountStatus.error:
          return 'Connection Error';
      }
    }

    String getDescription() {
      switch (status) {
        case StripeAccountStatus.notConnected:
          return 'Connect your bank account via Stripe to start receiving payouts.';
        case StripeAccountStatus.pending:
          return 'Your account is under review. Verification takes 1–2 business days.';
        case StripeAccountStatus.active:
          return 'Your payout account is verified and ready to receive funds.';
        case StripeAccountStatus.restricted:
          return 'Your account has been restricted. Please resolve outstanding issues.';
        case StripeAccountStatus.error:
          return 'There was an error connecting to Stripe. Please try again.';
      }
    }

    IconData getIcon() {
      switch (status) {
        case StripeAccountStatus.notConnected:
          return Icons.link_off_rounded;
        case StripeAccountStatus.pending:
          return Icons.hourglass_top_rounded;
        case StripeAccountStatus.active:
          return Icons.check_circle_rounded;
        case StripeAccountStatus.restricted:
          return Icons.block_rounded;
        case StripeAccountStatus.error:
          return Icons.error_rounded;
      }
    }

    Color getColor() {
      switch (status) {
        case StripeAccountStatus.active:
          return Colors.green;
        case StripeAccountStatus.pending:
          return Colors.orange;
        case StripeAccountStatus.restricted:
          return Colors.red;
        case StripeAccountStatus.error:
          return Colors.red;
        case StripeAccountStatus.notConnected:
          return Colors.grey;
      }
    }

    final color = getColor();

    return Container(
      padding: const EdgeInsets.all(AppTokens.s20),
      decoration: BoxDecoration(
        color: AppTokens.surface,
        borderRadius: BorderRadius.circular(AppTokens.r16),
        border: Border.all(color: color.withOpacity(0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTokens.r12),
                ),
                child: Icon(getIcon(), color: color, size: 22),
              ),
              const SizedBox(width: AppTokens.s12),
              Expanded(
                child: Text(
                  getTitle(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              _buildStatusBadge(getTitle().split(' ').first, color),
            ],
          ),
          const SizedBox(height: AppTokens.s12),
          Text(
            getDescription(),
            style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.5),
          ),
          if (status == StripeAccountStatus.active && _maskedBankAccount != null) ...[
            const SizedBox(height: AppTokens.s12),
            Divider(color: Colors.grey.shade100, height: 1),
            const SizedBox(height: AppTokens.s12),
            Row(
              children: [
                _buildDetailChip(Icons.credit_card_outlined, 'Bank: $_maskedBankAccount'),
                const SizedBox(width: AppTokens.s8),
                if (_country != null) _buildDetailChip(Icons.public_outlined, _country!),
                const SizedBox(width: AppTokens.s8),
                _buildDetailChip(Icons.attach_money_rounded, _currency),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(AppTokens.r8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.s10, vertical: AppTokens.s4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppTokens.rFull),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // ACTION BUTTONS (conditional on status)
  // ─────────────────────────────────────────────
  Widget _buildActionButtons() {
    final status = _stripeStatus;

    return Column(
      children: [
        if (status == StripeAccountStatus.notConnected)
          _buildPrimaryButton(
            label: 'Connect Stripe Account',
            icon: Icons.link_rounded,
            onTap: _handleConnectStripe,
          ),

        if (status == StripeAccountStatus.pending) ...[
          _buildPrimaryButton(
            label: 'Complete Verification',
            icon: Icons.verified_user_outlined,
            onTap: _handleCompleteVerification,
            color: Colors.orange.shade700,
          ),
          const SizedBox(height: AppTokens.s10),
          _buildSecondaryButton(
            label: 'Manage Payout Account',
            icon: Icons.manage_accounts_outlined,
            onTap: _handleManagePayoutAccount,
          ),
        ],

        if (status == StripeAccountStatus.active)
          _buildSecondaryButton(
            label: 'Manage Payout Account',
            icon: Icons.manage_accounts_outlined,
            onTap: _handleManagePayoutAccount,
          ),

        if (status == StripeAccountStatus.restricted)
          _buildPrimaryButton(
            label: 'Fix Account Issues',
            icon: Icons.build_outlined,
            onTap: _handleCompleteVerification,
            color: Colors.red.shade700,
          ),

        if (status == StripeAccountStatus.error)
          _buildPrimaryButton(
            label: 'Retry Connection',
            icon: Icons.refresh_rounded,
            onTap: _handleConnectStripe,
          ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    Color color = AppTokens.dark,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.r14)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: AppTokens.s8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: Colors.black),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          side: const BorderSide(color: Colors.black),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.r14)),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // INFO CARDS
  // ─────────────────────────────────────────────
  Widget _buildInfoCards() {
    return Column(
      children: [
        _buildInfoItemCard(
          icon: Icons.public_outlined,
          iconColor: Colors.blue,
          label: 'Supported Countries',
          value: 'US, UK, EU & 40+',
        ),
        const SizedBox(height: AppTokens.s8),
        _buildInfoItemCard(
          icon: Icons.attach_money_rounded,
          iconColor: Colors.green,
          label: 'Currency',
          value: _currency,
        ),
        const SizedBox(height: AppTokens.s8),
        _buildInfoItemCard(
          icon: Icons.schedule_outlined,
          iconColor: Colors.orange,
          label: 'Estimated Transfer Time',
          value: '1–3 business days',
        ),
        const SizedBox(height: AppTokens.s8),
        _buildInfoItemCard(
          icon: Icons.percent_rounded,
          iconColor: Colors.purple,
          label: 'Platform Commission',
          value: '7% per sale',
        ),
      ],
    );
  }

  Widget _buildInfoItemCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.s16, vertical: AppTokens.s14),
      decoration: BoxDecoration(
        color: AppTokens.surface,
        borderRadius: BorderRadius.circular(AppTokens.r14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTokens.r10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: AppTokens.s12),
          Expanded(
            child: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // SECURITY NOTICE
  // ─────────────────────────────────────────────
  Widget _buildSecurityNotice() {
    return Container(
      padding: const EdgeInsets.all(AppTokens.s16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppTokens.r14),
        border: Border.all(color: Colors.blue.withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined, color: Colors.blue, size: 20),
          const SizedBox(width: AppTokens.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Security Notice',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blue)),
                const SizedBox(height: AppTokens.s6),
                Text(
                  'All payouts are processed securely via Stripe. We never store your full bank details. Data is encrypted under PCI-DSS Level 1 compliance.',
                  style: TextStyle(color: Colors.blue[600], fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // FAQ SECTION
  // ─────────────────────────────────────────────
  Widget _buildFaqSection() {
    return _buildCardWrapper(
      child: Column(
        children: List.generate(_faqs.length, (i) {
          final isLast = i == _faqs.length - 1;
          return Column(
            children: [
              _buildFaqTile(
                question: _faqs[i]['q']!,
                answer: _faqs[i]['a']!,
                isExpanded: _expandedFaq == i,
                onTap: () => setState(() => _expandedFaq = _expandedFaq == i ? -1 : i),
              ),
              if (!isLast) _buildCardDivider(),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildFaqTile({
    required String question,
    required String answer,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(question, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 20),
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: isExpanded
                  ? Padding(
                padding: const EdgeInsets.only(top: AppTokens.s10),
                child: Text(answer, style: TextStyle(color: Colors.grey[600], fontSize: 12, height: 1.6)),
              )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // ERROR BANNER
  // ─────────────────────────────────────────────
  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(AppTokens.s16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.07),
        borderRadius: BorderRadius.circular(AppTokens.r12),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: AppTokens.s10),
          Expanded(
            child: Text(_errorMessage!, style: TextStyle(color: Colors.red[700], fontSize: 13)),
          ),
          TextButton(
            onPressed: _loadPayoutStatus,
            child: const Text('Retry', style: TextStyle(color: Colors.red, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // HELPER WIDGETS
  // ─────────────────────────────────────────────
  Widget _buildCardWrapper({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTokens.surface,
        borderRadius: BorderRadius.circular(AppTokens.r16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildCardDivider() => Divider(
    height: 1,
    indent: AppTokens.s16,
    endIndent: AppTokens.s16,
    color: Colors.grey.shade100,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// STRIPE ONBOARDING WEBVIEW
// ─────────────────────────────────────────────────────────────────────────────

class StripeOnboardingWebView extends StatefulWidget {
  final String url;
  final VoidCallback onComplete;

  const StripeOnboardingWebView({
    super.key,
    required this.url,
    required this.onComplete,
  });

  @override
  State<StripeOnboardingWebView> createState() => _StripeOnboardingWebViewState();
}

class _StripeOnboardingWebViewState extends State<StripeOnboardingWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _error = null;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });

            // Check if onboarding is complete (redirected to return URL)
            if (url.contains('success=true') || url.contains('return_url')) {
              widget.onComplete();
              Navigator.pop(context);
              CustomSnackbar.showSuccess(context, 'Stripe account connected successfully!');
            }
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _error = error.description;
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            // Allow all navigation
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
            widget.onComplete();
          },
        ),
        title: const Text(
          'Connect Stripe Account',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.black),
                    SizedBox(height: 16),
                    Text(
                      'Loading secure connection...',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          if (_error != null)
            Center(
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.withOpacity(0.2)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load',
                      style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _error = null;
                          _isLoading = true;
                        });
                        _initWebView();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPER WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const _SectionTitle(this.title, {this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black87),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const _SkeletonBox({
    this.width = double.infinity,
    required this.height,
    this.radius = AppTokens.r12,
  });

  @override
  State<_SkeletonBox> createState() => __SkeletonBoxState();
}

class __SkeletonBoxState extends State<_SkeletonBox> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.9).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(_anim.value * 0.3),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}