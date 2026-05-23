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

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _addressController = TextEditingController();
  final _locationController = TextEditingController();
  final _nationalIdController = TextEditingController();

  String? _selectedGender;
  String? _selectedBloodType;

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isFetchingLocation = false;

  // Lat/lng captured when user uses GPS — sent to API
  double _latitude = 0.0;
  double _longitude = 0.0;

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

      // Store lat/lng for API submission
      _latitude = position.latitude;
      _longitude = position.longitude;

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
            if ((p.administrativeArea ?? '').isNotEmpty)
              p.administrativeArea!,
          ];
          if (parts.isNotEmpty) address = parts.join(', ');
        }
      } catch (_) {}

      if (mounted) _locationController.text = address;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not get location. Type it manually.'),
            backgroundColor: AppTheme.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedGender == null) {
      _showSnack('Please select your gender');
      return;
    }
    if (_selectedBloodType == null) {
      _showSnack('Please select your blood type');
      return;
    }

    final success = await context.read<AuthProvider>().register(
          RegisterRequestModel(
            fullName: _fullNameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            confirmPassword: _confirmPasswordController.text,
            phoneNumber: _phoneController.text.trim(),
            age: int.parse(_ageController.text.trim()),
            gender: _selectedGender!,
            address: _addressController.text.trim(),
            nationalId: _nationalIdController.text.trim(),
            bloodType: _selectedBloodType!,
            latitude: _latitude,
            longitude: _longitude,
          ),
        );

    if (success && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Create Account'), centerTitle: true),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          children: [
            _SectionTitle('Personal Information'),
            const SizedBox(height: 12),

            _field(_fullNameController, 'Full Name', 'Ahmed Hassan',
                Icons.person_outline, validator: Validators.validateName),
            const SizedBox(height: 16),

            _field(_emailController, 'Email', 'you@example.com',
                Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail),
            const SizedBox(height: 16),

            _field(_phoneController, 'Phone Number', '010XXXXXXXX',
                Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: Validators.validatePhone),
            const SizedBox(height: 16),

            _field(_ageController, 'Age', 'e.g. 25', Icons.cake_outlined,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter your age';
                  }
                  final age = int.tryParse(v.trim());
                  if (age == null) return 'Invalid age';
                  if (age < 18) return 'Must be at least 18';
                  if (age > 65) return 'Must be 65 or younger';
                  return null;
                }),
            const SizedBox(height: 16),

            _dropdown('Gender', Icons.wc_outlined, _selectedGender,
                _genders, (v) => setState(() => _selectedGender = v)),
            const SizedBox(height: 16),

            _dropdown(
                'Blood Type',
                Icons.bloodtype_outlined,
                _selectedBloodType,
                _bloodTypes,
                (v) => setState(() => _selectedBloodType = v)),
            const SizedBox(height: 24),

            _SectionTitle('Location'),
            const SizedBox(height: 12),

            _field(_addressController, 'Address', 'Street, district...',
                Icons.home_outlined,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null),
            const SizedBox(height: 16),

            // Location field with GPS
            _locationField(),
            const SizedBox(height: 24),

            _SectionTitle('Identity'),
            const SizedBox(height: 12),

            _field(_nationalIdController, 'National ID',
                '14-digit national ID', Icons.badge_outlined,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter your national ID';
                  }
                  if (v.trim().length != 14) {
                    return 'National ID must be 14 digits';
                  }
                  if (int.tryParse(v.trim()) == null) {
                    return 'Numbers only';
                  }
                  return null;
                }),
            const SizedBox(height: 24),

            _SectionTitle('Security'),
            const SizedBox(height: 12),

            _passwordField(_passwordController, 'Password',
                'At least 6 characters', _obscurePassword,
                () => setState(() => _obscurePassword = !_obscurePassword),
                validator: Validators.validatePassword),
            const SizedBox(height: 16),

            _passwordField(_confirmPasswordController, 'Confirm Password',
                'Re-enter your password', _obscureConfirm,
                () => setState(() => _obscureConfirm = !_obscureConfirm),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (v != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                }),
            const SizedBox(height: 24),

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
                          child: Text(error,
                              style: const TextStyle(
                                  color: AppTheme.red, fontSize: 13))),
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
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.white))
                        : const Text('Create Account',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Already have an account? ',
                    style: TextStyle(color: Color(0xFF666666))),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text('Sign In',
                      style: TextStyle(
                          color: AppTheme.red,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Field builders ────────────────────────────────────────────────────────

  InputDecoration _dec(String label, String hint, IconData icon,
      {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: AppTheme.grey, size: 20),
      suffixIcon: suffix,
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

  Widget _field(
    TextEditingController ctrl,
    String label,
    String hint,
    IconData icon, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      validator: validator,
      decoration: _dec(label, hint, icon),
    );
  }

  Widget _passwordField(
    TextEditingController ctrl,
    String label,
    String hint,
    bool obscure,
    VoidCallback onToggle, {
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      validator: validator,
      decoration: _dec(label, hint, Icons.lock_outline,
          suffix: IconButton(
            icon: Icon(
              obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppTheme.grey,
              size: 20,
            ),
            onPressed: onToggle,
          )),
    );
  }

  Widget _dropdown(
    String label,
    IconData icon,
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      validator: (v) => v == null ? 'Please select $label' : null,
      onChanged: onChanged,
      decoration: _dec(label, 'Select $label', icon),
      items: items
          .map((item) =>
              DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
    );
  }

  Widget _locationField() {
    return TextFormField(
      controller: _locationController,
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Please enter location' : null,
      decoration: _dec('Location', 'Your city / area',
              Icons.location_on_outlined,
              suffix: _isFetchingLocation
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppTheme.red),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.my_location,
                          color: AppTheme.red, size: 20),
                      tooltip: 'Use my current location',
                      onPressed: _fetchLocation,
                    ))
          .copyWith(
              prefixIcon: const Icon(Icons.location_on_outlined,
                  color: AppTheme.grey, size: 20)),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.black));
  }
}