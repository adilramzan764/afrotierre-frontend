import 'package:afrotierre/Models/BuyerModels/BuyerLoginandProfileModels.dart';
import 'package:afrotierre/Repository/BuyerRepository/BuyerLoginProfileRepo.dart';
import 'package:afrotierre/View/Buyers_Screens/add_card_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../Repository/BuyerRepository/BuyerPaymentRepository.dart';
import '../../Services/AppSession.dart';
import '../../res/Widgets/CustomSnackbar.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  List<dynamic> _savedCards = [];
  bool _isLoadingCards = true;
  bool _isProcessing = false;
  String? _selectedCardId;

  @override
  void initState() {
    super.initState();
    _loadSavedCards();
  }

  Future<void> _loadSavedCards() async {
    setState(() => _isLoadingCards = true);
    try {
      if (AppSession.instance.isLoggedIn) {
        final cards = await BuyerPaymentRepository.getPaymentMethods();
        setState(() {
          _savedCards = cards;
          // Auto-select the default card, or the first non-expired card
          final defaultCard = cards.firstWhere(
                (c) => c['isDefault'] == true,
            orElse: () {
              final nonExpired = cards.where((c) => !_isCardExpired(c)).toList();
              return nonExpired.isNotEmpty ? nonExpired[0] : (cards.isNotEmpty ? cards[0] : null);
            },
          );
          if (defaultCard != null) {
            _selectedCardId = defaultCard['id'];
          }
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoadingCards = false);
    }
  }

  /// Returns true if the card's expiry is in the past.
  bool _isCardExpired(dynamic card) {
    try {
      final expMonth = card['expMonth'] as int;
      final expYear = card['expYear'] as int;
      // Card expires at the end of expMonth, so expired when next month begins.
      final expiryDate = DateTime(expYear, expMonth + 1);
      return DateTime.now().isAfter(expiryDate);
    } catch (_) {
      return false;
    }
  }

  Future<void> _removeCard(String cardId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red.shade400,
                  size: 26,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Remove Card',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to remove this card?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  color: Colors.grey[500],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade500,
                        minimumSize: const Size(0, 46),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Remove',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);
    try {
      await BuyerPaymentRepository.removePaymentMethod(cardId);
      // If the removed card was selected, clear selection
      if (_selectedCardId == cardId) {
        setState(() => _selectedCardId = null);
      }
      await _loadSavedCards();
      await _refreshBuyerProfile();
      if (mounted) {
        CustomSnackbar.showSuccess(context, 'Card removed successfully');
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(context, 'Error: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  /// Sets a card as default. Stays on this screen — does NOT navigate away.
  Future<void> _setDefaultCard(String cardId) async {
    setState(() => _isProcessing = true);
    try {
      await BuyerPaymentRepository.setDefaultPaymentMethod(cardId);
      await _loadSavedCards();
      await _refreshBuyerProfile();
      if (mounted) {
        CustomSnackbar.showSuccess(context, 'Default card updated');
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(context, 'Error: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  /// Shows a bottom sheet with actions for a given card.
  void _showCardOptions(dynamic card) {
    final bool isDefault = card['isDefault'] ?? false;
    final bool expired = _isCardExpired(card);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Card summary header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: FaIcon(
                          _getCardIcon((card['brand'] ?? '').toString().toLowerCase()),
                          size: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '•••• •••• •••• ${card['last4']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Expires ${card['expMonth']}/${card['expYear']}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                    if (expired) ...[
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Expired',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.red.shade400,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Divider(height: 16),
              // Set as default (hidden if already default or expired)
              if (!isDefault && !expired)
                ListTile(
                  leading: const Icon(Icons.check_circle_outline_rounded, size: 20),
                  title: const Text('Set as default', style: TextStyle(fontSize: 14)),
                  onTap: () {
                    Navigator.pop(context);
                    _setDefaultCard(card['id']);
                  },
                ),
              // Remove
              ListTile(
                leading: Icon(Icons.delete_outline_rounded,
                    size: 20, color: Colors.red.shade400),
                title: Text(
                  'Remove card',
                  style: TextStyle(fontSize: 14, color: Colors.red.shade400),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _removeCard(card['id']);
                },
              ),
              // Cancel
              ListTile(
                leading: const Icon(Icons.close_rounded, size: 20),
                title: Text('Cancel',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refreshBuyerProfile() async {
    try {
      BuyerLoginProfileRepo repo = BuyerLoginProfileRepo();
      final buyerProfileResponse =
      await repo.getProfile(AppSession.instance.authToken ?? '');
      if (buyerProfileResponse != null && buyerProfileResponse.buyer != null) {
        final freshProfile = buyerProfileResponse.buyer;
        await AppSession.instance.updateBuyerProfile(freshProfile);
        debugPrint('✅ Buyer profile refreshed in AppSession');
      } else {
        debugPrint('⚠️ Failed to get valid buyer profile from API');
      }
    } catch (e) {
      debugPrint('❌ Failed to refresh buyer profile: $e');
    }
  }

  Future<void> _addNewCard() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddCardScreen()),
    );
    if (result == true) {
      await _loadSavedCards();
      await _refreshBuyerProfile();
      if (mounted) {
        CustomSnackbar.showSuccess(context, 'Card added successfully');
      }
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Returns the brand label and last4 of the currently selected card for the
  /// Continue button label, e.g. "Continue with Visa ···· 4242".
  String _continueButtonLabel() {
    if (_selectedCardId == null) return 'Continue';
    final card = _savedCards.firstWhere(
          (c) => c['id'] == _selectedCardId,
      orElse: () => null,
    );
    if (card == null) return 'Continue';
    final brand = _capitalise((card['brand'] ?? '').toString());
    final last4 = card['last4'] ?? '';
    return 'Continue with $brand ···· $last4';
  }

  String _capitalise(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Payment Methods',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      // Non-blocking progress indicator at the top instead of full-screen spinner
      body: Stack(
        children: [
          _isLoadingCards
              ? _buildSkeleton()
              : _savedCards.isEmpty
              ? _buildEmptyState()
              : _buildCardList(),
          if (_isProcessing)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                color: Colors.black,
                minHeight: 2,
              ),
            ),
        ],
      ),
      bottomNavigationBar: _isLoadingCards || _savedCards.isEmpty
          ? null
          : _buildBottomBar(),
    );
  }

  // ── Card List ─────────────────────────────────────────────────────────────

  Widget _buildCardList() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Text(
          '${_savedCards.length} saved card${_savedCards.length == 1 ? '' : 's'}',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 14),
        ..._savedCards.map((card) => _buildCardTile(card)),
      ],
    );
  }

  Widget _buildCardTile(dynamic card) {
    final bool isDefault = card['isDefault'] ?? false;
    final bool isSelected = _selectedCardId == card['id'];
    final bool expired = _isCardExpired(card);
    final String brand = (card['brand'] ?? '').toString().toLowerCase();

    return GestureDetector(
      // Tapping the card selects it (unless expired)
      onTap: expired ? null : () => setState(() => _selectedCardId = card['id']),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: expired
                ? Colors.red.shade100
                : isSelected
                ? Colors.black
                : Colors.transparent,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Brand icon
            Container(
              width: 52,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: FaIcon(
                  _getCardIcon(brand),
                  size: 20,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Card info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '•••• •••• •••• ${card['last4']}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          letterSpacing: 0.5,
                          color: expired ? Colors.grey[400] : Colors.black,
                        ),
                      ),
                      if (isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Default',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Expires ${card['expMonth']}/${card['expYear']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      // Expired badge
                      if (expired) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Expired',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.red.shade400,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Checkmark selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.black : Colors.transparent,
                border: isSelected
                    ? null
                    : Border.all(color: Colors.grey.shade300, width: 1.5),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                  size: 13, color: Colors.white)
                  : null,
            ),

            // Divider + Edit/options button
            Container(
              width: 1,
              height: 28,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              color: Colors.grey.shade200,
            ),
            GestureDetector(
              onTap: () => _showCardOptions(card),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Text(
                  'Edit',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.credit_card_off_outlined,
              size: 40,
              color: Colors.grey[350],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No cards saved',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a card for faster checkout',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
          const SizedBox(height: 28),
          // Inline CTA so users don't have to scroll to the bottom
          ElevatedButton.icon(
            onPressed: _addNewCard,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              minimumSize: const Size(200, 50),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
            label: const Text(
              'Add a Card',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Bar ────────────────────────────────────────────────────────────

  Widget _buildBottomBar() {
    // Resolve the selected card map once for use below
    final dynamic selectedCard = _selectedCardId != null
        ? _savedCards.firstWhere(
          (c) => c['id'] == _selectedCardId,
      orElse: () => null,
    )
        : null;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Continue button — only shown when a valid (non-expired) card is selected
          if (selectedCard != null && !_isCardExpired(selectedCard)) ...[
            ElevatedButton(
              onPressed: _isProcessing
                  ? null
                  : () => Navigator.pop(context, {
                'method': 'Debit or Credit Card',
                'cardId': selectedCard['id'],
                'last4': selectedCard['last4'],
                'brand': selectedCard['brand'],
                'expMonth': selectedCard['expMonth'],
                'expYear': selectedCard['expYear'],
                'isDefault': selectedCard['isDefault'] ?? false,
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                disabledBackgroundColor: Colors.grey[300],
                minimumSize: const Size(double.infinity, 54),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                _continueButtonLabel(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Expired card warning
          if (selectedCard != null && _isCardExpired(selectedCard)) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 16, color: Colors.red.shade400),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This card has expired. Please select or add another card.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.red.shade400,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Add new card button
          OutlinedButton.icon(
            onPressed: _isProcessing ? null : _addNewCard,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            icon: const Icon(Icons.add_rounded, color: Colors.black, size: 18),
            label: const Text(
              'Add New Card',
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Shimmer Skeleton ──────────────────────────────────────────────────────

  Widget _buildSkeleton() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _Shimmer(width: 100, height: 13, radius: 6),
        const SizedBox(height: 14),
        ...List.generate(
          3,
              (_) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                _Shimmer(width: 52, height: 36, radius: 8),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Shimmer(width: 160, height: 15, radius: 6),
                      const SizedBox(height: 6),
                      _Shimmer(width: 90, height: 12, radius: 5),
                    ],
                  ),
                ),
                _Shimmer(width: 22, height: 22, radius: 11),
              ],
            ),
          ),
        ),
      ],
    );
  }

  IconData _getCardIcon(String brand) {
    switch (brand) {
      case 'visa':
        return FontAwesomeIcons.ccVisa;
      case 'mastercard':
        return FontAwesomeIcons.ccMastercard;
      case 'amex':
        return FontAwesomeIcons.ccAmex;
      case 'discover':
        return FontAwesomeIcons.ccDiscover;
      default:
        return FontAwesomeIcons.creditCard;
    }
  }
}

// ── Shimmer Widget ────────────────────────────────────────────────────────────

class _Shimmer extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const _Shimmer({
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _anim = Tween<double>(begin: -1, end: 2).animate(
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
    final base = Colors.grey[200]!;
    final highlight = Colors.grey[100]!;
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          gradient: LinearGradient(
            colors: [base, highlight, base],
            stops: [
              (_anim.value - 0.3).clamp(0.0, 1.0),
              _anim.value.clamp(0.0, 1.0),
              (_anim.value + 0.3).clamp(0.0, 1.0),
            ],
          ),
        ),
      ),
    );
  }
}