import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:afrotierre/Repository/SellerRepository/SellerProductsRepo.dart';


import '../../Models/SellerModels/SellerProductModels.dart';
import '../../res/Widgets/CustomSnackbar.dart';

class VendorAddProductScreen extends StatefulWidget {
  const VendorAddProductScreen({super.key});

  @override
  State<VendorAddProductScreen> createState() => _VendorAddProductScreenState();
}

class _VendorAddProductScreenState extends State<VendorAddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late final SellerProductsRepo _productsRepo;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountedPriceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  // Change from TextEditingController to dropdown
  String? _selectedCategory;
  List<String> _availableCategories = [];
  bool _isLoadingCategories = true;

  // Dynamic attributes: list of {key, value} controllers
  final List<Map<String, TextEditingController>> _attributes = [];

  // Colors
  final List<Map<String, dynamic>> _availableColors = [
    {'name': 'Red', 'color': Colors.red},
    {'name': 'Blue', 'color': Colors.blue},
    {'name': 'Green', 'color': Colors.green},
    {'name': 'Black', 'color': Colors.black},
    {'name': 'White', 'color': Colors.white},
    {'name': 'Yellow', 'color': Colors.yellow},
    {'name': 'Purple', 'color': Colors.purple},
    {'name': 'Orange', 'color': Colors.orange},
    {'name': 'Pink', 'color': const Color(0xFFE91E8C)},
    {'name': 'Grey', 'color': Colors.grey},
    {'name': 'Brown', 'color': Colors.brown},
    {'name': 'Teal', 'color': Colors.teal},
  ];
  final List<String> _selectedColors = [];

  // Images (up to 5)
  final List<File> _selectedImages = [];

  // Loading states
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _productsRepo = SellerProductsRepo();
    _loadSellerCategories();
  }

  Future<void> _loadSellerCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });

    try {
      final response = await _productsRepo.getSellerAllowedCategories();

      if (response.success && response.categories.isNotEmpty) {
        setState(() {
          _availableCategories = response.categories;
          _isLoadingCategories = false;
        });
        print('✅ Loaded categories: $_availableCategories');
      } else {
        // Fallback to default categories if API fails
        setState(() {
          _availableCategories = [
            'Socks', 'Scarf', 'Shoes', 'Bags', 'Jewelry',
            'Hats', 'Belts', 'Watches', 'Glasses'
          ];
          _isLoadingCategories = false;
        });
        print('⚠️ Using fallback categories');
      }
    } catch (e) {
      print('❌ Error loading categories: $e');
      setState(() {
        _availableCategories = [
          'Socks', 'Scarf', 'Shoes', 'Bags', 'Jewelry',
          'Hats', 'Belts', 'Watches', 'Glasses'
        ];
        _isLoadingCategories = false;
      });
    }
  }

  void _addAttribute() {
    setState(() {
      _attributes.add({
        'key': TextEditingController(),
        'value': TextEditingController(),
      });
    });
  }

  void _removeAttribute(int index) {
    _attributes[index]['key']!.dispose();
    _attributes[index]['value']!.dispose();
    setState(() => _attributes.removeAt(index));
  }

  // Quick-fill suggestions for attribute keys
  final List<String> _attributeSuggestions = [
    'Size', 'Material', 'Warranty', 'Weight', 'Brand',
    'Color', 'Model', 'Origin', 'Care', 'Style',
  ];

  Future<File?> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) return File(picked.path);
    return null;
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Select Image Source",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text("Gallery"),
              onTap: () async {
                Navigator.pop(context);
                final file = await _pickImage(ImageSource.gallery);
                if (file != null && _selectedImages.length < 5) {
                  setState(() => _selectedImages.add(file));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text("Camera"),
              onTap: () async {
                Navigator.pop(context);
                final file = await _pickImage(ImageSource.camera);
                if (file != null && _selectedImages.length < 5) {
                  setState(() => _selectedImages.add(file));
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String? _discountPercent() {
    final original = double.tryParse(_priceController.text);
    final discounted = double.tryParse(_discountedPriceController.text);
    if (original != null &&
        discounted != null &&
        original > 0 &&
        discounted < original) {
      final percent = ((original - discounted) / original * 100).round();
      return '$percent% off';
    }
    return null;
  }

// In your VendorAddProductScreen.dart, update the _saveProduct method:

  Future<void> _saveProduct({required bool isDraft}) async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      print('❌ Form validation failed');
      return;
    }

    // Validate category
    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      CustomSnackbar.showError(context, 'Please select a category');
      return;
    }

    // Validate images (at least one image required for published products)
    if (!isDraft && _selectedImages.isEmpty) {
      CustomSnackbar.showError(context, 'Please add at least one product image');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Parse price and stock
      final double price = double.tryParse(_priceController.text) ?? 0.0;
      final int stock = int.tryParse(_stockController.text) ?? 0;

      if (price <= 0) {
        CustomSnackbar.showError(context, 'Price must be greater than 0');
        setState(() => _isSubmitting = false);
        return;
      }

      // Build attributes map
      final Map<String, dynamic> attributes = {};
      for (final attr in _attributes) {
        final key = attr['key']!.text.trim();
        final value = attr['value']!.text.trim();
        if (key.isNotEmpty && value.isNotEmpty) {
          attributes[key] = value;
        }
      }

      print('📦 Creating product:');
      print('   Name: ${_nameController.text}');
      print('   Price: $price');
      print('   Stock: $stock');
      print('   Category: $_selectedCategory');
      print('   Colors: $_selectedColors');
      print('   Attributes: $attributes');
      print('   Images: ${_selectedImages.length}');
      print('   Is Draft: $isDraft');

      // Create request - IMPORTANT: draft is explicitly set
      final request = CreateProductRequest(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: price,
        discountedPrice: _discountedPriceController.text.isNotEmpty
            ? double.tryParse(_discountedPriceController.text)
            : null,
        stock: stock,
        category: _selectedCategory!,
        colors: _selectedColors,
        attributes: attributes,
        sizes: [],
        materials: [],
        draft: isDraft, // This is already correct - false for publish, true for draft
      );

      // Call API
      final response = await _productsRepo.createProduct(
        request: request,
        images: _selectedImages.isNotEmpty ? _selectedImages : null,
      );

      print('📦 API Response: success=${response.success}, message=${response.message}');

      if (response.success) {
        CustomSnackbar.showSuccess(
          context,
          isDraft ? 'Product saved as draft successfully!' : 'Product published successfully!',
        );

        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        String errorMessage = response.message;
        if (response.error != null) {
          errorMessage = response.error!;
        }
        CustomSnackbar.showError(context, errorMessage);
        print('❌ API Error: ${response.error}');
      }
    } catch (e) {
      print('❌ Exception: $e');
      CustomSnackbar.showError(context, 'Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountedPriceController.dispose();
    _stockController.dispose();
    for (final attr in _attributes) {
      attr['key']!.dispose();
      attr['value']!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F6F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Header
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.arrow_back, size: 18),
                        ),
                      ),
                    ),
                    const Text(
                      "Add Product",
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Basic Info ──────────────────────────────────────
                        _sectionHeader("Basic Information"),
                        const SizedBox(height: 12),

                        _buildLabel("Product Name"),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _nameController,
                          hint: "Enter product name...",
                          validator: (v) =>
                          v == null || v.isEmpty ? "Name is required" : null,
                        ),
                        const SizedBox(height: 16),

                        _buildLabel("Description"),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _descriptionController,
                          hint: "Describe your product...",
                          maxLines: 4,
                          validator: (v) => v == null || v.isEmpty
                              ? "Description is required"
                              : null,
                        ),
                        const SizedBox(height: 16),

                        // Category Dropdown
                        _buildLabel("Category"),
                        const SizedBox(height: 8),
                        _buildCategoryDropdown(),

                        const SizedBox(height: 24),

                        // ── Pricing & Stock ─────────────────────────────────
                        _sectionHeader("Pricing & Inventory"),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel("Price (\$)"),
                                  const SizedBox(height: 8),
                                  _buildTextField(
                                    controller: _priceController,
                                    hint: "0.00",
                                    keyboardType: TextInputType.number,
                                    prefixText: "\$ ",
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d+\.?\d{0,2}')),
                                    ],
                                    validator: (v) =>
                                    v == null || v.isEmpty ? "Required" : null,
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel("Stock"),
                                  const SizedBox(height: 8),
                                  _buildTextField(
                                    controller: _stockController,
                                    hint: "0",
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    validator: (v) =>
                                    v == null || v.isEmpty ? "Required" : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        _buildLabel("Discounted Price (\$)", required: false),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _discountedPriceController,
                                hint: "0.00",
                                keyboardType: TextInputType.number,
                                prefixText: "\$ ",
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d+\.?\d{0,2}')),
                                ],
                                required: false,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return null;
                                  final original =
                                  double.tryParse(_priceController.text);
                                  final discounted = double.tryParse(v);
                                  if (original == null || discounted == null)
                                    return null;
                                  if (discounted >= original) {
                                    return "Must be less than original price";
                                  }
                                  return null;
                                },
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            const SizedBox(width: 12),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: _discountPercent() != null
                                  ? Container(
                                key: const ValueKey('badge'),
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade600,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _discountPercent()!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              )
                                  : const SizedBox(
                                  key: ValueKey('empty'), width: 0),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // ── Colors ──────────────────────────────────────────
                        Row(
                          children: [
                            Expanded(child: _sectionHeader("Colors")),
                            _optionalBadge(),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildColorSelector(),

                        const SizedBox(height: 24),

                        // ── Dynamic Attributes ──────────────────────────────
                        Row(
                          children: [
                            Expanded(child: _sectionHeader("Attributes")),
                            _optionalBadge(),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Add any product details: size, material, warranty, etc.",
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500),
                        ),
                        const SizedBox(height: 12),

                        // Suggestion chips
                        _buildAttributeSuggestions(),
                        const SizedBox(height: 12),

                        // Attribute rows
                        ..._attributes.asMap().entries.map((entry) {
                          final i = entry.key;
                          final attr = entry.value;
                          return _buildAttributeRow(i, attr);
                        }),

                        // Add attribute button
                        GestureDetector(
                          onTap: _addAttribute,
                          child: Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_circle_outline,
                                    size: 18, color: Colors.grey.shade600),
                                const SizedBox(width: 8),
                                Text(
                                  "Add Attribute",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Photos ──────────────────────────────────────────
                        _sectionHeader("Product Photos"),
                        const SizedBox(height: 4),
                        Text(
                          "Add up to 5 photos (first photo will be the cover)",
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500),
                        ),
                        const SizedBox(height: 12),
                        _buildImageGrid(),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),

                // ── Bottom Buttons ──────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _buildButton(
                        title: _isSubmitting ? "Saving..." : "Save Draft",
                        outlined: true,
                        onTap: _isSubmitting ? null : () => _saveProduct(isDraft: true),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildButton(
                        title: _isSubmitting ? "Publishing..." : "Publish",
                        onTap: _isSubmitting ? null : () => _saveProduct(isDraft: false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Category Dropdown Widget ────────────────────────────────────────────────
  Widget _buildCategoryDropdown() {
    if (_isLoadingCategories) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xffEFEFEF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Loading categories...'),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xffEFEFEF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        isExpanded: true,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
        hint: const Text('Select a category'),
        items: _availableCategories.map((category) {
          return DropdownMenuItem(
            value: category,
            child: Text(category),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedCategory = value;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a category';
          }
          return null;
        },
      ),
    );
  }

  // ── Attribute suggestion chips ──────────────────────────────────────────────
  Widget _buildAttributeSuggestions() {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _attributeSuggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final label = _attributeSuggestions[i];
          // Check if already used
          final alreadyAdded = _attributes
              .any((a) => a['key']!.text.toLowerCase() == label.toLowerCase());
          return GestureDetector(
            onTap: alreadyAdded
                ? null
                : () {
              setState(() {
                _attributes.add({
                  'key': TextEditingController(text: label),
                  'value': TextEditingController(),
                });
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: alreadyAdded ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color:
                  alreadyAdded ? Colors.black : Colors.grey.shade300,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (alreadyAdded) ...[
                    const Icon(Icons.check, size: 12, color: Colors.white),
                    const SizedBox(width: 4),
                  ] else ...[
                    Icon(Icons.add, size: 12, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color:
                      alreadyAdded ? Colors.white : Colors.grey.shade700,
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

  // ── Single attribute row ────────────────────────────────────────────────────
  Widget _buildAttributeRow(
      int index, Map<String, TextEditingController> attr) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Key field
          Expanded(
            flex: 4,
            child: TextField(
              controller: attr['key'],
              textCapitalization: TextCapitalization.words,
              style:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: "Attribute",
                hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 13,
                    fontWeight: FontWeight.w400),
                isDense: true,
                border: InputBorder.none,
              ),
            ),
          ),

          Container(
            width: 1,
            height: 24,
            color: Colors.grey.shade200,
            margin: const EdgeInsets.symmetric(horizontal: 10),
          ),

          // Value field
          Expanded(
            flex: 5,
            child: TextField(
              controller: attr['value'],
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: "Value",
                hintStyle: TextStyle(
                    color: Colors.grey.shade400, fontSize: 13),
                isDense: true,
                border: InputBorder.none,
              ),
            ),
          ),

          // Remove button
          GestureDetector(
            onTap: () => _removeAttribute(index),
            child: Container(
              margin: const EdgeInsets.only(left: 6),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close,
                  size: 14, color: Colors.red.shade400),
            ),
          ),
        ],
      ),
    );
  }

  // ── Color Selector ──────────────────────────────────────────────────────────
  Widget _buildColorSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffEFEFEF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _availableColors.map((colorMap) {
          final name = colorMap['name'] as String;
          final color = colorMap['color'] as Color;
          final isSelected = _selectedColors.contains(name);
          final isWhite = color == Colors.white;

          return GestureDetector(
            onTap: () {
              setState(() {
                isSelected
                    ? _selectedColors.remove(name)
                    : _selectedColors.add(name);
              });
            },
            child: Tooltip(
              message: name,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? Colors.black
                        : isWhite
                        ? Colors.grey.shade300
                        : Colors.transparent,
                    width: isSelected ? 2.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: color.withOpacity(0.5),
                      blurRadius: 6,
                      spreadRadius: 1,
                    )
                  ]
                      : [],
                ),
                child: isSelected
                    ? Icon(
                  Icons.check,
                  size: 18,
                  color: isWhite ? Colors.black : Colors.white,
                )
                    : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Image Grid ──────────────────────────────────────────────────────────────
  Widget _buildImageGrid() {
    const int maxPhotos = 5;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _selectedImages.length < maxPhotos
          ? _selectedImages.length + 1
          : maxPhotos,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        if (index == _selectedImages.length) {
          return GestureDetector(
            onTap: _showImageSourceSheet,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xffEFEFEF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined,
                      color: Colors.grey.shade500, size: 30),
                  const SizedBox(height: 4),
                  Text(
                    "Add Photo",
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          );
        }

        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                _selectedImages[index],
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            if (index == 0)
              Positioned(
                bottom: 6,
                left: 6,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "Cover",
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () =>
                    setState(() => _selectedImages.removeAt(index)),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close,
                      color: Colors.white, size: 14),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
  Widget _optionalBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "Optional",
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text, {bool required = true}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        children: required
            ? const [TextSpan(text: " *", style: TextStyle(color: Colors.red))]
            : [],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String hint = "",
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool required = true,
    String? prefixText,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixText: prefixText,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: const Color(0xffEFEFEF),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String title,
    required VoidCallback? onTap,
    bool outlined = false,
  }) {
    return SizedBox(
      height: 55,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: outlined ? Colors.white : Colors.black,
          foregroundColor: outlined ? Colors.black : Colors.white,
          elevation: 0,
          side: outlined
              ? const BorderSide(color: Colors.black, width: 1.5)
              : BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: outlined ? Colors.black : Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}