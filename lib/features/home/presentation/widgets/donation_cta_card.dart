import 'package:blood_donation/core/network/api_client.dart';
import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:blood_donation/features/donations/data/datasources/donation_remote_datasource.dart';
import 'package:blood_donation/features/donations/data/models/create_donation_model.dart';
import 'package:blood_donation/features/donations/presentation/donation_qr_screen.dart';
import 'package:blood_donation/features/home/data/models/eligibility_result.dart';
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
            child: const Icon(Icons.favorite,
                color: AppTheme.red, size: 26),
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
                      height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => _onDonateTapped(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Donate',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _onDonateTapped(BuildContext context) async {
    final profileProvider = context.read<ProfileProvider>();
    EligibilityResult? eligibilityResult;

    await CheckEligibilitySheet.show(
      context,
      onEligible: (result) => eligibilityResult = result,
    );

    if (eligibilityResult == null || !context.mounted) return;

    try {
      final ds = DonationRemoteDataSourceImpl(const ApiClient());
      final created = await ds.createDonation(CreateDonationModel(
        hospitalId: eligibilityResult!.hospitalId,
        age: eligibilityResult!.age,
        weight: eligibilityResult!.weight,
        hasTattoo: eligibilityResult!.hasTattoo,
        lastDonationDate: eligibilityResult!.lastDonationDate,
        medicalCondition: eligibilityResult!.medicalCondition,
      ));

      // Add to Donation History with the real DB id
      profileProvider.addDonationFromApi(created);

      if (!context.mounted) return;

      // Navigate to QR screen — the donor shows this to hospital staff
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DonationQrScreen(
            donationId: created.id,
            hospitalName: eligibilityResult!.hospitalName,
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to record donation: $e'),
            backgroundColor: AppTheme.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }
}