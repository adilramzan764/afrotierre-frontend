import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../constants.dart';

class VendorProductScreen extends StatefulWidget {
  const VendorProductScreen({super.key});

  @override
  State<VendorProductScreen> createState() => _VendorProductScreenState();
}

class _VendorProductScreenState extends State<VendorProductScreen> {
  // Placeholder data
  final List<Map<String, dynamic>> _products = [
    {
      'name': 'Dunk Nike Sneakers',
      'price': 3000.0,
      'stock': 24,
      'status': 'In Stock',
      'image': 'assets/stock_image.png',
      'colors': [Colors.black, Colors.blue, Colors.grey.shade300],
    },
    {
      'name': 'Luxury Hand Bag',
      'price': 3000.0,
      'stock': 10,
      'status': 'In Stock',
      'image': 'assets/stock_image.png',
      'colors': [Colors.orange, Colors.blue, Colors.black],
    },
    {
      'name': 'JBL Tunes',
      'price': 500.0,
      'stock': 0,
      'status': 'Out of stock',
      'image': 'assets/stock_image.png',
      'colors': [Colors.black, Colors.red, Colors.grey.shade300],
    },
    {
      'name': 'Running sneakers',
      'price': 3000.0,
      'stock': 14,
      'status': 'In Stock',
      'image': 'assets/stock_image.png',
      'colors': [Colors.black, Colors.orange, Colors.grey.shade300],
    },
    {
      'name': 'Tote bag',
      'price': 1000.0,
      'stock': 5,
      'status': 'In Stock',
      'image': 'assets/stock_image.png',
      'colors': [Colors.black, Colors.red.shade900, Colors.grey.shade300],
    },
    {
      'name': 'Macbook 12',
      'price': 3000.0,
      'stock': 24,
      'status': 'In Stock',
      'image': 'assets/stock_image.png',
      'colors': [Colors.grey.shade300, Colors.black],
    },
  ];

  Future<File?> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  void _showImageSourceActionSheet(
    BuildContext context,
    Function(File) onImageSelected,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  final file = await _pickImage(ImageSource.gallery);
                  if (file != null) {
                    onImageSelected(file);
                  }
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () async {
                  final file = await _pickImage(ImageSource.camera);
                  if (file != null) {
                    onImageSelected(file);
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditProductSheet(Map<String, dynamic> product) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController(text: product['name']);
    final _descriptionController = TextEditingController(text: 'Dunk sneakers');
    final _priceController = TextEditingController(
      text: (product['price'] as double).toString(),
    );

    String? _selectedVariant = 'Colour';

    File? _editedImage;

    String? _currentImagePath = product['image'];

    showCupertinoModalPopup(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          Widget buildImageUpload() {
            ImageProvider? imageProvider;

            if (_editedImage != null) {
              imageProvider = FileImage(_editedImage!);
            } else if (_currentImagePath != null &&
                _currentImagePath!.startsWith('assets/')) {
              imageProvider = AssetImage(_currentImagePath!);
            }

            return Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (imageProvider != null)
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () {
                        _showImageSourceActionSheet(context, (file) {
                          setModalState(() {
                            _editedImage = file;
                            _currentImagePath = null;
                          });
                        });
                      },
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 48,
                        ),
                      ),
                    ),
                  if (imageProvider != null)
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.black.withOpacity(0.3),
                      ),

                      child: Center(
                        child: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                            size: 32,
                          ),
                          onPressed: () {
                            setModalState(() {
                              _editedImage = null;
                              _currentImagePath = null;
                            });
                          },
                        ),
                      ),
                    ),
                ],
              ),
            );
          }

          return DraggableScrollableSheet(
            initialChildSize: 0.85,
            maxChildSize: 0.95,
            minChildSize: 0.6,
            expand: false,
            builder: (_, controller) => Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                controller: controller,
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Edit Product',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildEditTextField(
                        label: 'Name',
                        controller: _nameController,
                        isRequired: true,
                      ),
                      const SizedBox(height: 16),
                      _buildEditTextField(
                        label: 'Description',
                        controller: _descriptionController,
                        isRequired: true,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      _buildEditDropdownField(
                        label: 'Variants',
                        value: _selectedVariant,
                        isRequired: true,
                        onChanged: (val) {
                          setModalState(() {
                            _selectedVariant = val;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildEditTextField(
                        label: 'Price',
                        controller: _priceController,
                        prefix: '\$',
                      ),
                      const SizedBox(height: 24),
                      buildImageUpload(),
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Save',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEditTextField({
    required String label,
    required TextEditingController controller,
    bool isRequired = false,
    int maxLines = 1,
    String? prefix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            children: isRequired
                ? [
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red),
                    ),
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixText: prefix,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildEditDropdownField({
    required String label,
    required String? value,
    bool isRequired = false,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            children: isRequired
                ? [
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red),
                    ),
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: [
            'Colour',
            'Size',
            'Material',
          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildProductGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search products....',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.filter_list, size: 28),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, vendorAddProductScreen);
              },
              icon: const Icon(Icons.add, color: Colors.white, size: 18),
              label: const Text(
                'Add product',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.57,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(_products[index]);
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final bool inStock = product['status'] == 'In Stock';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    image: (product['image'] != null)
                        ? DecorationImage(
                            image: AssetImage(product['image'] as String),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: (product['image'] == null)
                      ? const Center(
                          child: Icon(
                            Icons.image,
                            color: Colors.grey,
                            size: 40,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Chip(
                    label: Text(
                      product['status'],
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    backgroundColor: inStock ? Colors.green : Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              product['name'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('\$${(product['price'] as double).toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Row(
              children: (product['colors'] as List<Color>).map((color) {
                return Container(
                  margin: const EdgeInsets.only(right: 4),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                );
              }).toList(),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    inStock ? '${product['stock']} in Stock' : 'Out of stock',
                    style: TextStyle(
                      color: inStock ? Colors.black : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _showEditProductSheet(product),
                  icon: const Icon(Icons.edit_outlined),
                  color: Colors.grey,
                  iconSize: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
