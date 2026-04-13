import 'package:flutter/material.dart';

import '../../Models/BuyerModels/BuyerHomeModels.dart';
import '../../Models/BuyerModels/BuyerCartModels.dart';
import '../../Repository/BuyerRepository/BuyerHomeRepo.dart';
import '../../Repository/BuyerRepository/BuyerWishlistRepository.dart';
import '../../Repository/BuyerRepository/BuyerCartRepo.dart';
import '../../Services/AppSession.dart';
import '../../res/Widgets/BuyerProductListScreenWidgets.dart';
import '../../res/Widgets/CustomSnackbar.dart';
import '../Buyers_Screens/product_details_screen.dart';
import '../Buyers_Screens/cart_screen.dart'; // Add this import


class ProductListScreen extends StatefulWidget {
  final String? filter;
  final String? category;

  const ProductListScreen({super.key, this.filter, this.category});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final BuyerHomeRepo _homeRepo = BuyerHomeRepo();
  final WishlistRepository _wishlistRepo = WishlistRepository();
  final BuyerCartRepo _cartRepo = BuyerCartRepo();
  final AppSession _session = AppSession.instance;

  String? _filterType;
  String? _category;

  String _sortBy = 'default';
  bool _isGridView = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  RangeValues _priceRange = const RangeValues(0, 500);
  double _minRating = 0;
  bool _onlyInStock = false;
  bool _showFilterPanel = false;

  List<ProductItem> _products = [];
  bool _isLoading = true;
  bool _hasMore = true;
  int _currentPage = 1;
  int _totalProducts = 0;
  final int _limit = 20;

  List<String> _availableCategories = [];
  PriceRange? _availablePriceRange;
  List<String> _availableSizes = [];
  List<String> _availableColors = [];

  // Track which products are being updated
  final Set<String> _updatingWishlistIds = {};
  final Set<String> _updatingCartIds = {};

