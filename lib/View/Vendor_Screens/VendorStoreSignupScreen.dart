import 'dart:io';
import 'package:afrotierre/constants.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:path_provider/path_provider.dart';

import '../../Models/SellerModels/SellerAuthModels.dart';
import '../../Repository/SellerRepository/SellerAuthRepository.dart';
import '../../res/Widgets/CustomSnackbar.dart';
import '../Onboarding_Screens/sign_in_account_seller.dart';

class VendorStoreSignupScreen extends StatefulWidget {
  final String token;
  const VendorStoreSignupScreen({super.key, required this.token});

  @override
  State<VendorStoreSignupScreen> createState() =>
      _VendorStoreSignupScreenState();
}

class _VendorStoreSignupScreenState extends State<VendorStoreSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storeNameController = TextEditingController();
  final _businessEmailController = TextEditingController();
  final _storeDescriptionController = TextEditingController();
  String? _phoneNumber; // Add this variable at the top with other variables


  List<String> _selectedCategories = [];
  bool _isLoading = false;
  String? _errorMessage;
  File? _logoImage;

  late SellerAuthRepository _authRepository;
  final List<String> _availableCategories = StoreCategories.allCategories;

  @override
  void initState() {
    super.initState();
    _authRepository = SellerAuthRepository();
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _businessEmailController.dispose();
    _storeDescriptionController.dispose();
    _authRepository.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final newPath =
          '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = await File(pickedFile.path).copy(newPath);
      setState(() => _logoImage = savedImage);
    }
  }

  void _showImageSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                'Select Image Source',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.photo_library_outlined, size: 20),
              ),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.photo_camera_outlined, size: 20),
              ),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        duration: const Duration(seconds: 4),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.red.shade700,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                child: Icon(
                  Icons.close,
                  color: Colors.white.withOpacity(0.7),
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;


    // Validate phone number
    if (_phoneNumber == null || _phoneNumber!.isEmpty) {
      _showErrorSnackbar('Please enter a valid phone number');
      return;
    }

    if (_selectedCategories.isEmpty) {
      _showErrorSnackbar('Please select at least one store category');  // ← changed
      return;
    }

    setState(() => _isLoading = true);

    try {
      final request = StoreDetailsRequest(
        storeName: _storeNameController.text.trim(),
        phoneNumber: _phoneNumber!, // Use _phoneNumber instead
        businessEmail: _businessEmailController.text.trim(),
        category: _selectedCategories,
        storeDescription: _storeDescriptionController.text.trim(),
        logoPath: _logoImage?.path,
      );

      final response = await _authRepository.submitStoreDetails(
        token: widget.token,
        request: request,
        includeLogo: _logoImage != null,
      );

      if (response.success && response.seller != null) {
        print("Store details submitted successfully: ${response.message}");
        await _showSuccessDialog(response.message);
      } else {
        String errorMessage = response.getFormattedErrorMessage();

        // Handle specific validation errors
        if (errorMessage.contains('phone number')) {
          CustomSnackbar.showError(
            context,
            'Please enter a valid phone number',
          );
          // Also highlight the phone number field
          setState(() {
            _errorMessage = 'Please enter a valid phone number';
          });
        } else if (errorMessage.contains('email')) {
          CustomSnackbar.showError(
            context,
            'Please enter a valid business email',
          );
        } else {
          CustomSnackbar.showError(
            context,
            errorMessage,
          );
        }

        setState(() {
          _errorMessage = errorMessage;
        });
      }

    } catch (e) {
      final errorMessage = 'Failed to submit store details: ${e.toString()}';
      print('Error in _handleSubmit: $e');
      CustomSnackbar.showError(
        context,
        'Network error. Please check your connection and try again.',
      );
      setState(() {
        _errorMessage = errorMessage;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  Future<void> _showSuccessDialog(String message) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.15),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 36,
                  color: Colors.green.shade600,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Store Created!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message.isNotEmpty
                    ? message
                    : 'Your store details have been submitted successfully. You can now start selling!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 8),

              // Store name chip
              if (_storeNameController.text.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 4, bottom: 4),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.storefront_outlined,
                          size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(
                        _storeNameController.text.trim(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Continue button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // close dialog
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => SignInAccountSellerScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Continue to Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
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
          child: Column(
            children: [
              const SizedBox(height: 20),

              // ── Header ───────────────────────────────────────────────────
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          size: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    'Store Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 28),

                        // ── Logo Upload ──────────────────────────────────
                        _buildLogoUpload(),
                        const SizedBox(height: 24),

                        // ── Basic Info ───────────────────────────────────
                        _sectionHeader('Basic Information'),
                        const SizedBox(height: 12),

                        _buildLabel('Store Name'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _storeNameController,
                          hint: 'Enter your store name...',
                          validator: (v) => v == null || v.isEmpty
                              ? 'Store name is required'
                              : null,
                        ),
                        const SizedBox(height: 16),

                        _buildLabel('Phone Number'),
                        const SizedBox(height: 8),


                        IntlPhoneField(
                          initialCountryCode: 'US',
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Phone number',
                            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                            filled: true,
                            fillColor: const Color(0xffEFEFEF),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(color: Colors.black, width: 1.5),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(color: Colors.red, width: 1),
                            ),
                          ),
                          onChanged: (phone) {
                            _phoneNumber = phone.completeNumber;
                          },
                          validator: (phone) {
                            if (phone == null || phone.number.isEmpty) {
                              return 'Phone number is required';
                            }
                            // Basic validation - ensure the number has reasonable length
                            if (phone.number.length < 5) {
                              return 'Please enter a valid phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildLabel('Business Email'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _businessEmailController,
                          hint: 'business@example.com',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.mail_outline_rounded,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Business email is required';
                            }
                            if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(v)) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // ── Categories ───────────────────────────────────
                        _sectionHeader('Store Category'),
                        const SizedBox(height: 4),
                        Text(
                          'Select all categories that apply to your store',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500),
                        ),
                        const SizedBox(height: 12),
                        _buildCategorySelector(),

                        const SizedBox(height: 24),

                        // ── Description ──────────────────────────────────
                        _sectionHeader('Store Description'),
                        const SizedBox(height: 12),

                        // Character count
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildLabel('Description'),
                            ValueListenableBuilder(
                              valueListenable: _storeDescriptionController,
                              builder: (_, __, ___) => Text(
                                '${_storeDescriptionController.text.length}/500',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade400),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _storeDescriptionController,
                          hint: 'Describe your store and what you sell...',
                          maxLines: 4,
                          maxLength: 500,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Store description is required';
                            }
                            if (v.length < 20) {
                              return 'Minimum 20 characters required';
                            }
                            return null;
                          },
                        ),


                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Bottom Buttons ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(bottom: 24, top: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 55,
                        child: ElevatedButton(
                          onPressed:
                          _isLoading ? null : () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            elevation: 0,
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Back',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: SizedBox(
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                              AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                            ),
                          )
                              : const Text(
                            'Submit',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
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

  // ── Logo Upload ─────────────────────────────────────────────────────────────
  Widget _buildLogoUpload() {
    return Center(
      child: GestureDetector(
        onTap: () => _showImageSourceSheet(context),
        child: Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                image: _logoImage != null
                    ? DecorationImage(
                  image: FileImage(_logoImage!),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: _logoImage == null
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.storefront_outlined,
                      size: 30, color: Colors.grey.shade400),
                  const SizedBox(height: 4),
                  Text(
                    'Logo',
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade400),
                  ),
                ],
              )
                  : null,
            ),
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt,
                    size: 14, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Category Selector ───────────────────────────────────────────────────────
  Widget _buildCategorySelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffEFEFEF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _availableCategories.map((cat) {
          final isSelected = _selectedCategories.contains(cat);
          return GestureDetector(
            onTap: () {
              setState(() {
                isSelected
                    ? _selectedCategories.remove(cat)
                    : _selectedCategories.add(cat);
                _errorMessage = null;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color:
                  isSelected ? Colors.black : Colors.grey.shade300,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected) ...[
                    const Icon(Icons.check, size: 13, color: Colors.white),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    cat,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
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
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
    IconData? prefixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      validator: validator,
      buildCounter: maxLength != null
          ? (_, {required currentLength, required isFocused, maxLength}) =>
      null
          : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: Colors.grey.shade400, size: 20)
            : null,
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
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}