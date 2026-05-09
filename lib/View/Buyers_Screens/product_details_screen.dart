import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../Models/BuyerModels/BuyerCartModels.dart';
import '../../Models/BuyerModels/BuyerHomeModels.dart';
import '../../Repository/BuyerRepository/BuyerCartRepo.dart';
import '../../Repository/BuyerRepository/BuyerHomeRepo.dart';
import '../../Repository/BuyerRepository/BuyerWishlistRepository.dart';
import '../../Services/AppSession.dart';
import '../../res/Widgets/CustomSnackbar.dart';
import '../../res/Widgets/SuccessDialog.dart';
import 'checkout_screen.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const Color _kBg    = Color(0xFFF2F2F7);
const Color _kCard  = Colors.white;
const Color _kInk   = Color(0xFF1C1C1E);
const Color _kMuted = Color(0xFF8E8E93);
const Color _kPill  = Color(0xFFF2F2F7);

class ProductDetailsScreen extends StatefulWidget {
  final String? productId;

  const ProductDetailsScreen({super.key, this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final BuyerHomeRepo _homeRepo = BuyerHomeRepo();
  final BuyerCartRepo _cartRepo = BuyerCartRepo();
  final WishlistRepository _wishlistRepo = WishlistRepository();

  final AppSession _session = AppSession.instance;

  ProductDetails? _product;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  int _selectedColorIndex = 0;
  int _selectedSizeIndex = 0;
  int _selectedMaterialIndex = 0;
  int _currentImagePage = 0;
  int _quantity = 1;
  bool _isWishlisted = false;
  bool _isUpdatingWishlist = false;
  bool _descriptionExpanded = false;
  bool _isAddingToCart = false;

  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _fetchProduct();
  }

  Future<void> _fetchProduct() async {
    if (widget.productId == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = "Product ID is missing";
        });
      }
      return;
    }

    try {
      if (mounted) setState(() => _isLoading = true);

      final token = _session.authToken;
      final response = await _homeRepo.getProductDetails(
        productId: widget.productId!,
        token: token,
      );

      if (mounted) {
        if (response.success && response.data != null) {
          setState(() {
            _product = response.data;
            _isWishlisted = response.data.isWishlisted;
            _isLoading = false;
            _hasError = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            _hasError = true;
            _errorMessage = "Failed to load product details";
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = "An error occurred while fetching product: ${e.toString()}";
        });
      }
      debugPrint('Error fetching product: $e');
    }
  }

  Future<void> _toggleWishlist() async {
    final token = _session.authToken;
    if (token == null || token.isEmpty) {
      CustomSnackbar.showError(context, 'Please login to manage wishlist');
      return;
    }

    if (_isUpdatingWishlist) return;

    setState(() => _isUpdatingWishlist = true);

    try {
      if (_isWishlisted) {
        // Remove from wishlist
        final response = await _wishlistRepo.removeFromWishlist(widget.productId!);
        if (response.success) {
          setState(() {
            _isWishlisted = false;
          });
          CustomSnackbar.showSuccess(context, 'Removed from wishlist');
        } else {
          CustomSnackbar.showError(context, response.message ?? 'Failed to remove from wishlist');
        }
      } else {
        // Add to wishlist
        final response = await _wishlistRepo.addToWishlist(widget.productId!);
        if (response.success) {
          setState(() {
            _isWishlisted = true;
          });
          CustomSnackbar.showSuccess(context, 'Added to wishlist');
        } else {
          CustomSnackbar.showError(context, response.message ?? 'Failed to add to wishlist');
        }
      }
    } catch (e) {
      debugPrint('Error toggling wishlist: $e');
      CustomSnackbar.showError(context, 'Error updating wishlist');
    } finally {
      if (mounted) {
        setState(() => _isUpdatingWishlist = false);
      }
    }
  }

  Future<void> _addToCart({required bool isBuyNow}) async {
    final token = _session.authToken;
    if (token == null || token.isEmpty) {
      CustomSnackbar.showError(context, 'Please login to add items to cart');
      return;
    }

    if (_isAddingToCart) return;

    setState(() => _isAddingToCart = true);

    try {
      final request = AddToCartRequest(
        productId: widget.productId ?? '',
        quantity: _quantity,
        // Add selected options if your backend supports them

      );

      final response = await _cartRepo.addToCart(token, request, context: context);

      if (response.success && mounted) {
        // Build message with selected options
        String selectedOptions = '';
        if (_product?.colors.isNotEmpty == true) {
          selectedOptions += '\nColor: ${_product!.colors[_selectedColorIndex]}';
        }
        if (_product?.sizes.isNotEmpty == true) {
          selectedOptions += '\nSize: ${_product!.sizes[_selectedSizeIndex]}';
        }
        if (_product?.materials.isNotEmpty == true) {
          selectedOptions += '\nMaterial: ${_product!.materials[_selectedMaterialIndex]}';
        }

        // Show success dialog
        showSuccessDialog(
          context,
          title: 'Added to Cart!',
          message: '${_product?.name}\nQuantity: $_quantity$selectedOptions\n\nAdded to your cart successfully.',
          buttonText: isBuyNow ? 'Proceed to Checkout' : 'Continue Shopping',
          onPressed: () {
            if (isBuyNow) {
              // Navigate to checkout screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CheckoutScreen()),
              );
            } else {
              Navigator.pop(context);
            }
          },
          barrierDismissible: false,
        );
      } else if (mounted) {
        CustomSnackbar.showError(context, response.message ?? 'Failed to add to cart');
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(
          context,
          'Failed to add to cart: ${e.toString().replaceFirst('Exception: ', '')}',
        );
      }
      debugPrint('Error adding to cart: $e');
    } finally {
      if (mounted) {
        setState(() => _isAddingToCart = false);
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: _kBg,
        body: _buildShimmer(),
      );
    }

    if (_hasError || _product == null) {
      return Scaffold(
        backgroundColor: _kBg,
        body: _buildErrorState(),
      );
    }

    return Scaffold(
      backgroundColor: _kBg,
      body: _buildContent(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Oops! Something went wrong",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _kInk,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? "We couldn't load the product details. Please try again later.",
              style: TextStyle(
                fontSize: 14,
                color: _kMuted,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: const Text("Go Back"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _fetchProduct,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text("Try Again"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kInk,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  SHIMMER
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE0E0E0),
      highlightColor: const Color(0xFFF5F5F5),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Container(height: 380, color: Colors.white),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmerBox(80, 14),
                  const SizedBox(height: 10),
                  _shimmerBox(double.infinity, 22),
                  const SizedBox(height: 8),
                  _shimmerBox(160, 16),
                  const SizedBox(height: 20),
                  _shimmerBox(120, 32),
                  const SizedBox(height: 24),
                  _shimmerBox(60, 14),
                  const SizedBox(height: 12),
                  Row(children: List.generate(4, (_) => Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _shimmerCircle(36),
                  ))),
                  const SizedBox(height: 24),
                  _shimmerBox(60, 14),
                  const SizedBox(height: 12),
                  Row(children: List.generate(4, (_) => Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _shimmerBox(56, 34),
                  ))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox(double width, double height) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
  );

  Widget _shimmerCircle(double size) => Container(
    width: size,
    height: size,
    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
  );

  // ─────────────────────────────────────────────────────────────────────────
  //  MAIN CONTENT
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildContent() {
    final p = _product!;
    return CustomScrollView(
      slivers: [
        // ── Sticky image header ──────────────────────────────────────────
        SliverAppBar(
          expandedHeight: 380,
          pinned: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: _circleBtn(
              Icons.arrow_back,
              onTap: () => Navigator.pop(context),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: _circleBtn(
                _isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                iconColor: _isWishlisted ? Colors.red.shade500 : _kInk,
                bgColor: _isWishlisted ? Colors.red.shade50 : Colors.white,
                onTap: _toggleWishlist,
                isLoading: _isUpdatingWishlist,
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: _buildImageSlider(p),
          ),
        ),

        // ── Body ────────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Container(
            decoration: const BoxDecoration(
              color: _kBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBadgeRow(p),
                  const SizedBox(height: 10),
                  _buildTitleRow(p),
                  const SizedBox(height: 12),
                  _buildRatingRow(p),
                  const SizedBox(height: 18),
                  _buildPriceCard(p),
                  const SizedBox(height: 22),
                  if (p.colors.isNotEmpty) ...[
                    _buildColorSelector(p),
                    const SizedBox(height: 22),
                  ],
                  if (p.sizes.isNotEmpty) ...[
                    _buildSizeSelector(p),
                    const SizedBox(height: 22),
                  ],
                  if (p.materials.isNotEmpty) ...[
                    _buildMaterialSelector(p),
                    const SizedBox(height: 22),
                  ],
                  _buildQuantityRow(),
                  const SizedBox(height: 22),
                  _buildDescriptionCard(p),
                  if (p.attributes != null && p.attributes!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildAttributesCard(p),
                  ],
                  const SizedBox(height: 22),
                  _buildStockStatus(p),
                  if (p.similarProducts.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    _buildSimilarProducts(p),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  IMAGE SLIDER
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildImageSlider(ProductDetails p) {
    final images = p.images.isNotEmpty ? p.images : [''];
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: images.length,
          onPageChanged: (i) => setState(() => _currentImagePage = i),
          itemBuilder: (_, i) => _networkImage(images[i], fit: BoxFit.cover),
        ),
        // Dot indicators
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (i) {
              final active = i == _currentImagePage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: active ? _kInk : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ),
        // Image counter pill
        Positioned(
          top: 100,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.45),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_currentImagePage + 1}/${images.length}',
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  HEADER SECTIONS
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildBadgeRow(ProductDetails p) {
    return Row(
      children: [
        _pill(p.category),
        if (p.seller != null) ...[
          const SizedBox(width: 8),
          _pill('by ${p.seller}', icon: Icons.storefront_rounded),
        ],
      ],
    );
  }

  Widget _buildTitleRow(ProductDetails p) {
    return Text(
      p.name,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: _kInk,
        letterSpacing: -0.5,
        height: 1.2,
      ),
    );
  }

  Widget _buildRatingRow(ProductDetails p) {
    return Row(
      children: [
        Row(
          children: List.generate(5, (i) {
            final filled = i < p.rating.floor();
            final half = !filled && i < p.rating;
            return Icon(
              half ? Icons.star_half_rounded : (filled ? Icons.star_rounded : Icons.star_outline_rounded),
              color: Colors.amber.shade500,
              size: 16,
            );
          }),
        ),
        const SizedBox(width: 6),
        Text(
          '${p.rating.toStringAsFixed(1)}',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _kInk),
        ),
        const SizedBox(width: 4),
        Text(
          '(${p.reviewCount} reviews)',
          style: const TextStyle(fontSize: 13, color: _kMuted),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  PRICE CARD
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildPriceCard(ProductDetails p) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (p.hasDiscount)
                Text(
                  '\$${p.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: _kMuted,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: _kMuted,
                  ),
                ),
              Text(
                '\$${p.currentPrice.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: _kInk, letterSpacing: -0.8),
              ),
            ],
          ),
          if (p.hasDiscount) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '-${p.discountPercent}% OFF',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.red.shade600),
              ),
            ),
          ],
          const Spacer(),
          _buildStockPill(p),
        ],
      ),
    );
  }

  Widget _buildStockPill(ProductDetails p) {
    final inStock = p.stock > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: inStock ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: inStock ? Colors.green.shade600 : Colors.red.shade600,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            inStock ? '${p.stock} left' : 'Out of stock',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: inStock ? Colors.green.shade700 : Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  COLOR SELECTOR
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildColorSelector(ProductDetails p) {
    return _sectionCard(
      label: 'Color',
      selected: p.colors[_selectedColorIndex],
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: List.generate(p.colors.length, (i) {
          final selected = i == _selectedColorIndex;
          final color = _parseColor(p.colors[i]);
          return GestureDetector(
            onTap: () => setState(() => _selectedColorIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                border: Border.all(
                  color: selected ? _kInk : Colors.transparent,
                  width: 2.5,
                ),
                boxShadow: selected
                    ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, spreadRadius: 1)]
                    : [],
              ),
              child: selected
                  ? Icon(Icons.check_rounded, color: _contrastColor(color), size: 15)
                  : null,
            ),
          );
        }),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  SIZE SELECTOR
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildSizeSelector(ProductDetails p) {
    return _sectionCard(
      label: 'Size',
      selected: p.sizes[_selectedSizeIndex],
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(p.sizes.length, (i) {
          final selected = i == _selectedSizeIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedSizeIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? _kInk : _kPill,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                p.sizes[i],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : _kMuted,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  MATERIAL SELECTOR
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildMaterialSelector(ProductDetails p) {
    return _sectionCard(
      label: 'Material',
      selected: p.materials[_selectedMaterialIndex],
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(p.materials.length, (i) {
          final selected = i == _selectedMaterialIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedMaterialIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? _kInk : _kPill,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected ? _kInk : Colors.transparent,
                ),
              ),
              child: Text(
                p.materials[i],
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : _kMuted,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  QUANTITY ROW
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildQuantityRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          const Text('Quantity', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _kInk)),
          const Spacer(),
          _qtyBtn(Icons.remove_rounded, () {
            if (_quantity > 1) setState(() => _quantity--);
          }),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: Padding(
              key: ValueKey(_quantity),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '$_quantity',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _kInk),
              ),
            ),
          ),
          _qtyBtn(Icons.add_rounded, () {
            if (_product != null && _quantity < _product!.stock) {
              setState(() => _quantity++);
            }
          }),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: _kPill,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 16, color: _kInk),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  DESCRIPTION
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildDescriptionCard(ProductDetails p) {
    const maxLines = 3;
    final lines = p.description.split('\n');
    final isTruncatable = p.description.length > 120 || lines.length > maxLines;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Description', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _kInk)),
          const SizedBox(height: 10),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: _descriptionExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: Text(
              p.description,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, color: _kMuted, height: 1.6),
            ),
            secondChild: Text(
              p.description,
              style: const TextStyle(fontSize: 14, color: _kMuted, height: 1.6),
            ),
          ),
          if (isTruncatable) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => setState(() => _descriptionExpanded = !_descriptionExpanded),
              child: Text(
                _descriptionExpanded ? 'Show less' : 'Read more',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _kInk),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  ATTRIBUTES
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildAttributesCard(ProductDetails p) {
    final attrs = p.attributes!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Specifications', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _kInk)),
          const SizedBox(height: 12),
          ...attrs.entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    _formatKey(e.key),
                    style: const TextStyle(fontSize: 13, color: _kMuted, fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    '${e.value}',
                    style: const TextStyle(fontSize: 13, color: _kInk, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  STOCK STATUS
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildStockStatus(ProductDetails p) {
    if (p.stock > 10) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: p.stock == 0 ? Colors.red.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: p.stock == 0 ? Colors.red.shade100 : Colors.orange.shade100,
        ),
      ),
      child: Row(
        children: [
          Icon(
            p.stock == 0 ? Icons.remove_shopping_cart_rounded : Icons.warning_amber_rounded,
            size: 16,
            color: p.stock == 0 ? Colors.red.shade600 : Colors.orange.shade700,
          ),
          const SizedBox(width: 8),
          Text(
            p.stock == 0
                ? 'This item is currently out of stock'
                : 'Only ${p.stock} item${p.stock == 1 ? '' : 's'} left — order soon!',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: p.stock == 0 ? Colors.red.shade700 : Colors.orange.shade800,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  SIMILAR PRODUCTS
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildSimilarProducts(ProductDetails p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Similar Products',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _kInk, letterSpacing: -0.3),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: p.similarProducts.length,
            itemBuilder: (_, i) => _buildSimilarCard(p.similarProducts[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildSimilarCard(ProductItem item) {
    return GestureDetector(
      onTap: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailsScreen(productId: item.id)),
      ),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: _networkImage(item.imageUrl, width: 150, height: 130),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _kInk),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, color: Colors.amber.shade500, size: 11),
                      const SizedBox(width: 2),
                      Text('${item.rating}', style: const TextStyle(fontSize: 10.5, color: _kMuted)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '\$${item.currentPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _kInk),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  BOTTOM BAR
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildBottomBar() {
    final inStock = (_product?.stock ?? 0) > 0;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: Row(
        children: [
          // Cart button
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: inStock && !_isAddingToCart
                    ? () => _addToCart(isBuyNow: false)
                    : null,
                icon: _isAddingToCart
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : const Icon(Icons.shopping_bag_outlined, size: 18),
                label: Text(
                  _isAddingToCart ? 'Adding...' : 'Add to Cart',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1C1C1E),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade200,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Buy now button
          Expanded(
            flex: 1,
            child: SizedBox(
              height: 52,
              child: OutlinedButton(
                onPressed: inStock && !_isAddingToCart
                    ? () => _addToCart(isBuyNow: true)
                    : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1C1C1E),
                  side: BorderSide(color: inStock ? const Color(0xFF1C1C1E) : Colors.grey.shade300, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Buy Now', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  Widget _sectionCard({required String label, required String selected, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _kInk)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(color: _kPill, borderRadius: BorderRadius.circular(20)),
                child: Text(selected, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _kMuted)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _pill(String text, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: _kPill, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: _kMuted),
            const SizedBox(width: 4),
          ],
          Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _kMuted)),
        ],
      ),
    );
  }

  Widget _circleBtn(
      IconData icon, {
        required VoidCallback onTap,
        Color? iconColor,
        Color? bgColor,
        bool isLoading = false,
      }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: bgColor ?? Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: isLoading
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
            : Icon(icon, size: 18, color: iconColor ?? _kInk),
      ),
    );
  }

  Widget _networkImage(String? url, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    if (url != null && (url.startsWith('http://') || url.startsWith('https://'))) {
      return Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return Shimmer.fromColors(
            baseColor: const Color(0xFFE0E0E0),
            highlightColor: const Color(0xFFF5F5F5),
            child: Container(width: width, height: height, color: Colors.white),
          );
        },
        errorBuilder: (_, __, ___) => _imageFallback(width, height),
      );
    }
    return Image.asset(
      'assets/stock_image.png',
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => _imageFallback(width, height),
    );
  }

  Widget _imageFallback(double? width, double? height) => Container(
    width: width,
    height: height,
    color: const Color(0xFFF2F2F7),
    child: Icon(Icons.image_not_supported_rounded, size: 32, color: Colors.grey.shade300),
  );

  Color _parseColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'black':   return Colors.black;
      case 'white':   return Colors.white;
      case 'red':     return Colors.red.shade600;
      case 'blue':    return Colors.blue.shade600;
      case 'green':   return Colors.green.shade600;
      case 'yellow':  return Colors.yellow.shade700;
      case 'orange':  return Colors.orange.shade600;
      case 'purple':  return Colors.purple.shade600;
      case 'pink':    return Colors.pink.shade400;
      case 'grey':
      case 'gray':    return Colors.grey.shade500;
      case 'brown':   return Colors.brown.shade600;
      case 'navy':    return const Color(0xFF001F5B);
      case 'beige':   return const Color(0xFFF5F0DC);
      case 'cream':   return const Color(0xFFFFFDD0);
      default:
      // Try hex
        try {
          final hex = colorName.replaceAll('#', '');
          return Color(int.parse('FF$hex', radix: 16));
        } catch (_) {
          return Colors.grey.shade400;
        }
    }
  }

  Color _contrastColor(Color bg) {
    final luminance = bg.computeLuminance();
    return luminance > 0.4 ? Colors.black : Colors.white;
  }

  String _formatKey(String key) {
    return key
        .replaceAll('_', ' ')
        .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(0)}')
        .trim()
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}