import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:blood_donation/core/utils/date_formatter.dart';
import 'package:flutter/material.dart';

class DonationCtaCard extends StatelessWidget {
  final bool isEligible;
  final DateTime? nextEligibleDate;

  const DonationCtaCard({
    super.key,
    required this.isEligible,
    this.nextEligibleDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isEligible ? AppTheme.red : AppTheme.grey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (isEligible)
            BoxShadow(
              color: AppTheme.red.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isEligible ? Icons.check_circle : Icons.schedule,
                color: isEligible ? AppTheme.white : AppTheme.grey,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isEligible ? 'Ready to Donate!' : 'Not Eligible Yet',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isEligible ? AppTheme.white : AppTheme.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            isEligible
                ? 'Your blood can save lives. Find a donation center near you.'
                : nextEligibleDate != null
                    ? 'You can donate again on ${DateFormatter.formatDate(nextEligibleDate!)}'
                    : 'Check your eligibility status',
            style: TextStyle(
              fontSize: 14,
              color: isEligible ? AppTheme.white : AppTheme.grey,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isEligible
                  ? () {
                      // TODO: Navigate to donation centers
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.white,
                foregroundColor: AppTheme.red,
                disabledBackgroundColor: AppTheme.grey.withValues(alpha: 0.3),
                disabledForegroundColor: AppTheme.grey,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(isEligible ? 'Find Donation Centers' : 'View Calendar'),
            ),
          ),
        ],
      ),
    );
  }
}
