import 'package:afrotierre/Buyers_Screens/profile_screen.dart';
import 'package:afrotierre/Buyers_Screens/settings_screen.dart';
import 'package:afrotierre/Vendor_Screens/vendor_customers_screen.dart';
import 'package:afrotierre/Vendor_Screens/vendor_home_screen.dart';
import 'package:afrotierre/Vendor_Screens/vendor_orders_screen.dart';
import 'package:afrotierre/Vendor_Screens/vendor_product_screen.dart';
import 'package:afrotierre/Vendor_Screens/vendor_profile_screen.dart';
import 'package:afrotierre/constants.dart';
import 'package:flutter/material.dart';

class VendorBottomNavigationScreen extends StatefulWidget {
  const VendorBottomNavigationScreen({super.key});

  @override
  State<VendorBottomNavigationScreen> createState() =>
      _VendorBottomNavigationScreenState();
}

class _VendorBottomNavigationScreenState
    extends State<VendorBottomNavigationScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const VendorHomeScreen(),
    const VendorOrdersScreen(),
    // const VendorCustomersScreen(),
    const VendorProductScreen(),
    // const VendorProfileScreen(),
    const SettingsScreen(),
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
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_basket_outlined),
              label: 'Orders',
            ),
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.people_outline),
            //   label: 'Customers',
            // ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              label: 'Product',
            ),
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.person_outline),
            //   label: 'Profile',
            // ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              label: 'Settings',
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
