import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../Models/BuyerModels/BuyerHomeModels.dart';
import '../../View/Buyers_Screens/product_details_screen.dart';

class ProductTopBar extends StatelessWidget {
  final String title;
  final bool isGridView;
  final VoidCallback onBackTap;
  final VoidCallback onViewToggle;

  const ProductTopBar({
    super.key,
    required this.title,
    required this.isGridView,
    required this.onBackTap,
    required this.onViewToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _IconButton(
              icon: Icons.arrow_back,
              onTap: onBackTap,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: _IconButton(
              icon: isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
              onTap: onViewToggle,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
}


class ProductSearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final int activeFilterCount;
  final bool showFilterPanel;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onFilterToggle;

  const ProductSearchBar({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.activeFilterCount,
    required this.showFilterPanel,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onFilterToggle,
  });

  @override
  Widget build(BuildContext context) {
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
                controller: searchController,
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.5),
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 20),
                  suffixIcon: searchQuery.isNotEmpty
                      ? GestureDetector(
                    onTap: onClearSearch,
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
            onTap: onFilterToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: activeFilterCount > 0 || showFilterPanel
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
                    color: activeFilterCount > 0 || showFilterPanel
                        ? Colors.white
                        : const Color(0xFF1C1C1E),
                  ),
                  if (activeFilterCount > 0)
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
                            color: showFilterPanel ? const Color(0xFF1C1C1E) : Colors.white,
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
}



class FilterPanel extends StatelessWidget {
  final RangeValues priceRange;
  final double minRating;
  final bool onlyInStock;
  final PriceRange? availablePriceRange;
  final ValueChanged<RangeValues> onPriceRangeChanged;
  final ValueChanged<double> onRatingChanged;
  final ValueChanged<bool> onInStockChanged;
  final VoidCallback onReset;
  final VoidCallback onApply;

  const FilterPanel({
    super.key,
    required this.priceRange,
    required this.minRating,
    required this.onlyInStock,
    required this.availablePriceRange,
    required this.onPriceRangeChanged,
    required this.onRatingChanged,
    required this.onInStockChanged,
    required this.onReset,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Filters', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              GestureDetector(
                onTap: onReset,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Reset all',
                    style: TextStyle(color: Color(0xFF8E8E93), fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Price range
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Price Range', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '\$${priceRange.start.round()} – \$${priceRange.end.round()}',
                  style: const TextStyle(color: Color(0xFF1C1C1E), fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF1C1C1E),
              thumbColor: const Color(0xFF1C1C1E),
              inactiveTrackColor: const Color(0xFFE5E5EA),
              overlayColor: Colors.black12,
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: RangeSlider(
              values: priceRange,
              min: availablePriceRange?.min ?? 0,
              max: availablePriceRange?.max ?? 500,
              divisions: 50,
              onChanged: onPriceRangeChanged,
              onChangeEnd: (_) => onApply(),
            ),
          ),
          const SizedBox(height: 12),

          // Min rating
          const Text('Minimum Rating', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [0, 3, 3.5, 4, 4.5].map((r) {
              final val = r.toDouble();
              final isSelected = minRating == val;
              return GestureDetector(
                onTap: () => onRatingChanged(val),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 12,
                        color: isSelected ? Colors.amber.shade300 : Colors.grey.shade400,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        val == 0 ? 'Any' : '$val+',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // In stock toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('In Stock Only', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Switch.adaptive(
                  value: onlyInStock,
                  onChanged: onInStockChanged,
                  activeColor: const Color(0xFF1C1C1E),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: onApply,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1C1C1E),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Apply Filters',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class SortChips extends StatelessWidget {
  final String currentSort;
  final ValueChanged<String> onSortChanged;

  const SortChips({
    super.key,
    required this.currentSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final sorts = [
      {'label': 'Default', 'value': 'default'},
      {'label': 'Price ↑', 'value': 'price_asc'},
      {'label': 'Price ↓', 'value': 'price_desc'},
      {'label': 'Top Rated', 'value': 'rating'},
      {'label': 'Biggest Deal', 'value': 'discount'},
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SizedBox(
        height: 34,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: sorts.length,
          itemBuilder: (_, i) {
            final isSelected = currentSort == sorts[i]['value'];
            return GestureDetector(
              onTap: () => onSortChanged(sorts[i]['value']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1C1C1E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF1C1C1E) : const Color(0xFFE5E5EA),
                  ),
                ),
                child: Text(
                  sorts[i]['label']!,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


class ResultsBar extends StatelessWidget {
  final int productCount;
  final String? filterType;

  const ResultsBar({
    super.key,
    required this.productCount,
    this.filterType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        children: [
          RichText(
            text: TextSpan(
              text: '$productCount ',
              style: const TextStyle(
                color: Color(0xFF1C1C1E),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              children: [
                TextSpan(
                  text: productCount == 1 ? 'product' : 'products',
                  style: const TextStyle(
                    color: Color(0xFF8E8E93),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if (filterType == 'discounted')
                  const TextSpan(
                    text: ' on sale',
                    style: TextStyle(color: Color(0xFF8E8E93), fontWeight: FontWeight.w400),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



class ProductGridCard extends StatelessWidget {
  final ProductItem product;
  final bool isUpdatingWishlist;
  final Widget cartControl;
  final VoidCallback onWishlistTap;

  const ProductGridCard({
    super.key,
    required this.product,
    required this.isUpdatingWishlist,
    required this.cartControl,
    required this.onWishlistTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final bool isSoldOut = product.stock <= 0;

    // Responsive values based on screen width
    final borderRadius = screenWidth * 0.04;
    final imageHeight = screenHeight * 0.16;
    final discountFontSize = screenWidth * 0.022;
    final wishlistSize = screenWidth * 0.07;
    final wishlistIconSize = screenWidth * 0.035;
    final categoryFontSize = screenWidth * 0.02;
    final nameFontSize = screenWidth * 0.03;
    final ratingIconSize = screenWidth * 0.028;
    final ratingFontSize = screenWidth * 0.022;
    final oldPriceFontSize = screenWidth * 0.022;
    final currentPriceFontSize = screenWidth * 0.032;
    final soldOutFontSize = screenWidth * 0.025;
    final padding = screenWidth * 0.025;
    final spacing = screenHeight * 0.004;

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
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: screenWidth * 0.02,
              offset: Offset(0, screenHeight * 0.003),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Important: prevents overflow
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(borderRadius),
                  ),
                  child: ColorFiltered(
                    colorFilter: isSoldOut
                        ? const ColorFilter.matrix([
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0, 0, 0, 1, 0,
                    ])
                        : const ColorFilter.mode(
                      Colors.transparent,
                      BlendMode.multiply,
                    ),
                    child: _buildProductImage(
                      product.imageUrl,
                      width: double.infinity,
                      height: imageHeight,
                    ),
                  ),
                ),

                /// SOLD OUT
                if (isSoldOut)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(borderRadius),
                      ),
                      child: Container(
                        color: Colors.black.withOpacity(0.25),
                        alignment: Alignment.center,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.025,
                            vertical: screenHeight * 0.004,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.72),
                            borderRadius: BorderRadius.circular(screenWidth * 0.04),
                          ),
                          child: Text(
                            'Sold Out',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: soldOutFontSize,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                /// DISCOUNT
                if (product.hasDiscount && !isSoldOut)
                  Positioned(
                    top: screenHeight * 0.01,
                    left: screenWidth * 0.02,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.018,
                        vertical: screenHeight * 0.002,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade500,
                        borderRadius: BorderRadius.circular(screenWidth * 0.04),
                      ),
                      child: Text(
                        '-${product.discountPercent}%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: discountFontSize,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),

                /// WISHLIST
                Positioned(
                  top: screenHeight * 0.01,
                  right: screenWidth * 0.02,
                  child: GestureDetector(
                    onTap: isUpdatingWishlist ? null : onWishlistTap,
                    child: Container(
                      width: wishlistSize,
                      height: wishlistSize,
                      decoration: BoxDecoration(
                        color: product.isWishlisted
                            ? Colors.red.shade50
                            : Colors.white.withOpacity(0.92),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: screenWidth * 0.008,
                          ),
                        ],
                      ),
                      child: isUpdatingWishlist
                          ? SizedBox(
                        width: wishlistSize * 0.5,
                        height: wishlistSize * 0.5,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                          : Icon(
                        product.isWishlisted
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: wishlistIconSize,
                        color: product.isWishlisted
                            ? Colors.red.shade500
                            : Colors.grey.shade500,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            /// INFO - Removed Expanded, using padding only
            Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Important: prevents overflow
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// CATEGORY
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.015,
                      vertical: screenHeight * 0.002,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(screenWidth * 0.04),
                    ),
                    child: Text(
                      product.category.toUpperCase(),
                      style: TextStyle(
                        fontSize: categoryFontSize,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF8E8E93),
                      ),
                    ),
                  ),

                  SizedBox(height: spacing),

                  /// NAME
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: nameFontSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  SizedBox(height: spacing * 0.8),

                  /// RATING
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: Colors.amber.shade500,
                        size: ratingIconSize,
                      ),
                      SizedBox(width: screenWidth * 0.008),
                      Flexible(
                        child: Text(
                          '${product.rating} (${product.reviewCount})',
                          style: TextStyle(
                            fontSize: ratingFontSize,
                            color: const Color(0xFF8E8E93),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: spacing),

                  /// PRICE + CART
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product.hasDiscount)
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: oldPriceFontSize,
                                color: const Color(0xFFC7C7CC),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          Text(
                            '\$${product.currentPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: currentPriceFontSize,
                              fontWeight: FontWeight.w800,
                              color: isSoldOut
                                  ? Colors.grey.shade400
                                  : const Color(0xFF1C1C1E),
                            ),
                          ),
                        ],
                      ),
                      if (!isSoldOut) cartControl,
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

  Widget _buildProductImage(String? imageUrl, {double? width, double? height}) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return _imageFallback(width, height);
    }

    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Shimmer.fromColors(
          baseColor: const Color(0xFFE0E0E0),
          highlightColor: const Color(0xFFF5F5F5),
          child: Container(width: width, height: height, color: Colors.white),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return _imageFallback(width, height);
      },
    );
  }

  Widget _imageFallback(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFF2F2F7),
      child: Icon(
        Icons.image_not_supported_rounded,
        size: (width != null && width.isFinite) ? width * 0.2 : 32, // ← guard against infinity
        color: Colors.grey.shade300,
      ),
    );
  }
}

class ProductListTile extends StatelessWidget {
  final ProductItem product;
  final bool isUpdatingWishlist;
  final Widget cartControl;
  final VoidCallback onWishlistTap;

  const ProductListTile({
    super.key,
    required this.product,
    required this.isUpdatingWishlist,
    required this.cartControl,
    required this.onWishlistTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSoldOut = product.stock <= 0;
    final wishlistIconSize = MediaQuery.of(context).size.width * 0.06;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailsScreen(productId: product.id)),
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
                    product.imageUrl ?? '',
                    width: 92,
                    height: 92,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 92,
                        height: 92,
                        color: const Color(0xFFF2F2F7),
                        child: Icon(Icons.image_not_supported_rounded, size: 32, color: Colors.grey.shade300),
                      );
                    },
                  ),
                ),
                if (product.hasDiscount && !isSoldOut)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.shade500,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '-${product.discountPercent}%',
                        style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w800),
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          product.category.toUpperCase(),
                          style: const TextStyle(fontSize: 9, color: Color(0xFF8E8E93), fontWeight: FontWeight.w700, letterSpacing: 0.4),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: isUpdatingWishlist ? null : onWishlistTap,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: product.isWishlisted ? Colors.red.shade50 : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: isUpdatingWishlist
                              ? Center(                          // ← wrap in Center
                            child: SizedBox(
                              width: wishlistIconSize,     // ← use icon size, not container size
                              height: wishlistIconSize,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          )
                              : Icon(
                            product.isWishlisted
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: wishlistIconSize,
                            color: product.isWishlisted
                                ? Colors.red.shade500
                                : Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    product.name,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1C1C1E)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, color: Colors.amber.shade500, size: 12),
                      const SizedBox(width: 3),
                      Text(
                        '${product.rating} (${product.reviewCount})',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF8E8E93)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '\$${product.currentPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: isSoldOut ? Colors.grey.shade400 : const Color(0xFF1C1C1E),
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
                        ],
                      ),
                      if (isSoldOut)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F2F7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Sold Out',
                            style: TextStyle(color: Color(0xFF8E8E93), fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        )
                      else
                        cartControl,
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
}


class ShimmerGrid extends StatelessWidget {
  const ShimmerGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE0E0E0),
      highlightColor: const Color(0xFFF5F5F5),
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.67,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => _ShimmerCard(),
      ),
    );
  }
}

class ShimmerList extends StatelessWidget {
  const ShimmerList({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE0E0E0),
      highlightColor: const Color(0xFFF5F5F5),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        itemCount: 5,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 100,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(16)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 50, height: 11, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(width: double.infinity, height: 13, color: Colors.white),
                      const SizedBox(height: 6),
                      Container(width: 80, height: 11, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(width: 60, height: 14, color: Colors.white),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 150,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 13,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 80,
                  height: 11,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 70,
                  height: 15,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class EmptyState extends StatelessWidget {
  final VoidCallback onReset;

  const EmptyState({
    super.key,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.search_off_rounded, size: 38, color: Colors.grey.shade300),
          ),
          const SizedBox(height: 18),
          Text(
            'No products found',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 6),
          Text(
            'Try adjusting your filters',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onReset,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                'Reset Filters',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}