import 'package:blood_donation/core/network/api_client.dart';
import 'package:blood_donation/core/network/api_endpoints.dart';
import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:blood_donation/features/profile/data/models/user_model.dart';
import 'package:blood_donation/features/profile/presentation/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  final dynamic user; // kept for backward compatibility — screen reads from provider
  const EditProfileScreen({super.key, this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _ageCtrl;
  late TextEditingController _addressCtrl;

  double? _selectedLat;
  double? _selectedLng;
  bool _isSaving = false;
  bool _locationChanged = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<ProfileProvider>().state.user!;
    _nameCtrl    = TextEditingController(text: user.name);
    _phoneCtrl   = TextEditingController(text: user.phone);
    _ageCtrl     = TextEditingController(text: user.age.toString());
    _addressCtrl = TextEditingController(text: user.address ?? '');
    _selectedLat = user.latitude;
    _selectedLng = user.longitude;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _ageCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final provider = context.read<ProfileProvider>();
    final current  = provider.state.user!;

    final updated = current.copyWith(
      name:      _nameCtrl.text.trim(),
      phone:     _phoneCtrl.text.trim(),
      age:       int.tryParse(_ageCtrl.text.trim()) ?? current.age,
      address:   _addressCtrl.text.trim(),
      latitude:  _selectedLat,
      longitude: _selectedLng,
    );

    final success = await provider.updateProfile(updated);

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppTheme.green,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update profile. Please try again.'),
            backgroundColor: AppTheme.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  /// Opens a full-screen map where the user taps to pin their location.
  Future<void> _openMapPicker() async {
    final result = await Navigator.push<_LocationResult>(
      context,
      MaterialPageRoute(
        builder: (_) => _MapLocationPickerScreen(
          initialLat: _selectedLat,
          initialLng: _selectedLng,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedLat    = result.lat;
        _selectedLng    = result.lng;
        _locationChanged = true;
        if (result.address.isNotEmpty) {
          _addressCtrl.text = result.address;
        }
      });
    }
  }

  /// Uses the device GPS to set the current location.
  Future<void> _useGPS() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      String address = '';
      try {
        final placemarks = await placemarkFromCoordinates(
            pos.latitude, pos.longitude);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          address = [p.subLocality, p.locality, p.administrativeArea]
              .where((s) => s != null && s.isNotEmpty)
              .join(', ');
        }
      } catch (_) {}

      if (mounted) {
        setState(() {
          _selectedLat     = pos.latitude;
          _selectedLng     = pos.longitude;
          _locationChanged = true;
          if (address.isNotEmpty) _addressCtrl.text = address;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not get GPS location. Please try again.'),
            backgroundColor: AppTheme.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppTheme.red))
                : const Text('Save',
                    style: TextStyle(
                        color: AppTheme.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Personal Information ─────────────────────────────────
              _SectionTitle('Personal Information'),
              const SizedBox(height: 12),

              _Field(
                label: 'Full Name',
                controller: _nameCtrl,
                icon: Icons.person_outline,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),

              _Field(
                label: 'Phone Number',
                controller: _phoneCtrl,
                icon: Icons.phone_outlined,
                keyboard: TextInputType.phone,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),

              _Field(
                label: 'Age',
                controller: _ageCtrl,
                icon: Icons.cake_outlined,
                keyboard: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null) return 'Required';
                  if (n < 18 || n > 60) return 'Age must be between 18 and 60';
                  return null;
                },
              ),
              const SizedBox(height: 28),

              // ── Location ─────────────────────────────────────────────
              _SectionTitle('Location'),
              const SizedBox(height: 8),
              Text(
                'Your location helps match you with nearby blood requests.',
                style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.grey.withValues(alpha: 0.85),
                    height: 1.4),
              ),
              const SizedBox(height: 14),

              _Field(
                label: 'Address',
                controller: _addressCtrl,
                icon: Icons.home_outlined,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              // Location status chip
              if (_selectedLat != null && _selectedLng != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.green.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppTheme.green.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: AppTheme.green, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _locationChanged
                              ? 'New location selected'
                              : 'Location already set',
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.green,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      Text(
                        '${_selectedLat!.toStringAsFixed(4)}, '
                        '${_selectedLng!.toStringAsFixed(4)}',
                        style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.green.withValues(alpha: 0.8)),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.location_off_outlined,
                          color: Colors.orange, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'No location set — tap below to add one',
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.orange,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),

              // Location action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _openMapPicker,
                      icon: const Icon(Icons.map_outlined, size: 18),
                      label: const Text('Pick on Map'),
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppTheme.blue),
                        foregroundColor: AppTheme.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _useGPS,
                      icon: const Icon(Icons.my_location, size: 18),
                      label: const Text('Use GPS'),
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppTheme.red),
                        foregroundColor: AppTheme.red,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ── Change Password ──────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const _ChangePasswordScreen()),
                  ),
                  icon: const Icon(Icons.lock_outlined,
                      size: 20, color: AppTheme.red),
                  label: const Text(
                    'Change Password',
                    style: TextStyle(
                      color: AppTheme.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppTheme.red, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Save button ──────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.white))
                      : const Text('Save Changes',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Full-screen map picker ─────────────────────────────────────────────────

class _LocationResult {
  final double lat;
  final double lng;
  final String address;
  const _LocationResult(
      {required this.lat, required this.lng, required this.address});
}

class _MapLocationPickerScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const _MapLocationPickerScreen({this.initialLat, this.initialLng});

  @override
  State<_MapLocationPickerScreen> createState() =>
      _MapLocationPickerScreenState();
}

