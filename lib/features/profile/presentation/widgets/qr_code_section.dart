import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:blood_donation/features/profile/presentation/screens/qr_scanner_screen.dart';
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
          // Header
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

          // QR code display
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

          // Scan QR button — now opens the real scanner
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openScanner(context),
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

  Future<void> _openScanner(BuildContext context) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
    );

    if (result != null && context.mounted) {
      _showScanResult(context, result);
    }
  }

  void _showScanResult(BuildContext context, String value) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.green),
            SizedBox(width: 8),
            Text('QR Code Scanned'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Scanned value:',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppTheme.grey.withValues(alpha: 0.4)),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.black,
                ),
              ),
            ),
          ],
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