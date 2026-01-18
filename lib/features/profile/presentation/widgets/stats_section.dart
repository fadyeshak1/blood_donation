import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:blood_donation/features/profile/data/models/user_model.dart';
import 'package:flutter/material.dart';

class StatsSection extends StatelessWidget {
  final UserModel user;

  const StatsSection({super.key, required this.user});

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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            icon: Icons.bloodtype,
            label: 'Donations',
            value: user.totalDonations.toString(),
            color: AppTheme.red,
          ),
          _buildDivider(),
          _StatItem(
            icon: Icons.star,
            label: 'Points',
            value: user.pointsEarned.toString(),
            color: AppTheme.blue,
          ),
          _buildDivider(),
          _StatItem(
            icon: Icons.favorite,
            label: 'Lives Saved',
            value: (user.totalDonations * 3).toString(),
            color: AppTheme.green,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: AppTheme.grey.withValues(alpha: 0.3),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.black,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.grey.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}