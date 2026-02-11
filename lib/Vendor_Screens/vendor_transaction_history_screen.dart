import 'package:flutter/material.dart';

class VendorTransactionHistoryScreen extends StatefulWidget {
  const VendorTransactionHistoryScreen({super.key});

  @override
  State<VendorTransactionHistoryScreen> createState() =>
      _VendorTransactionHistoryScreenState();
}

class _VendorTransactionHistoryScreenState
    extends State<VendorTransactionHistoryScreen> {
  String _selectedFilter = 'All';

  // Placeholder data
  final Map<String, List<Map<String, dynamic>>> _transactions = {
    'Today': [
      {
        'icon': Icons.shopping_cart_outlined,
        'title': 'Subscription payment',
        'time': '15-01-2026 12:03 AM',
        'amount': -42209.0,
      },
      {
        'icon': Icons.shopping_cart_outlined,
        'title': 'Funds added (Bank transfer)',
        'time': '15-01-2026 12:03 AM',
        'amount': 2209.0,
      },
      {
        'icon': Icons.storefront_outlined,
        'title': 'Sale commission-product xyz',
        'time': '15-01-2026 12:03 AM',
        'amount': 2209.0,
      },
    ],
    'Yesterday': [
      {
        'icon': Icons.shopping_cart_outlined,
        'title': 'Monthly software fee',
        'time': '15-01-2026 12:03 AM',
        'amount': -10.0,
      },
      {
        'icon': Icons.shopping_cart_outlined,
        'title': 'Subscription payment',
        'time': '15-01-2026 12:03 AM',
        'amount': -42209.0,
      },
      {
        'icon': Icons.shopping_cart_outlined,
        'title': 'Monthly software fee',
        'time': '15-01-2026 12:03 AM',
        'amount': -10.0,
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Transaction History',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(child: _buildTransactionList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search transactions',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Commission', 'Pending', 'Refund'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        }
                      },
                      backgroundColor: isSelected
                          ? Colors.black
                          : Colors.grey[200],
                      selectedColor: Colors.black,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide.none,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    return ListView.builder(
      itemCount: _transactions.keys.length,
      itemBuilder: (context, index) {
        final date = _transactions.keys.elementAt(index);
        final transactionsForDate = _transactions[date]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Text(
                date,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            ...transactionsForDate.map(
              (transaction) => _buildTransactionItem(transaction),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final isCredit = transaction['amount'] >= 0;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey[100],
        child: Icon(transaction['icon'], color: Colors.grey[600]),
      ),
      title: Text(
        transaction['title'],
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        transaction['time'],
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
      trailing: Text(
        '${isCredit ? '+' : '-'}\$${transaction['amount'].abs().toStringAsFixed(2)}',
        style: TextStyle(
          color: isCredit ? Colors.green : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
