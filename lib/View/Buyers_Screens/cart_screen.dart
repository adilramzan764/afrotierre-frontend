import 'package:flutter/material.dart';
import 'package:afrotierre/Models/BuyerModels/BuyerCartModels.dart';
import 'package:afrotierre/Repository/BuyerRepository/BuyerCartRepo.dart';
import 'package:afrotierre/Services/AppSession.dart';
import 'package:afrotierre/View/Buyers_Screens/checkout_screen.dart';
import 'package:afrotierre/res/Widgets/CustomSnackbar.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final BuyerCartRepo _cartRepo = BuyerCartRepo();
  final AppSession _session = AppSession.instance;

  bool _isLoading = true;
  List<CartItem> _cartItems = [];
  final Set<String> _updatingItems = {};

  @override
  void initState() {
    super.initState();
    _fetchCart();
  }

  Future<void> _fetchCart() async {
    setState(() => _isLoading = true);
    try {
      final token = _session.authToken;
      if (token == null || token.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final response = await _cartRepo.getCart(token, context: context);
      if (mounted && response.success) {
        setState(() {
          _cartItems = response.cart;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error fetching cart: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _removeItem(CartItem item) async {
    final productId = item.productDetails?.id ?? item.productId;
    print('Removing item with productId: $productId');

    setState(() => _updatingItems.add(productId));

    try {
      final token = _session.authToken;
      if (token == null) throw Exception('Not authenticated');

      final response = await _cartRepo.removeFromCart(
        token,
        productId,
        context: context,
      );

      if (mounted && response.success) {
        setState(() {
          _cartItems = response.cart;
        });
      }
    } catch (e) {
      print('Error removing item: $e');
      if (mounted) {
        CustomSnackbar.showError(context, 'Failed to remove item');
      }
    } finally {
      if (mounted) setState(() => _updatingItems.remove(productId));
    }
  }

  Future<void> _updateQuantity(CartItem item, int newQty) async {
    if (newQty < 1) {
      await _removeItem(item);
      return;
    }

    final productId = item.productDetails?.id ?? item.productId;
    setState(() => _updatingItems.add(productId));

    try {
      final token = _session.authToken;
      if (token == null) throw Exception('Not authenticated');

      final response = await _cartRepo.updateCartQuantity(
        token,
        UpdateCartQuantityRequest(productId: productId, quantity: newQty),
        context: context,
      );

      if (mounted && response.success) {
        setState(() {
          _cartItems = response.cart;
        });
      }
    } catch (e) {
      print('Error updating quantity: $e');
      if (mounted) {
        CustomSnackbar.showError(context, 'Failed to update quantity');
      }
    } finally {
      if (mounted) setState(() => _updatingItems.remove(productId));
    }
  }

  double get _subtotal => _cartItems.fold(0, (sum, item) {
    final price = item.productDetails?.price ?? 0;
    return sum + (price * item.quantity);
  });

  double get _discountTotal => _cartItems.fold(0, (sum, item) {
    final price = item.productDetails?.price ?? 0;
    final discounted = item.productDetails?.discountedPrice ?? price;
    return sum + ((price - discounted) * item.quantity);
  });

  double get _total => _subtotal - _discountTotal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: _buildAppBar(),
      body: _isLoading
          ? _buildSkeleton()
          : _cartItems.isEmpty
          ? _buildEmptyState()
          : _buildCartBody(),
      bottomNavigationBar:
      (!_isLoading && _cartItems.isNotEmpty) ? _buildCheckoutBar() : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF7F7F7),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Column(
        children: [
          const Text(
            'My Cart',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          if (!_isLoading && _cartItems.isNotEmpty)
            Text(
              '${_cartItems.length} item${_cartItems.length == 1 ? '' : 's'}',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
      centerTitle: true,
      actions: [
        if (!_isLoading && _cartItems.isNotEmpty)
          TextButton(
            onPressed: () => _clearCart(),
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
      ],
    );
  }

  Future<void> _clearCart() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to remove all items from your cart?'),
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

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      final token = _session.authToken;
      if (token == null) throw Exception('Not authenticated');

      final response = await _cartRepo.clearCart(token, context: context);
      if (mounted && response.success) {
        setState(() {
          _cartItems = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        CustomSnackbar.showError(context, 'Failed to clear cart');
      }
    }
  }

  Widget _buildCartBody() {
    return RefreshIndicator(
      onRefresh: _fetchCart,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: _cartItems.length,
        itemBuilder: (context, index) => _buildCartItem(_cartItems[index]),
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    final product = item.productDetails;
    final productId = product?.id ?? item.productId;
    final isUpdating = _updatingItems.contains(productId);
    final price = product?.price ?? 0;
    final discountedPrice = product?.discountedPrice ?? price;
    final hasDiscount = discountedPrice < price;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isUpdating ? 0.5 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Product image
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: _buildProductImage(product?.imageUrl, 90, 90),
              ),
              const SizedBox(width: 12),

              // Product info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product?.name ?? 'Product',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: isUpdating ? null : () => _removeItem(item),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.delete_outline_rounded,
                              size: 16,
                              color: Colors.red[400],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (product?.category != null)
                      Text(
                        product!.category!,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Price
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '\$${discountedPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            if (hasDiscount)
                              Text(
                                '\$${price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 11,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                          ],
                        ),
                        // Quantity controls
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              _quantityBtn(
                                icon: Icons.remove_rounded,
                                onTap: isUpdating
                                    ? null
                                    : () => _updateQuantity(item, item.quantity - 1),
                              ),
                              SizedBox(
                                width: 28,
                                child: isUpdating
                                    ? const Center(
                                  child: SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      color: Colors.black,
                                    ),
                                  ),
                                )
                                    : Text(
                                  item.quantity.toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              _quantityBtn(
                                icon: Icons.add_rounded,
                                isAdd: true,
                                onTap: isUpdating
                                    ? null
                                    : () => _updateQuantity(item, item.quantity + 1),
                              ),
                            ],
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
      ),
    );
  }

  Widget _quantityBtn({
    required IconData icon,
    bool isAdd = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isAdd ? Colors.black : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 15,
          color: isAdd ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildProductImage(String? url, double w, double h) {
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        width: w,
        height: h,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imagePlaceholder(w, h),
      );
    }
    return _imagePlaceholder(w, h);
  }

  Widget _imagePlaceholder(double w, double h) {
    return Container(
      width: w,
      height: h,
      color: Colors.grey[100],
      child: Icon(Icons.image_not_supported_outlined,
          color: Colors.grey[300], size: 28),
    );
  }

  Widget _buildCheckoutBar() {
    final hasDiscount = _discountTotal > 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasDiscount) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal',
                    style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                Text(
                  '\$${_subtotal.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Discount',
                  style: TextStyle(
                      color: Colors.green[600],
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                ),
                Text(
                  '-\$${_discountTotal.toStringAsFixed(2)}',
                  style: TextStyle(
                      color: Colors.green[600],
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Divider(color: Colors.grey[100], thickness: 1),
            ),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                '\$${_total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          if (hasDiscount) ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'You saved \$${_discountTotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CheckoutScreen()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Proceed to Checkout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 48,
              color: Colors.grey[350],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items to get started',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Start Shopping',
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: 3,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(width: 90, height: 90, color: Colors.grey[200]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 14, color: Colors.grey[200]),
                  const SizedBox(height: 8),
                  Container(width: 80, height: 12, color: Colors.grey[200]),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(width: 60, height: 16, color: Colors.grey[200]),
                      Container(width: 80, height: 32, color: Colors.grey[200]),
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