import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:afrotierre/Repository/SellerRepository/SellerPayoutRepository.dart';
import 'package:afrotierre/Models/SellerModels/SellerPayoutModels.dart';

import '../../res/Widgets/CustomSnackbar.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN 2: Earnings & Withdrawals
// Purpose: Day-to-day money management — view balances, withdraw, see history
// ─────────────────────────────────────────────────────────────────────────────

class EarningsWithdrawalsScreen extends StatefulWidget {
  const EarningsWithdrawalsScreen({super.key});

  @override
  State<EarningsWithdrawalsScreen> createState() =>
      _EarningsWithdrawalsScreenState();
}

class _EarningsWithdrawalsScreenState
    extends State<EarningsWithdrawalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _amountController = TextEditingController();
  bool _isProcessing = false;
  bool _isLoading = true;
  String? _error;

  // Repository
  final SellerPayoutRepository _payoutRepository = SellerPayoutRepository();

  // Data from API
  PayoutStatusResponse? _payoutStatus;
  WithdrawalHistoryResponse? _withdrawalHistory;
  List<Withdrawal> _withdrawals = [];
  List<PayoutTransaction> _transactions = [];

  // Monthly earnings calculation
  List<Map<String, dynamic>> _monthlyEarnings = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load payout status
      final status = await _payoutRepository.getPayoutStatus();

      // Load withdrawal history
      final history = await _payoutRepository.getWithdrawalHistory(limit: 20);

      // Load transactions
      final transactions = await _payoutRepository.getPayoutTransactionHistory(limit: 20);

      // Calculate monthly earnings from transactions
      _calculateMonthlyEarnings(transactions.transactions);

      setState(() {
        _payoutStatus = status;
        _withdrawalHistory = history;
        _withdrawals = history.withdrawals;
        _transactions = transactions.transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      CustomSnackbar.showError(context, 'Failed to load data: $e');
    }
  }

  void _calculateMonthlyEarnings(List<PayoutTransaction> transactions) {
    final Map<String, double> monthlyMap = {};
    final now = DateTime.now();

    // Get last 6 months
    for (int i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final monthKey = '${date.month}/${date.year}';
      final monthName = _getMonthAbbr(date.month);
      monthlyMap[monthKey] = 0;
      _monthlyEarnings.add({
        'month': monthName,
        'amount': 0.0,
        'key': monthKey,
      });
    }

    // Aggregate earnings from completed sales
    for (final transaction in transactions) {
      if ((transaction.type == PayoutTransactionType.sale ||
          transaction.type == PayoutTransactionType.saleAvailable) &&
          transaction.status == 'completed') {
        final date = transaction.createdAt;
        final monthKey = '${date.month}/${date.year}';

        // Find if this month is in our list
        final index = _monthlyEarnings.indexWhere((m) => m['key'] == monthKey);
        if (index != -1) {
          _monthlyEarnings[index]['amount'] = (_monthlyEarnings[index]['amount'] as double) + transaction.netAmount;
        }
      }
    }
  }

  String _getMonthAbbr(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  double get _availableBalance => _payoutStatus?.wallet.effectiveAvailableBalance ?? 0;
  double get _pendingBalance => _payoutStatus?.wallet.pendingBalance ?? 0;
  double get _negativeBalance => _payoutStatus?.wallet.negativeBalance ?? 0;
  String get _nextPayoutDate {
    final date = _payoutStatus?.nextEligiblePayoutDate;
    if (date == null) return 'No pending payouts';
    return _formatDate(date);
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  void _setQuickAmount(double percentage) {
    final amount = _availableBalance * percentage;
    _amountController.text = amount.toStringAsFixed(2);
  }

  Future<void> _handleWithdraw() async {
    final text = _amountController.text.trim();
    if (text.isEmpty) {
      CustomSnackbar.showWarning(context, 'Please enter a withdrawal amount.');
      return;
    }

    final amount = double.tryParse(text);
    if (amount == null || amount <= 0) {
      CustomSnackbar.showWarning(context, 'Please enter a valid amount.');
      return;
    }

    final minWithdrawal = _payoutStatus?.minimumWithdrawal ?? 10;
    if (amount < minWithdrawal) {
      CustomSnackbar.showWarning(context, 'Minimum withdrawal amount is \$${minWithdrawal.toStringAsFixed(2)}');
      return;
    }

    if (amount > _availableBalance) {
      CustomSnackbar.showWarning(context, 'Amount exceeds available balance.');
      return;
    }

    // Show confirmation dialog
    final confirmed = await _showWithdrawalConfirmation(amount);
    if (!confirmed) return;

    setState(() => _isProcessing = true);

    try {
      final response = await _payoutRepository.requestWithdrawal(
        amount: amount,
        paymentMethod: 'bank_transfer',
        accountDetails: {
          'note': 'Manual withdrawal request',
        },
      );

      if (mounted) {
        _amountController.clear();
        _showSuccessSheet(amount);
        await _loadData(); // Refresh balances
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(context, 'Withdrawal failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<bool> _showWithdrawalConfirmation(double amount) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Withdrawal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amount: \$${amount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            const Text(
              'Funds will be sent to your connected bank account.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Estimated arrival: 1-3 business days',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showSuccessSheet(double amount) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: Colors.green, size: 40),
            ),
            const SizedBox(height: 16),
            const Text('Withdrawal Submitted!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              '\$${amount.toStringAsFixed(2)} will arrive in 1–3 business days.',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Done',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Earnings & Withdrawals',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: Colors.black,
        child: _isLoading
            ? _buildSkeleton()
            : _error != null
            ? _buildErrorWidget()
            : SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance cards
              _buildBalanceSection(),
              const SizedBox(height: 24),

              // Next payout date
              _buildNextPayoutBanner(),
              const SizedBox(height: 24),

              // Withdraw section
              _buildSectionTitle('Withdraw Funds'),
              const SizedBox(height: 12),
              _buildWithdrawSection(),
              const SizedBox(height: 28),

              // Monthly analytics
              _buildSectionTitle('Monthly Earnings'),
              const SizedBox(height: 12),
              _buildMonthlyAnalytics(),
              const SizedBox(height: 28),

              // History tabs
              _buildSectionTitle('History'),
              const SizedBox(height: 12),
              _buildHistorySection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _SkeletonBox(height: 140),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _SkeletonBox(height: 100)),
              const SizedBox(width: 10),
              Expanded(child: _SkeletonBox(height: 100)),
            ],
          ),
          const SizedBox(height: 24),
          _SkeletonBox(height: 50),
          const SizedBox(height: 24),
          _SkeletonBox(height: 200),
          const SizedBox(height: 28),
          _SkeletonBox(height: 200),
          const SizedBox(height: 28),
          _SkeletonBox(height: 300),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red[300], size: 64),
          const SizedBox(height: 16),
          Text(
            'Failed to load data',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unknown error',
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // BALANCE SECTION (3 cards)
  // ─────────────────────────────────────────────
  Widget _buildBalanceSection() {
    return Column(
      children: [
        // Main available balance
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Available Balance',
                      style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 13)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Ready to withdraw',
                        style: TextStyle(color: Colors.greenAccent, fontSize: 10)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '\$${_availableBalance.toStringAsFixed(2)}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5),
              ),
              const SizedBox(height: 4),
              Text('Last updated: Today',
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildSmallBalanceCard(
                label: 'Pending',
                amount: _pendingBalance,
                icon: Icons.hourglass_top_rounded,
                color: Colors.orange,
                tooltip: 'Being processed',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildSmallBalanceCard(
                label: 'Negative',
                amount: _negativeBalance.abs(),
                icon: Icons.trending_down_rounded,
                color: _negativeBalance < 0 ? Colors.red : Colors.grey,
                tooltip: _negativeBalance < 0 ? 'Owed amount' : 'None',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallBalanceCard({
    required String label,
    required double amount,
    required IconData icon,
    required Color color,
    required String tooltip,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 14),
              ),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),
          Text('\$${amount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 2),
          Text(tooltip, style: TextStyle(color: Colors.grey[400], fontSize: 10)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // NEXT PAYOUT BANNER
  // ─────────────────────────────────────────────
  Widget _buildNextPayoutBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_outlined, color: Colors.green, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 12, color: Colors.black87),
                children: [
                  const TextSpan(text: 'Next payout release: '),
                  TextSpan(
                    text: _nextPayoutDate,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // WITHDRAW SECTION
  // ─────────────────────────────────────────────
  Widget _buildWithdrawSection() {
    final minWithdrawal = _payoutStatus?.minimumWithdrawal ?? 10;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Amount input
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              prefixText: '\$ ',
              prefixStyle: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
              hintText: '0.00',
              hintStyle: TextStyle(
                  color: Colors.grey[300], fontSize: 22, fontWeight: FontWeight.bold),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 12),

          // Quick amount chips
          Row(
            children: [
              _buildChip('25%', () => _setQuickAmount(0.25)),
              const SizedBox(width: 8),
              _buildChip('50%', () => _setQuickAmount(0.50)),
              const SizedBox(width: 8),
              _buildChip('75%', () => _setQuickAmount(0.75)),
              const SizedBox(width: 8),
              _buildChip('Max', () => _setQuickAmount(1.0)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available: \$${_availableBalance.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.grey[400], fontSize: 11),
              ),
              Text(
                'Min: \$${minWithdrawal.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.grey[400], fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Withdraw button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _handleWithdraw,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _isProcessing
                  ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send_rounded, size: 18),
                  SizedBox(width: 8),
                  Text('Withdraw Now',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 12, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text('Funds arrive in 1–3 business days via Stripe',
                  style: TextStyle(color: Colors.grey[400], fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // MONTHLY ANALYTICS (mini bar chart)
  // ─────────────────────────────────────────────
  Widget _buildMonthlyAnalytics() {
    if (_monthlyEarnings.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: const Center(child: Text('No earnings data available')),
      );
    }

    final maxAmount = _monthlyEarnings
        .map((e) => e['amount'] as double)
        .reduce((a, b) => a > b ? a : b);
    final maxHeight = maxAmount > 0 ? maxAmount : 1;

    final totalThisMonth = (_monthlyEarnings.last['amount'] as double).toStringAsFixed(0);

    final prevMonth = _monthlyEarnings.length >= 2
        ? (_monthlyEarnings[_monthlyEarnings.length - 2]['amount'] as double)
        : 0;
    final thisMonth = (_monthlyEarnings.last['amount'] as double);
    final change = prevMonth > 0 ? ((thisMonth - prevMonth) / prevMonth * 100).toStringAsFixed(1) : '0';
    final isPositive = thisMonth >= prevMonth;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('\$$totalThisMonth',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                  const Text('This month',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isPositive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 12,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 3),
                    Text('$change%',
                        style: TextStyle(
                            color: isPositive ? Colors.green : Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Bar chart
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _monthlyEarnings.map((entry) {
                final amount = entry['amount'] as double;
                final heightFraction = maxHeight > 0 ? amount / maxHeight : 0;
                final isCurrentMonth = entry == _monthlyEarnings.last;

                return Expanded(
                  child: Padding(
                    padding:  EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration:  Duration(milliseconds: 600),
                          height: 72.0 * heightFraction.clamp(0.0, 1.0),
                          decoration: BoxDecoration(
                            color: isCurrentMonth ? Colors.black : Colors.grey[200],
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(entry['month'] as String,
                            style: TextStyle(
                                fontSize: 10,
                                color: isCurrentMonth ? Colors.black : Colors.grey,
                                fontWeight: isCurrentMonth ? FontWeight.bold : FontWeight.normal)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // HISTORY TABS
  // ─────────────────────────────────────────────
  Widget _buildHistorySection() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'Withdrawals'),
              Tab(text: 'Transactions'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 400,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildWithdrawalHistory(),
              _buildTransactionHistory(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWithdrawalHistory() {
    if (_withdrawals.isEmpty) {
      return _buildEmptyState('No withdrawals yet');
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        itemCount: _withdrawals.length,
        separatorBuilder: (_, __) => Divider(height: 1, indent: 16, endIndent: 16, color: Colors.grey[100]),
        itemBuilder: (_, i) => _buildWithdrawalItem(_withdrawals[i]),
      ),
    );
  }

  Widget _buildTransactionHistory() {
    if (_transactions.isEmpty) {
      return _buildEmptyState('No transactions yet');
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        itemCount: _transactions.length,
        separatorBuilder: (_, __) => Divider(height: 1, indent: 16, endIndent: 16, color: Colors.grey[100]),
        itemBuilder: (_, i) => _buildTransactionItem(_transactions[i]),
      ),
    );
  }

  Widget _buildWithdrawalItem(Withdrawal withdrawal) {
    final isIncoming = false; // Withdrawals are always outgoing
    final status = withdrawal.status;

    Color getStatusColor() {
      switch (status) {
        case WithdrawalStatus.completed:
          return Colors.green;
        case WithdrawalStatus.pending:
          return Colors.orange;
        case WithdrawalStatus.processing:
          return Colors.blue;
        case WithdrawalStatus.failed:
          return Colors.red;
        case WithdrawalStatus.cancelled:
          return Colors.grey;
      }
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(11),
        ),
        child: const Icon(Icons.account_balance_outlined, color: Colors.blue, size: 18),
      ),
      title: Text(withdrawal.paymentMethodDisplay,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      subtitle: Text(withdrawal.formattedDate,
          style: const TextStyle(color: Colors.grey, fontSize: 11)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '-\$${withdrawal.amount.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: getStatusColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              withdrawal.status.displayValue,
              style: TextStyle(color: getStatusColor(), fontSize: 9, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(PayoutTransaction transaction) {
    final isIncoming = transaction.netAmount > 0;
    final type = transaction.type;

    IconData icon;
    Color iconColor;
    Color iconBg;

    switch (type) {
      case PayoutTransactionType.sale:
      case PayoutTransactionType.saleAvailable:
        icon = Icons.shopping_bag_outlined;
        iconColor = Colors.green[700]!;
        iconBg = Colors.green.withOpacity(0.1);
        break;
      case PayoutTransactionType.withdrawal:
        icon = Icons.account_balance_outlined;
        iconColor = Colors.blue[700]!;
        iconBg = Colors.blue.withOpacity(0.1);
        break;
      case PayoutTransactionType.refundDebit:
        icon = Icons.replay_outlined;
        iconColor = Colors.red[700]!;
        iconBg = Colors.red.withOpacity(0.1);
        break;
      case PayoutTransactionType.commission:
        icon = Icons.percent_rounded;
        iconColor = Colors.orange[700]!;
        iconBg = Colors.orange.withOpacity(0.1);
        break;
      case PayoutTransactionType.salePending:
        icon = Icons.hourglass_top_rounded;
        iconColor = Colors.orange[700]!;
        iconBg = Colors.orange.withOpacity(0.1);
        break;
      default:
        icon = Icons.receipt_outlined;
        iconColor = Colors.grey;
        iconBg = Colors.grey.withOpacity(0.1);
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(transaction.description,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          maxLines: 1,
          overflow: TextOverflow.ellipsis),
      subtitle: Text(_formatDateTime(transaction.createdAt),
          style: const TextStyle(color: Colors.grey, fontSize: 11)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${isIncoming ? '+' : '-'}\$${transaction.netAmount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              color: isIncoming ? Colors.green[700] : Colors.red[700],
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          if (transaction.status == 'pending')
            const SizedBox(height: 3),
          if (transaction.status == 'pending')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('Pending',
                  style: TextStyle(color: Colors.orange, fontSize: 9, fontWeight: FontWeight.w500)),
            ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.month}/${date.day}/${date.year} • ${date.hour % 12 == 0 ? 12 : date.hour % 12}:${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'PM' : 'AM'}';
  }

  Widget _buildEmptyState(String msg) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, color: Colors.grey[300], size: 48),
            const SizedBox(height: 10),
            Text(msg, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Text(title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black87));
}

// ─────────────────────────────────────────────────────────────────────────────
// SKELETON LOADER WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _SkeletonBox({
    this.width = double.infinity,
    required this.height,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(radius),
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey),
        ),
      ),
    );
  }
}