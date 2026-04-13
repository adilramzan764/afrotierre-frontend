import 'package:afrotierre/constants.dart';
import 'package:flutter/material.dart';

class FiltersScreen extends StatefulWidget {
  const FiltersScreen({super.key});

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  final List<String> _categories = [
    'Health',
    'Clothing',
    'Beddings',
    'Pets',
    'Technology',
    'Baby Toys',
    'Bathroom',
    'Sports & Training',
    'Home Wares',
    'Tools',
    'Food & Beverages',
    'Clothes',
  ];

  final List<String> _brands = ['Adidas', 'Hisense', 'Samsung'];

  String? _selectedCategory;
  final Set<String> _selectedBrands = {};
  RangeValues _priceRange = const RangeValues(10, 200);
  int _selectedRating = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        title: const Text(
          'Filter',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedCategory = null;
                _selectedBrands.clear();
                _priceRange = const RangeValues(10, 200);
                _selectedRating = 0;
              });
            },
            child: const Text('Reset', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Category'),
            _buildCategoryChips(),
            const SizedBox(height: 24),
            _buildSectionTitle('Brands', showViewAll: true),
            _buildBrandChips(),
            const SizedBox(height: 24),
            _buildSectionTitle('Price ranges'),
            _buildPriceRange(),
            const SizedBox(height: 24),
            _buildRatingSelector(),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            'Save',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool showViewAll = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        if (showViewAll)
          TextButton(
            onPressed: () {},
            child: const Text('View all', style: TextStyle(color: Colors.grey)),
          ),
      ],
    );
  }

  Widget _buildCategoryChips() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: _categories.map((category) {
        final isSelected = _selectedCategory == category;
        return ChoiceChip(
          label: Text(category),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedCategory = selected ? category : null;
            });
          },
          backgroundColor: Colors.grey[200],
          selectedColor: primaryColor.withOpacity(0.2),
          labelStyle: TextStyle(
            color: isSelected ? primaryColor : Colors.black,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected ? primaryColor : Colors.grey[300]!,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBrandChips() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: _brands.map((brand) {
        final isSelected = _selectedBrands.contains(brand);
        return FilterChip(
          label: Text(brand),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedBrands.add(brand);
              } else {
                _selectedBrands.remove(brand);
              }
            });
          },
          avatar: isSelected
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : null,
          backgroundColor: Colors.grey[200],
          selectedColor: Colors.black,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected ? Colors.black : Colors.grey[300]!,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriceRange() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Min', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: TextEditingController(
                      text: '\$${_priceRange.start.toStringAsFixed(2)}',
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Max', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: TextEditingController(
                      text: '\$${_priceRange.end.toStringAsFixed(0)}',
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        RangeSlider(
          values: _priceRange,
          min: 0,
          max: 500,
          divisions: 50,
          activeColor: Colors.black,
          inactiveColor: Colors.grey[300],
          onChanged: (values) {
            setState(() {
              _priceRange = values;
            });
          },
        ),
      ],
    );
  }

  Widget _buildRatingSelector() {
    return Column(
      children: List.generate(5, (index) {
        final rating = 5 - index;
        return RadioListTile<int>(
          value: rating,
          groupValue: _selectedRating,
          onChanged: (value) {
            setState(() {
              _selectedRating = value!;
            });
          },
          title: Row(
            children: [
              ...List.generate(5, (starIndex) {
                return Icon(
                  starIndex < rating ? Icons.star : Icons.star_border,
                  color: Colors.orange,
                  size: 20,
                );
              }),
              const SizedBox(width: 8),
              const Text('& above', style: TextStyle(color: Colors.grey)),
            ],
          ),
          activeColor: Colors.black,
        );
      }),
    );
  }
}