class _MapLocationPickerScreenState
    extends State<_MapLocationPickerScreen> {
  final MapController _mapCtrl = MapController();
  LatLng? _pinned;
  String _address = '';
  bool _isResolving = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != null && widget.initialLng != null) {
      _pinned =
          LatLng(widget.initialLat!, widget.initialLng!);
    }
  }

  Future<void> _onTap(TapPosition _, LatLng point) async {
    setState(() {
      _pinned     = point;
      _address    = '';
      _isResolving = true;
    });

    try {
      final placemarks = await placemarkFromCoordinates(
          point.latitude, point.longitude);
      if (placemarks.isNotEmpty && mounted) {
        final p = placemarks.first;
        final addr = [
          p.subLocality,
          p.locality,
          p.administrativeArea
        ].where((s) => s != null && s.isNotEmpty).join(', ');
        setState(() => _address = addr);
      }
    } catch (_) {}

    if (mounted) setState(() => _isResolving = false);
  }

  void _confirm() {
    if (_pinned == null) return;
    Navigator.pop(
      context,
      _LocationResult(
          lat: _pinned!.latitude,
          lng: _pinned!.longitude,
          address: _address),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Default center: Cairo
    final center = _pinned ?? const LatLng(30.0444, 31.2357);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapCtrl,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 13,
              onTap: _onTap,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.blooddonation.app',
              ),
              if (_pinned != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _pinned!,
                      width: 44,
                      height: 44,
                      child: const Icon(
                        Icons.location_pin,
                        color: AppTheme.red,
                        size: 44,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Top instruction card
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Material(
              borderRadius: BorderRadius.circular(12),
              elevation: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.touch_app_outlined,
                        color: AppTheme.blue, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _pinned == null
                            ? 'Tap anywhere on the map to pin your location'
                            : _isResolving
                                ? 'Getting address…'
                                : _address.isNotEmpty
                                    ? _address
                                    : 'Location selected — tap Confirm to save',
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Confirm button
          if (_pinned != null)
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: ElevatedButton.icon(
                onPressed: _confirm,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Confirm Location',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Shared helpers ─────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppTheme.black,
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboard;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _Field({
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboard,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.red, size: 20),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: AppTheme.grey.withValues(alpha: 0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.red, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
      ),
    );
  }
}

// ── Change Password Screen ─────────────────────────────────────────────────

class _ChangePasswordScreen extends StatefulWidget {
  const _ChangePasswordScreen();

  @override
  State<_ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<_ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPwCtrl = TextEditingController();
  final _newPwCtrl     = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew     = true;
  bool _isSubmitting   = false;

  @override
  void dispose() {
    _currentPwCtrl.dispose();
    _newPwCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final apiClient = const ApiClient();
      final response = await apiClient.post(
        ApiEndpoints.changePassword,
        body: {
          'currentPassword': _currentPwCtrl.text.trim(),
          'newPassword':     _newPwCtrl.text.trim(),
        },
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully'),
            backgroundColor: AppTheme.green,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ApiClient.errorMessage(response)),
            backgroundColor: AppTheme.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to change password. Please try again.'),
            backgroundColor: AppTheme.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _currentPwCtrl,
                obscureText: _obscureCurrent,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  prefixIcon:
                      const Icon(Icons.lock_outline, color: AppTheme.red),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureCurrent
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppTheme.grey,
                    ),
                    onPressed: () => setState(
                        () => _obscureCurrent = !_obscureCurrent),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: AppTheme.grey.withValues(alpha: 0.4)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppTheme.red, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPwCtrl,
                obscureText: _obscureNew,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (v.length < 6) return 'Minimum 6 characters';
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'New Password',
                  prefixIcon:
                      const Icon(Icons.lock_reset, color: AppTheme.red),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNew
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppTheme.grey,
                    ),
                    onPressed: () =>
                        setState(() => _obscureNew = !_obscureNew),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: AppTheme.grey.withValues(alpha: 0.4)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppTheme.red, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppTheme.white))
                      : const Text('Change Password',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}