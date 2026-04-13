import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:afrotierre/Repository/SellerRepository/SellerProductsRepo.dart';

import '../../Models/SellerModels/SellerProductModels.dart';
import '../../res/Widgets/CustomSnackbar.dart';

class VendorEditProductScreen extends StatefulWidget {
  final Product product;

  const VendorEditProductScreen({super.key, required this.product});

  @override
  State<VendorEditProductScreen> createState() =>
      _VendorEditProductScreenState();
}

class _VendorEditProductScreenState extends State<VendorEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late final SellerProductsRepo _productsRepo;

  // ── Controllers pre-filled from product ──────────────────────────────────────
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _discountedPriceController;
  late final TextEditingController _stockController;

  // ── Category ──────────────────────────────────────────────────────────────────
  String? _selectedCategory;
  List<String> _availableCategories = [];
  bool _isLoadingCategories = true;

  // ── Attributes ────────────────────────────────────────────────────────────────
  final List<Map<String, TextEditingController>> _attributes = [];

  final List<String> _attributeSuggestions = [
    'Size', 'Material', 'Warranty', 'Weight', 'Brand',
    'Color', 'Model', 'Origin', 'Care', 'Style',
  ];

  // ── Colors ────────────────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _availableColors = [
    {'name': 'Red',    'color': const Color(0xFFE24B4A)},
    {'name': 'Blue',   'color': const Color(0xFF378ADD)},
    {'name': 'Green',  'color': const Color(0xFF639922)},
    {'name': 'Black',  'color': const Color(0xFF2C2C2A)},
    {'name': 'White',  'color': const Color(0xFFD3D1C7)},
    {'name': 'Yellow', 'color': const Color(0xFFEF9F27)},
    {'name': 'Purple', 'color': const Color(0xFF7F77DD)},
    {'name': 'Orange', 'color': const Color(0xFFD85A30)},
    {'name': 'Pink',   'color': const Color(0xFFD4537E)},
    {'name': 'Grey',   'color': const Color(0xFF888780)},
    {'name': 'Brown',  'color': const Color(0xFF854F0B)},
    {'name': 'Teal',   'color': const Color(0xFF1D9E75)},
  ];
  late List<String> _selectedColors;

  // ── Images ────────────────────────────────────────────────────────────────────
  // Existing network images from the product
  late List<ProductImage> _existingImages;
  // Newly picked local files
  final List<File> _newImages = [];
  // Track which existing image IDs to delete on save
  final List<String> _deletedImageIds = [];

  int get _totalImageCount => _existingImages.length + _newImages.length;

  // ── Draft toggle ──────────────────────────────────────────────────────────────
  late bool _isDraft;

  // ── Loading ───────────────────────────────────────────────────────────────────
  bool _isSubmitting = false;
  bool _hasChanges = false;

  // ── Scroll ────────────────────────────────────────────────────────────────────
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _productsRepo = SellerProductsRepo();
    final p = widget.product;

    // Pre-fill controllers
    _nameController = TextEditingController(text: p.name);
    _descriptionController = TextEditingController(text: p.description);
    _priceController = TextEditingController(text: p.price.toStringAsFixed(2));
    _discountedPriceController = TextEditingController(
      text: p.discountedPrice != null ? p.discountedPrice!.toStringAsFixed(2) : '',
    );
    _stockController = TextEditingController(text: p.stock.toString());

    _selectedCategory = p.category;
    _selectedColors = List<String>.from(p.colors);
    _existingImages = List<ProductImage>.from(p.images);
    _isDraft = p.draft;

    // Pre-fill attributes
    for (final entry in p.attributes.entries) {
      _attributes.add({
        'key': TextEditingController(text: entry.key),
        'value': TextEditingController(text: entry.value.toString()),
      });
    }

    // Listen for any change to track unsaved edits
    _nameController.addListener(_markChanged);
    _descriptionController.addListener(_markChanged);
    _priceController.addListener(_markChanged);
    _discountedPriceController.addListener(_markChanged);
    _stockController.addListener(_markChanged);

    _loadSellerCategories();
  }

  void _markChanged() => setState(() => _hasChanges = true);

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountedPriceController.dispose();
    _stockController.dispose();
    _scrollController.dispose();
    for (final attr in _attributes) {
      attr['key']!.dispose();
      attr['value']!.dispose();
    }
    super.dispose();
  }

  // ── Categories ────────────────────────────────────────────────────────────────

  Future<void> _loadSellerCategories() async {
    try {
      final response = await _productsRepo.getSellerAllowedCategories();
      if (response.success && response.categories.isNotEmpty) {
        setState(() {
          _availableCategories = response.categories;
          // Ensure current category is in list
          if (_selectedCategory != null &&
              !_availableCategories.contains(_selectedCategory)) {
            _availableCategories.insert(0, _selectedCategory!);
          }
          _isLoadingCategories = false;
        });
      } else {
        _useFallbackCategories();
      }
    } catch (_) {
      _useFallbackCategories();
    }
  }

  void _useFallbackCategories() {
    setState(() {
      _availableCategories = [
        'Socks', 'Scarf', 'Shoes', 'Bags', 'Jewelry',
        'Hats', 'Belts', 'Watches', 'Glasses',
      ];
      if (_selectedCategory != null &&
          !_availableCategories.contains(_selectedCategory)) {
        _availableCategories.insert(0, _selectedCategory!);
      }
      _isLoadingCategories = false;
    });
  }

  // ── Attributes ────────────────────────────────────────────────────────────────

  void _addAttribute() {
    setState(() {
      _attributes.add({
        'key': TextEditingController(),
        'value': TextEditingController(),
      });
      _hasChanges = true;
    });
  }

  void _removeAttribute(int index) {
    _attributes[index]['key']!.dispose();
    _attributes[index]['value']!.dispose();
    setState(() {
      _attributes.removeAt(index);
      _hasChanges = true;
    });
  }

  // ── Image handling ────────────────────────────────────────────────────────────

  Future<File?> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) return File(picked.path);
    return null;
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Add photo',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              _imageSourceTile(
                icon: Icons.photo_library_outlined,
                label: 'Choose from gallery',
                onTap: () async {
                  Navigator.pop(context);
                  final file = await _pickImage(ImageSource.gallery);
                  if (file != null && _totalImageCount < 5) {
                    setState(() { _newImages.add(file); _hasChanges = true; });
                  }
                },
              ),
              const SizedBox(height: 8),
              _imageSourceTile(
                icon: Icons.photo_camera_outlined,
                label: 'Take a photo',
                onTap: () async {
                  Navigator.pop(context);
                  final file = await _pickImage(ImageSource.camera);
                  if (file != null && _totalImageCount < 5) {
                    setState(() { _newImages.add(file); _hasChanges = true; });
                  }
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageSourceTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.black87),
            const SizedBox(width: 14),
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  void _removeExistingImage(ProductImage image) {
    setState(() {
      _existingImages.remove(image);
      _deletedImageIds.add(image.id);
      _hasChanges = true;
    });
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
      _hasChanges = true;
    });
  }

  // ── Discount helper ───────────────────────────────────────────────────────────

  String? _discountPercent() {
    final original = double.tryParse(_priceController.text);
    final discounted = double.tryParse(_discountedPriceController.text);
    if (original != null && discounted != null && original > 0 && discounted < original) {
      return '${((original - discounted) / original * 100).round()}% off';
    }
    return null;
  }

  // ── Save ──────────────────────────────────────────────────────────────────────

  Future<void> _saveProduct({required bool isDraft}) async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      CustomSnackbar.showError(context, 'Please select a category');
      return;
    }

    if (!isDraft && _totalImageCount == 0) {
      CustomSnackbar.showError(context, 'Please add at least one product image');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final double price = double.tryParse(_priceController.text) ?? 0.0;
      final int stock = int.tryParse(_stockController.text) ?? 0;

      if (price <= 0) {
        CustomSnackbar.showError(context, 'Price must be greater than 0');
        setState(() => _isSubmitting = false);
        return;
      }

      // FIRST: Delete any images that were removed
      if (_deletedImageIds.isNotEmpty) {
        for (final imageId in _deletedImageIds) {
          final deleteResponse = await _productsRepo.deleteProductImage(
              widget.product.id,
              imageId
          );
          if (!deleteResponse.success) {
            CustomSnackbar.showError(context,
                'Failed to delete image: ${deleteResponse.message}'
            );
            setState(() => _isSubmitting = false);
            return;
          }
        }
      }

      final Map<String, dynamic> attributes = {};
      for (final attr in _attributes) {
        final key = attr['key']!.text.trim();
        final value = attr['value']!.text.trim();
        if (key.isNotEmpty && value.isNotEmpty) attributes[key] = value;
      }

      final request = UpdateProductRequest(
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
      );

      // THEN: Update the product with new images
      final response = await _productsRepo.updateProduct(
        request: request,
        newImages: _newImages.isNotEmpty ? _newImages : null,
        productId: widget.product.id,
      );

      if (response.success) {
        CustomSnackbar.showSuccess(
          context,
          isDraft ? 'Draft updated successfully!' : 'Product updated and published!',
        );
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) Navigator.pop(context, true);
      } else {
        CustomSnackbar.showError(context, response.error ?? response.message);
      }
    } catch (e) {
      CustomSnackbar.showError(context, 'Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
  // ── Discard confirmation ──────────────────────────────────────────────────────

  Future<bool> _confirmDiscard() async {
    if (!_hasChanges) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Discard changes?', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        content: const Text(
          'You have unsaved changes. Leave without saving?',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep editing', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Discard', style: TextStyle(color: Colors.red.shade400)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _confirmDiscard,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F6F6),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildTopBar(),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Draft banner ──────────────────────────────────
                          if (_isDraft) _buildDraftBanner(),

                          // ── Basic Info ────────────────────────────────────
                          _sectionHeader('Basic Information'),
                          const SizedBox(height: 12),
                          _buildLabel('Product Name'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _nameController,
                            hint: 'Enter product name...',
                            validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('Description'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _descriptionController,
                            hint: 'Describe your product...',
                            maxLines: 4,
                            validator: (v) => v == null || v.isEmpty ? 'Description is required' : null,
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('Category'),
                          const SizedBox(height: 8),
                          _buildCategoryDropdown(),
                          const SizedBox(height: 24),

                          // ── Pricing & Stock ───────────────────────────────
                          _sectionHeader('Pricing & Inventory'),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('Price (\$)'),
                                    const SizedBox(height: 8),
                                    _buildTextField(
                                      controller: _priceController,
                                      hint: '0.00',
                                      keyboardType: TextInputType.number,
                                      prefixText: '\$ ',
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                                      ],
                                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
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
                                    _buildLabel('Stock'),
                                    const SizedBox(height: 8),
                                    _buildTextField(
                                      controller: _stockController,
                                      hint: '0',
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('Discounted Price (\$)', required: false),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _discountedPriceController,
                                  hint: '0.00',
                                  keyboardType: TextInputType.number,
                                  prefixText: '\$ ',
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                                  ],
                                  required: false,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return null;
                                    final original = double.tryParse(_priceController.text);
                                    final discounted = double.tryParse(v);
                                    if (original == null || discounted == null) return null;
                                    if (discounted >= original) return 'Must be less than original price';
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
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3B6D11),
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
                                    : const SizedBox(key: ValueKey('empty'), width: 0),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // ── Colors ────────────────────────────────────────
                          Row(
                            children: [
                              Expanded(child: _sectionHeader('Colors')),
                              _optionalBadge(),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildColorSelector(),
                          const SizedBox(height: 24),

                          // ── Attributes ────────────────────────────────────
                          Row(
                            children: [
                              Expanded(child: _sectionHeader('Attributes')),
                              _optionalBadge(),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Add any product details: size, material, warranty, etc.',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                          ),
                          const SizedBox(height: 12),
                          _buildAttributeSuggestions(),
                          const SizedBox(height: 12),
                          ..._attributes.asMap().entries.map(
                                (e) => _buildAttributeRow(e.key, e.value),
                          ),
                          _buildAddAttributeButton(),
                          const SizedBox(height: 24),

                          // ── Photos ────────────────────────────────────────
                          _sectionHeader('Product Photos'),
                          const SizedBox(height: 4),
                          Text(
                            'Add up to 5 photos. First photo is the cover.',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                          ),
                          const SizedBox(height: 12),
                          _buildImageGrid(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),

                  // ── Bottom Buttons ────────────────────────────────────────
                  _buildBottomButtons(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Top bar ───────────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: () async {
              if (await _confirmDiscard()) Navigator.pop(context);
            },
            child: Container(
              height: 40, width: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back, size: 18),
            ),
          ),
        ),
        const Text(
          'Edit Product',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        // Unsaved changes indicator
        if (_hasChanges)
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFAEEDA),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Unsaved',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF854F0B),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ── Draft banner ──────────────────────────────────────────────────────────────

  Widget _buildDraftBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAEEDA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEF9F27).withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.edit_note_rounded, color: Color(0xFF854F0B), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This product is a draft',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF854F0B),
                  ),
                ),
                Text(
                  'Tap "Publish" to make it visible in your store.',
                  style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Category dropdown ─────────────────────────────────────────────────────────

  Widget _buildCategoryDropdown() {
    if (_isLoadingCategories) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFEFEFEF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 18, height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
            ),
            SizedBox(width: 12),
            Text('Loading categories...', style: TextStyle(color: Colors.black54, fontSize: 14)),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFEF),
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
        items: _availableCategories.map((cat) {
          return DropdownMenuItem(value: cat, child: Text(cat));
        }).toList(),
        onChanged: (v) => setState(() { _selectedCategory = v; _hasChanges = true; }),
        validator: (v) => v == null || v.isEmpty ? 'Please select a category' : null,
      ),
    );
  }

  // ── Attribute suggestions ─────────────────────────────────────────────────────

  Widget _buildAttributeSuggestions() {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _attributeSuggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final label = _attributeSuggestions[i];
          final alreadyAdded = _attributes.any(
                (a) => a['key']!.text.toLowerCase() == label.toLowerCase(),
          );
          return GestureDetector(
            onTap: alreadyAdded
                ? null
                : () {
              setState(() {
                _attributes.add({
                  'key': TextEditingController(text: label),
                  'value': TextEditingController(),
                });
                _hasChanges = true;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: alreadyAdded ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: alreadyAdded ? Colors.black : Colors.grey.shade300,
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
                      color: alreadyAdded ? Colors.white : Colors.grey.shade700,
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

  // ── Attribute row ─────────────────────────────────────────────────────────────

  Widget _buildAttributeRow(int index, Map<String, TextEditingController> attr) {
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
          Expanded(
            flex: 4,
            child: TextField(
              controller: attr['key'],
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => _markChanged(),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Attribute',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.w400),
                isDense: true,
                border: InputBorder.none,
              ),
            ),
          ),
          Container(width: 1, height: 24, color: Colors.grey.shade200, margin: const EdgeInsets.symmetric(horizontal: 10)),
          Expanded(
            flex: 5,
            child: TextField(
              controller: attr['value'],
              onChanged: (_) => _markChanged(),
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Value',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                isDense: true,
                border: InputBorder.none,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _removeAttribute(index),
            child: Container(
              margin: const EdgeInsets.only(left: 6),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFFCEBEB),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Color(0xFFA32D2D)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddAttributeButton() {
    return GestureDetector(
      onTap: _addAttribute,
      child: Container(
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, size: 18, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              'Add Attribute',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  // ── Color selector ────────────────────────────────────────────────────────────

  Widget _buildColorSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFEF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _availableColors.map((colorMap) {
          final name = colorMap['name'] as String;
          final color = colorMap['color'] as Color;
          final isSelected = _selectedColors.contains(name);
          final isLight = color.computeLuminance() > 0.6;

          return GestureDetector(
            onTap: () {
              setState(() {
                isSelected ? _selectedColors.remove(name) : _selectedColors.add(name);
                _hasChanges = true;
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
                    color: isSelected ? Colors.black : (isLight ? Colors.grey.shade300 : Colors.transparent),
                    width: isSelected ? 2.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 6, spreadRadius: 1)]
                      : [],
                ),
                child: isSelected
                    ? Icon(Icons.check, size: 18, color: isLight ? Colors.black : Colors.white)
                    : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Image grid ────────────────────────────────────────────────────────────────

  Widget _buildImageGrid() {
    // Build unified list: existing network images + new local files
    // Show add button if < 5 total
    final List<Widget> cells = [];

    // Existing images
    for (int i = 0; i < _existingImages.length; i++) {
      final img = _existingImages[i];
      final isCover = i == 0 && _newImages.isEmpty;
      cells.add(_existingImageCell(img, isCover: isCover));
    }

    // New local images
    for (int i = 0; i < _newImages.length; i++) {
      final isCover = _existingImages.isEmpty && i == 0;
      cells.add(_newImageCell(i, isCover: isCover));
    }

    // Add button
    if (_totalImageCount < 5) {
      cells.add(_addImageCell());
    }

    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: cells,
    );
  }

  Widget _existingImageCell(ProductImage img, {required bool isCover}) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            img.url,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey.shade200,
              child: Icon(Icons.broken_image_outlined, color: Colors.grey.shade400),
            ),
          ),
        ),
        if (isCover)
          Positioned(
            bottom: 6, left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('Cover', style: TextStyle(color: Colors.white, fontSize: 10)),
            ),
          ),
        Positioned(
          top: 4, right: 4,
          child: GestureDetector(
            onTap: () => _removeExistingImage(img),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _newImageCell(int index, {required bool isCover}) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            _newImages[index],
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        // "New" badge
        Positioned(
          bottom: 6, left: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isCover ? Colors.black87 : const Color(0xFF1D9E75),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isCover ? 'Cover' : 'New',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        ),
        Positioned(
          top: 4, right: 4,
          child: GestureDetector(
            onTap: () => _removeNewImage(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _addImageCell() {
    return GestureDetector(
      onTap: _showImageSourceSheet,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEFEFEF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined, color: Colors.grey.shade500, size: 28),
            const SizedBox(height: 4),
            Text('Add Photo', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  // ── Bottom buttons ────────────────────────────────────────────────────────────

  Widget _buildBottomButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildButton(
            title: _isSubmitting ? 'Saving...' : 'Save Draft',
            outlined: true,
            onTap: _isSubmitting ? null : () => _saveProduct(isDraft: true),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildButton(
            title: _isSubmitting ? 'Saving...' : (_isDraft ? 'Publish' : 'Save Changes'),
            onTap: _isSubmitting ? null : () => _saveProduct(isDraft: false),
          ),
        ),
      ],
    );
  }

  // ── Shared helpers ────────────────────────────────────────────────────────────

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4, height: 20,
          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.black)),
      ],
    );
  }

  Widget _buildLabel(String text, {bool required = true}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
        children: required
            ? const [TextSpan(text: ' *', style: TextStyle(color: Colors.red))]
            : [],
      ),
    );
  }

  Widget _optionalBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(20)),
      child: Text(
        'Optional',
        style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String hint = '',
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
        fillColor: const Color(0xFFEFEFEF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
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
          side: outlined ? const BorderSide(color: Colors.black, width: 1.5) : BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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