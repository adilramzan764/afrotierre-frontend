import 'package:flutter/material.dart';
import 'package:afrotierre/Repository/SellerRepository/PasswordResetRepo.dart';
import '../../Models/SellerModels/PasswordResetModels.dart';
import '../../res/Widgets/CustomSnackbar.dart';

class ChangePasswordScreen extends StatefulWidget {
  final bool isSeller;
  const ChangePasswordScreen({super.key, required this.isSeller});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final PasswordResetRepo _apiService = PasswordResetRepo();

  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  // ── Password strength ─────────────────────────────────────────────────────────
  int _strengthScore = 0; // 0-4

  void _evaluateStrength(String value) {
    int score = 0;
    if (value.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(value)) score++;
    if (RegExp(r'[0-9]').hasMatch(value)) score++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) score++;
    setState(() => _strengthScore = score);
  }

  String get _strengthLabel {
    switch (_strengthScore) {
      case 0:
      case 1: return 'Weak';
      case 2: return 'Fair';
      case 3: return 'Good';
      case 4: return 'Strong';
      default: return '';
    }
  }

  Color get _strengthColor {
    switch (_strengthScore) {
      case 0:
      case 1: return const Color(0xFFA32D2D);
      case 2: return const Color(0xFF854F0B);
      case 3: return const Color(0xFF3B6D11);
      case 4: return const Color(0xFF0F6E56);
      default: return Colors.grey;
    }
  }

  // ── Requirement checks ────────────────────────────────────────────────────────
  bool get _hasMinLength => _newPasswordController.text.length >= 8;
  bool get _hasUppercase => RegExp(r'[A-Z]').hasMatch(_newPasswordController.text);
  bool get _hasNumber => RegExp(r'[0-9]').hasMatch(_newPasswordController.text);
  bool get _hasSymbol => RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(_newPasswordController.text);

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ── Submit ────────────────────────────────────────────────────────────────────

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final response = await _apiService.changePassword(
      currentPassword: _currentPasswordController.text.trim(),
      newPassword: _newPasswordController.text.trim(),
      confirmPassword: _confirmPasswordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (response.success) {
      _showSuccessDialog();
    } else {
      CustomSnackbar.showError(context, response.message);
    }
  }

  // ── Success dialog ────────────────────────────────────────────────────────────

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated success icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3DE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_open_rounded,
                  size: 38,
                  color: Color(0xFF3B6D11),
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Password updated!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Your password has been changed successfully. Use your new password next time you log in.',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop(true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoBanner(),
                      const SizedBox(height: 28),

                      // ── Current password ──────────────────────────────────
                      _sectionHeader('Current password'),
                      const SizedBox(height: 10),
                      _buildPasswordField(
                        controller: _currentPasswordController,
                        hint: 'Enter current password',
                        isVisible: _showCurrent,
                        onToggle: () => setState(() => _showCurrent = !_showCurrent),
                        validator: (v) => v == null || v.isEmpty ? 'Enter your current password' : null,
                      ),
                      const SizedBox(height: 28),

                      // ── New password ──────────────────────────────────────
                      _sectionHeader('New password'),
                      const SizedBox(height: 10),
                      _buildPasswordField(
                        controller: _newPasswordController,
                        hint: 'Enter new password',
                        isVisible: _showNew,
                        onToggle: () => setState(() => _showNew = !_showNew),
                        onChanged: _evaluateStrength,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter a new password';
                          if (v.length < 8) return 'Must be at least 8 characters';
                          if (v == _currentPasswordController.text) {
                            return 'New password must differ from current';
                          }
                          return null;
                        },
                      ),

                      // Strength bar (only shown when typing)
                      if (_newPasswordController.text.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildStrengthBar(),
                      ],

                      const SizedBox(height: 20),

                      // ── Confirm password ──────────────────────────────────
                      _sectionHeader('Confirm new password'),
                      const SizedBox(height: 10),
                      _buildPasswordField(
                        controller: _confirmPasswordController,
                        hint: 'Re-enter new password',
                        isVisible: _showConfirm,
                        onToggle: () => setState(() => _showConfirm = !_showConfirm),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Please confirm your password';
                          if (v != _newPasswordController.text) return 'Passwords do not match';
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),

                      // ── Requirements checklist ────────────────────────────
                      _buildRequirementsCard(),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),

            // ── Save button ───────────────────────────────────────────────────
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  // ── Top bar ───────────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200, width: 0.8),
                ),
                child: const Icon(Icons.arrow_back, size: 18, color: Colors.black),
              ),
            ),
          ),
          const Text(
            'Change Password',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black),
          ),
        ],
      ),
    );
  }

  // ── Info banner ───────────────────────────────────────────────────────────────

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAEEDA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEF9F27).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, color: Color(0xFF854F0B), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Choose a strong password with at least 8 characters, including uppercase letters, numbers, and symbols.',
              style: TextStyle(fontSize: 13, color: Colors.orange.shade900, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section header ────────────────────────────────────────────────────────────

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black),
    );
  }

  // ── Password field ────────────────────────────────────────────────────────────

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool isVisible,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      validator: validator,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14, fontWeight: FontWeight.w400),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 0.8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFA32D2D), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFA32D2D), width: 1.5),
        ),
        suffixIcon: GestureDetector(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Icon(
              isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: Colors.grey.shade400,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  // ── Strength bar ──────────────────────────────────────────────────────────────

  Widget _buildStrengthBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (i) {
            final filled = i < _strengthScore;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: EdgeInsets.only(right: i < 3 ? 5 : 0),
                height: 5,
                decoration: BoxDecoration(
                  color: filled ? _strengthColor : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        if (_strengthScore > 0)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                _strengthLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _strengthColor,
                ),
              ),
            ],
          ),
      ],
    );
  }

  // ── Requirements card ─────────────────────────────────────────────────────────

  Widget _buildRequirementsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Password requirements',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black),
          ),
          const SizedBox(height: 14),
          _requirementRow('At least 8 characters', _hasMinLength),
          const SizedBox(height: 10),
          _requirementRow('Upper & lowercase letters', _hasUppercase),
          const SizedBox(height: 10),
          _requirementRow('At least one number', _hasNumber),
          const SizedBox(height: 10),
          _requirementRow('At least one symbol (!@#\$…)', _hasSymbol),
        ],
      ),
    );
  }

  Widget _requirementRow(String label, bool met) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: met ? const Color(0xFFEAF3DE) : Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            met ? Icons.check_rounded : Icons.remove_rounded,
            size: 13,
            color: met ? const Color(0xFF3B6D11) : Colors.grey.shade400,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: met ? FontWeight.w600 : FontWeight.w400,
            color: met ? Colors.black87 : Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  // ── Save button ───────────────────────────────────────────────────────────────

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 0.8)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleChangePassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            disabledBackgroundColor: Colors.grey.shade300,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: _isLoading
              ? const SizedBox(
            width: 22, height: 22,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2.5,
            ),
          )
              : const Text(
            'Save Changes',
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}