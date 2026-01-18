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
              border: Border.all(color: AppTheme.grey.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                Icons.qr_code_2,
                size: 150,
                color: AppTheme.black,
              ),
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
        ],
      ),
    );
  }
}