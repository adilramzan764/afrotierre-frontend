import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

import '../../Models/BuyerModels/BuyerAuthModels.dart';
import '../../Models/BuyerModels/BuyerLoginandProfileModels.dart';
import '../../Repository/BuyerRepository/BuyerAuthRepository.dart';
import '../../Repository/BuyerRepository/BuyerLoginProfileRepo.dart';
import '../../Services/AppSession.dart';
import '../../res/Widgets/CustomSnackbar.dart';
import '../Onboarding_Screens/sign_in_account_buyer.dart';
import '../Buyers_Screens/bottom_navigation_screen.dart';
import '../../res/Widgets/SuccessDialog.dart';

class BuyerPersonalInfoSignup extends StatefulWidget {
  final String? token;
  final String? refreshToken;
  final String? email;
  final bool isGoogleUser;
  final String? googleEmail;
  final String? googleName;

  const BuyerPersonalInfoSignup({
    super.key,
    this.token,
    this.refreshToken,
    this.email,
    this.isGoogleUser = false,
    this.googleEmail,
    this.googleName,
  });

  @override
  State<BuyerPersonalInfoSignup> createState() =>
      _BuyerPersonalInfoSignupState();
}

class _BuyerPersonalInfoSignupState extends State<BuyerPersonalInfoSignup> {
  final _formKey = GlobalKey<FormState>();
  final _buyerAuthRepo = BuyerAuthRepo();
  final _buyerProfileRepo = BuyerLoginProfileRepo();
  final _session = AppSession.instance;

  bool _isLoading = false;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController(
    text: 'United States',
  );
  final TextEditingController _zipCodeController = TextEditingController();

  // Phone state
  String _completePhoneNumber = '';
  String? _phoneErrorText;
  bool _phoneInteracted = false;

