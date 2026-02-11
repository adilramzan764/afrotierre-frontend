import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class VendorAddProductScreen extends StatefulWidget {
  const VendorAddProductScreen({super.key});

  @override
  State<VendorAddProductScreen> createState() => _VendorAddProductScreenState();
}

class _VendorAddProductScreenState extends State<VendorAddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String? _selectedVariant;

  File? _selectedImage;

  /// Pick image
  Future<File?> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      return File(picked.path);
    }
    return null;
  }

  /// Show bottom sheet
  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Gallery"),
              onTap: () async {
                final file = await _pickImage(ImageSource.gallery);
                if (file != null) {
                  setState(() {
                    _selectedImage = file;
                  });
                }
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text("Camera"),
              onTap: () async {
                final file = await _pickImage(ImageSource.camera);
                if (file != null) {
                  setState(() {
                    _selectedImage = file;
                  });
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
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

                const Center(
                  child: Text(
                    "Add product",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),

                const SizedBox(height: 30),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Name"),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _nameController,
                          hint: "Enter product name......",
                        ),
                        const SizedBox(height: 20),

                        _buildLabel("Description"),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _descriptionController,
                          maxLines: 5,
                        ),
                        const SizedBox(height: 20),

                        _buildLabel("Variants"),
                        const SizedBox(height: 8),
                        _buildDropdown(),
                        const SizedBox(height: 20),

                        _buildLabel("Price"),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _priceController,
                          hint: "Enter price range",
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 30),

                        _buildUploadBox(),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),

                Row(
                  children: [
                    Expanded(
                      child: _buildButton(
                        title: "Save as draft",
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildButton(
                        title: "Add product",
                        onTap: () {
                          Navigator.pop(context);
                        },
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

  /// Upload Box with image preview
  Widget _buildUploadBox() {
    return GestureDetector(
      onTap: _showImageSourceSheet,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 180,
              width: 180,
              decoration: BoxDecoration(
                color: const Color(0xffEFEFEF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: _selectedImage == null
                  ? const Icon(
                      Icons.image_outlined,
                      size: 40,
                      color: Colors.grey,
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
            ),

            /// Delete overlay
            if (_selectedImage != null)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: Colors.black.withOpacity(0.35),
                  ),
                  child: Center(
                    child: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedImage = null;
                        });
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        children: const [
          TextSpan(
            text: " *",
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String hint = "",
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xffEFEFEF),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedVariant,
      hint: const Text("Select variants"),
      items: [
        "Colour",
        "Size",
        "Material",
      ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: (val) {
        setState(() {
          _selectedVariant = val;
        });
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xffEFEFEF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
      icon: const Icon(Icons.keyboard_arrow_down),
    );
  }

  Widget _buildButton({required String title, required VoidCallback onTap}) {
    return SizedBox(
      height: 55,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
      ),
    );
  }
}
