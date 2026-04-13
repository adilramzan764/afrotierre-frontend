import 'package:afrotierre/View/Buyers_Screens/ProductListScreen.dart';
import 'package:afrotierre/View/Buyers_Screens/cart_screen.dart';
import 'package:afrotierre/View/Buyers_Screens/categories_screen.dart';
import 'package:afrotierre/View/Buyers_Screens/filters_screen.dart';
import 'package:afrotierre/View/Buyers_Screens/product_details_screen.dart';
import 'package:afrotierre/View/Buyers_Screens/search_screen.dart';
import 'package:afrotierre/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../Models/BuyerModels/BuyerHomeModels.dart';
import '../../Repository/BuyerRepository/BuyerHomeRepo.dart';
import '../../Services/AppSession.dart';
import '../../res/Widgets/CustomSnackbar.dart';
import '../../res/Widgets/ShimmerBox.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentBanner = 0;
  final PageController _bannerController = PageController();
  final BuyerHomeRepo _homeRepo = BuyerHomeRepo();
  final AppSession _session = AppSession.instance;

  // State variables
  bool _isLoading = true;
  HomeData? _homeData;
  String _userName = 'Guest';

  // Cache for category products
  final Map<String, List<ProductItem>> _categoryProductsCache = {};
  final Map<String, bool> _categoryLoadingCache = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchHomeData();
  }

  void _loadUserData() {
    final buyerProfile = _session.buyerProfile;
    setState(() {
      _userName = buyerProfile?.fullName?.split(' ').first ?? 'Guest';
    });
  }

  Future<void> _fetchHomeData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final token = _session.authToken;
      final response = await _homeRepo.getHomeData(
        token: token,
        context: context,
      );

      if (mounted && response.success) {
        setState(() {
          _homeData = response.data;
          _isLoading = false;
        });
        print('Home data loaded successfully');
        print(
          'Banners: ${_homeData!.banners.length}, Categories: ${_homeData!.categories.length}, Flash Sale: ${_homeData!.flashSale.length}, New Arrivals: ${_homeData!.newArrivals.length}',
        );
        print(
          'Banner Images: ${_homeData!.banners.map((b) => b.imageUrl).toList()}',
        );

        // Pre-fetch products for each category
        _prefetchCategoryProducts();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        CustomSnackbar.showError(context, 'Failed to load home data');
      }
      print('Error fetching home data: $e');
    }
  }

  Future<void> _prefetchCategoryProducts() async {
    if (_homeData == null) return;

    for (var category in _homeData!.categories) {
      _fetchCategoryProducts(category.name);
    }
  }

  Future<void> _fetchCategoryProducts(String categoryName) async {
    // Don't fetch if already cached or currently loading
    if (_categoryProductsCache.containsKey(categoryName) ||
        _categoryLoadingCache[categoryName] == true) {
      return;
    }

    setState(() {
      _categoryLoadingCache[categoryName] = true;
    });

    try {
      final token = _session.authToken;
      final response = await _homeRepo.getCategoryProducts(
        categoryId: categoryName,
        token: token,
        page: 1,
        limit: 6,
        // Fetch only 6 products for preview
        context: context,
      );

      if (mounted && response.success) {
        setState(() {
          _categoryProductsCache[categoryName] = response.data.products;
          _categoryLoadingCache[categoryName] = false;
        });
      } else {
        setState(() {
          _categoryLoadingCache[categoryName] = false;
        });
      }
    } catch (e) {
      print('Error fetching products for category $categoryName: $e');
      setState(() {
        _categoryLoadingCache[categoryName] = false;
      });
    }
  }

  void _handleCategoryTap(String categoryName) {
    // Navigate to ProductListScreen with category filter
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductListScreen(category: categoryName),
      ),
    );
  }

  void _handleBannerTap(BannerItem banner) {
    switch (banner.actionType) {
      case 'filter':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductListScreen(filter: banner.actionValue),
          ),
        );
        break;
      case 'category':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ProductListScreen(category: banner.actionValue),
          ),
        );
        break;
      case 'product':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                ProductDetailsScreen(productId: banner.actionValue ?? ''),
          ),
        );
        break;
      default:
        break;
    }
  }

  void _toggleWishlist(ProductItem product, int index, bool isFlashSale) async {
    // TODO: Call wishlist API
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive values based on screen width
    final horizontalPadding = screenWidth < 380 ? 12.0 : (screenWidth < 600 ? 16.0 : 24.0);
    final bannerHeight = screenWidth < 380 ? 150.0 : (screenWidth < 600 ? 175.0 : 220.0);
    final productCardWidth = screenWidth < 380 ? 140.0 : (screenWidth < 600 ? 155.0 : 200.0);
    final productImageHeight = screenWidth < 380 ? 130.0 : (screenWidth < 600 ? 145.0 : 180.0);
    final categorySize = screenWidth < 380 ? 60.0 : (screenWidth < 600 ? 70.0 : 90.0);
    final categoryTextSize = screenWidth < 380 ? 10.0 : (screenWidth < 600 ? 12.0 : 14.0);
    final sectionTitleSize = screenWidth < 380 ? 16.0 : (screenWidth < 600 ? 18.0 : 22.0);
    final gridCrossAxisCount = screenWidth < 380 ? 2 : (screenWidth < 600 ? 2 : (screenWidth > 900 ? 4 : 3));
    final gridChildAspectRatio = screenWidth < 380 ? 0.8 : (screenWidth < 600 ? 0.79 : 0.75);
    final bannerButtonTextSize = screenWidth < 380 ? 10.0 : (screenWidth < 600 ? 11.0 : 12.0);
    final bannerTitleSize = screenWidth < 380 ? 20.0 : (screenWidth < 600 ? 26.0 : 32.0);
    final bannerSubtitleSize = screenWidth < 380 ? 10.0 : (screenWidth < 600 ? 11.0 : 12.0);
    final avatarRadius = screenWidth < 380 ? 20.0 : (screenWidth < 600 ? 24.0 : 28.0);
    final iconSize = screenWidth < 380 ? 22.0 : (screenWidth < 600 ? 26.0 : 28.0);
    final searchBarHeight = screenWidth < 380 ? 42.0 : (screenWidth < 600 ? 48.0 : 52.0);
    final categoryCircleRadius = screenWidth < 380 ? 28.0 : (screenWidth < 600 ? 35.0 : 45.0);
    final categoryImageSize = screenWidth < 380 ? 32.0 : (screenWidth < 600 ? 40.0 : 50.0);
    final productPriceSize = screenWidth < 380 ? 12.0 : (screenWidth < 600 ? 14.0 : 16.0);
    final productNameSize = screenWidth < 380 ? 11.0 : (screenWidth < 600 ? 13.0 : 14.0);
    final productRatingSize = screenWidth < 380 ? 10.0 : (screenWidth < 600 ? 11.0 : 12.0);
    final flashSaleHeight = screenWidth < 380 ? 200.0 : (screenWidth < 600 ? 230.0 : 280.0);
    final categoryListHeight = screenWidth < 380 ? 80.0 : (screenWidth < 600 ? 95.0 : 115.0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchHomeData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: _buildHeader(avatarRadius: avatarRadius, iconSize: iconSize),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: _buildSearchBar(searchBarHeight: searchBarHeight, iconSize: iconSize),
                ),
                const SizedBox(height: 20),

                if (_isLoading) _buildSkeletonLoader(
                  horizontalPadding: horizontalPadding,
                  bannerHeight: bannerHeight,
                  categoryListHeight: categoryListHeight,
                  flashSaleHeight: flashSaleHeight,
                  productImageHeight: productImageHeight,
                  productCardWidth: productCardWidth,
                  gridCrossAxisCount: gridCrossAxisCount,
                  gridChildAspectRatio: gridChildAspectRatio,
                )

                else if (_homeData != null) ...[
                  // Banner carousel
                  if (_homeData!.banners.isNotEmpty)
                    _buildBannerCarousel(
                      _homeData!.banners,
                      bannerHeight: bannerHeight,
                      bannerTitleSize: bannerTitleSize,
                      bannerSubtitleSize: bannerSubtitleSize,
                      bannerButtonTextSize: bannerButtonTextSize,
                      horizontalPadding: horizontalPadding,
                    ),
                  if (_homeData!.banners.isNotEmpty) const SizedBox(height: 24),

                  // Categories
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: _buildSectionHeader(
                      title: 'Categories',
                      sectionTitleSize: sectionTitleSize,
                      onSeeAll:
                          () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CategoriesScreen(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildCategories(
                    _homeData!.categories,
                    categoryCircleRadius: categoryCircleRadius,
                    categoryImageSize: categoryImageSize,
                    categoryTextSize: categoryTextSize,
                    categoryListHeight: categoryListHeight,
                  ),
                  const SizedBox(height: 24),

                  // Flash Sale section
                  if (_homeData!.flashSale.isNotEmpty) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: _buildSectionHeader(
                        title: 'Flash Sale',
                        sectionTitleSize: sectionTitleSize,
                        badge: '${_homeData!.flashSale.length} items',
                        onSeeAll: () {
                          print('See all flash sale items');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                  ProductListScreen(filter: 'discounted'),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: flashSaleHeight,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        itemCount: _homeData!.flashSale.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 14),
                            child: SizedBox(
                              width: productCardWidth,
                              child: _buildProductCard(
                                _homeData!.flashSale[index],
                                index: index,
                                isFlashSale: true,
                                productImageHeight: productImageHeight,
                                productNameSize: productNameSize,
                                productRatingSize: productRatingSize,
                                productPriceSize: productPriceSize,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // New Arrivals section
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: _buildSectionHeader(
                      title: 'New Arrivals',
                      sectionTitleSize: sectionTitleSize,
                      onSeeAll: () {
                        print('See all new arrivals');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                ProductListScreen(filter: 'newest'),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridCrossAxisCount,
                      childAspectRatio: gridChildAspectRatio,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemCount:
                    _homeData!.newArrivals.length > 4
                        ? 4
                        : _homeData!.newArrivals.length,
                    itemBuilder:
                        (context, index) => _buildProductCard(
                      _homeData!.newArrivals[index],
                      index: index,
                      isFlashSale: false,
                      productImageHeight: productImageHeight,
                      productNameSize: productNameSize,
                      productRatingSize: productRatingSize,
                      productPriceSize: productPriceSize,
                    ),
                  ),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader({required double avatarRadius, required double iconSize}) {
    // Get profile picture URL safely
    String? profileImageUrl;
    final buyerProfile = _session.buyerProfile;

    if (buyerProfile?.profilePicture != null) {
      if (buyerProfile!.profilePicture is Map) {
        profileImageUrl = buyerProfile.profilePicture!['url'] as String?;
      } else if (buyerProfile.profilePicture is String) {
        profileImageUrl = buyerProfile.profilePicture as String?;
      }
    }

    return Row(
      children: [
        CircleAvatar(
          radius: avatarRadius,
          backgroundImage:
          profileImageUrl != null
              ? NetworkImage(profileImageUrl)
              : const AssetImage("assets/stock_image.png") as ImageProvider,
          backgroundColor: Colors.grey[200],
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome Back',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Text(
              _userName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: avatarRadius * 0.7),
            ),
          ],
        ),
        const Spacer(),
        Stack(
          children: [
            IconButton(
              onPressed:
                  () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              ),
              icon: Icon(Icons.shopping_cart_outlined, size: iconSize),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.notifications_outlined, size: iconSize),
        ),
      ],
    );
  }

  // ── Search Bar ────────────────────────────────────────────────────────────
  Widget _buildSearchBar({required double searchBarHeight, required double iconSize}) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap:
                () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchScreen()),
            ),
            child: Container(
              height: searchBarHeight,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(Icons.search, color: Colors.grey[400], size: iconSize * 0.8),
                  const SizedBox(width: 8),
                  Text(
                    'Search products...',
                    style: TextStyle(color: Colors.grey[400], fontSize: searchBarHeight * 0.3),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: searchBarHeight,
          height: searchBarHeight,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(14),
          ),
          child: IconButton(
            onPressed:
                () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FiltersScreen(),
              ),
            ),
            icon: Icon(Icons.tune_rounded, size: iconSize * 0.85),
          ),
        ),
      ],
    );
  }

  // ── Banner Carousel ───────────────────────────────────────────────────────
  Widget _buildBannerCarousel(
      List<BannerItem> banners, {
        required double bannerHeight,
        required double bannerTitleSize,
        required double bannerSubtitleSize,
        required double bannerButtonTextSize,
        required double horizontalPadding,
      }) {
    return Column(
      children: [
        SizedBox(
          height: bannerHeight,
          child: PageView.builder(
            controller: _bannerController,
            onPageChanged: (i) => setState(() => _currentBanner = i),
            itemCount: banners.length,
            itemBuilder: (_, i) => _buildBannerCard(
              banners[i],
              bannerTitleSize: bannerTitleSize,
              bannerSubtitleSize: bannerSubtitleSize,
              bannerButtonTextSize: bannerButtonTextSize,
              horizontalPadding: horizontalPadding,
            ),
          ),
        ),
        if (banners.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              banners.length,
                  (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _currentBanner == i ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color:
                  _currentBanner == i ? Colors.black : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBannerCard(
      BannerItem banner, {
        required double bannerTitleSize,
        required double bannerSubtitleSize,
        required double bannerButtonTextSize,
        required double horizontalPadding,
      }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 0, 16),
        decoration: BoxDecoration(
          color: _hexToColor(banner.backgroundColor ?? '#FFFFFF'),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (banner.tag != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        banner.tag!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (banner.tag != null) const SizedBox(height: 8),
                  if (banner.title != null)
                    Text(
                      banner.title!,
                      style: TextStyle(
                        fontSize: bannerTitleSize,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                  if (banner.title != null) const SizedBox(height: 4),
                  if (banner.subtitle != null)
                    Text(
                      banner.subtitle!,
                      style: TextStyle(
                        fontSize: bannerSubtitleSize,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (banner.buttonText != null) ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => _handleBannerTap(banner),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          banner.buttonText!,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: bannerButtonTextSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(20),
              ),
              child: SizedBox(
                width: 120,
                height: 180,
                child: SvgPicture.asset(
                  'assets/flash_sale_right_image_v2.svg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section Header ────────────────────────────────────────────────────────
  Widget _buildSectionHeader({
    required String title,
    required double sectionTitleSize,
    String? badge,
    required VoidCallback onSeeAll,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: sectionTitleSize),
        ),
        if (badge != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badge,
              style: TextStyle(
                color: Colors.red.shade400,
                fontSize: sectionTitleSize * 0.6,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        const Spacer(),
        GestureDetector(
          onTap: onSeeAll,
          child: Text(
            'See All',
            style: TextStyle(color: Colors.grey.shade500, fontSize: sectionTitleSize * 0.7),
          ),
        ),
      ],
    );
  }

  // ── Categories ────────────────────────────────────────────────────────────
  Widget _buildCategories(
      List<CategoryItem> categories, {
        required double categoryCircleRadius,
        required double categoryImageSize,
        required double categoryTextSize,
        required double categoryListHeight,
      }) {
    return SizedBox(
      height: categoryListHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return GestureDetector(
            onTap: () => _handleCategoryTap(cat.name),
            child: Padding(
              padding: const EdgeInsets.only(right: 18),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: categoryCircleRadius,
                    backgroundColor: Colors.grey[100],
                    child: ClipOval(
                      child:
                      cat.imageUrl != null
                          ? Image.network(
                        cat.imageUrl!,
                        width: categoryImageSize,
                        height: categoryImageSize,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/stock_image.png',
                            width: categoryImageSize,
                            height: categoryImageSize,
                            fit: BoxFit.contain,
                          );
                        },
                      )
                          : Image.asset(
                        'assets/stock_image.png',
                        width: categoryImageSize,
                        height: categoryImageSize,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cat.name,
                    style: TextStyle(
                      fontSize: categoryTextSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Product Card ──────────────────────────────────────────────────────────
  Widget _buildProductCard(
      ProductItem product, {
        required int index,
        required bool isFlashSale,
        required double productImageHeight,
        required double productNameSize,
        required double productRatingSize,
        required double productPriceSize,
      }) {
    return GestureDetector(
      onTap:
          () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailsScreen(productId: product.id),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: _buildProductImage(
                    product.imageUrl,
                    width: double.infinity,
                    height: productImageHeight,
                  ),
                ),
                // Discount badge
                if (product.hasDiscount)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade500,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '-${product.discountPercent}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: productNameSize,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Rating
                  Row(
                    children: [
                      Icon(Icons.star_rounded, color: primaryColor, size: productRatingSize + 2),
                      const SizedBox(width: 3),
                      Text(
                        '${product.rating}(${product.reviewCount})',
                        style: TextStyle(
                          fontSize: productRatingSize,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Price
                  if (product.hasDiscount)
                    Row(
                      children: [
                        Text(
                          '\$${product.currentPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: productPriceSize,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: productPriceSize - 3,
                            color: Colors.grey.shade400,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: productPriceSize,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build product image
  Widget _buildProductImage(String? imageUrl, {double? height, double? width}) {
    if (imageUrl != null &&
        (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'))) {
      return Image.network(
        imageUrl,
        height: height,
        width: width,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: height,
            width: width,
            color: Colors.grey[200],
            child: const Icon(Icons.image_not_supported),
          );
        },
      );
    }

    return Container(
      height: height,
      width: width,
      color: Colors.grey[200],
      child: const Icon(Icons.image_not_supported),
    );
  }

  Widget _buildSkeletonLoader({
    required double horizontalPadding,
    required double bannerHeight,
    required double categoryListHeight,
    required double flashSaleHeight,
    required double productImageHeight,
    required double productCardWidth,
    required int gridCrossAxisCount,
    required double gridChildAspectRatio,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Banner skeleton
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: ShimmerBox(
            width: double.infinity,
            height: bannerHeight,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(height: 10),
        // Dot indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: ShimmerBox(
              width: i == 0 ? 20 : 6,
              height: 6,
              borderRadius: BorderRadius.circular(3),
            ),
          )),
        ),
        const SizedBox(height: 24),

        // Categories section header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: _buildSkeletonSectionHeader(),
        ),
        const SizedBox(height: 14),
        _buildSkeletonCategories(categoryListHeight: categoryListHeight),
        const SizedBox(height: 24),

        // Flash sale section header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: _buildSkeletonSectionHeader(),
        ),
        const SizedBox(height: 14),
        _buildSkeletonFlashSale(
          flashSaleHeight: flashSaleHeight,
          productImageHeight: productImageHeight,
          productCardWidth: productCardWidth,
        ),
        const SizedBox(height: 24),

        // New arrivals section header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: _buildSkeletonSectionHeader(),
        ),
        const SizedBox(height: 14),
        _buildSkeletonGrid(
          productImageHeight: productImageHeight,
          gridCrossAxisCount: gridCrossAxisCount,
          gridChildAspectRatio: gridChildAspectRatio,
        ),
      ],
    );
  }

  Widget _buildSkeletonSectionHeader() {
    return Row(
      children: [
        ShimmerBox(
          width: 120,
          height: 18,
          borderRadius: BorderRadius.circular(6),
        ),
        const Spacer(),
        ShimmerBox(
          width: 50,
          height: 13,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
    );
  }

  Widget _buildSkeletonCategories({required double categoryListHeight}) {
    return SizedBox(
      height: categoryListHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 5,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(right: 18),
          child: Column(
            children: [
              ShimmerBox(
                width: categoryListHeight * 0.7,
                height: categoryListHeight * 0.7,
                borderRadius: BorderRadius.circular(35),
              ),
              const SizedBox(height: 6),
              ShimmerBox(
                width: 52,
                height: 10,
                borderRadius: BorderRadius.circular(5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonFlashSale({
    required double flashSaleHeight,
    required double productImageHeight,
    required double productCardWidth,
  }) {
    return SizedBox(
      height: flashSaleHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 3,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(right: 14),
          child: _buildSkeletonProductCard(
            width: productCardWidth,
            imageHeight: productImageHeight,
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonGrid({
    required double productImageHeight,
    required int gridCrossAxisCount,
    required double gridChildAspectRatio,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridCrossAxisCount,
        childAspectRatio: gridChildAspectRatio,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: 4,
      itemBuilder: (_, __) => _buildSkeletonProductCard(imageHeight: productImageHeight),
    );
  }

  Widget _buildSkeletonProductCard({double? width, required double imageHeight}) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(
            width: width ?? double.infinity,
            height: imageHeight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(
                  width: 100,
                  height: 12,
                  borderRadius: BorderRadius.circular(6),
                ),
                const SizedBox(height: 6),
                ShimmerBox(
                  width: 70,
                  height: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
                const SizedBox(height: 8),
                ShimmerBox(
                  width: 60,
                  height: 14,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _hexToColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.white;
    }
  }
}