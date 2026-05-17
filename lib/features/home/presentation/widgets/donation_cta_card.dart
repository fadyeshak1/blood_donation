import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:blood_donation/features/home/presentation/widgets/check_eligibility_sheet.dart';
import 'package:blood_donation/features/profile/presentation/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DonationCtaCard extends StatelessWidget {
  const DonationCtaCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite, color: AppTheme.red, size: 26),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ready to Donate?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your blood can save lives. Find a donation center near you.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF666666),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => _onDonateTapped(context),
            style: ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Donate',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onDonateTapped(BuildContext context) async {
    // Capture ProfileProvider HERE in the parent context — the bottom sheet
    // runs in a separate route and cannot access providers by itself.
    final profileProvider = context.read<ProfileProvider>();

    String? selectedHospital;

    await CheckEligibilitySheet.show(
      context,
      onEligible: (hospitalName) {
        selectedHospital = hospitalName;
      },
    );

    // Sheet is now closed. If eligible, add to Donation History.
    if (selectedHospital != null) {
      profileProvider.addPendingDonation(hospitalName: selectedHospital!);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.favorite, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'Thank you for your donation! 🩸',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}