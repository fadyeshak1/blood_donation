import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:blood_donation/features/home/data/models/urgent_request_model.dart';
import 'package:blood_donation/features/home/presentation/providers/home_provider.dart';
import 'package:blood_donation/features/profile/data/models/user_model.dart';
import 'package:blood_donation/features/requests/presentation/screens/map_location_picker_screen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class UrgentRequestsSection extends StatelessWidget {
  final List<UrgentRequestModel> requests;
  final VoidCallback? onViewAll;
  final UserModel? currentUser;

  const UrgentRequestsSection({
    super.key,
    required this.requests,
    this.onViewAll,
    this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Urgent Blood Requests',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.black,
                ),
              ),
              TextButton(
                onPressed: onViewAll,
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: AppTheme.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (requests.isEmpty)
          _EmptyLocationState(currentUser: currentUser)
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: requests.length > 3 ? 3 : requests.length,
            itemBuilder: (context, index) {
              return _UrgentRequestCard(request: requests[index]);
            },
          ),
      ],
    );
  }
}

// ── Empty state with location update ──────────────────────────────────────

class _EmptyLocationState extends StatefulWidget {
  final UserModel? currentUser;

  const _EmptyLocationState({this.currentUser});

  @override
  State<_EmptyLocationState> createState() => _EmptyLocationStateState();
}

class _EmptyLocationStateState extends State<_EmptyLocationState> {
  bool _isLocating = false;

  Future<void> _updateLocation() async {
    // Open the map picker — user taps anywhere to drop a pin
    LatLng? initialPos;
    try {
      final pos = await Geolocator.getLastKnownPosition();
      if (pos != null) initialPos = LatLng(pos.latitude, pos.longitude);
    } catch (_) {}

    if (!mounted) return;

    final result = await MapLocationPickerScreen.open(
      context,
      initialPosition: initialPos,
    );

    if (result == null || !mounted) return;

    setState(() => _isLocating = true);

    try {
      final user = widget.currentUser;
      final success = await context.read<HomeProvider>().updateUserLocation(
            latitude: result.latLng.latitude,
            longitude: result.latLng.longitude,
            address: result.address,
            currentFullName: user?.name ?? '',
            currentPhone: user?.phone ?? '',
            currentAge: user?.age ?? 25,
            currentGender: user?.gender ?? 0,
          );

      if (mounted) {
        _showSnack(
          success
              ? 'Location updated. Finding nearby requests...'
              : 'Failed to update location. Please try again.',
          color: success ? AppTheme.green : AppTheme.red,
        );
      }
    } catch (_) {
      if (mounted) _showSnack('Failed to update location. Please try again.');
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  void _showSnack(String message, {Color color = AppTheme.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.grey.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: 36,
              color: AppTheme.green.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            'No urgent requests nearby',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.grey.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 6),

          // Subtitle
          Text(
            'Pin your location on the map to see\nblood requests near you',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.grey.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          // Update Location button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isLocating ? null : _updateLocation,
              icon: _isLocating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppTheme.red),
                    )
                  : const Icon(Icons.map_outlined,
                      size: 16, color: AppTheme.red),
              label: Text(
                _isLocating ? 'Updating…' : 'Set My Location',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.red,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 10),
                side: const BorderSide(color: AppTheme.red, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Request card (unchanged) ───────────────────────────────────────────────

class _UrgentRequestCard extends StatelessWidget {
  final UrgentRequestModel request;

  const _UrgentRequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: request.isUrgent
              ? AppTheme.red.withValues(alpha: 0.3)
              : AppTheme.green.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                request.bloodType,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.red,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.hospitalName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 14,
                        color: AppTheme.grey.withValues(alpha: 0.8)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        request.location,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.grey.withValues(alpha: 0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: request.isUrgent ? AppTheme.red : AppTheme.green,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              request.isUrgent ? 'URGENT' : 'NORMAL',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppTheme.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}