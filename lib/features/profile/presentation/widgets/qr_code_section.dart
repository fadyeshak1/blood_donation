import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:blood_donation/features/requests/presentation/screens/pickup_scan_screen.dart';
import 'package:flutter/material.dart';

/// Shows a "Scan QR to Confirm Blood Receipt" button in the Profile.
/// Tapping it opens the scanner directly — no request ID needed since
/// POST /api/requests/pickup-scan only requires the scanned qrToken.
class QrCodeSection extends StatelessWidget {
  const QrCodeSection({super.key});

  @override
  Widget build(BuildContext context) {
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
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PickupScanScreen(),
                ),
              ),
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
                side: const BorderSide(color: AppTheme.blue, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}