  // Track cart quantities locally for optimistic UI updates
  final Map<String, int> _cartQuantities = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeFilters());
    _filterType = widget.filter;
    _category = widget.category;

    debugPrint('🎯 ProductListScreen initialized:');
    debugPrint('   Filter from widget: $_filterType');
    debugPrint('   Category from widget: $_category');
    _fetchProducts();
    _fetchFilters();
    _fetchCartQuantities(); // Fetch current cart quantities
  }

  void _initializeFilters() {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _filterType = args['filter'] as String?;
      _category = args['category'] as String?;
    }
    if (widget.filter != null) _filterType = widget.filter;
    if (widget.category != null) _category = widget.category;
    if (mounted) setState(() {});
  }

  Future<void> _fetchCartQuantities() async {
    try {
      final token = _session.authToken;
      if (token == null) return;

      final response = await _cartRepo.getCart(token, context: context);
      if (mounted && response.success) {
        setState(() {
          for (var item in response.cart) {
            _cartQuantities[item.productId] = item.quantity;
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching cart: $e');
    }
  }

  Future<void> _fetchFilters() async {
    try {
      final token = _session.authToken;
      final response = await _homeRepo.getFilters(token: token);
      if (mounted && response.success) {
        setState(() {
          _availableCategories = response.data.categories;
          _availablePriceRange = response.data.priceRange;
          _priceRange = RangeValues(
            response.data.priceRange.min,
            response.data.priceRange.max,
          );
          _availableSizes = response.data.sizes;
          _availableColors = response.data.colors;
        });
      }
    } catch (e) {
      debugPrint('Error fetching filters: $e');
    }
  }

  Future<void> _fetchProducts({bool loadMore = false}) async {
    if (loadMore && !_hasMore) return;
    if (loadMore) {
      _currentPage++;
    } else {
      _currentPage = 1;
      if (mounted) setState(() => _isLoading = true);
    }

    try {
      final token = _session.authToken;

      String sortParam = 'newest';
      switch (_sortBy) {
        case 'price_asc':
          sortParam = 'price_low';
          break;
        case 'price_desc':
          sortParam = 'price_high';
          break;
        case 'rating':
          sortParam = 'rating';
          break;
        case 'discount':
          sortParam = 'popular';
          break;
        default:
          sortParam = 'newest';
      }

      debugPrint('📦 Fetching products with params:');
      debugPrint('   Category: $_category');
      debugPrint('   Filter: $_filterType');
      debugPrint('   Search: ${_searchQuery.isNotEmpty ? _searchQuery : 'none'}');
      debugPrint('   Page: $_currentPage');
      debugPrint('   Sort: $sortParam');

      final response = await _homeRepo.getProducts(
        token: token,
        category: _category,
        filter: _filterType,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        minPrice: _priceRange.start,
        maxPrice: _priceRange.end,
        sort: sortParam,
        page: _currentPage,
        limit: _limit,
        context: context,
      );

      debugPrint('📦 Response success: ${response.success}');
      debugPrint('📦 Products count: ${response.data.products.length}');
      debugPrint('📦 Total products: ${response.data.pagination.total}');

      if (mounted && response.success) {
        var filteredProducts = response.data.products;
        if (_minRating > 0) {
          filteredProducts = filteredProducts.where((p) => p.rating >= _minRating).toList();
        }
        if (_onlyInStock) {
          filteredProducts = filteredProducts.where((p) => p.stock > 0).toList();
        }
        setState(() {
          if (loadMore) {
            _products.addAll(filteredProducts);
          } else {
            _products = filteredProducts;
          }
          _totalProducts = response.data.pagination.total;
          _hasMore = _currentPage < response.data.pagination.pages;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error fetching products: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    _searchQuery = query;
    _currentPage = 1;
    _fetchProducts();
  }

  void _applyFilters() {
    setState(() => _showFilterPanel = false);
    _currentPage = 1;
    _fetchProducts();
  }

  void _resetFilters() {
    setState(() {
      _priceRange = RangeValues(
        _availablePriceRange?.min ?? 0,
        _availablePriceRange?.max ?? 500,
      );
      _minRating = 0;
      _onlyInStock = false;
      _sortBy = 'default';
      _searchQuery = '';
      _searchController.clear();
    });
    _currentPage = 1;
    _fetchProducts();
  }

  void _loadMore() {
    if (_hasMore && !_isLoading) _fetchProducts(loadMore: true);
  }

  // Updated Cart Methods with optimistic updates
  Future<void> _addToCart(ProductItem product) async {
    final token = _session.authToken;
    if (token == null || token.isEmpty) {
      CustomSnackbar.showError(context, 'Please login to add items to cart');
      return;
    }

    final currentQty = _cartQuantities[product.id] ?? 0;
    final newQty = currentQty + 1;

    // Optimistic update
    setState(() {
      _cartQuantities[product.id] = newQty;
      _updatingCartIds.add(product.id);
    });

    try {
      final request = AddToCartRequest(productId: product.id, quantity: newQty);
      final response = await _cartRepo.addToCart(token, request, context: context);

      if (!response.success && mounted) {
        // Revert on failure
        setState(() {
          if (newQty == 1) {
            _cartQuantities.remove(product.id);
          } else {
            _cartQuantities[product.id] = currentQty;
          }
        });
        CustomSnackbar.showError(context, response.message ?? 'Failed to add to cart');
      }
    } catch (e) {
      // Revert on error
      setState(() {
        if (newQty == 1) {
          _cartQuantities.remove(product.id);
        } else {
          _cartQuantities[product.id] = currentQty;
        }
      });
      CustomSnackbar.showError(
        context,
        'Failed to add to cart: ${e.toString().replaceFirst('Exception: ', '')}',
      );
      debugPrint('Error adding to cart: $e');
    } finally {
      if (mounted) {
        setState(() {
          _updatingCartIds.remove(product.id);
        });
      }
    }
  }

  Future<void> _decrementCart(ProductItem product) async {
    final currentQty = _cartQuantities[product.id] ?? 0;
    if (currentQty <= 0) return;

    final newQty = currentQty - 1;

    // Optimistic update
    setState(() {
      if (newQty == 0) {
        _cartQuantities.remove(product.id);
      } else {
        _cartQuantities[product.id] = newQty;
      }
      _updatingCartIds.add(product.id);
    });

    try {
      final token = _session.authToken;
      if (token == null) return;

      if (newQty == 0) {
        // CORRECTED: token first, then product.id
        final response = await _cartRepo.removeFromCart(
          token,        // First parameter: auth token
          product.id,   // Second parameter: product ID
          context: context,
        );

        if (!response.success && mounted) {
          // Revert
          setState(() {
            _cartQuantities[product.id] = currentQty;
          });
          CustomSnackbar.showError(context, response.message ?? 'Failed to remove from cart');
        }
      } else {
        // Update quantity
        final request = AddToCartRequest(productId: product.id, quantity: newQty);
        final response = await _cartRepo.addToCart(token, request, context: context);
        if (!response.success && mounted) {
          // Revert
          setState(() {
            _cartQuantities[product.id] = currentQty;
          });
          CustomSnackbar.showError(context, response.message ?? 'Failed to update cart');
          print('❌ Failed to update cart: ${response.message}');
        }
      }
    } catch (e) {
      // Revert on error
      if (mounted) {
        setState(() {
          _cartQuantities[product.id] = currentQty;
        });
        CustomSnackbar.showError(context, 'Failed to update cart');
        debugPrint('Error updating cart: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _updatingCartIds.remove(product.id);
        });
      }
    }
  }
// Cart Control Widget
  Widget _buildCartControl(ProductItem product, {bool compact = true}) {
    final qty = _cartQuantities[product.id] ?? 0;
    final isUpdating = _updatingCartIds.contains(product.id);
    final inCart = qty > 0;

    if (compact) {
      return GestureDetector(
        // Tap on the whole container when not in cart
        onTap: (!inCart && !isUpdating) ? () => _addToCart(product) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          width: inCart ? 80 : 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(inCart ? 16 : 10),
          ),
          child: isUpdating
              ? const Center(
            child: SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
          )
              : inCart
              ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque, // ← crucial
                onTap: () => _decrementCart(product),
                child: SizedBox(
                  width: 24,
                  height: 32,
                  child: Icon(
                    qty == 1
                        ? Icons.delete_outline_rounded
                        : Icons.remove_rounded,
                    color: Colors.white,
                    size: 13,
                  ),
                ),
              ),
              Text(
                '$qty',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque, // ← crucial
                onTap: () => _addToCart(product),
                child: const SizedBox(
                  width: 24,
                  height: 32,
                  child: Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 13,
                  ),
                ),
              ),
            ],
          )
              : const Center(
            child: Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      );
    }

    // List tile style
    return GestureDetector(
      onTap: (!inCart && !isUpdating) ? () => _addToCart(product) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(20),
        ),
        child: isUpdating
            ? const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
          ),
        )
            : inCart
            ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _decrementCart(product),
              child: SizedBox(
                width: 36,
                height: 36,
                child: Icon(
                  qty == 1
                      ? Icons.delete_outline_rounded
                      : Icons.remove_rounded,
                  color: Colors.white,
                  size: 15,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                '$qty',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _addToCart(product),
              child: const SizedBox(
                width: 36,
                height: 36,
                child: Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 15,
                ),
              ),
            ),
          ],
        )
            : const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: Text(
              'Add',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _cartPillBtn({
    required IconData icon,
    required VoidCallback onTap,
    double size = 12,
    double padding = 4,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: Icon(icon, color: Colors.white, size: size),
      ),
    );
  }

  // Wishlist Methods
  Future<void> _toggleWishlist(ProductItem product) async {
    setState(() {
      _updatingWishlistIds.add(product.id);
    });

    try {
      if (product.isWishlisted) {
        // Remove from wishlist
        final response = await _wishlistRepo.removeFromWishlist(product.id);
        if (response.success) {
          setState(() {
            final index = _products.indexWhere((p) => p.id == product.id);
            if (index != -1) {
              _products[index] = product.copyWith(isWishlisted: false);
            }
          });
          CustomSnackbar.showSuccess(context, 'Removed from wishlist');
        } else {
          print('❌ Failed to remove from wishlist: ${response.message}');
          CustomSnackbar.showError(context, response.message ?? 'Failed to remove from wishlist');
        }
      } else {
        // Add to wishlist
        final response = await _wishlistRepo.addToWishlist(product.id);
        if (response.success) {
          setState(() {
            final index = _products.indexWhere((p) => p.id == product.id);
            if (index != -1) {
              _products[index] = product.copyWith(isWishlisted: true);
            }
          });
          CustomSnackbar.showSuccess(context, 'Added to wishlist');
        } else {
          print('❌ Failed to add to wishlist: ${response.message}');
          CustomSnackbar.showError(context, response.message ?? 'Failed to add to wishlist');
        }
      }
    } catch (e) {
      print('Error toggling wishlist: $e');
      CustomSnackbar.showError(context, 'Error updating wishlist');
      debugPrint('Error toggling wishlist: $e');
    } finally {
      setState(() {
        _updatingWishlistIds.remove(product.id);
      });
    }
  }

  String get _screenTitle {
    if (_filterType == 'discounted') return 'Flash Sale';
    if (_filterType == 'newest') return 'New Arrivals';
    if (_filterType == 'trending') return 'Trending';
    if (_category != null) return _category!;
    return 'All Products';
  }

  int get _activeFilterCount {
    int count = 0;
    if (_priceRange.start != (_availablePriceRange?.min ?? 0) ||
        _priceRange.end != (_availablePriceRange?.max ?? 500)) count++;
    if (_minRating > 0) count++;
    if (_onlyInStock) count++;
    if (_sortBy != 'default') count++;
    if (_searchQuery.isNotEmpty) count++;
    return count;
  }

  int get _totalCartItems {
    return _cartQuantities.values.fold(0, (a, b) => a + b);
  }

  Future<void> _refreshCartQuantities() async {
    final token = _session.authToken;
    if (token == null) return;

    try {
      final response = await _cartRepo.getCart(token, context: context);
      if (mounted && response.success) {
        setState(() {
          _cartQuantities.clear();
          for (var item in response.cart) {
            _cartQuantities[item.productId] = item.quantity;
          }
        });
      }
    } catch (e) {
      debugPrint('Error refreshing cart: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _wishlistRepo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildSearchAndControls(),
            AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOut,
              child: _showFilterPanel
                  ? FilterPanel(
                priceRange: _priceRange,
                minRating: _minRating,
                onlyInStock: _onlyInStock,
                availablePriceRange: _availablePriceRange,
                onPriceRangeChanged: (v) => setState(() => _priceRange = v),
                onRatingChanged: (v) => setState(() => _minRating = v),
                onInStockChanged: (v) {
                  setState(() => _onlyInStock = v);
                  _applyFilters();
                },
                onReset: _resetFilters,
                onApply: _applyFilters,
              )
                  : const SizedBox.shrink(),
            ),
            SortChips(
              currentSort: _sortBy,
              onSortChanged: (sort) {
                setState(() => _sortBy = sort);
                _currentPage = 1;
                _fetchProducts();
              },
            ),
            Expanded(
              child: _isLoading && _products.isEmpty
                  ? const ShimmerGrid()
                  : _products.isEmpty
                  ? EmptyState(onReset: _resetFilters)
                  : _isGridView
                  ? _buildGrid()
                  : _buildList(),
            ),
          ],
        ),
      ),
    );
  }

  // Updated Top Bar with Cart Badge
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _iconButton(
              icon: Icons.arrow_back,
              onTap: () => Navigator.pop(context),
            ),
          ),
          Text(
            _screenTitle,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Cart badge - always visible when there are items
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () async {
                      // Navigate to cart screen and wait for result
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CartScreen()),
                      );

                      // If we came back from cart (result can be true/false/null)
                      // Always refresh cart quantities
                      await _refreshCartQuantities();

                      // Also refresh products to update stock if items were removed
                      if (result == true) {
                        _currentPage = 1;
                        await _fetchProducts();
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.shopping_bag_outlined,
                            size: 18,
                            color: Color(0xFF1C1C1E),
                          ),
                          if (_totalCartItems > 0)
                            Positioned(
                              top: 7,
                              right: 7,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '$_totalCartItems',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                _iconButton(
                  icon: _isGridView
                      ? Icons.view_list_rounded
                      : Icons.grid_view_rounded,
                  onTap: () => setState(() => _isGridView = !_isGridView),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _iconButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF1C1C1E)),
      ),
    );
  }

  Widget _buildSearchAndControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search in $_screenTitle...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.5),
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                    child: Icon(Icons.cancel_rounded, color: Colors.grey.shade400, size: 18),
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => setState(() => _showFilterPanel = !_showFilterPanel),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _activeFilterCount > 0 || _showFilterPanel
                    ? const Color(0xFF1C1C1E)
                    : Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 20,
                    color: _activeFilterCount > 0 || _showFilterPanel
                        ? Colors.white
                        : const Color(0xFF1C1C1E),
                  ),
                  if (_activeFilterCount > 0)
                    Positioned(
                      top: 9,
                      right: 9,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _showFilterPanel ? const Color(0xFF1C1C1E) : Colors.white,
                            width: 1.2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return NotificationListener<ScrollNotification>(
      onNotification: (info) {
        if (info.metrics.pixels >= info.metrics.maxScrollExtent - 200) _loadMore();
        return false;
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: ResultsBar(productCount: _products.length, filterType: _filterType)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                    (context, index) => ProductGridCard(
                  product: _products[index],
                  isUpdatingWishlist: _updatingWishlistIds.contains(_products[index].id),
                  cartControl: _buildCartControl(_products[index], compact: true),
                  onWishlistTap: () => _toggleWishlist(_products[index]),
                ),
                childCount: _products.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
            ),
          ),
          if (_hasMore)
            const SliverToBoxAdapter(child: ShimmerGrid()),
        ],
      ),
    );
  }

  Widget _buildList() {
    return NotificationListener<ScrollNotification>(
      onNotification: (info) {
        if (info.metrics.pixels >= info.metrics.maxScrollExtent - 200) _loadMore();
        return false;
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: ResultsBar(productCount: _products.length, filterType: _filterType)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ProductListTile(
                    product: _products[index],
                    isUpdatingWishlist: _updatingWishlistIds.contains(_products[index].id),
                    cartControl: _buildCartControl(_products[index], compact: false),
                    onWishlistTap: () => _toggleWishlist(_products[index]),
                  ),
                ),
                childCount: _products.length,
              ),
            ),
          ),
          if (_hasMore)
            const SliverToBoxAdapter(child: ShimmerList()),
        ],
      ),
    );
  }
}