import 'package:afrotierre/Repository/SellerRepository/SellerProductsRepo.dart';
import 'package:afrotierre/View/Vendor_Screens/vendor_add_product_screen.dart';
import 'package:flutter/material.dart';

import '../../Models/SellerModels/SellerProductModels.dart';
import '../../constants.dart';
import '../../res/Widgets/CustomSnackbar.dart';
import 'VendorEditProductScreen.dart';

// ─── Semantic color palette ────────────────────────────────────────────────────
class _StatusColors {
  static const inStockBg = Color(0xFFEAF3DE);
  static const inStockFg = Color(0xFF3B6D11);
  static const lowStockBg = Color(0xFFFAEEDA);
  static const lowStockFg = Color(0xFF854F0B);
  static const outOfStockBg = Color(0xFFFCEBEB);
  static const outOfStockFg = Color(0xFFA32D2D);
  static const discontinuedBg = Color(0xFFF1EFE8);
  static const discontinuedFg = Color(0xFF5F5E5A);
  static const draftBg = Color(0xFFFAEEDA);
  static const draftFg = Color(0xFF854F0B);
  static const discountBg = Color(0xFF2C2C2A);
  static const discountFg = Color(0xFFFFFFFF);
}

class VendorProductScreen extends StatefulWidget {
  const VendorProductScreen({super.key});

  @override
  State<VendorProductScreen> createState() => _VendorProductScreenState();
}

class _VendorProductScreenState extends State<VendorProductScreen> {
  // ── Search / loading ─────────────────────────────────────────────────────────
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = true;
  bool _isLoadingMore = false;

  // ── Pagination ───────────────────────────────────────────────────────────────
  List<Product> _products = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;

  // ── Active filters ───────────────────────────────────────────────────────────
  String? _selectedStatus;
  String? _selectedCategory;
  bool _showDrafts = false;

  // ── Quick-chip selection (status shortcut in header) ──────────────────────────
  String _chipFilter = 'all'; // 'all' | 'In Stock' | 'Low Stock' | 'Out of Stock' | 'draft'

  // ── Scroll controller for infinite scroll ────────────────────────────────────
  final ScrollController _scrollController = ScrollController();

  // ── Repo + categories ────────────────────────────────────────────────────────
  final SellerProductsRepo _productsRepo = SellerProductsRepo();
  List<String> _availableCategories = [];
  bool _isLoadingCategories = true;

  // ── Computed stats ───────────────────────────────────────────────────────────
  int get _inStockCount =>
      _products.where((p) => !p.draft && p.status == 'In Stock').length;

  int get _lowStockCount =>
      _products.where((p) => !p.draft && p.status == 'Low Stock').length;

  int get _draftCount => _products.where((p) => p.draft).length;

