
import 'package:afrotierre/View/Buyers_Screens/profile_screen.dart';
import 'package:afrotierre/View/Buyers_Screens/settings_screen.dart';
import 'package:afrotierre/constants.dart';
import 'package:flutter/material.dart';

import 'BuyerWishlistScreen.dart';
import 'home_screen.dart';
import 'my_orders_screen.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const HomeScreen(),
    const MyOrdersScreen(),
    // const MarketplaceScreen(),
    const WishlistScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return Future.value(false);
      },
      child: Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_shopping_cart_sharp),
              label: 'My Orders',
            ),
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.shopping_cart_outlined),
            //   label: 'Marketplace',
            // ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline),
              label: 'My WishList',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
