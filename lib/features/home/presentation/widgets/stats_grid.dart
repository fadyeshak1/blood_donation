import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:blood_donation/features/home/data/models/dashboard_stats_model.dart';
import 'package:blood_donation/features/home/presentation/widgets/stats_card.dart';
import 'package:flutter/material.dart';

class StatsGrid extends StatelessWidget {
  final DashboardStatsModel stats;

  const StatsGrid({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: StatsCard(
              icon: Icons.bloodtype,
              title: 'Total Donations',
              value: stats.totalDonations.toString(),
              iconColor: AppTheme.red,
            ),
          ),
          Expanded(
            child: StatsCard(
              icon: Icons.star_rounded,
              title: 'Total Points',
              value: _formatPoints(stats.totalPoints),
              iconColor: AppTheme.purple,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPoints(int points) {
    if (points >= 1000) {
      return '${(points / 1000).toStringAsFixed(1)}K';
    }
    return points.toString();
  }
}