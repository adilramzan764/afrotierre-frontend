import 'package:afrotierre/constants.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Placeholder data for cart items
  final List<Map<String, dynamic>> _cartItems = [
    {
      'name': 'Unisex Black Duffle Bag',
      'size': 'S-Large',
      'price': 2400.0,
      'originalPrice': 2400.0,
      'image': 'assets/stock_image.png', // Placeholder
      'quantity': 1,
      'color': Colors.grey[200],
    },
    {
      'name': 'Unisex Black Duffle Bag',
      'size': 'S-Large',
      'price': 2400.0,
      'originalPrice': 2410.0,
      'image': 'assets/stock_image.png', // Placeholder
      'quantity': 1,
      'color': Colors.red[100],
    },
    {
      'name': 'Unisex Black Duffle Bag',
      'size': 'S-Large',
      'price': 2400.0,
      'originalPrice': 2400.0,
      'image': 'assets/stock_image.png', // Placeholder
      'quantity': 1,
      'color': Colors.grey[200],
    },
    {
      'name': 'Unisex Black Duffle Bag',
      'size': 'S-Large',
      'price': 2400.0,
      'originalPrice': 2410.0,
      'image': 'assets/stock_image.png', // Placeholder
      'quantity': 1,
      'color': Colors.red[100],
    },
    {
      'name': 'Unisex Black Duffle Bag',
      'size': 'S-Large',
      'price': 2400.0,
      'originalPrice': 2400.0,
      'image': 'assets/stock_image.png', // Placeholder
      'quantity': 1,
      'color': Colors.grey[200],
    },
  ];

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
          'Cart',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: _cartItems.length,
        itemBuilder: (context, index) {
          return _buildCartItem(index);
        },
      ),
      bottomNavigationBar: _buildCheckoutSection(),
    );
  }

  Widget _buildCartItem(int index) {
    final item = _cartItems[index];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: item['color'],
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: AssetImage(item['image']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(item['size'], style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '\$${item['price'].toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '\$${item['originalPrice'].toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.grey),
                onPressed: () {
                  setState(() {
                    _cartItems.removeAt(index);
                  });
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildQuantityButton(
                    icon: Icons.remove,
                    onPressed: () {
                      if (item['quantity'] > 1) {
                        setState(() {
                          item['quantity']--;
                        });
                      }
                    },
                    isAdd: false,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      item['quantity'].toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  _buildQuantityButton(
                    icon: Icons.add,
                    onPressed: () {
                      setState(() {
                        item['quantity']++;
                      });
                    },
                    isAdd: true,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isAdd,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isAdd ? Colors.black : Colors.grey[200],
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: isAdd ? Colors.white : Colors.black),
      ),
    );
  }

  Widget _buildCheckoutSection() {
    double total = _cartItems.fold(
      0,
      (sum, item) => sum + (item['price'] * item['quantity']),
    );
    double originalTotal = _cartItems.fold(
      0,
      (sum, item) => sum + (item['originalPrice'] * item['quantity']),
    );
    double discount = originalTotal - total;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total payment',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                '\$${total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'You saved \$${discount.toStringAsFixed(0)} with this discount',
                style: const TextStyle(color: Colors.grey),
              ),
              Row(
                children: [
                  Text(
                    '\$${originalTotal.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_up, color: Colors.grey),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, checkoutScreen);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Checkout',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
