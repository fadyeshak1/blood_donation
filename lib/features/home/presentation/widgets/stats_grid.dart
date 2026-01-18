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
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: StatsCard(
                  icon: Icons.bloodtype,
                  iconColor: AppTheme.red,
                  title: 'Total Donations',
                  value: stats.totalDonations.toString(),
                ),
              ),
              Expanded(
                child: StatsCard(
                  icon: Icons.favorite,
                  iconColor: AppTheme.blue,
                  title: 'Lives Saved',
                  value: stats.livesSaved.toString(),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: StatsCard(
                  icon: Icons.local_fire_department,
                  iconColor: AppTheme.green,
                  title: 'Streak Days',
                  value: stats.streakDays.toString(),
                ),
              ),
              Expanded(
                child: StatsCard(
                  icon: Icons.star,
                  iconColor: AppTheme.purple,
                  title: 'Total Points',
                  value: _formatPoints(stats.totalPoints),
                ),
              ),
            ],
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