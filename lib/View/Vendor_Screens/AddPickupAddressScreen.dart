import 'package:flutter/material.dart';
import '../../Models/SellerModels/SellerPickupAddressModels.dart';
import '../../Repository/SellerRepository/SellerPickupAddressRepository.dart';
import '../../res/Widgets/CustomSnackbar.dart';
import '../../res/Widgets/SuccessDialog.dart';

class AddPickupAddressScreen extends StatefulWidget {
  final PickupAddress? addressToEdit;

  const AddPickupAddressScreen({super.key, this.addressToEdit});

  @override
  State<AddPickupAddressScreen> createState() => _AddPickupAddressScreenState();
}

class _AddPickupAddressScreenState extends State<AddPickupAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController(text: 'United States');

  final _addressLabelController = TextEditingController();
  final _streetAddressController = TextEditingController();
  final _suiteController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  bool _isDefault = false;
  late final SellerPickupAddressRepository _repository;

  // Getter to check if we're in edit mode
  bool get isEditMode => widget.addressToEdit != null;

  @override
  void initState() {
    super.initState();
    _repository = SellerPickupAddressRepository();

    // If editing, populate the form fields
    if (isEditMode) {
      _populateFormWithExistingData();
    }
  }

  void _populateFormWithExistingData() {
    final address = widget.addressToEdit!;
    _addressLabelController.text = address.addressLabel;
    _streetAddressController.text = address.street;
    _suiteController.text = address.apartment;
    _cityController.text = address.city;
    _stateController.text = address.state;
    _zipController.text = address.zipCode;
    _countryController.text = address.country;
    _phoneController.text = address.phoneNumber;
    _isDefault = address.isDefault;
  }

  @override
  void dispose() {
    _addressLabelController.dispose();
    _streetAddressController.dispose();
    _suiteController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditMode ? 'Edit Pickup Address' : 'Pickup / Warehouse Address',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        actions: isEditMode && widget.addressToEdit?.isDefault == false
            ? [
          TextButton(
            onPressed: _setAsDefault,
            child: const Text(
              'Set as Default',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ]
            : null,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoBanner(),
                  const SizedBox(height: 20),

                  _buildSectionLabel('Pickup Address'),
                  const SizedBox(height: 16),

                  // 1. Address label
                  _buildTextField(
                    controller: _addressLabelController,
                    label: 'Address label',
                    hint: 'e.g. Warehouse, Home, Storefront',
                    prefixIcon: Icons.label_outline,
                    maxLength: 50,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Address label is required';
                      }
                      if (v.length > 50) {
                        return 'Address label cannot exceed 50 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // 2. Street address
                  _buildTextField(
                    controller: _streetAddressController,
                    label: 'Street address',
                    hint: '1224 University Drive',
                    prefixIcon: Icons.search,
                    validator: (v) =>
                    (v == null || v.isEmpty) ? 'Street address is required' : null,
                  ),
                  const SizedBox(height: 14),

                  // 3. Apartment / Suite (optional)
                  _buildTextField(
                    controller: _suiteController,
                    label: 'Apartment / Suite (optional)',
                    hint: '2nd floor, Unit B1',
                  ),
                  const SizedBox(height: 14),

                  // 4. City
                  _buildTextField(
                    controller: _cityController,
                    label: 'City',
                    hint: 'Houston',
                    validator: (v) =>
                    (v == null || v.isEmpty) ? 'City is required' : null,
                  ),
                  const SizedBox(height: 14),

                  // 5. State / Zip
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _stateController,
                          label: 'State',
                          hint: 'e.g. Texas',
                          validator: (v) =>
                          (v == null || v.isEmpty) ? 'State is required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _zipController,
                          label: 'Zip code',
                          hint: '77002 or 77002-1234',
                          keyboardType: TextInputType.text,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Zip code is required';
                            }
                            final zipRegex = RegExp(r'^\d{5}(-\d{4})?$');
                            if (!zipRegex.hasMatch(v)) {
                              return 'Please enter a valid zip code (e.g., 77002 or 77002-1234)';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 6. Country
                  _buildTextField(
                    controller: _countryController,
                    label: 'Country',
                    hint: 'e.g. United States',
                    validator: (v) =>
                    (v == null || v.isEmpty) ? 'Country is required' : null,
                  ),
                  const SizedBox(height: 14),

                  // 7. Phone number
                  _buildPhoneField(),
                  const SizedBox(height: 16),

                  // Default address toggle
                  if (!isEditMode || !widget.addressToEdit!.isDefault)
                    _buildDefaultToggle(),

                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      isEditMode
                          ? 'Update the address details as needed'
                          : 'This will be your default pickup address for all shipments',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveAddress,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 0,
            disabledBackgroundColor: Colors.grey.shade400,
          ),
          child: Text(
            _isLoading
                ? (isEditMode ? 'Updating...' : 'Saving...')
                : (isEditMode ? 'Update address' : 'Save address'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.35),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 2.5,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Saving address…',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isEditMode ? 'Updating your address' : 'Completing your registration',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F1FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB5D4F4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF185FA5), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isEditMode
                  ? 'Update your pickup address details. Changes will affect future shipments.'
                  : 'This address is where buyers ship returns and where you dispatch orders from.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade800,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
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
          label,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    String? hint,
    IconData? prefixIcon,
    TextEditingController? controller,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          maxLength: maxLength,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: Colors.grey.shade400, size: 18)
                : null,
            counterText: maxLength != null ? null : '',
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phone number',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          style: const TextStyle(fontSize: 14),
          validator: (v) {
            if (v == null || v.isEmpty) {
              return 'Phone number is required';
            }
            final phoneRegex = RegExp(r'^\+?[\d\s-]{10,}$');
            if (!phoneRegex.hasMatch(v)) {
              return 'Please enter a valid phone number (e.g., +1 650 313 7379)';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: '650 313 7379',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black, width: 1.5),
            ),
            prefixIcon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🇺🇸', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    '+1',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              const Icon(Icons.star_outline, color: Colors.black, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Set as default address',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'This address will be used as default for all shipments',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isDefault,
                onChanged: (value) {
                  setState(() {
                    _isDefault = value;
                  });
                },
                activeColor: Colors.black,
                inactiveThumbColor: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _saveAddress() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (isEditMode) {
        await _updateAddress();
      } else {
        // First validate the address
        final isValid = await _validateAddressBeforeSave();
        if (isValid) {
          await _createAddress();
        }
      }
    } catch (e) {
      String errorMessage = e.toString();
      errorMessage = errorMessage.replaceAll('Exception: ', '');
      CustomSnackbar.showError(context, errorMessage);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _validateAddressBeforeSave() async {
    try {
      String cleanPhone = _phoneController.text.trim();
      cleanPhone = cleanPhone.replaceAll(RegExp(r'[\s-]'), '');

      final validation = await _repository.validateAddress(
        street: _streetAddressController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        zipCode: _zipController.text.trim(),
        phoneNumber: cleanPhone,
        addressLabel: _addressLabelController.text.trim(),
        apartment: _suiteController.text.trim().isEmpty ? null : _suiteController.text.trim(),
        country: _countryController.text.trim(),
      );

      if (!validation.success) {
        // Show validation error dialog
        await _showAddressValidationErrorDialog(validation);
        return false;
      }

      return true;
    } catch (e) {
      print('Validation error: $e');
      return true; // Proceed with save if validation fails (fallback)
    }
  }

  Future<void> _createAddress() async {
    String cleanPhone = _phoneController.text.trim();
    cleanPhone = cleanPhone.replaceAll(RegExp(r'[\s-]'), '');

    final request = CreatePickupAddressRequest(
      addressLabel: _addressLabelController.text.trim(),
      street: _streetAddressController.text.trim(),
      apartment: _suiteController.text.trim().isEmpty
          ? null
          : _suiteController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      zipCode: _zipController.text.trim(),
      country: _countryController.text.trim(),
      phoneNumber: cleanPhone,
      isDefault: _isDefault,
    );

    final newAddress = await _repository.createPickupAddress(request);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Address added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, newAddress);
    }
  }

  Future<void> _updateAddress() async {
    String cleanPhone = _phoneController.text.trim();
    cleanPhone = cleanPhone.replaceAll(RegExp(r'[\s-]'), '');

    final request = UpdatePickupAddressRequest(
      addressLabel: _addressLabelController.text.trim(),
      street: _streetAddressController.text.trim(),
      apartment: _suiteController.text.trim().isEmpty
          ? null
          : _suiteController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      zipCode: _zipController.text.trim(),
      country: _countryController.text.trim(),
      phoneNumber: cleanPhone,
      isDefault: _isDefault,
    );

    final updatedAddress = await _repository.updatePickupAddress(
      widget.addressToEdit!.id,
      request,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Address updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, updatedAddress);
    }
  }

  Future<void> _setAsDefault() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _repository.setDefaultPickupAddress(widget.addressToEdit!.id);

      if (mounted) {
        CustomSnackbar.showSuccess(context, 'Address set as default successfully');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString().replaceAll('Exception: ', '');
        CustomSnackbar.showError(context, errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showAddressValidationErrorDialog(AddressValidationResponse response) async {
    if (response.hasSuggestedAddress) {
      final shouldUseSuggested = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.4),
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF7ED),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit_location_alt_outlined,
                          color: Color(0xFFC2570A), size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Address Correction',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              letterSpacing: -0.2,
                            ),
                          ),
                          Text(
                            'We found a possible improvement',
                            style: TextStyle(fontSize: 12, color: Colors.black45),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (response.errors != null && response.errors!.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ISSUES FOUND',
                          style: TextStyle(
                            color: Color(0xFFBE123C),
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...response.errors!.map(
                              (e) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.remove_circle_outline_rounded,
                                    size: 14, color: Color(0xFFBE123C)),
                                const SizedBox(width: 7),
                                Expanded(
                                  child: Text(e,
                                      style: const TextStyle(
                                          fontSize: 12.5,
                                          color: Color(0xFFBE123C),
                                          height: 1.4)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (response.suggestedAddress != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SUGGESTED ADDRESS',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _suggestionRow(
                          'Street',
                          response.suggestedAddress!['street'],
                          _streetAddressController.text,
                        ),
                        _suggestionRow(
                          'City',
                          response.suggestedAddress!['city'],
                          _cityController.text,
                        ),
                        _suggestionRow(
                          'State',
                          response.suggestedAddress!['state'],
                          _stateController.text,
                        ),
                        _suggestionRow(
                          'ZIP',
                          response.suggestedAddress!['zipCode'],
                          _zipController.text,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 46),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          'Keep mine',
                          style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                              fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          minimumSize: const Size(0, 46),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Use suggested',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      if (shouldUseSuggested == true && response.suggestedAddress != null) {
        setState(() {
          if (response.suggestedAddress!['street'] != null)
            _streetAddressController.text = response.suggestedAddress!['street'];
          if (response.suggestedAddress!['city'] != null)
            _cityController.text = response.suggestedAddress!['city'];
          if (response.suggestedAddress!['state'] != null)
            _stateController.text = response.suggestedAddress!['state'];
          if (response.suggestedAddress!['zipCode'] != null)
            _zipController.text = response.suggestedAddress!['zipCode'];
        });
        _saveAddress(); // Retry save
        return;
      }
    }

    // Simple error dialog
    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF1F2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.location_off_outlined,
                        color: Color(0xFFBE123C), size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Address Not Verified',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            letterSpacing: -0.2,
                          ),
                        ),
                        Text(
                          'Please review and correct your address',
                          style: TextStyle(fontSize: 12, color: Colors.black45),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'WHAT TO CHECK',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      response.getUserFriendlyErrorMessage(),
                      style: const TextStyle(
                          fontSize: 13, color: Colors.white70, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "OK, I'll fix it",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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

  Widget _suggestionRow(String label, String? suggested, String original) {
    if (suggested == null || suggested == original) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 48,
            child: Text(
              label,
              style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  original,
                  style: const TextStyle(
                    color: Colors.white30,
                    fontSize: 12,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: Colors.white30,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  suggested,
                  style: const TextStyle(
                    color: Color(0xFF4ADE80),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}