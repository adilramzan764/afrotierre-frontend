// lib/Screens/Buyers_Screens/wishlist_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import '../../Models/BuyerModels/BuyerWishListModels.dart';
import '../../Repository/BuyerRepository/BuyerWishlistRepository.dart';
import '../../res/Widgets/CustomSnackbar.dart';
import 'product_details_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen>
    with SingleTickerProviderStateMixin {
  final WishlistRepository _repository = WishlistRepository();

  List<WishlistProduct> _wishlistItems = [];
  bool _isLoading = true;
  bool _isGridView = true;
  final Set<String> _removingIds = {};
  late AnimationController _emptyAnimController;
  late Animation<double> _emptyFadeAnim;

  @override
  void initState() {
    super.initState();
    _emptyAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _emptyFadeAnim = CurvedAnimation(
      parent: _emptyAnimController,
      curve: Curves.easeOut,
    );
    _fetchWishlist();
  }

  Future<void> _fetchWishlist() async {
    setState(() => _isLoading = true);
    final response = await _repository.getWishlist();
    if (mounted) {
      if (response.success && response.data != null) {
        setState(() {
          _wishlistItems = response.data!.wishlist;
          _isLoading = false;
        });
        if (_wishlistItems.isEmpty) _emptyAnimController.forward();
      } else {
        setState(() => _isLoading = false);
        if (response.message != null) {
          CustomSnackbar.showError(context, response.message!);
        }
      }
    }
  }

  Future<void> _removeItem(String productId) async {
    setState(() => _removingIds.add(productId));
    await Future.delayed(const Duration(milliseconds: 340));

    final response = await _repository.removeFromWishlist(productId);

    if (mounted) {
      if (response.success && response.data != null) {
        setState(() {
          _wishlistItems = response.data!.wishlist;
          _removingIds.remove(productId);
        });
        if (_wishlistItems.isEmpty) _emptyAnimController.forward();
        CustomSnackbar.showSuccess(context, 'Removed from wishlist');
      } else {
        setState(() => _removingIds.remove(productId));
        CustomSnackbar.showError(
            context, response.message ?? 'Failed to remove item');
      }
    }
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear Wishlist?'),
        content: const Text(
            'All saved items will be removed. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      final response = await _repository.clearWishlist();
      if (mounted) {
        setState(() => _isLoading = false);
        if (response.success) {
          setState(() => _wishlistItems = []);
          _emptyAnimController.forward();
          CustomSnackbar.showSuccess(
              context, response.message ?? 'Wishlist cleared');
        } else {
          CustomSnackbar.showError(
              context, response.message ?? 'Failed to clear wishlist');
        }
      }
    }
  }

  @override
  void dispose() {
    _repository.dispose();
    _emptyAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Wishlist',
          style: TextStyle(
            fontSize: screenWidth * 0.055,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1C1C1E),
          ),
        ),
        actions: [
          if (_wishlistItems.isNotEmpty) ...[
            IconButton(
              icon: Icon(
                _isGridView ? Icons.view_list : Icons.grid_view,
                size: screenWidth * 0.06,
                color: const Color(0xFF1C1C1E),
              ),
              onPressed: () => setState(() => _isGridView = !_isGridView),
            ),
            IconButton(
              icon: Icon(Icons.delete_sweep,
                  color: Colors.red, size: screenWidth * 0.06),
              onPressed: _clearAll,
            ),
          ],
        ],
      ),
      body: _isLoading
          ? (_isGridView ? _buildShimmerGrid() : _buildShimmerList())
          : _wishlistItems.isEmpty
          ? _buildEmptyState()
          : _isGridView
          ? _buildGrid()
          : _buildList(),
    );
  }

  // ── Grid ─────────────────────────────────────────────

  Widget _buildGrid() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GridView.builder(
      padding: EdgeInsets.fromLTRB(
        screenWidth * 0.04,
        0,
        screenWidth * 0.04,
        screenHeight * 0.03,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: screenWidth > 1200
            ? 4
            : screenWidth > 800
            ? 3
            : 2,
        childAspectRatio: 0.71,
        crossAxisSpacing: screenWidth * 0.03,
        mainAxisSpacing: screenWidth * 0.03,
      ),
      itemCount: _wishlistItems.length,
      itemBuilder: (_, index) {
        final item = _wishlistItems[index];
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _removingIds.contains(item.id) ? 0 : 1,
          child: _buildGridCard(item),
        );
      },
    );
  }

  Widget _buildGridCard(WishlistProduct product) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isSoldOut = !product.inStock;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailsScreen(productId: product.id),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: screenWidth * 0.02,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Image ──
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(screenWidth * 0.04),
                  ),
                  child: Image.network(
                    product.imageUrl,
                    height: screenHeight * 0.17,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: screenHeight * 0.17,
                      width: double.infinity,
                      color: const Color(0xFFF2F2F7),
                      child: Icon(
                        Icons.image_not_supported_rounded,
                        size: 32,
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
                // Discount badge
                if (product.hasDiscount && !isSoldOut)
                  Positioned(
                    top: screenHeight * 0.01,
                    left: screenWidth * 0.02,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.02,
                        vertical: screenHeight * 0.003,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade500,
                        borderRadius:
                        BorderRadius.circular(screenWidth * 0.04),
                      ),
                      child: Text(
                        '-${product.discountPercent}%',
                        style: TextStyle(
                          fontSize: screenWidth * 0.025,
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                // Sold out overlay
                if (isSoldOut)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(screenWidth * 0.04),
                      ),
                      child: Container(
                        color: Colors.black.withOpacity(0.35),
                        alignment: Alignment.center,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.025,
                            vertical: screenHeight * 0.004,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.72),
                            borderRadius:
                            BorderRadius.circular(screenWidth * 0.04),
                          ),
                          child: Text(
                            'Sold Out',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.028,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                // Remove (favourite) button
                Positioned(
                  top: screenHeight * 0.01,
                  right: screenWidth * 0.02,
                  child: GestureDetector(
                    onTap: () => _removeItem(product.id),
                    child: Container(
                      width: screenWidth * 0.08,
                      height: screenWidth * 0.08,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.favorite,
                        size: screenWidth * 0.04,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ── Info ──
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.025),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: screenWidth * 0.032,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.004),
                  Row(
                    children: [
                      Icon(Icons.star_rounded,
                          size: screenWidth * 0.03,
                          color: Colors.amber.shade500),
                      SizedBox(width: screenWidth * 0.01),
                      Text(
                        '${product.rating}',
                        style: TextStyle(
                          fontSize: screenWidth * 0.025,
                          color: const Color(0xFF8E8E93),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.007),
                  // ── Price ──
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (product.hasDiscount)
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: screenWidth * 0.022,
                            color: const Color(0xFFC7C7CC),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      Text(
                        '\$${product.currentPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: screenWidth * 0.034,
                          fontWeight: FontWeight.w800,
                          color: isSoldOut
                              ? Colors.grey.shade400
                              : const Color(0xFF1C1C1E),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── List ─────────────────────────────────────────────

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: _wishlistItems.length,
      itemBuilder: (_, index) {
        final item = _wishlistItems[index];
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _removingIds.contains(item.id) ? 0 : 1,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildListCard(item),
          ),
        );
      },
    );
  }

  Widget _buildListCard(WishlistProduct product) {
    final bool isSoldOut = !product.inStock;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(productId: product.id)),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    product.imageUrl,
                    width: 92,
                    height: 92,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 92,
                      height: 92,
                      color: const Color(0xFFF2F2F7),
                      child: Icon(Icons.image_not_supported_rounded,
                          size: 32, color: Colors.grey.shade300),
                    ),
                  ),
                ),
                if (product.hasDiscount && !isSoldOut)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.shade500,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '-${product.discountPercent}%',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1C1C1E),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _removeItem(product.id),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.favorite_rounded,
                              size: 16, color: Colors.red.shade400),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star_rounded,
                          color: Colors.amber.shade500, size: 12),
                      const SizedBox(width: 3),
                      Text(
                        '${product.rating}',
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF8E8E93)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '\$${product.currentPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isSoldOut
                              ? Colors.grey.shade400
                              : const Color(0xFF1C1C1E),
                          letterSpacing: -0.3,
                        ),
                      ),
                      if (product.hasDiscount) ...[
                        const SizedBox(width: 5),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: Color(0xFFC7C7CC),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                      if (isSoldOut) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F2F7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Sold Out',
                            style: TextStyle(
                                color: Color(0xFF8E8E93),
                                fontSize: 11,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty / Shimmer ───────────────────────────────────

  Widget _buildEmptyState() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return FadeTransition(
      opacity: _emptyFadeAnim,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: screenWidth * 0.25,
              height: screenWidth * 0.25,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.favorite_border,
                  size: screenWidth * 0.12, color: Colors.red.shade300),
            ),
            SizedBox(height: screenHeight * 0.03),
            Text(
              'Your wishlist is empty',
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              'Save items you love by tapping the heart icon',
              textAlign: TextAlign.center,
              style:
              TextStyle(fontSize: screenWidth * 0.035, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 110,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}