  DateTime? _dateOfBirth;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _prefillGoogleData();
  }

  void _prefillGoogleData() {
    if (widget.isGoogleUser) {
      if (widget.googleName != null && widget.googleName!.isNotEmpty) {
        _fullNameController.text = widget.googleName!;
      }
      print('📝 Google User - Email: ${widget.googleEmail} (pre-verified)');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() => _profileImage = File(pickedFile.path));
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
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final now = DateTime.now();
    final minAge = DateTime(now.year - 18, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? minAge,
      firstDate: DateTime(1900),
      lastDate: minAge,
      helpText: 'Select date of birth',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.black),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) setState(() => _dateOfBirth = picked);
  }

  String? _validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Full name is required';
    if (value.trim().length < 2) return 'Minimum 2 characters';
    if (value.trim().length > 50) return 'Maximum 50 characters';
    return null;
  }

  String? _validateStreet(String? value) {
    if (value == null || value.trim().isEmpty) return 'Street address is required';
    if (value.trim().length < 5) return 'Please enter a valid street address';
    return null;
  }

  String? _validateCity(String? value) {
    if (value == null || value.trim().isEmpty) return 'City is required';
    if (value.trim().length < 2) return 'Please enter a valid city name';
    return null;
  }

  String? _validateState(String? value) {
    if (value == null || value.trim().isEmpty) return 'State is required';
    if (value.trim().length < 2) return 'Please enter a valid state name';
    return null;
  }

  String? _validateCountry(String? value) {
    if (value == null || value.trim().isEmpty) return 'Country is required';
    if (value.trim().length < 2) return 'Please enter a valid country name';
    return null;
  }

  String? _validateZipCode(String? value) {
    if (value == null || value.trim().isEmpty) return 'ZIP code is required';
    if (value.trim().length < 3) return 'Please enter a valid ZIP code';
    return null;
  }

  String? _validateDateOfBirth() {
    if (_dateOfBirth == null) return 'Date of birth is required';
    final now = DateTime.now();
    int age = now.year - _dateOfBirth!.year;
    if (now.month < _dateOfBirth!.month ||
        (now.month == _dateOfBirth!.month && now.day < _dateOfBirth!.day)) {
      age--;
    }
    if (age < 18) return 'You must be at least 18 years old';
    if (age > 120) return 'Please enter a valid date of birth';
    return null;
  }

  void _validatePhoneNumber(String value) {
    setState(() {
      if (value.isEmpty) {
        _phoneErrorText = 'Phone number is required';
      } else if (value.length < 10) {
        _phoneErrorText = 'Please enter a valid phone number';
      } else {
        _phoneErrorText = null;
      }
    });
  }

  Future<void> _handleSave() async {
    setState(() => _phoneInteracted = true);

    // Validate phone before form validation
    _validatePhoneNumber(_completePhoneNumber);

    if (!_formKey.currentState!.validate()) return;

    if (_phoneErrorText != null || _completePhoneNumber.isEmpty) {
      print('Error validating phone number: $_phoneErrorText');
      // CustomSnackbar.showError(context, _phoneErrorText ?? 'Please enter a valid phone number');
      return;
    }

    final dobError = _validateDateOfBirth();
    if (dobError != null) {
      CustomSnackbar.showError(context, dobError);
      return;
    }

    if (widget.token == null || widget.token!.isEmpty) {
      CustomSnackbar.showError(context, 'Authentication error. Please try logging in again.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final addressMap = {
        'street': _streetController.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'country': _countryController.text.trim(),
        'zipCode': _zipCodeController.text.trim(),
      };

      final response = await _buyerAuthRepo.submitProfileDetails(
        token: widget.token!,
        fullName: _fullNameController.text.trim(),
        phoneNumber: _completePhoneNumber,
        dateOfBirth: _dateOfBirth,
        address: addressMap,
        profilePicture: _profileImage,
      );

      if (mounted) {
        if (response.success && response.token != null && response.buyer != null) {
          await _session.setBuyerSession(
            token: response.token!,
            refreshToken: widget.refreshToken ?? '',
            buyer: _convertToBuyerData(response.buyer!),
          );

          showSuccessDialog(
            context,
            title: widget.isGoogleUser ? 'Welcome!' : 'Profile Saved!',
            message: widget.isGoogleUser
                ? 'Your account has been created successfully with Google!'
                : 'Your personal information has been saved successfully.',
            buttonText: 'Continue to Shop',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const BottomNavigationScreen()),
              );
            },
          );
        } else {
          print('Error saving profile details: ${response.message}');
          CustomSnackbar.showError(context, response.message ?? 'Failed to save profile details');
        }
      }
    } catch (e) {
      if (mounted) {
        print('Exception during profile submission: $e');
        CustomSnackbar.showError(context, e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  BuyerData _convertToBuyerData(Buyer buyer) {
    return BuyerData(
      id: buyer.id,
      email: buyer.email,
      fullName: buyer.fullName,
      phoneNumber: buyer.phoneNumber,
      registrationStep: buyer.registrationStep,
      isEmailVerified: buyer.isEmailVerified,
      status: buyer.status,
      profilePicture: buyer.profilePicture?.toJson(),
      preferences: buyer.preferences,
      dateOfBirth: buyer.dateOfBirth,
      address: buyer.address?.toJson(),
      completedAt: buyer.completedAt,
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

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
          'Personal information',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Google User Info Banner
              if (widget.isGoogleUser) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.g_mobiledata, color: Colors.blue.shade700, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Signed in with Google',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              widget.googleEmail ?? 'Email verified',
                              style: TextStyle(color: Colors.blue.shade600, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.verified, color: Colors.green.shade600, size: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Profile Picture
              Center(
                child: GestureDetector(
                  onTap: () => _showImageSourceSheet(context),
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 52,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                        child: _profileImage == null
                            ? Icon(Icons.person_outline, color: Colors.grey[600], size: 40)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Tap to upload photo (Optional)',
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                ),
              ),

              const SizedBox(height: 32),

              _sectionLabel('Personal details'),
              const SizedBox(height: 12),

              _buildTextField(
                label: 'Full name *',
                controller: _fullNameController,
                hint: 'e.g. John Doe',
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                validator: _validateFullName,
              ),
              const SizedBox(height: 16),

              // Phone field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Phone number *',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  IntlPhoneField(
                    initialCountryCode: 'US',
                    decoration: InputDecoration(
                      hintText: '800 000 0000',
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.black, width: 1.5),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red, width: 1.5),
                      ),
                      errorText: _phoneInteracted && _phoneErrorText != null ? _phoneErrorText : null,
                    ),
                    style: const TextStyle(fontSize: 15),
                    dropdownTextStyle: const TextStyle(fontSize: 15),
                    flagsButtonPadding: const EdgeInsets.symmetric(horizontal: 12),
                    dropdownIcon: Icon(Icons.arrow_drop_down, color: Colors.grey[600], size: 20),
                    onChanged: (PhoneNumber phone) {
                      setState(() {
                        _completePhoneNumber = phone.completeNumber;
                        _phoneInteracted = true;
                        _validatePhoneNumber(phone.completeNumber);
                      });
                    },
                    onCountryChanged: (_) {
                      setState(() {
                        _completePhoneNumber = '';
                        _phoneErrorText = null;
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Date of Birth
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Date of birth *',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _selectDateOfBirth(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _dateOfBirth != null
                                ? DateFormat('dd MMM yyyy').format(_dateOfBirth!)
                                : 'Select date of birth',
                            style: TextStyle(
                              fontSize: 15,
                              color: _dateOfBirth != null ? Colors.black : Colors.grey[400],
                            ),
                          ),
                          Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey[500]),
                        ],
                      ),
                    ),
                  ),
                  if (_dateOfBirth == null && _phoneInteracted)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 14),
                      child: Text(
                        'Date of birth is required',
                        style: TextStyle(fontSize: 12, color: Colors.red.shade700),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 28),

              _sectionLabel('Address'),
              const SizedBox(height: 12),

              _buildTextField(
                label: 'Street *',
                controller: _streetController,
                hint: '200 Broadway Ave',
                textCapitalization: TextCapitalization.sentences,
                validator: _validateStreet,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'City *',
                      controller: _cityController,
                      hint: 'New York',
                      textCapitalization: TextCapitalization.words,
                      validator: _validateCity,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      label: 'State *',
                      controller: _stateController,
                      hint: 'New York',
                      textCapitalization: TextCapitalization.words,
                      validator: _validateState,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'Country *',
                      controller: _countryController,
                      hint: 'United States',
                      textCapitalization: TextCapitalization.words,
                      validator: _validateCountry,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      label: 'ZIP code *',
                      controller: _zipCodeController,
                      hint: '10001',
                      keyboardType: TextInputType.number,
                      validator: _validateZipCode,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: _isLoading
              ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : const Text(
            'Save & Continue',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.grey[500],
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
    IconData? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          validator: validator,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: Colors.grey[500], size: 18) : null,
          ),
        ),
      ],
    );
  }
}