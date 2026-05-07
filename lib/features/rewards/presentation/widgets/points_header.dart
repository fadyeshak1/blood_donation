import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:blood_donation/features/rewards/data/models/user_points_model.dart';
import 'package:flutter/material.dart';

class PointsHeader extends StatelessWidget {
  final UserPointsModel points;

  const PointsHeader({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.purple, AppTheme.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.purple.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: AppTheme.white, size: 28),
              SizedBox(width: 8),
              Text(
                'Your Points',
                style: TextStyle(
                  fontSize: 18,
                  color: AppTheme.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            points.availablePoints.toString(),
            style: const TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: AppTheme.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Available Points',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 20),
          // Only Redeemed remains
          _buildStat('Redeemed', points.redeemedPoints.toString()),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}