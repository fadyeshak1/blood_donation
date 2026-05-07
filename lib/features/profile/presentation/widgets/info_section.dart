import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:blood_donation/core/utils/date_formatter.dart';
import 'package:blood_donation/features/profile/data/models/user_model.dart';
import 'package:flutter/material.dart';

class InfoSection extends StatelessWidget {
  final UserModel user;

  const InfoSection({super.key, required this.user});

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
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 16),
          _InfoRow(icon: Icons.email, label: 'Email', value: user.email),
          _InfoRow(icon: Icons.phone, label: 'Phone', value: user.phone),
          if (user.dateOfBirth != null)
            _InfoRow(
              icon: Icons.cake,
              label: 'Date of Birth',
              value: DateFormatter.formatDate(user.dateOfBirth!),
            ),
          if (user.city != null && user.city!.isNotEmpty)
            _InfoRow(
              icon: Icons.location_on,
              label: 'Location',
              value: user.city!,
            ),
          if (user.nextEligibleDate != null)
            _InfoRow(
              icon: Icons.schedule,
              label: 'Next Eligible',
              value: DateFormatter.formatDate(user.nextEligibleDate!),
              valueColor:
                  user.isEligibleToDonate ? AppTheme.green : AppTheme.red,
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF444444),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: valueColor ?? AppTheme.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}