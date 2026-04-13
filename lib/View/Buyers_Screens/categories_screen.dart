import 'package:afrotierre/Models/BuyerModels/BuyerHomeModels.dart';
import 'package:afrotierre/Repository/BuyerRepository/BuyerHomeRepo.dart';
import 'package:afrotierre/Services/AppSession.dart';
import 'package:afrotierre/View/Buyers_Screens/categories_products_screen.dart';
import 'package:afrotierre/View/Buyers_Screens/search_screen.dart';
import 'package:flutter/material.dart';

import 'ProductListScreen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final BuyerHomeRepo _homeRepo = BuyerHomeRepo();
  final AppSession _session = AppSession.instance;

  bool _isLoading = true;
  bool _isSearching = false;
  List<CategoryItem> _categories = [];
  List<CategoryItem> _filteredCategories = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final FocusNode _searchFocusNode = FocusNode();

  // Palette of soft tints — cycles through for each category icon background
  static const List<Color> _iconTints = [
    Color(0xFFE8F4FD), // soft blue
    Color(0xFFFFF3E0), // soft amber
    Color(0xFFE8F5E9), // soft green
    Color(0xFFFCE4EC), // soft pink
    Color(0xFFEDE7F6), // soft purple
    Color(0xFFE0F7FA), // soft teal
    Color(0xFFFFF8E1), // soft yellow
    Color(0xFFF3E5F5), // soft lavender
    Color(0xFFE8EAF6), // soft indigo
    Color(0xFFE0F2F1), // soft mint
  ];

  static const List<Color> _iconColors = [
    Color(0xFF1565C0), // blue
    Color(0xFFE65100), // amber
    Color(0xFF2E7D32), // green
    Color(0xFFC62828), // pink/red
    Color(0xFF4527A0), // purple
    Color(0xFF00695C), // teal
    Color(0xFFF57F17), // yellow
    Color(0xFF6A1B9A), // lavender
    Color(0xFF283593), // indigo
    Color(0xFF00695C), // mint
  ];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _searchController.addListener(_filterCategories);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterCategories);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _filterCategories() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      if (_searchQuery.isEmpty) {
        _filteredCategories = List.from(_categories);
      } else {
        _filteredCategories = _categories.where((category) {
          return category.name.toLowerCase().contains(_searchQuery);
        }).toList();
      }
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchFocusNode.unfocus();
      } else {
        Future.delayed(const Duration(milliseconds: 100), () {
          _searchFocusNode.requestFocus();
        });
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.requestFocus();
  }

  void _navigateToProductList(String categoryName) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ProductListScreen(category: categoryName),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  Future<void> _fetchCategories() async {
    setState(() => _isLoading = true);
    try {
      final token = _session.authToken;
      final response = await _homeRepo.getCategories(
        token: token,
        context: context,
      );
      if (mounted && response.success) {
        setState(() {
          _categories = response.data;
          _filteredCategories = List.from(response.data);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
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
        title: _isSearching
            ? TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search categories...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            border: InputBorder.none,
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
              icon: Icon(Icons.clear, color: Colors.grey.shade500, size: 18),
              onPressed: _clearSearch,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            )
                : null,
          ),
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
          cursorColor: Colors.black,
          onSubmitted: (_) {
            // Optional: handle submit
          },
        )
            : const Text(
          'All Categories',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: !_isSearching,
        actions: [
          IconButton(
            onPressed: _toggleSearch,
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Colors.black,
            ),
          ),
        ],
        bottom: _isSearching
            ? null
            : PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade100, height: 1),
        ),
      ),
      body: _isLoading
          ? _buildSkeleton()
          : _filteredCategories.isEmpty && _searchQuery.isNotEmpty && _isSearching
          ? _buildNoResults()
          : _buildList(),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No categories found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with a different keyword',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _clearSearch,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              foregroundColor: Colors.grey.shade700,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Clear Search'),
          ),
        ],
      ),
    );
  }

  // ── Category List ─────────────────────────────────────────────────────────
  Widget _buildList() {
    if (_filteredCategories.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.category_outlined, size: 56, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'No categories found',
              style: TextStyle(color: Colors.grey[500], fontSize: 15),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchCategories,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _filteredCategories.length,
        itemBuilder: (context, index) {
          final cat = _filteredCategories[index];
          final tint = _iconTints[index % _iconTints.length];
          final iconColor = _iconColors[index % _iconColors.length];
          return _buildCategoryTile(cat, tint, iconColor);
        },
      ),
    );
  }

  Widget _buildCategoryTile(
      CategoryItem cat,
      Color tintColor,
      Color iconColor,
      ) {
    return InkWell(
      onTap: () => _navigateToProductList(cat.name),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Icon container with tinted background
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.grey[100],
                  child: ClipOval(
                    child: cat.imageUrl != null
                        ? Image.network(
                      cat.imageUrl!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/stock_image.png',
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                        );
                      },
                    )
                        : Image.asset(
                      'assets/stock_image.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Name + product count
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cat.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${cat.productCount} products',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),

            // Arrow
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(CategoryItem cat, Color iconColor) {
    if (cat.imageUrl != null &&
        (cat.imageUrl!.startsWith('http://') ||
            cat.imageUrl!.startsWith('https://'))) {
      return Image.network(
        cat.imageUrl!,
        width: 40,
        height: 40,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _fallbackIcon(),
      );
    }
    return _fallbackIcon();
  }

  Widget _fallbackIcon() {
    return Icon(Icons.category_outlined, size: 30, color: Colors.grey[400]);
  }

  // ── Shimmer Skeleton ──────────────────────────────────────────────────────
  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 8,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            _ShimmerBox(width: 62, height: 62, radius: 16),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerBox(width: 140, height: 14, radius: 6),
                  const SizedBox(height: 8),
                  _ShimmerBox(width: 80, height: 11, radius: 5),
                ],
              ),
            ),
            _ShimmerBox(width: 32, height: 32, radius: 8),
          ],
        ),
      ),
    );
  }
}

// ── Shimmer Widget ────────────────────────────────────────────────────────────
class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? Colors.grey[800]! : Colors.grey[200]!;
    final highlight = isDark ? Colors.grey[600]! : Colors.grey[100]!;

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