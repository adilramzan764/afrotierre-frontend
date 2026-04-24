import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:afrotierre/Repository/SellerRepository/SellerLoginandProfileRepo.dart';
import 'package:afrotierre/Services/AppSession.dart';
import 'package:afrotierre/Models/SellerModels/SellerAuthModels.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../Models/SellerModels/SellerLoginandProfleModels.dart';
import '../../res/Widgets/CustomSnackbar.dart';

class StoreInformationScreen extends StatefulWidget {
  const StoreInformationScreen({super.key});

  @override
  State<StoreInformationScreen> createState() => _StoreInformationScreenState();
}

class _StoreInformationScreenState extends State<StoreInformationScreen> {
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<String> _selectedCategories = [];
  File? _logo;
  bool _isUpdating = false;

  // Phone number handling
  String _completePhoneNumber = '';
  String _initialCountryCode = 'US';

  final List<String> _categories = [
    'Anniversary & Holiday Gifts',
    'Odds & Ends',
    'Oral Care',
    'Scarf',
    'Socks',
    'Adventure/Outdoor',
    'Mind-Body',
    'Team Sports',
    'Vehicles',
    'Ethnic Toys',
    'Stuffed Animals',
    'Educational Toys',
    'Arts & Crafts',
    'Dolls & Accessories',
    'Games & Puzzles',
    'Sensors',
    'Audio',
    'Home Devices',
    'Mobile Devices',
    'Computer',
    'Shoes',
    'Health & Beauty',
    'Clothing & Fashion',
    'Technology & Device',
  ];

  final AppSession _session = AppSession.instance;
  final SellerLoginandProfileRepo _repo = SellerLoginandProfileRepo();

  @override
  void initState() {
    super.initState();
    _loadDataFromSession();
  }

