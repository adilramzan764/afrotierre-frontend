import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../../Services/AppSession.dart';
import '../../Repository/BuyerRepository/BuyerLoginProfileRepo.dart';
import '../../Constants/ApiConstants.dart';
import '../../res/Widgets/CustomSnackbar.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  final AppSession _session = AppSession.instance;
  final BuyerLoginProfileRepo _repo = BuyerLoginProfileRepo();
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();

  DateTime? _dateOfBirth;
  File? _profileImage;
  String? _existingProfileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final buyerProfile = _session.buyerProfile;

    if (buyerProfile != null) {
      _fullNameController.text = buyerProfile.fullName ?? '';
      _emailController.text = buyerProfile.email ?? '';
      _phoneController.text = buyerProfile.phoneNumber ?? '';

      // Handle profile picture (could be String or Map)
      if (buyerProfile.profilePicture != null) {
        if (buyerProfile.profilePicture is String) {
          _existingProfileImageUrl = buyerProfile.profilePicture as String;
        } else if (buyerProfile.profilePicture is Map) {
          _existingProfileImageUrl = (buyerProfile.profilePicture as Map)['url'];
        }
      }

      // Load address if exists
      if (buyerProfile.address != null) {
        _streetController.text = buyerProfile.address!['street']?.toString() ?? '';
        _cityController.text = buyerProfile.address!['city']?.toString() ?? '';
        _stateController.text = buyerProfile.address!['state']?.toString() ?? '';
        _countryController.text = buyerProfile.address!['country']?.toString() ?? 'United States';
        _zipCodeController.text = buyerProfile.address!['zipCode']?.toString() ?? '';
      }

      // Load date of birth
      if (buyerProfile.dateOfBirth != null) {
        _dateOfBirth = buyerProfile.dateOfBirth;
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
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

    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }


  // Validators
  String? _validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Please enter a valid full name';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final regex = RegExp(r'^\+?[\d\s\-]{10,}$');
    if (!regex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? _validateStreet(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Street address is required';
    }
    return null;
  }

  String? _validateCity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'City is required';
    }
    return null;
  }

  String? _validateState(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'State is required';
    }
    return null;
  }

  String? _validateZipCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'ZIP code is required';
    }
    return null;
  }

  String? _validateDateOfBirth() {
    if (_dateOfBirth == null) {
      return 'Date of birth is required';
    }

    final now = DateTime.now();
    var age = now.year - _dateOfBirth!.year;
    final monthDiff = now.month - _dateOfBirth!.month;
    final dayDiff = now.day - _dateOfBirth!.day;

    if (monthDiff < 0 || (monthDiff == 0 && dayDiff < 0)) {
      age--;
    }

    if (age < 18) {
      return 'You must be at least 18 years old';
    }
    return null;
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final dobValidation = _validateDateOfBirth();
    if (dobValidation != null) {
      CustomSnackbar.showError(context, dobValidation);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final token = _session.authToken;
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      // Prepare address map
      final addressMap = {
        'street': _streetController.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'country': _countryController.text.trim(),
        'zipCode': _zipCodeController.text.trim(),
      };

      // Prepare profile data (only include fields that should be updated)
      final Map<String, dynamic> profileData = {};

      // Only add fields that have changed
      if (_fullNameController.text.trim() != _session.buyerProfile?.fullName) {
        profileData['fullName'] = _fullNameController.text.trim();
      }

      if (_phoneController.text.trim() != _session.buyerProfile?.phoneNumber) {
        profileData['phoneNumber'] = _phoneController.text.trim();
      }

      if (_dateOfBirth != _session.buyerProfile?.dateOfBirth) {
        profileData['dateOfBirth'] = _dateOfBirth?.toIso8601String();
      }

      // Always include address if it exists or has been changed
      final currentAddress = _session.buyerProfile?.address;
      bool addressChanged = currentAddress == null ||
          currentAddress['street'] != addressMap['street'] ||
          currentAddress['city'] != addressMap['city'] ||
          currentAddress['state'] != addressMap['state'] ||
          currentAddress['country'] != addressMap['country'] ||
          currentAddress['zipCode'] != addressMap['zipCode'];

      if (addressChanged) {
        profileData['address'] = addressMap;
      }

      // If no changes and no new image, show info and return
      if (profileData.isEmpty && _profileImage == null) {
        if (mounted) {
          CustomSnackbar.showInfo(context, 'No changes to save');
        }
        setState(() => _isSaving = false);
        return;
      }

      // Call API to update profile with optional image
      final response = await _repo.updateProfile(
        token,
        profileData,
        profileImage: _profileImage,
        context: context,
      );

      if (response.success && mounted) {
        // Fetch the latest profile from server to ensure we have all data
        final updatedProfileResponse = await _repo.getProfile(
          token,
          context: context,
        );

        if (updatedProfileResponse.success && mounted) {
          // Update session with the complete latest profile
          await _session.updateBuyerProfile(updatedProfileResponse.buyer);


          // Go back to previous screen
          Navigator.pop(context);
        } else {
          // If profile fetch fails, update session with local changes
          final updatedProfile = _session.buyerProfile?.copyWith(
            fullName: _fullNameController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            dateOfBirth: _dateOfBirth,
            address: addressMap,
          );

          if (updatedProfile != null) {
            await _session.updateBuyerProfile(updatedProfile);
          }
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(
          context,
          'Failed to update profile: ${e.toString().replaceFirst('Exception: ', '')}',
        );
      }
      print('Profile update error: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
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
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
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

              // ── Profile Picture ──
              Center(
                child: GestureDetector(
                  onTap: () => _showImageSourceSheet(context),
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 52,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : (_existingProfileImageUrl != null && _existingProfileImageUrl!.isNotEmpty
                            ? NetworkImage(_existingProfileImageUrl!)
                            : null) as ImageProvider?,
                        child: (_profileImage == null && (_existingProfileImageUrl == null || _existingProfileImageUrl!.isEmpty))
                            ? Icon(
                          Icons.person_outline,
                          color: Colors.grey[600],
                          size: 40,
                        )
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
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Tap to change photo',
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                ),
              ),

              const SizedBox(height: 32),

              // ── Personal Details Section ──
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

              _buildTextField(
                label: 'Email',
                controller: _emailController,
                hint: 'email@example.com',
                keyboardType: TextInputType.emailAddress,
                enabled: false, // Email cannot be changed
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: 'Phone number *',
                controller: _phoneController,
                hint: '+234 800 000 0000',
                keyboardType: TextInputType.phone,
                validator: _validatePhone,
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
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
                              color: _dateOfBirth != null
                                  ? Colors.black
                                  : Colors.grey[400],
                            ),
                          ),
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 18,
                            color: Colors.grey[500],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── Address Section ──
              _sectionLabel('Address'),
              const SizedBox(height: 12),

              _buildTextField(
                label: 'Street *',
                controller: _streetController,
                hint: '350 5th Avenue',
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
                      label: 'Country',
                      controller: _countryController,
                      hint: 'Nigeria',
                      textCapitalization: TextCapitalization.words,
                      enabled: false,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      label: 'ZIP code *',
                      controller: _zipCodeController,
                      hint: '100001',
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
          onPressed: _isSaving ? null : _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: _isSaving
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
    bool enabled = true,
    IconData? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          validator: validator,
          enabled: enabled,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
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
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, color: Colors.grey[500], size: 18)
                : null,
          ),
        ),
      ],
    );
  }
}