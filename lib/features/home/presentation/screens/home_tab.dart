import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:blood_donation/core/utils/date_formatter.dart';
import 'package:blood_donation/core/widgets/custom_app_bar.dart';
import 'package:blood_donation/features/home/presentation/widgets/stats_card.dart';
import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Home',
        subtitle: DateFormatter.formatDate(DateTime.now()),
        showNotification: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: () {
                // TODO: Navigate to donation flow
              },
              child: const Text('Donate'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Welcome Banner
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.blue, AppTheme.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome, Donor!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your next donation makes a difference',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),

            // Stats Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    child: StatsCard(
                      icon: Icons.bloodtype,
                      iconColor: AppTheme.red,
                      title: 'Total Donations',
                      value: '12',
                    ),
                  ),
                  Expanded(
                    child: StatsCard(
                      icon: Icons.favorite,
                      iconColor: AppTheme.blue,
                      title: 'Lives Saved',
                      value: '36',
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    child: StatsCard(
                      icon: Icons.trending_up,
                      iconColor: AppTheme.green,
                      title: 'Streak Days',
                      value: '45',
                    ),
                  ),
                  Expanded(
                    child: StatsCard(
                      icon: Icons.star,
                      iconColor: AppTheme.purple,
                      title: 'Points',
                      value: '1.2K',
                    ),
                  ),
                ],
              ),
            ),

            // Call to Action
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.red,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ready to Donate?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your blood can save lives. Find a donation center near you.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Navigate to donation centers
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.white,
                      foregroundColor: AppTheme.red,
                    ),
                    child: const Text('Find Centers'),
                  ),
                ],
              ),
            ),

            // Nearby Requests Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Nearby Blood Requests',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.black,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to requests tab
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
            ),

            // Placeholder for requests
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.grey.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 60,
                    color: AppTheme.grey.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No urgent requests nearby',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.grey.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}