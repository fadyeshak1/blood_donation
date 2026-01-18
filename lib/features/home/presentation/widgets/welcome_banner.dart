import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class WelcomeBanner extends StatelessWidget {
  final String userName;

  const WelcomeBanner({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.blue, AppTheme.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.blue.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, $userName!',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your next donation makes a difference',
            style: TextStyle(
              fontSize: 15,
              color: AppTheme.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}