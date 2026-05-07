import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class QrCodeSection extends StatelessWidget {
  final String donorId;

  const QrCodeSection({super.key, required this.donorId});

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
        children: [
          const Row(
            children: [
              Icon(Icons.qr_code_2, color: AppTheme.blue, size: 24),
              SizedBox(width: 8),
              Text(
                'Your Donor QR Code',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: 200,
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.white,
              border:
                  Border.all(color: AppTheme.grey.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.qr_code_2, size: 150, color: AppTheme.black),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Show this QR code at the hospital',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.grey.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showScannerPlaceholder(context),
              icon: const Icon(Icons.qr_code_scanner, color: AppTheme.blue),
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

  void _showScannerPlaceholder(BuildContext context) {
    // TODO: Replace with real QR scanner using mobile_scanner package
    // Add to pubspec.yaml: mobile_scanner: ^5.x.x
    // Then navigate to a scanner screen:
    // Navigator.push(context, MaterialPageRoute(builder: (_) => const QrScannerScreen()));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.qr_code_scanner, color: AppTheme.blue),
            SizedBox(width: 8),
            Text('Scan QR Code'),
          ],
        ),
        content: const Text(
          'QR scanning will be available after integrating the mobile_scanner package.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}