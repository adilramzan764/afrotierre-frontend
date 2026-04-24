import 'package:afrotierre/View/Vendor_Screens/vendor_bottom_navigation_screen.dart';
import 'package:flutter/material.dart';
import '../../Models/SellerModels/SellerAuthModels.dart';
import '../../Models/SellerModels/SellerPickupAddressModels.dart';
import '../../Repository/SellerRepository/SellerAuthRepository.dart';
import '../../Repository/SellerRepository/SellerPickupAddressRepository.dart';
import '../../res/Widgets/CustomSnackbar.dart';
import '../Onboarding_Screens/sign_in_account_seller.dart';

class VendorSignUpAddressScreen extends StatefulWidget {
  final bool isGoogleUser;
  final String? googleEmail;
  final String storeName;
  final String? token;

  const VendorSignUpAddressScreen({
    super.key,
    required this.isGoogleUser,
    this.googleEmail,
    required this.storeName,
    this.token,
  });

  @override
  State<VendorSignUpAddressScreen> createState() =>
      _VendorSignUpAddressScreenState();
}

class _VendorSignUpAddressScreenState
    extends State<VendorSignUpAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController(text: 'United States');
  final _addressLabelController = TextEditingController();
  final _streetAddressController = TextEditingController();
  final _suiteController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _isDefault = true;
  late final SellerAuthRepository _authRepository;
  late final SellerPickupAddressRepository _pickupRepository;

  @override
  void initState() {
    super.initState();
    _authRepository = SellerAuthRepository();
    _pickupRepository = SellerPickupAddressRepository();
    if (widget.googleEmail != null) {
      _emailController.text = widget.googleEmail!;
    }
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
    _emailController.dispose();
    _authRepository.dispose();
    super.dispose();
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Your Account',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 17,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
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
                  _buildSectionLabel('Pickup / Warehouse Address'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _addressLabelController,
                    label: 'Address label',
                    hint: 'e.g. Warehouse, Home, Storefront',
                    prefixIcon: Icons.label_outline,
                    maxLength: 50,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Address label is required';
                      if (v.length > 50) return 'Max 50 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: _streetAddressController,
                    label: 'Street address',
                    hint: '1224 University Drive',
                    prefixIcon: Icons.search,
                    validator: (v) =>
                    (v == null || v.isEmpty) ? 'Street address is required' : null,
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: _suiteController,
                    label: 'Apartment / Suite (optional)',
                    hint: '2nd floor, Unit B1',
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: _cityController,
                    label: 'City',
                    hint: 'Houston',
                    validator: (v) =>
                    (v == null || v.isEmpty) ? 'City is required' : null,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _stateController,
                          label: 'State',
                          hint: 'Texas',
                          validator: (v) =>
                          (v == null || v.isEmpty) ? 'State is required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _zipController,
                          label: 'Zip code',
                          hint: '77002',
                          keyboardType: TextInputType.text,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Zip code is required';
                            if (!RegExp(r'^\d{5}(-\d{4})?$').hasMatch(v)) {
                              return 'Format: 77002 or 77002-1234';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: _countryController,
                    label: 'Country',
                    hint: 'United States',
                    validator: (v) =>
                    (v == null || v.isEmpty) ? 'Country is required' : null,
                  ),
                  const SizedBox(height: 14),
                  _buildPhoneField(),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email (for pickup notifications)',
                    hint: widget.googleEmail ?? 'business@example.com',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Email is required';
                      if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(v)) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildDefaultToggle(),
                  const SizedBox(height: 14),
                  Center(
                    child: Text(
                      'This will be your default pickup address for all shipments',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Loading overlay ──────────────────────────────────────────────
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveAddressAndCompleteRegistration,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 0,
            disabledBackgroundColor: Colors.grey.shade300,
          ),
          child: _isLoading
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
                color: Colors.white, strokeWidth: 2),
          )
              : const Text(
            'Complete Registration',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ─── Loading overlay ───────────────────────────────────────────────────────

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
                'Completing your registration',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Form fields ───────────────────────────────────────────────────────────

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: Colors.white54, size: 16),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'This address is where buyers ship returns and where you dispatch orders from. Adding a pickup address completes your registration.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white70,
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
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
              fontSize: 13.5, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        const SizedBox(height: 6),
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
            contentPadding:
            const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
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
              borderSide: const BorderSide(color: Color(0xFFBE123C)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
              const BorderSide(color: Color(0xFFBE123C), width: 1.5),
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: Colors.grey.shade400, size: 18)
                : null,
            counterText: '',
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
              fontSize: 13.5, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          style: const TextStyle(fontSize: 14),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Phone number is required';
            if (!RegExp(r'^\+?[\d\s-]{10,}$').hasMatch(v)) {
              return 'Enter a valid phone number (e.g. +1 650 313 7379)';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: '650 313 7379',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
            const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
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
              borderSide: const BorderSide(color: Color(0xFFBE123C)),
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
                  Text('+1',
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade700)),
                  Icon(Icons.arrow_drop_down,
                      size: 16, color: Colors.grey.shade400),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultToggle() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.star_outline_rounded,
                color: Colors.black54, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Set as default address',
                  style: TextStyle(
                      fontSize: 13.5, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Used by default for all shipments',
                  style: TextStyle(fontSize: 11.5, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _isDefault,
            onChanged: (v) => setState(() => _isDefault = v),
            activeColor: const Color(0xFF4ADE80),
            activeTrackColor: const Color(0xFF4ADE80).withOpacity(0.25),
          ),
        ],
      ),
    );
  }

  // ─── Logic ────────────────────────────────────────────────────────────────

  Future<void> _saveAddressAndCompleteRegistration() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final request = PickupAddressRequest(
        addressLabel: _addressLabelController.text.trim(),
        street: _streetAddressController.text.trim(),
        apartment: _suiteController.text.trim().isEmpty
            ? null
            : _suiteController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        zipCode: _zipController.text.trim(),
        country: _countryController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        company: widget.storeName,
        email: _emailController.text.trim(),
        isDefault: _isDefault,
      );

      final response = await _authRepository.addPickupAddress(
        token: widget.token!,
        request: request,
      );

      if (response.success) {
        if (mounted) await _showSuccessDialog();
      } else {
        if (mounted) await _showAddressValidationErrorDialog(response);
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(
            context, 'Network error: Please check your connection and try again.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Address validation dialog ─────────────────────────────────────────────

  Future<void> _showAddressValidationErrorDialog(AuthResponse response) async {
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
                // ── Header ──────────────────────────────────────────────
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
                            style: TextStyle(
                                fontSize: 12, color: Colors.black45),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // ── Errors block ─────────────────────────────────────────
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

                // ── Suggestion block (black card) ─────────────────────────
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

                // ── Action buttons ────────────────────────────────────────
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
        _saveAddressAndCompleteRegistration();
        return;
      }
    }

    // ── Simple error dialog (no suggestion) ─────────────────────────────────
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
              // Header
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
                          style:
                          TextStyle(fontSize: 12, color: Colors.black45),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Error details (black card)
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
                    if (response.validationSource == 'shippo') ...[
                      const SizedBox(height: 10),
                      const Divider(color: Colors.white12, height: 1),
                      const SizedBox(height: 10),
                      ...[
                        'Street address is spelled correctly',
                        'City name matches the ZIP code',
                        'State abbreviation is correct',
                      ].map(
                            (tip) => Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Row(
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                margin: const EdgeInsets.only(right: 8, top: 1),
                                decoration: const BoxDecoration(
                                  color: Colors.white24,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Text(tip,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white54,
                                      height: 1.4)),
                            ],
                          ),
                        ),
                      ),
                    ],
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

  /// One row in the suggestion black card.
  /// Only renders if the suggested value differs from the original.
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

  // ─── Success dialog ────────────────────────────────────────────────────────

  Future<void> _showSuccessDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Icon ──────────────────────────────────────────────────
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    size: 32, color: Color(0xFF16A34A)),
              ),
              const SizedBox(height: 18),

              // ── Title ─────────────────────────────────────────────────
              const Text(
                'Registration Complete!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.isGoogleUser
                    ? 'Your store has been created with Google Sign-In. You can now start selling.'
                    : 'Your store has been created and your pickup address saved. You can now start selling.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 18),

              // ── Store + address summary (black card) ──────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Store name row
                    if (widget.storeName.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(Icons.storefront_outlined,
                              size: 14, color: Colors.white38),
                          const SizedBox(width: 8),
                          Text(
                            widget.storeName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 1,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        color: Colors.white10,
                      ),
                    ],
                    // Address rows
                    const Text(
                      'PICKUP ADDRESS',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: Colors.white38),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _addressLabelController.text.trim(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_streetAddressController.text.trim()}, ${_cityController.text.trim()}',
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── CTA ────────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const VendorBottomNavigationScreen(),
                      ),
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
                    'Go to Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your account is fully registered and ready to sell',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
              ),
            ],
          ),
        ),
      ),
    );
  }
}