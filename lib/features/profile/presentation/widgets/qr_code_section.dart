import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:blood_donation/features/profile/data/models/request_history_model.dart';
import 'package:blood_donation/features/profile/presentation/providers/profile_provider.dart';
import 'package:blood_donation/features/requests/presentation/screens/pickup_scan_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Shows a "Scan QR to Confirm Blood Receipt" button in the Profile.
/// If the user has exactly one open request, it goes straight to the scanner.
/// If they have multiple, it shows a bottom sheet to pick which request.
class QrCodeSection extends StatelessWidget {
  const QrCodeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, _) {
        final openRequests = provider.state.requestHistory
            .where((r) => r.status == 'pending' || r.status == 'Open' || r.status == 'open')
            .toList();

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.qr_code_scanner, color: AppTheme.blue, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Blood Pickup',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'If you are at the hospital to receive blood, scan the QR shown by hospital staff to confirm receipt.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF666666),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _handleScan(context, openRequests),
                  icon: const Icon(Icons.qr_code_scanner,
                      color: AppTheme.blue),
                  label: const Text(
                    'Scan QR Code',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.blue,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(
                        color: AppTheme.blue, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleScan(
      BuildContext context, List<RequestHistoryModel> openRequests) {
    if (openRequests.isEmpty) {
      // No open requests — scan anyway (hospital might handle matching)
      _openScanner(context, openRequests.isNotEmpty ? openRequests.first.id : '0');
      return;
    }

    if (openRequests.length == 1) {
      // Exactly one open request — go straight to scanner
      _openScanner(context, openRequests.first.id);
      return;
    }

    // Multiple open requests — let the user pick
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _RequestPickerSheet(
        requests: openRequests,
        onPicked: (id) => _openScanner(context, id),
      ),
    );
  }

  void _openScanner(BuildContext context, String requestId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PickupScanScreen(requestId: requestId),
      ),
    );
  }
}

class _RequestPickerSheet extends StatelessWidget {
  final List<RequestHistoryModel> requests;
  final ValueChanged<String> onPicked;

  const _RequestPickerSheet({
    required this.requests,
    required this.onPicked,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Which request are you picking up?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 16),
          ...requests.map(
            (r) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  r.bloodType,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.white,
                  ),
                ),
              ),
              title: Text(r.hospitalName,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(r.hospitalLocation,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF666666))),
              trailing:
                  const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {
                Navigator.pop(context);
                onPicked(r.id);
              },
            ),
          ),
        ],
      ),
    );
  }
}