import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:blood_donation/core/utils/constants.dart';
import 'package:blood_donation/core/utils/date_formatter.dart';
import 'package:blood_donation/features/requests/data/models/create_request_model.dart';
import 'package:blood_donation/features/requests/presentation/providers/requests_provider.dart';
import 'package:blood_donation/features/requests/presentation/screens/map_location_picker_screen.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  final _hospitalNameController = TextEditingController();
  final _hospitalLocationController = TextEditingController();
  final _bloodQuantityController = TextEditingController(text: '1');

  String _selectedBloodType = AppConstants.bloodTypes[0];
  DateTime? _neededByDate;
  bool _isSubmitting = false;
  bool _isFetchingLocation = false;

  // Derived from selected date
  int? get _daysRemaining {
    if (_neededByDate == null) return null;
    return _neededByDate!.difference(DateTime.now()).inDays;
  }

  String? get _urgencyLabel {
    if (_daysRemaining == null) return null;
    return _daysRemaining! <= 3 ? 'Emergency' : 'Normal';
  }

  Color get _urgencyColor =>
      _urgencyLabel == 'Emergency' ? AppTheme.red : AppTheme.green;

  @override
  void dispose() {
    _hospitalNameController.dispose();
    _hospitalLocationController.dispose();
    _bloodQuantityController.dispose();
    super.dispose();
  }

  // ── Geolocation ─────────────────────────────────────────────────────────────

  Future<void> _fetchCurrentLocation() async {
    setState(() => _isFetchingLocation = true);

    try {
      // 1. Check / request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLocationError('Location permission was denied.');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _showLocationError(
            'Location permission is permanently denied. Please enable it in app settings.');
        return;
      }

      // 2. Get position
      // Try getLastKnownPosition first — it's instant and works on emulators
      // that have a mock location set. Fall back to getCurrentPosition if null.
      Position? position;
      try {
        position = await Geolocator.getLastKnownPosition();
      } catch (_) {}

      if (position == null) {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.lowest,
          ),
        );
      }

      // 3. Build address — raw coordinates as guaranteed fallback
      String address =
          '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';

      // 4. Reverse-geocode — silently falls back to coordinates on failure
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        ).timeout(const Duration(seconds: 10));

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final parts = <String>[
            if ((place.subLocality ?? '').isNotEmpty) place.subLocality!,
            if ((place.locality ?? '').isNotEmpty) place.locality!,
            if ((place.administrativeArea ?? '').isNotEmpty)
              place.administrativeArea!,
          ];
          if (parts.isNotEmpty) address = parts.join(', ');
        }
      } catch (_) {
        // Geocoding failed — coordinates are already set, no error shown
      }

      if (mounted) {
        _hospitalLocationController.text = address;
      }
    } catch (e) {
      _showLocationError(
          'Could not get location.\n'
          'On emulator: open Extended Controls → Location → set a mock location first.');
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  void _showLocationError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── Submit ───────────────────────────────────────────────────────────────────

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_neededByDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select the blood receiving date'),
          backgroundColor: AppTheme.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final request = CreateRequestModel(
      bloodType: _selectedBloodType,
      hospitalName: _hospitalNameController.text.trim(),
      hospitalLocation: _hospitalLocationController.text.trim(),
      bloodQuantity:
          int.tryParse(_bloodQuantityController.text.trim()) ?? 1,
      neededByDate: _neededByDate!,
    );

    if (!mounted) return;
    final success =
        await context.read<RequestsProvider>().createRequest(request);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Blood request created successfully!'),
          backgroundColor: AppTheme.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create request'),
          backgroundColor: AppTheme.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Blood Request'),
        actions: [
          if (_isSubmitting)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.red,
                  ),
                ),
              ),
            )
          else
            IconButton(
              onPressed: _handleSubmit,
              icon: const Icon(Icons.check),
              tooltip: 'Submit',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle('Blood Type Required'),
            const SizedBox(height: 8),
            _buildBloodTypeSelector(),
            const SizedBox(height: 24),

            _buildSectionTitle('Hospital Information'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _hospitalNameController,
              label: 'Hospital Name',
              hint: 'Enter hospital name',
              icon: Icons.local_hospital,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter hospital name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Hospital Location — with geolocation button
            _buildLocationField(),

            const SizedBox(height: 24),

            _buildSectionTitle('Blood Receiving Date'),
            const SizedBox(height: 8),
            _buildDatePicker(),
            const SizedBox(height: 24),

            _buildSectionTitle('Blood Quantity'),
            const SizedBox(height: 8),
            _buildQuantitySelector(),
            const SizedBox(height: 32),

            _buildSubmitButton(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ── Widgets ──────────────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppTheme.black,
      ),
    );
  }

  /// Hospital Location field with two suffix buttons:
  ///   📍 — opens the map picker
  ///   🎯 — auto-fills with current GPS location
  Widget _buildLocationField() {
    return TextFormField(
      controller: _hospitalLocationController,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter hospital location';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Hospital Location',
        hintText: 'Type, pick on map, or use GPS',
        prefixIcon: const Icon(Icons.location_on, color: AppTheme.grey),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Map picker button
            IconButton(
              icon: const Icon(Icons.map_outlined, color: AppTheme.red),
              tooltip: 'Pick on map',
              onPressed: () async {
                // Try to center the map on current location if possible
                LatLng? initialPos;
                try {
                  final pos = await Geolocator.getLastKnownPosition();
                  if (pos != null) {
                    initialPos = LatLng(pos.latitude, pos.longitude);
                  }
                } catch (_) {}

                if (!mounted) return;
                final result = await MapLocationPickerScreen.open(
                  context,
                  initialPosition: initialPos,
                );
                if (result != null && mounted) {
                  _hospitalLocationController.text = result.address;
                }
              },
            ),
            // GPS auto-fill button
            _isFetchingLocation
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
                    icon: const Icon(Icons.my_location, color: AppTheme.red),
                    tooltip: 'Use my current location',
                    onPressed: _fetchCurrentLocation,
                  ),
          ],
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: AppTheme.grey.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: AppTheme.grey.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.red, width: 2),
        ),
        filled: true,
        fillColor: AppTheme.white,
      ),
    );
  }

  Widget _buildBloodTypeSelector() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.5,
      ),
      itemCount: AppConstants.bloodTypes.length,
      itemBuilder: (context, index) {
        final type = AppConstants.bloodTypes[index];
        final isSelected = _selectedBloodType == type;
        return GestureDetector(
          onTap: () => setState(() => _selectedBloodType = type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.red : AppTheme.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? AppTheme.red
                    : AppTheme.grey.withValues(alpha: 0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              type,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppTheme.white : AppTheme.black,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate:
                  DateTime.now().add(const Duration(days: 1)),
              firstDate:
                  DateTime.now().add(const Duration(days: 1)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              builder: (ctx, child) => Theme(
                data: Theme.of(ctx).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppTheme.red,
                  ),
                ),
                child: child!,
              ),
            );
            if (picked != null) setState(() => _neededByDate = picked);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _neededByDate != null
                    ? AppTheme.red
                    : AppTheme.grey.withValues(alpha: 0.3),
                width: _neededByDate != null ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color:
                      _neededByDate != null ? AppTheme.red : AppTheme.grey,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  _neededByDate != null
                      ? DateFormatter.formatDate(_neededByDate!)
                      : 'Select date',
                  style: TextStyle(
                    fontSize: 15,
                    color: _neededByDate != null
                        ? AppTheme.black
                        : AppTheme.grey,
                    fontWeight: _neededByDate != null
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_urgencyLabel != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                _urgencyLabel == 'Emergency'
                    ? Icons.warning_amber
                    : Icons.schedule,
                size: 16,
                color: _urgencyColor,
              ),
              const SizedBox(width: 6),
              Text(
                '$_daysRemaining ${_daysRemaining == 1 ? 'day' : 'days'} remaining — ',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF444444),
                ),
              ),
              Text(
                _urgencyLabel!,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: _urgencyColor,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.grey.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.water_drop, color: AppTheme.red, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Units Needed',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.black,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              final current =
                  int.tryParse(_bloodQuantityController.text) ?? 1;
              if (current > 1) {
                _bloodQuantityController.text = (current - 1).toString();
              }
            },
            icon: const Icon(Icons.remove_circle_outline),
            color: AppTheme.red,
          ),
          SizedBox(
            width: 60,
            child: TextFormField(
              controller: _bloodQuantityController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Required';
                final q = int.tryParse(value.trim());
                if (q == null || q < 1) return 'Min 1';
                if (q > 10) return 'Max 10';
                return null;
              },
            ),
          ),
          IconButton(
            onPressed: () {
              final current =
                  int.tryParse(_bloodQuantityController.text) ?? 1;
              if (current < 10) {
                _bloodQuantityController.text = (current + 1).toString();
              }
            },
            icon: const Icon(Icons.add_circle_outline),
            color: AppTheme.red,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: AppTheme.grey.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: AppTheme.grey.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.red, width: 2),
        ),
        filled: true,
        fillColor: AppTheme.white,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : _handleSubmit,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _isSubmitting
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.white,
              ),
            )
          : const Text(
              'Create Request',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }
}