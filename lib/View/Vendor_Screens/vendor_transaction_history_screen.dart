import 'package:afrotierre/Models/SellerModels/SellerDashboardModels.dart';
import 'package:afrotierre/Repository/SellerRepository/SellerDashboardRepository.dart';
import 'package:flutter/material.dart';
import '../../res/Widgets/ShimmerBox.dart';

class VendorTransactionHistoryScreen extends StatefulWidget {
  const VendorTransactionHistoryScreen({super.key});

  @override
  State<VendorTransactionHistoryScreen> createState() =>
      _VendorTransactionHistoryScreenState();
}

class _VendorTransactionHistoryScreenState
    extends State<VendorTransactionHistoryScreen> {
  final SellerDashboardRepository _repository = SellerDashboardRepository();

  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Loading states
  bool _isLoading = true;
  String? _error;

  // Data
  TransactionHistoryResponse? _transactionData;
  List<Transaction> _transactions = [];

  // Pagination
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _transactions = [];
        _hasMore = true;
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final data = await _repository.getTransactionHistory(
        page: _currentPage,
        limit: 20,
      );

      setState(() {
        _transactionData = data;
        if (_currentPage == 1) {
          _transactions = data.transactions;
        } else {
          _transactions.addAll(data.transactions);
        }
        _hasMore = data.pagination.hasNextPage;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _loadMore() {
    if (_hasMore && !_isLoadingMore && !_isLoading) {
      setState(() {
        _isLoadingMore = true;
        _currentPage++;
      });
      _loadTransactions();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _refreshTransactions() async {
    await _loadTransactions(refresh: true);
  }

  // ─── Filter and Search ───────────────────────────────────────────────────

  List<Transaction> get _filteredTransactions {
    return _transactions.where((t) {
      // Filter by type
      final matchesFilter = _selectedFilter == 'All' ||
          (_selectedFilter == 'Sales' &&
              (t.type == TransactionType.sale ||
                  t.type == TransactionType.saleAvailable)) ||
          (_selectedFilter == 'Withdrawals' && t.type == TransactionType.withdrawal) ||
          (_selectedFilter == 'Refunds' && t.type == TransactionType.refund) ||
          (_selectedFilter == 'Fees' && t.type == TransactionType.fee);

      // Search
      final q = _searchQuery.toLowerCase();
      final matchesSearch = q.isEmpty ||
          t.type.displayValue.toLowerCase().contains(q) ||
          t.description.toLowerCase().contains(q) ||
          (t.reference?.toLowerCase().contains(q) ?? false);

      return matchesFilter && matchesSearch;
    }).toList();
  }

  /// Groups filtered transactions by date
  Map<String, List<Transaction>> get _groupedTransactions {
    final Map<String, List<Transaction>> grouped = {};
    for (final t in _filteredTransactions) {
      final dateKey = _getDateKey(t.createdAt);
      grouped.putIfAbsent(dateKey, () => []).add(t);
    }
    return grouped;
  }

  String _getDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Today';
    } else if (transactionDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  String _formatDateForDisplay(DateTime date) {
    return '${date.month}/${date.day}/${date.year} • ${_formatTime(date)}';
  }

  String _formatTime(DateTime date) {
    int hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final ampm = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    if (hour == 0) hour = 12;
    return '$hour:$minute $ampm';
  }

  double get _availableBalance => _transactionData?.summary.availableBalance ?? 0;
  double get _totalSales => _transactionData?.summary.totalSales ?? 0;
  double get _totalWithdrawn => _transactionData?.summary.totalWithdrawn ?? 0;
  double get _totalFees => _transactionData?.summary.totalFees ?? 0;

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
        title: const Text(
          'Transactions',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          _buildBalanceSummary(),
          Expanded(child: _buildTransactionList()),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // BALANCE SUMMARY CARD
  // ─────────────────────────────────────────────
  Widget _buildBalanceSummary() {
    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: ShimmerBox(width: double.infinity, height: 80, borderRadius: BorderRadius.circular(16)),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Available Balance',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.account_balance_wallet, color: Colors.white70, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '\$${_availableBalance.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBalanceStat('Total Sales', _totalSales, Colors.green),
              _buildBalanceStat('Withdrawn', _totalWithdrawn, Colors.orange),
              _buildBalanceStat('Fees', _totalFees, Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceStat(String label, double amount, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // SEARCH BAR
  // ─────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search transactions...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
            onPressed: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
          )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.black, width: 1.5),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // FILTER CHIPS
  // ─────────────────────────────────────────────
  Widget _buildFilterChips() {
    final filters = ['All', 'Sales', 'Withdrawals', 'Refunds', 'Fees'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: GestureDetector(
                onTap: () => setState(() => _selectedFilter = filter),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.black : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    filter,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // TRANSACTION LIST
  // ─────────────────────────────────────────────
  Widget _buildTransactionList() {
    if (_isLoading) {
      return _buildShimmerList();
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red[300], size: 60),
            const SizedBox(height: 12),
            Text(
              'Failed to load transactions',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshTransactions,
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

    final grouped = _groupedTransactions;

    if (grouped.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, color: Colors.grey[300], size: 60),
            const SizedBox(height: 12),
            Text(
              'No transactions found',
              style: TextStyle(color: Colors.grey[400], fontSize: 15),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshTransactions,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: grouped.keys.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == grouped.keys.length) {
            return _buildLoadingMoreIndicator();
          }
          final dateLabel = grouped.keys.elementAt(index);
          final items = grouped[dateLabel]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateHeader(dateLabel, items.first.createdAt),
              ...items.map((t) => _buildTransactionItem(t)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: 8,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ShimmerBox(
          width: double.infinity,
          height: 80,
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // DATE HEADER
  // ─────────────────────────────────────────────
  Widget _buildDateHeader(String label, DateTime date) {
    IconData icon;
    Color color;

    switch (label) {
      case 'Today':
        icon = Icons.wb_sunny_outlined;
        color = Colors.green;
        break;
      case 'Yesterday':
        icon = Icons.history_outlined;
        color = Colors.orange;
        break;
      default:
        icon = Icons.calendar_today_outlined;
        color = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: color,
            ),
          ),
          const Spacer(),
          Text(
            '${date.month}/${date.day}',
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // SINGLE TRANSACTION ITEM
  // ─────────────────────────────────────────────
  Widget _buildTransactionItem(Transaction transaction) {
    final bool isIncoming = transaction.netAmount > 0;
    final type = transaction.type;
    final amount = transaction.netAmount.abs();

    // Icon & color per type
    IconData icon;
    Color tagColor;
    Color tagBg;

    switch (type) {
      case TransactionType.sale:
      case TransactionType.saleAvailable:
        icon = Icons.shopping_bag_outlined;
        tagColor = Colors.green[700]!;
        tagBg = Colors.green.withOpacity(0.1);
        break;
      case TransactionType.withdrawal:
        icon = Icons.account_balance_outlined;
        tagColor = Colors.red[700]!;
        tagBg = Colors.red.withOpacity(0.1);
        break;
      case TransactionType.refund:
        icon = Icons.replay_outlined;
        tagColor = Colors.red[700]!;
        tagBg = Colors.red.withOpacity(0.1);
        break;
      case TransactionType.fee:
        icon = Icons.local_atm_outlined;
        tagColor = Colors.orange[700]!;
        tagBg = Colors.orange.withOpacity(0.1);
        break;
      case TransactionType.salePending:
        icon = Icons.hourglass_empty_outlined;
        tagColor = Colors.blue[700]!;
        tagBg = Colors.blue.withOpacity(0.1);
        break;
      default:
        icon = Icons.receipt_outlined;
        tagColor = Colors.grey;
        tagBg = Colors.grey.withOpacity(0.1);
    }

    final displayType = type.displayValue;
    final formattedDate = _formatDateForDisplay(transaction.createdAt);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: tagBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: tagColor, size: 20),
        ),
        title: Row(
          children: [
            // Type tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: tagBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                displayType,
                style: TextStyle(
                  color: tagColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                transaction.description,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            formattedDate,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isIncoming ? '+' : '-'}\$${amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: isIncoming ? Colors.green[700] : Colors.red[700],
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            if (transaction.status == 'pending')
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Pending',
                  style: TextStyle(fontSize: 9, color: Colors.orange),
                ),
              ),
          ],
        ),
      ),
    );
  }
}