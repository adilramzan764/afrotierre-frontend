import 'package:afrotierre/Buyers_Screens/categories_products_screen.dart';
import 'package:afrotierre/constants.dart';
import 'package:flutter/material.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final List<Map<String, String>> _categories = [
    {'name': 'Health & Beauty', 'image': ''},
    {'name': 'Clothing & Fashion', 'image': ''},
    {'name': 'Technology & Device', 'image': ''},
    {'name': 'Toys & Handicrafts', 'image': ''},
    {'name': 'Sports & Training', 'image': ''},
    {'name': 'Home & Living', 'image': ''},
    {'name': 'Pets & Gardening', 'image': ''},
    {'name': 'Bath & Gardening', 'image': ''},
    {'name': 'Colognes & grooming', 'image': ''},
    {'name': 'Food & Beverages', 'image': ''},
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
          'Shop All Categories',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              // Navigator.pushNamed(context, searchScreen);
            },
            icon: const Icon(Icons.search, color: Colors.black),
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final category = _categories[index];
          return ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[200],
              backgroundImage: AssetImage("assets/stock_image.png"),
            ),
            title: Text(category['name']!),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CategoriesProductsScreen(categoryName: category['name']!),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
