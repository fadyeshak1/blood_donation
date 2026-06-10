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
                style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _onDonateTapped(BuildContext context) async {
    final profileProvider = context.read<ProfileProvider>();

    // ── Pending donation gate ───────────────────────────────────────────
    // Only one active Pending donation is allowed at a time.
    if (profileProvider.state.hasPendingDonation) {
      _showPendingBlockDialog(context, profileProvider);
      return;
    }

    // ── Eligibility sheet (steps 1–5) ───────────────────────────────────
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

      profileProvider.addDonationFromApi(created);

      if (!context.mounted) return;

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

  /// Shown when the user already has a Pending donation.
  /// Offers a direct "Cancel Donation" action so they can immediately
  /// cancel and then come back to donate.
  void _showPendingBlockDialog(
      BuildContext context, ProfileProvider profileProvider) {
    final pending = profileProvider.state.pendingDonation!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.pending_outlined,
                  color: Colors.orange, size: 36),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pending Donation Exists',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'You already have a pending donation at '
              '${pending.hospitalName}. '
              'You can only have one active donation at a time.\n\n'
              'Please cancel your existing donation first if you no '
              'longer plan to complete it.',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF444444),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          // Cancel the pending donation directly from this dialog
          OutlinedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success =
                  await profileProvider.cancelDonation(pending.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Donation cancelled. You can now create a new donation.'
                        : 'Failed to cancel donation. Please try again.'),
                    backgroundColor:
                        success ? AppTheme.green : AppTheme.red,
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(16),
                  ),
                );
              }
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.red),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Cancel Existing Donation',
                style: TextStyle(color: AppTheme.red)),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ),
        ],
      ),
    );
  }
}