  void _loadDataFromSession() {
    final sellerProfile = _session.sellerProfile;

    if (sellerProfile != null) {
      // Populate form fields with session data
      _storeNameController.text = sellerProfile.storeName ?? '';
      _emailController.text = sellerProfile.businessEmail ?? '';
      _descriptionController.text = sellerProfile.storeDescription ?? '';
      _selectedCategories = sellerProfile.category ?? [];

      // Parse and handle phone number correctly
      String phone = sellerProfile.phoneNumber ?? '';

      if (phone.isNotEmpty) {
        // Parse country code and local number
        if (phone.startsWith('+1')) {
          _initialCountryCode = 'US';
          _phoneController.text = phone.replaceFirst('+1', '');
          _completePhoneNumber = phone;
        } else if (phone.startsWith('+44')) {
          _initialCountryCode = 'GB';
          _phoneController.text = phone.replaceFirst('+44', '');
          _completePhoneNumber = phone;
        } else if (phone.startsWith('+91')) {
          _initialCountryCode = 'IN';
          _phoneController.text = phone.replaceFirst('+91', '');
          _completePhoneNumber = phone;
        } else if (phone.startsWith('+61')) {
          _initialCountryCode = 'AU';
          _phoneController.text = phone.replaceFirst('+61', '');
          _completePhoneNumber = phone;
        } else if (phone.startsWith('+86')) {
          _initialCountryCode = 'CN';
          _phoneController.text = phone.replaceFirst('+86', '');
          _completePhoneNumber = phone;
        } else {
          // Default to US if country code not recognized
          _initialCountryCode = 'US';
          _phoneController.text = phone;
          _completePhoneNumber = phone;
        }
      }

      print('✅ Loaded seller profile from session');
      print('   Store Name: ${sellerProfile.storeName}');
      print('   Original Phone: $phone');
      print('   Parsed - Country: $_initialCountryCode, Local: ${_phoneController.text}');
      print('   Categories: ${sellerProfile.category}');
      print('   Description: ${sellerProfile.storeDescription}');
    } else {
      print('⚠️ No seller profile found in session');
      CustomSnackbar.showWarning(context, 'Profile data not found. Please restart the app.');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() => _logo = File(pickedFile.path));
    }
  }

  Future<void> _updateProfile() async {
    // Validate inputs
    if (_storeNameController.text.trim().isEmpty) {
      CustomSnackbar.showError(context, 'Please enter store name');
      return;
    }

    // Use the complete phone number (preferred) or build from controller
    String phoneNumberToSubmit = _completePhoneNumber.isNotEmpty
        ? _completePhoneNumber
        : _phoneController.text.trim();

    if (phoneNumberToSubmit.isEmpty) {
      CustomSnackbar.showError(context, 'Please enter phone number');
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      CustomSnackbar.showError(context, 'Please enter business email');
      return;
    }

    if (_selectedCategories.isEmpty) {
      CustomSnackbar.showError(context, 'Please select at least one category');
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      CustomSnackbar.showError(context, 'Please enter store description');
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      final token = _session.authToken;
      if (token == null) {
        CustomSnackbar.showError(context, 'Session expired. Please login again.');
        return;
      }

      // Prepare update request
      final request = UpdateProfileRequest(
        storeName: _storeNameController.text.trim(),
        phoneNumber: phoneNumberToSubmit,
        businessEmail: _emailController.text.trim(),
        category: _selectedCategories,
        storeDescription: _descriptionController.text.trim(),
        logoPath: _logo?.path,
      );

      print('📤 Updating profile with:');
      print('   Phone number being submitted: $phoneNumberToSubmit');

      // Update profile with or without logo
      final response = await _repo.updateProfile(
        token: token,
        request: request,
        includeLogo: _logo != null,
      );

      if (response.success && response.seller != null) {
        // Update session with new profile data
        await _session.updateSellerProfile(response.seller!);

        CustomSnackbar.showSuccess(context, 'Store information updated successfully!');

        // Wait a moment to show success message before popping
        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        CustomSnackbar.showError(context, response.message);
      }
    } catch (e) {
      print('❌ Error updating profile: $e');
      CustomSnackbar.showError(context, 'Error updating profile: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
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
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                'Update Store Logo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

  @override
  void dispose() {
    _storeNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    super.dispose();
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

              // ── Header ──────────────────────────────────────────────────
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
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
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    'Store Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Logo ───────────────────────────────────────────
                      Center(
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
                                  border: Border.all(
                                      color: Colors.grey.shade200,
                                      width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  image: _logo != null
                                      ? DecorationImage(
                                    image: FileImage(_logo!),
                                    fit: BoxFit.cover,
                                  )
                                      : (_session.sellerProfile?.logo?.url != null
                                      ? DecorationImage(
                                    image: NetworkImage(
                                      _session.sellerProfile!.logo!.url!,
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                      : null),
                                ),
                                child: _logo == null && _session.sellerProfile?.logo?.url == null
                                    ? Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.storefront_outlined,
                                      size: 30,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Logo',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade400,
                                      ),
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
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ── Basic Info ─────────────────────────────────────
                      _sectionHeader('Basic Information'),
                      const SizedBox(height: 12),

                      _buildLabel('Store Name'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _storeNameController,
                        hint: 'Enter your store name',
                        prefixIcon: Icons.storefront_outlined,
                      ),
                      const SizedBox(height: 16),

                      _buildLabel('Phone Number'),
                      const SizedBox(height: 8),

                      // ✅ FIXED: IntlPhoneField with proper handling
                      IntlPhoneField(
                        controller: _phoneController,
                        initialCountryCode: _initialCountryCode,
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
                        ),
                        // ✅ IMPORTANT: Do NOT set controller.text here
                        onChanged: (phone) {
                          // Only store the complete number, don't update controller
                          _completePhoneNumber = phone.completeNumber;
                          print('📱 Phone changed: ${phone.completeNumber}');
                        },
                      ),

                      const SizedBox(height: 16),

                      _buildLabel('Business Email'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _emailController,
                        hint: 'store@example.com',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.mail_outline_rounded,
                      ),

                      const SizedBox(height: 24),

                      // ── Categories ─────────────────────────────────────
                      _sectionHeader('Store Categories'),
                      const SizedBox(height: 4),
                      Text(
                        'Select all categories that apply to your store',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500),
                      ),
                      const SizedBox(height: 12),
                      _buildCategorySelector(),

                      const SizedBox(height: 24),

                      // ── Description ────────────────────────────────────
                      _sectionHeader('Store Description'),
                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildLabel('Description'),
                          ValueListenableBuilder(
                            valueListenable: _descriptionController,
                            builder: (_, __, ___) => Text(
                              '${_descriptionController.text.length}/500',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade400),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _descriptionController,
                        hint: 'Describe your store...',
                        maxLines: 4,
                        maxLength: 500,
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // ── Save Button ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(bottom: 24, top: 8),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isUpdating ? null : _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _isUpdating
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Text(
                      'Save Changes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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
        children: _categories.map((cat) {
          final isSelected = _selectedCategories.contains(cat);
          return GestureDetector(
            onTap: () {
              setState(() {
                isSelected
                    ? _selectedCategories.remove(cat)
                    : _selectedCategories.add(cat);
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected
                      ? Colors.black
                      : Colors.grey.shade300,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected) ...[
                    const Icon(Icons.check,
                        size: 13, color: Colors.white),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    cat,
                    style: TextStyle(
                      color:
                      isSelected ? Colors.white : Colors.black87,
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
    IconData? prefixIcon,
    int maxLines = 1,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      buildCounter: maxLength != null
          ? (_, {required currentLength, required isFocused, maxLength}) =>
      null
          : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
        TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon,
            color: Colors.grey.shade400, size: 20)
            : null,
        filled: true,
        fillColor: const Color(0xffEFEFEF),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide:
          const BorderSide(color: Colors.black, width: 1.5),
        ),
      ),
    );
  }
}