  bool get _hasActiveFilters =>
      _selectedStatus != null || _selectedCategory != null || _showDrafts;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadCategories();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 250) {
      _loadMoreProducts();
    }
  }

  // ── Data loading ─────────────────────────────────────────────────────────────

  Future<void> _loadCategories() async {
    try {
      final response = await _productsRepo.getSellerAllowedCategories();
      if (response.success && response.categories.isNotEmpty) {
        setState(() {
          _availableCategories = response.categories;
          _isLoadingCategories = false;
        });
      } else {
        setState(() => _isLoadingCategories = false);
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
      setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _loadProducts({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _products = [];
        _hasMore = true;
        _isLoading = true;
      });
    } else if (!_hasMore || _isLoadingMore) {
      return;
    }

    if (!refresh && _currentPage > 1) {
      setState(() => _isLoadingMore = true);
    }

    // Map chip filter → API params
    String? effectiveStatus = _selectedStatus;
    bool effectiveDraft = _showDrafts;
    if (_chipFilter == 'draft') {
      effectiveDraft = true;
      effectiveStatus = null;
    } else if (_chipFilter != 'all') {
      effectiveStatus = _chipFilter;
    }

    try {
      final response = await _productsRepo.getSellerProducts(
        status: effectiveStatus,
        category: _selectedCategory,
        page: _currentPage,
        limit: 10,
        search: _searchQuery.isEmpty ? null : _searchQuery,
        draft: effectiveDraft,
      );

      if (response.success && response.products != null) {
        setState(() {
          if (refresh) {
            _products = response.products!;
          } else {
            _products.addAll(response.products!);
          }
          if (response.pagination != null) {
            _totalPages = response.pagination!.pages;
            _hasMore = _currentPage < _totalPages;
          }
          _isLoading = false;
          _isLoadingMore = false;
        });
      } else {
        if (mounted) CustomSnackbar.showError(context, response.message);
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading products: $e');
      if (mounted)
        CustomSnackbar.showError(
          context,
          'Error loading products: ${e.toString()}',
        );
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _refreshProducts() async {
    _currentPage = 1;
    await _loadProducts(refresh: true);
  }

  Future<void> _loadMoreProducts() async {
    if (_hasMore && !_isLoadingMore && !_isLoading) {
      _currentPage++;
      await _loadProducts();
    }
  }

  void _applyFilters() {
    _currentPage = 1;
    _loadProducts(refresh: true);
  }

  // ── Bottom-sheet filter ───────────────────────────────────────────────────────

  void _showFilterSheet() {
    // Temp state for the sheet
    String? tempStatus = _selectedStatus;
    String? tempCategory = _selectedCategory;
    bool tempDraft = _showDrafts;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filter products',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (tempStatus != null ||
                        tempCategory != null ||
                        tempDraft)
                      TextButton(
                        onPressed: () {
                          setSheet(() {
                            tempStatus = null;
                            tempCategory = null;
                            tempDraft = false;
                          });
                        },
                        child: const Text(
                          'Clear all',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                // Status section
                _filterSectionLabel('Status'),
                const SizedBox(height: 8),
                _buildFilterChips(
                  options: const [
                    'All',
                    'In Stock',
                    'Low Stock',
                    'Out of Stock',
                    'Discontinued',
                  ],
                  selected: tempStatus ?? 'All',
                  onTap:
                      (val) => setSheet(
                        () => tempStatus = val == 'All' ? null : val,
                  ),
                ),
                const SizedBox(height: 20),

                // Category section
                _filterSectionLabel('Category'),
                const SizedBox(height: 8),
                _isLoadingCategories
                    ? const SizedBox(
                  height: 36,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  ),
                )
                    : _buildFilterChips(
                  options: ['All categories', ..._availableCategories],
                  selected: tempCategory ?? 'All categories',
                  onTap:
                      (val) => setSheet(
                        () =>
                    tempCategory =
                    val == 'All categories' ? null : val,
                  ),
                ),
                const SizedBox(height: 20),

                // Show drafts toggle
                _filterSectionLabel('Show'),
                const SizedBox(height: 8),
                _buildFilterChips(
                  options: const ['All products', 'Drafts only'],
                  selected: tempDraft ? 'Drafts only' : 'All products',
                  onTap:
                      (val) =>
                      setSheet(() => tempDraft = val == 'Drafts only'),
                ),
                const SizedBox(height: 28),

                // Apply button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedStatus = tempStatus;
                        _selectedCategory = tempCategory;
                        _showDrafts = tempDraft;
                      });
                      Navigator.pop(ctx);
                      _applyFilters();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Apply filters',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _filterSectionLabel(String label) => Text(
    label,
    style: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Colors.grey.shade500,
      letterSpacing: 0.5,
    ),
  );

  Widget _buildFilterChips({
    required List<String> options,
    required String selected,
    required void Function(String) onTap,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
      options.map((opt) {
        final isSelected = opt == selected;
        return GestureDetector(
          onTap: () => onTap(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: isSelected ? Colors.black : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? Colors.black : Colors.grey.shade300,
                width: 0.8,
              ),
            ),
            child: Text(
              opt,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Color helpers ─────────────────────────────────────────────────────────────

  Color _getColorFromName(String colorName) {
    const colorMap = {
      'red': Color(0xFFE24B4A),
      'blue': Color(0xFF378ADD),
      'green': Color(0xFF639922),
      'black': Color(0xFF2C2C2A),
      'white': Color(0xFFD3D1C7),
      'yellow': Color(0xFFEF9F27),
      'purple': Color(0xFF7F77DD),
      'orange': Color(0xFFD85A30),
      'pink': Color(0xFFD4537E),
      'grey': Color(0xFF888780),
      'gray': Color(0xFF888780),
      'brown': Color(0xFF854F0B),
      'teal': Color(0xFF1D9E75),
      'gold': Color(0xFFBA7517),
    };
    return colorMap[colorName.toLowerCase()] ?? const Color(0xFF888780);
  }

  Color _getStatusBgColor(String status) {
    switch (status) {
      case 'In Stock':
        return _StatusColors.inStockBg;
      case 'Low Stock':
        return _StatusColors.lowStockBg;
      case 'Out of Stock':
        return _StatusColors.outOfStockBg;
      case 'Discontinued':
        return _StatusColors.discontinuedBg;
      default:
        return _StatusColors.discontinuedBg;
    }
  }

  Color _getStatusFgColor(String status) {
    switch (status) {
      case 'In Stock':
        return _StatusColors.inStockFg;
      case 'Low Stock':
        return _StatusColors.lowStockFg;
      case 'Out of Stock':
        return _StatusColors.outOfStockFg;
      case 'Discontinued':
        return _StatusColors.discontinuedFg;
      default:
        return _StatusColors.discontinuedFg;
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(screenWidth, screenHeight),
            _buildStatsBar(screenWidth),
            Expanded(child: _buildBody(screenWidth, screenHeight)),
          ],
        ),
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader(double screenWidth, double screenHeight) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        screenWidth * 0.04,
        screenHeight * 0.02,
        screenWidth * 0.04,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + Add button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Products',
                style: TextStyle(
                  fontSize: screenWidth < 380 ? 20 : 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              _buildAddButton(screenWidth, screenHeight),
            ],
          ),
          SizedBox(height: screenHeight * 0.018),

          // Search + filter
          Row(
            children: [
              Expanded(child: _buildSearchField(screenWidth, screenHeight)),
              SizedBox(width: screenWidth * 0.025),
              _buildFilterButton(screenWidth),
            ],
          ),
          SizedBox(height: screenHeight * 0.015),

          // Quick-filter chips
          _buildQuickChips(screenWidth),
          SizedBox(height: screenHeight * 0.005),

          // Thin divider
          Divider(color: Colors.grey.shade100, height: 1),
        ],
      ),
    );
  }

  Widget _buildAddButton(double screenWidth, double screenHeight) {
    return ElevatedButton.icon(
      onPressed: () async {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (_) => const VendorAddProductScreen()),
        );
        if (result == true) _refreshProducts();
      },
      icon: Icon(
        Icons.add_rounded,
        color: Colors.white,
        size: screenWidth < 380 ? 15 : 17,
      ),
      label: Text(
        screenWidth < 450 ? 'Add' : 'Add product',
        style: TextStyle(
          color: Colors.white,
          fontSize: screenWidth < 380 ? 11 : 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        elevation: 0,
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth < 380 ? 10 : 14,
          vertical: screenHeight * 0.012,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildSearchField(double screenWidth, double screenHeight) {
    return TextField(
      controller: _searchController,
      onChanged: (v) {
        setState(() => _searchQuery = v);
        _applyFilters();
      },
      decoration: InputDecoration(
        hintText: 'Search products...',
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontSize: screenWidth < 380 ? 12 : 14,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: Colors.grey.shade400,
          size: screenWidth < 380 ? 18 : 20,
        ),
        suffixIcon:
        _searchQuery.isNotEmpty
            ? IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: Colors.grey.shade400,
            size: screenWidth < 380 ? 16 : 18,
          ),
          onPressed: () {
            _searchController.clear();
            setState(() => _searchQuery = '');
            _applyFilters();
          },
        )
            : null,
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: EdgeInsets.symmetric(vertical: screenHeight * 0.012),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
    );
  }

  Widget _buildFilterButton(double screenWidth) {
    return Stack(
      children: [
        GestureDetector(
          onTap: _showFilterSheet,
          child: Container(
            width: screenWidth < 380 ? 38 : 44,
            height: screenWidth < 380 ? 38 : 44,
            decoration: BoxDecoration(
              color: _hasActiveFilters ? Colors.black : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.tune_rounded,
              size: screenWidth < 380 ? 17 : 19,
              color: _hasActiveFilters ? Colors.white : Colors.black87,
            ),
          ),
        ),
        if (_hasActiveFilters)
          Positioned(
            top: 5,
            right: 5,
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: const Color(0xFFD85A30),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuickChips(double screenWidth) {
    final chips = <String, String>{
      'all': 'All',
      'In Stock': 'In Stock',
      'Low Stock': 'Low Stock',
      'Out of Stock': 'Out of Stock',
      'draft': 'Drafts',
    };

    return SizedBox(
      height: screenWidth < 380 ? 30 : 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children:
        chips.entries.map((entry) {
          final isActive = _chipFilter == entry.key;
          return GestureDetector(
            onTap: () {
              setState(() => _chipFilter = entry.key);
              _applyFilters();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              margin: const EdgeInsets.only(right: 8),
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth < 380 ? 10 : 14,
                vertical: screenWidth < 380 ? 5 : 7,
              ),
              decoration: BoxDecoration(
                color: isActive ? Colors.black : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? Colors.black : Colors.grey.shade300,
                  width: 0.8,
                ),
              ),
              child: Text(
                entry.value,
                style: TextStyle(
                  fontSize: screenWidth < 380 ? 11 : 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? Colors.white : Colors.grey.shade600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Stats bar ────────────────────────────────────────────────────────────────

  Widget _buildStatsBar(double screenWidth) {
    return Container(
      color: Colors.grey.shade50,
      padding: EdgeInsets.symmetric(
        vertical: screenWidth < 380 ? 8 : 12,
        horizontal: screenWidth * 0.04,
      ),
      child: Row(
        children: [
          _statItem('${_products.length}', 'total', screenWidth),
          _statDivider(),
          _statItem('$_inStockCount', 'in stock', screenWidth),
          _statDivider(),
          _statItem('$_lowStockCount', 'low stock', screenWidth),
          _statDivider(),
          _statItem('$_draftCount', 'drafts', screenWidth),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label, double screenWidth) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: screenWidth < 380 ? 13 : 15,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: TextStyle(
              fontSize: screenWidth < 380 ? 9 : 10,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statDivider() {
    return Container(width: 0.5, height: 28, color: Colors.grey.shade200);
  }

  // ─── Body ─────────────────────────────────────────────────────────────────────

  Widget _buildBody(double screenWidth, double screenHeight) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
        ),
      );
    }

    if (_products.isEmpty) {
      return _buildEmptyState(screenWidth, screenHeight);
    }

    // Determine crossAxisCount based on screen width
    int crossAxisCount = 2;
    if (screenWidth >= 900) {
      crossAxisCount = 4;
    } else if (screenWidth >= 600) {
      crossAxisCount = 3;
    } else if (screenWidth < 380) {
      crossAxisCount = 1;
    }

    // Adjust aspect ratio for different screen sizes
    double aspectRatio = screenWidth < 380 ? 0.9 : 0.65;

    return RefreshIndicator(
      color: Colors.black,
      onRefresh: _refreshProducts,
      child: GridView.builder(
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(
          screenWidth * 0.035,
          screenHeight * 0.018,
          screenWidth * 0.035,
          screenHeight * 0.035,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: aspectRatio,
          crossAxisSpacing: screenWidth * 0.03,
          mainAxisSpacing: screenHeight * 0.018,
        ),
        itemCount: _products.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (ctx, index) {
          if (index == _products.length && _isLoadingMore) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              ),
            );
          }
          return _buildProductCard(_products[index], screenWidth, screenHeight);
        },
      ),
    );
  }

  Widget _buildEmptyState(double screenWidth,double screenHeight) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: screenWidth < 380 ? 60 : 72,
            height: screenWidth < 380 ? 60 : 72,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: screenWidth < 380 ? 25 : 30,
              color: Colors.grey.shade400,
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          Text(
            _searchQuery.isNotEmpty
                ? 'No results for "$_searchQuery"'
                : 'No products found',
            style: TextStyle(
              fontSize: screenWidth < 380 ? 14 : 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: screenHeight * 0.008),
          Text(
            _hasActiveFilters
                ? 'Try changing your filters'
                : 'Add your first product to get started',
            style: TextStyle(
              fontSize: screenWidth < 380 ? 12 : 13,
              color: Colors.grey.shade500,
            ),
          ),
          SizedBox(height: screenHeight * 0.025),
          if (_hasActiveFilters)
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _selectedStatus = null;
                  _selectedCategory = null;
                  _showDrafts = false;
                  _chipFilter = 'all';
                });
                _applyFilters();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.black, width: 0.8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.012,
                ),
              ),
              child: Text(
                'Clear filters',
                style: TextStyle(fontSize: screenWidth < 380 ? 12 : 13),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Product card ─────────────────────────────────────────────────────────────

  Widget _buildProductCard(Product product, double screenWidth, double screenHeight) {
    final double price = product.price;
    print('Product: ${product.name}, Price: $price, Discounted: ${product.discountedPrice}');
    final double? discountedPrice = product.discountedPrice;
    final List<String> colors = product.colors;
    final Map<String, dynamic> attributes = product.attributes;
    final bool inStock = product.isInStock;

    int? discountPercent;
    if (discountedPrice != null && price > 0) {
      discountPercent = ((price - discountedPrice) / price * 100).round();
    }

    final previewAttrs = attributes.entries.take(2).toList();

    return GestureDetector(
      onTap: () {
        // Navigate to product detail — implement as needed
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200, width: 0.8),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ───────────────────────────────────────────────────────
            _buildCardImage(
              product,
              discountPercent,
              screenWidth,
              screenHeight,
            ),

            // ── Info ─────────────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  screenWidth * 0.025,
                  screenHeight * 0.012,
                  screenWidth * 0.025,
                  screenHeight * 0.012,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category chip
                    Container(
                      margin: const EdgeInsets.only(bottom: 5),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.02,
                        vertical: screenHeight * 0.004,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        product.category,
                        style: TextStyle(
                          fontSize: screenWidth < 380 ? 8 : 9,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    // Product name
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: screenWidth < 380 ? 11 : 13,
                        height: 1.3,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.006),

                    // Price
                    _buildPriceRow(price, discountedPrice, screenWidth),

                    SizedBox(height: screenHeight * 0.008),

                    // Attribute pills
                    if (previewAttrs.isNotEmpty)
                      _buildAttrPills(
                        previewAttrs,
                        attributes.length,
                        screenWidth,
                      ),

                    const Spacer(),

                    // Bottom: color dots + stock count
                    _buildCardFooter(product, colors, inStock, screenWidth),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardImage(
      Product product,
      int? discountPercent,
      double screenWidth,
      double screenHeight,
      ) {
    double imageHeight = screenWidth < 380 ? 120 : 142;

    return Stack(
      children: [
        // Product image
        ClipRRect(
          child:
          product.images.isNotEmpty
              ? Image.network(
            product.images[0].url,
            height: imageHeight,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _imagePlaceholder(imageHeight),
          )
              : _imagePlaceholder(imageHeight),
        ),

        // Status / Draft badge — top left
        Positioned(
          top: screenHeight * 0.01,
          left: screenWidth * 0.02,
          child:
          product.draft
              ? _buildBadge(
            'Draft',
            _StatusColors.draftBg,
            _StatusColors.draftFg,
            showDot: true,
            screenWidth: screenWidth,
          )
              : _buildBadge(
            product.status,
            _getStatusBgColor(product.status),
            _getStatusFgColor(product.status),
            showDot: true,
            screenWidth: screenWidth,
          ),
        ),

        // Discount badge — top right
        if (discountPercent != null && !product.draft)
          Positioned(
            top: screenHeight * 0.01,
            right: screenWidth * 0.02,
            child: _buildBadge(
              '-$discountPercent%',
              _StatusColors.discountBg,
              _StatusColors.discountFg,
              screenWidth: screenWidth,
            ),
          ),

        // Edit button — bottom right
        Positioned(
          bottom: screenHeight * 0.01,
          right: screenWidth * 0.02,
          child: GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VendorEditProductScreen(product: product),
                ),
              );
              if (result == true) {
                _refreshProducts(); // 🔥 reload list
              }
            },
            child: Container(
              width: screenWidth < 380 ? 26 : 30,
              height: screenWidth < 380 ? 26 : 30,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200, width: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.edit_outlined,
                size: screenWidth < 380 ? 11 : 13,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _imagePlaceholder(double height) {
    return Container(
      height: height,
      width: double.infinity,
      color: Colors.grey.shade100,
      child: Icon(Icons.image_outlined, color: Colors.grey.shade300, size: 32),
    );
  }

  Widget _buildBadge(
      String label,
      Color bg,
      Color fg, {
        bool showDot = false,
        required double screenWidth,
      }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth < 380 ? 6 : 8,
        vertical: screenWidth < 380 ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: screenWidth < 380 ? 8 : 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(double price, double? discountedPrice, double screenWidth) {
    if (discountedPrice != null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '\$${discountedPrice.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: screenWidth < 380 ? 11 : 13,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            '\$${price.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: screenWidth < 380 ? 9 : 10,
              color: Colors.grey.shade400,
              decoration: TextDecoration.lineThrough,
              decorationColor: Colors.grey.shade400,
            ),
          ),
        ],
      );
    }
    return Text(
      '\$${price.toStringAsFixed(2)}',
      style: TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: screenWidth < 380 ? 11 : 13,
      ),
    );
  }

  Widget _buildAttrPills(
      List<MapEntry<String, dynamic>> entries,
      int totalCount,
      double screenWidth,
      ) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        ...entries.map(
              (e) => Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth < 380 ? 4 : 6,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade200, width: 0.5),
            ),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${e.key}: ',
                    style: TextStyle(
                      fontSize: screenWidth < 380 ? 8 : 9,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: e.value.toString(),
                    style: TextStyle(
                      fontSize: screenWidth < 380 ? 8 : 9,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (totalCount > 2)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth < 380 ? 4 : 6,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '+${totalCount - 2}',
              style: TextStyle(
                fontSize: screenWidth < 380 ? 8 : 9,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCardFooter(
      Product product,
      List<String> colors,
      bool inStock,
      double screenWidth,
      ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Color dots
        if (colors.isNotEmpty)
          Row(
            children: [
              ...colors
                  .take(4)
                  .map(
                    (c) => Container(
                  margin: const EdgeInsets.only(right: 3),
                  width: screenWidth < 380 ? 9 : 11,
                  height: screenWidth < 380 ? 9 : 11,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getColorFromName(c),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 0.8,
                    ),
                  ),
                ),
              ),
              if (colors.length > 4)
                Container(
                  width: screenWidth < 380 ? 9 : 11,
                  height: screenWidth < 380 ? 9 : 11,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade200,
                  ),
                  child: Center(
                    child: Text(
                      '+${colors.length - 4}',
                      style: TextStyle(
                        fontSize: screenWidth < 380 ? 5 : 6,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
            ],
          ),

        // Stock pill
        if (!product.draft) _buildStockPill(product, inStock, screenWidth),
      ],
    );
  }

  Widget _buildStockPill(Product product, bool inStock, double screenWidth) {
    final isLow = product.status == 'Low Stock';
    Color bg;
    Color fg;

    if (!inStock) {
      bg = _StatusColors.outOfStockBg;
      fg = _StatusColors.outOfStockFg;
    } else if (isLow) {
      bg = _StatusColors.lowStockBg;
      fg = _StatusColors.lowStockFg;
    } else {
      bg = Colors.grey.shade100;
      fg = Colors.grey.shade600;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth < 380 ? 5 : 7,
        vertical: screenWidth < 380 ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        inStock ? '${product.stock} left' : 'Sold out',
        style: TextStyle(
          fontSize: screenWidth < 380 ? 8 : 9,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}