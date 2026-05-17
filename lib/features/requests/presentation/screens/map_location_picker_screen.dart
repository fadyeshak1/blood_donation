import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Full-screen map picker.
/// Returns a [LocationResult] when the user taps Confirm, or null if dismissed.
class MapLocationPickerScreen extends StatefulWidget {
  /// Initial center for the map (defaults to Cairo).
  final LatLng? initialPosition;

  const MapLocationPickerScreen({super.key, this.initialPosition});

  static Future<LocationResult?> open(
    BuildContext context, {
    LatLng? initialPosition,
  }) {
    return Navigator.push<LocationResult>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            MapLocationPickerScreen(initialPosition: initialPosition),
      ),
    );
  }

  @override
  State<MapLocationPickerScreen> createState() =>
      _MapLocationPickerScreenState();
}

class _MapLocationPickerScreenState extends State<MapLocationPickerScreen> {
  static const LatLng _cairo = LatLng(30.0444, 31.2357);

  late final MapController _mapController;
  LatLng? _pickedPoint;
  String _address = '';
  bool _isResolving = false;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  // ── Tap on map ───────────────────────────────────────────────────────────────

  Future<void> _onTap(TapPosition _, LatLng point) async {
    setState(() {
      _pickedPoint = point;
      _address = '';
      _isResolving = true;
    });

    try {
      final placemarks = await placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = <String>[
          if ((p.subLocality ?? '').isNotEmpty) p.subLocality!,
          if ((p.locality ?? '').isNotEmpty) p.locality!,
          if ((p.administrativeArea ?? '').isNotEmpty) p.administrativeArea!,
        ];
        setState(() {
          _address = parts.isNotEmpty
              ? parts.join(', ')
              : '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}';
        });
      } else {
        setState(() {
          _address =
              '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _address =
            '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}';
      });
    } finally {
      if (mounted) setState(() => _isResolving = false);
    }
  }

  // ── Go to my location ────────────────────────────────────────────────────────

  Future<void> _goToMyLocation() async {
    setState(() => _isLocating = true);

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
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.lowest,
        ),
      );

      final point = LatLng(position.latitude, position.longitude);
      _mapController.move(point, 15);
      await _onTap(const TapPosition(Offset.zero, Offset.zero), point);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Could not get location. Set a mock location in the emulator first.'),
            backgroundColor: AppTheme.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  // ── Confirm ──────────────────────────────────────────────────────────────────

  void _confirm() {
    if (_pickedPoint == null) return;
    Navigator.pop(
      context,
      LocationResult(
        latLng: _pickedPoint!,
        address: _address,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initialCenter = widget.initialPosition ?? _cairo;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        centerTitle: true,
        actions: [
          if (_pickedPoint != null)
            TextButton(
              onPressed: _isResolving ? null : _confirm,
              child: const Text(
                'Confirm',
                style: TextStyle(
                  color: AppTheme.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // ── Map ────────────────────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: 12,
              onTap: _onTap,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.blood_donation',
              ),
              if (_pickedPoint != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _pickedPoint!,
                      width: 48,
                      height: 48,
                      child: const Icon(
                        Icons.location_pin,
                        color: AppTheme.red,
                        size: 48,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // ── Hint banner at the top ─────────────────────────────────────────
          if (_pickedPoint == null)
            Positioned(
              top: 12,
              left: 24,
              right: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Tap anywhere on the map to drop a pin',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),

          // ── My location button ─────────────────────────────────────────────
          Positioned(
            right: 16,
            bottom: _pickedPoint != null ? 160 : 24,
            child: FloatingActionButton.small(
              heroTag: 'my_location',
              backgroundColor: AppTheme.white,
              onPressed: _isLocating ? null : _goToMyLocation,
              child: _isLocating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppTheme.red),
                    )
                  : const Icon(Icons.my_location, color: AppTheme.red),
            ),
          ),

          // ── Bottom address card ────────────────────────────────────────────
          if (_pickedPoint != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                decoration: const BoxDecoration(
                  color: AppTheme.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, -3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selected Location',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: AppTheme.red, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _isResolving
                              ? const Row(
                                  children: [
                                    SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppTheme.red),
                                    ),
                                    SizedBox(width: 8),
                                    Text('Resolving address...',
                                        style: TextStyle(
                                            color: AppTheme.grey,
                                            fontSize: 14)),
                                  ],
                                )
                              : Text(
                                  _address,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.black,
                                  ),
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isResolving ? null : _confirm,
                        style: ElevatedButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Confirm Location',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Result model ──────────────────────────────────────────────────────────────

class LocationResult {
  final LatLng latLng;
  final String address;

  const LocationResult({required this.latLng, required this.address});
}