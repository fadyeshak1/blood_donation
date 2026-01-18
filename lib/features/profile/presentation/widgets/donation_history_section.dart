import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:blood_donation/core/utils/date_formatter.dart';
import 'package:blood_donation/features/profile/data/models/donation_history_model.dart';
import 'package:flutter/material.dart';

class DonationHistorySection extends StatelessWidget {
  final List<DonationHistoryModel> history;

  const DonationHistorySection({super.key, required this.history});

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Donation History',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.black,
                ),
              ),
              if (history.length > 3)
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to full history
                  },
                  child: const Text('View All'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (history.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'No donations yet',
                  style: TextStyle(color: AppTheme.grey),
                ),
              ),
            )
          else
            ...history
                .take(3)
                .map((donation) => _DonationHistoryCard(donation: donation)),
        ],
      ),
    );
  }
}

class _DonationHistoryCard extends StatelessWidget {
  final DonationHistoryModel donation;

  const _DonationHistoryCard({required this.donation});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.red.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bloodtype, color: AppTheme.red, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  donation.hospitalName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormatter.formatDate(donation.date),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.grey.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${donation.pointsEarned}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.green,
                ),
              ),
              Text(
                '${donation.unitsQuantity} ${donation.unitsQuantity == 1 ? 'unit' : 'units'}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.grey.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}