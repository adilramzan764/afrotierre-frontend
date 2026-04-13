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
          // Auto-select the default card
          final defaultCard = cards.firstWhere(
                (c) => c['isDefault'] == true,
            orElse: () => cards.isNotEmpty ? cards[0] : null,
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
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
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
      await _loadSavedCards();
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

  Future<void> _setDefaultCard(String cardId) async {
    setState(() => _isProcessing = true);
    try {
      await BuyerPaymentRepository.setDefaultPaymentMethod(cardId);
      await _loadSavedCards();
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

  Future<void> _addNewCard() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddCardScreen()),
    );
    if (result == true) {
      await _loadSavedCards();
      if (mounted) {
        CustomSnackbar.showSuccess(context, 'Card added successfully');
      }
    }
  }

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
      body: _isLoadingCards
          ? _buildSkeleton()
          : _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : _savedCards.isEmpty
          ? _buildEmptyState()
          : _buildCardList(),
      bottomNavigationBar: _buildBottomBar(),
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
        ..._savedCards.map((card) => _buildCardTile(card)).toList(),
      ],
    );
  }

  Widget _buildCardTile(dynamic card) {
    final bool isDefault = card['isDefault'] ?? false;
    final bool isSelected = _selectedCardId == card['id'];
    final String brand = (card['brand'] ?? '').toString().toLowerCase();

    return GestureDetector(
      onTap: () => setState(() => _selectedCardId = card['id']),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.transparent,
            width: 1.5,
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
            // Card brand icon container
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
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          letterSpacing: 0.5,
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
                  const SizedBox(height: 3),
                  Text(
                    'Expires ${card['expMonth']}/${card['expYear']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),

            // Actions menu
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'default') _setDefaultCard(card['id']);
                if (value == 'remove') _removeCard(card['id']);
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              itemBuilder: (_) => [
                if (!isDefault)
                  PopupMenuItem(
                    value: 'default',
                    child: Row(
                      children: const [
                        Icon(Icons.check_circle_outline_rounded,
                            size: 16, color: Colors.black),
                        SizedBox(width: 10),
                        Text('Set as default',
                            style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                PopupMenuItem(
                  value: 'remove',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded,
                          size: 16, color: Colors.red.shade400),
                      const SizedBox(width: 10),
                      Text(
                        'Remove',
                        style: TextStyle(
                            fontSize: 13, color: Colors.red.shade400),
                      ),
                    ],
                  ),
                ),
              ],
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.more_horiz_rounded,
                  size: 16,
                  color: Colors.black54,
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
        ],
      ),
    );
  }

  // ── Bottom Bar ────────────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Continue button — only shown when a card is selected
          if (_selectedCardId != null && !_isLoadingCards) ...[
            ElevatedButton(
              onPressed: _isProcessing
                  ? null
                  : () => Navigator.pop(context, {
                'method': 'Debit or Credit Card',
                'cardId': _selectedCardId,
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 54),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 10),
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
            icon: const Icon(
              Icons.add_rounded,
              color: Colors.black,
              size: 18,
            ),
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
                _Shimmer(width: 32, height: 32, radius: 8),
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

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
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