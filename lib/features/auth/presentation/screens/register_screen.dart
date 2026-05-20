import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:blood_donation/core/utils/validators.dart';
import 'package:blood_donation/features/auth/data/models/auth_model.dart';
import 'package:blood_donation/features/auth/presentation/providers/auth_provider.dart';
import 'package:blood_donation/features/auth/presentation/providers/auth_state.dart';
import 'package:blood_donation/features/home/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _addressController = TextEditingController();
  final _locationController = TextEditingController();
  final _nationalIdController = TextEditingController();

  // Dropdown values
  String? _selectedGender;
  String? _selectedBloodType;

  // UI state
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isFetchingLocation = false;

  static const List<String> _genders = ['Male', 'Female'];
  static const List<String> _bloodTypes = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    _locationController.dispose();
    _nationalIdController.dispose();
    super.dispose();
  }

  // ── GPS location ─────────────────────────────────────────────────────────────

  Future<void> _fetchLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      Position? position;
      try {
        position = await Geolocator.getLastKnownPosition();
      } catch (_) {}
      position ??= await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.lowest),
      );

      String address =
          '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        ).timeout(const Duration(seconds: 10));
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final parts = <String>[
            if ((p.subLocality ?? '').isNotEmpty) p.subLocality!,
            if ((p.locality ?? '').isNotEmpty) p.locality!,
            if ((p.administrativeArea ?? '').isNotEmpty) p.administrativeArea!,
          ];
          if (parts.isNotEmpty) address = parts.join(', ');
        }
      } catch (_) {}

      if (mounted) _locationController.text = address;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not get location. Please type it manually.'),
            backgroundColor: AppTheme.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  // ── Submit ────────────────────────────────────────────────────────────────────

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedGender == null) {
      _showValidationError('Please select your gender');
      return;
    }
    if (_selectedBloodType == null) {
      _showValidationError('Please select your blood type');
      return;
    }

    final success = await context.read<AuthProvider>().register(
          RegisterRequestModel(
            fullName: _fullNameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            phoneNumber: _phoneController.text.trim(),
            age: int.parse(_ageController.text.trim()),
            gender: _selectedGender!,
            bloodType: _selectedBloodType!,
            address: _addressController.text.trim(),
            location: _locationController.text.trim(),
            nationalId: _nationalIdController.text.trim(),
          ),
        );

    if (success && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    }
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.red,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Create Account'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          children: [
            // ── Section: Personal Info ─────────────────────────────────────
            _SectionTitle('Personal Information'),
            const SizedBox(height: 12),

            _buildField(
              controller: _fullNameController,
              label: 'Full Name',
              hint: 'e.g. Ahmed Hassan',
              icon: Icons.person_outline,
              validator: Validators.validateName,
            ),
            const SizedBox(height: 16),

            _buildField(
              controller: _emailController,
              label: 'Email',
              hint: 'you@example.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.validateEmail,
            ),
            const SizedBox(height: 16),

            _buildField(
              controller: _phoneController,
              label: 'Phone Number',
              hint: '010XXXXXXXX',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: Validators.validatePhone,
            ),
            const SizedBox(height: 16),

            _buildField(
              controller: _ageController,
              label: 'Age',
              hint: 'e.g. 25',
              icon: Icons.cake_outlined,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your age';
                }
                final age = int.tryParse(value.trim());
                if (age == null) return 'Please enter a valid age';
                if (age < 18) return 'Must be at least 18 years old';
                if (age > 65) return 'Must be 65 years or younger';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Gender dropdown
            _buildDropdown(
              label: 'Gender',
              icon: Icons.wc_outlined,
              value: _selectedGender,
              items: _genders,
              hint: 'Select gender',
              onChanged: (val) => setState(() => _selectedGender = val),
            ),
            const SizedBox(height: 16),

            // Blood Type dropdown
            _buildDropdown(
              label: 'Blood Type',
              icon: Icons.bloodtype_outlined,
              value: _selectedBloodType,
              items: _bloodTypes,
              hint: 'Select blood type',
              onChanged: (val) => setState(() => _selectedBloodType = val),
            ),
            const SizedBox(height: 24),

            // ── Section: Location ──────────────────────────────────────────
            _SectionTitle('Location'),
            const SizedBox(height: 12),

            _buildField(
              controller: _addressController,
              label: 'Address',
              hint: 'Street, district...',
              icon: Icons.home_outlined,
              validator: (v) => Validators.validateRequired(v, 'address'),
            ),
            const SizedBox(height: 16),

            // Location field with GPS button
            _buildLocationField(),
            const SizedBox(height: 24),

            // ── Section: Identity ──────────────────────────────────────────
            _SectionTitle('Identity'),
            const SizedBox(height: 12),

            _buildField(
              controller: _nationalIdController,
              label: 'National ID',
              hint: '14-digit national ID',
              icon: Icons.badge_outlined,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your national ID';
                }
                if (value.trim().length != 14) {
                  return 'National ID must be 14 digits';
                }
                if (int.tryParse(value.trim()) == null) {
                  return 'National ID must contain only numbers';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // ── Section: Security ──────────────────────────────────────────
            _SectionTitle('Security'),
            const SizedBox(height: 12),

            _buildPasswordField(
              controller: _passwordController,
              label: 'Password',
              hint: 'At least 6 characters',
              obscure: _obscurePassword,
              onToggle: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              validator: Validators.validatePassword,
            ),
            const SizedBox(height: 16),

            _buildPasswordField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              hint: 'Re-enter your password',
              obscure: _obscureConfirm,
              onToggle: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Error message
            Consumer<AuthProvider>(
              builder: (_, provider, __) {
                final error = provider.state.errorMessage;
                if (error == null) return const SizedBox.shrink();
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppTheme.red.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppTheme.red, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          error,
                          style: const TextStyle(
                              color: AppTheme.red, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Register button
            Consumer<AuthProvider>(
              builder: (_, provider, __) {
                final isLoading =
                    provider.state.status == AuthStatus.loading;
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.white,
                            ),
                          )
                        : const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Login link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Already have an account? ',
                  style: TextStyle(color: Color(0xFF666666)),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      color: AppTheme.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Field builders ────────────────────────────────────────────────────────────

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: _inputDecoration(hint: hint, icon: icon),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator,
          decoration: _inputDecoration(hint: hint, icon: Icons.lock_outline)
              .copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppTheme.grey,
                size: 20,
              ),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required String hint,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          validator: (v) =>
              v == null ? 'Please select $label' : null,
          onChanged: onChanged,
          decoration: _inputDecoration(hint: hint, icon: icon),
          items: items
              .map((item) =>
                  DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('Location'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _locationController,
          validator: (v) =>
              Validators.validateRequired(v, 'location'),
          decoration: _inputDecoration(
            hint: 'Your city / area',
            icon: Icons.location_on_outlined,
          ).copyWith(
            suffixIcon: _isFetchingLocation
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.red,
                      ),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.my_location,
                        color: AppTheme.red, size: 20),
                    tooltip: 'Use my current location',
                    onPressed: _fetchLocation,
                  ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(
      {required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppTheme.grey),
      prefixIcon: Icon(icon, color: AppTheme.grey, size: 20),
      filled: true,
      fillColor: AppTheme.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: AppTheme.grey.withValues(alpha: 0.4)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: AppTheme.grey.withValues(alpha: 0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.red, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.red, width: 2),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

// ─── Small helpers ────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppTheme.black,
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF444444),
      ),
    );
  }
}