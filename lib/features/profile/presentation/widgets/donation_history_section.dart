import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:blood_donation/core/utils/date_formatter.dart';
import 'package:blood_donation/features/donations/presentation/donation_qr_screen.dart';
import 'package:blood_donation/features/profile/data/models/donation_history_model.dart';
import 'package:blood_donation/features/profile/presentation/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DonationHistorySection extends StatefulWidget {
  const DonationHistorySection({super.key});

  @override
  State<DonationHistorySection> createState() =>
      _DonationHistorySectionState();
}

class _DonationHistorySectionState extends State<DonationHistorySection> {
  static const int _initialCount = 2;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, _) {
        final donations = provider.state.donationHistory;
        final showExpander = donations.length > _initialCount;
        final displayed = _expanded
            ? donations
            : donations.take(_initialCount).toList();

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
              // Header
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
                  if (donations.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${donations.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.red,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              if (donations.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'No donations yet',
                      style: TextStyle(color: AppTheme.grey),
                    ),
                  ),
                )
              else ...[
                ...displayed.map(
                  (d) => _DonationCard(
                    donation: d,
                    onCancel: () =>
                        _confirmCancel(context, provider, d),
                    onShowQr: () => _openQr(context, d),
                  ),
                ),

                // Show More / Show Less button
                if (showExpander) ...[
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () =>
                          setState(() => _expanded = !_expanded),
                      icon: Icon(
                        _expanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 18,
                        color: AppTheme.red,
                      ),
                      label: Text(
                        _expanded
                            ? 'Show Less'
                            : 'Show More (${donations.length - _initialCount} more)',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.red,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 4),
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  void _openQr(BuildContext context, DonationHistoryModel donation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DonationQrScreen(
          donationId: donation.id,
          hospitalName: donation.hospitalName,
        ),
      ),
    );
  }

  void _confirmCancel(
    BuildContext context,
    ProfileProvider provider,
    DonationHistoryModel donation,
  ) {
    if (donation.status != 'pending') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Only pending donations can be cancelled. '
              'This donation is already ${donation.status}.'),
          backgroundColor: AppTheme.grey,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Donation'),
        content: Text(
            'Cancel the donation at ${donation.hospitalName}?\n\n'
            'It will be marked as Cancelled and remain in your history.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final scaffold = ScaffoldMessenger.of(context);
              final success =
                  await provider.cancelDonation(donation.id);
              if (!context.mounted) return;
              scaffold.showSnackBar(
                SnackBar(
                  content: Text(success
                      ? 'Donation cancelled successfully.'
                      : 'Failed to cancel donation. Please try again.'),
                  backgroundColor:
                      success ? AppTheme.green : AppTheme.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.red),
            child: const Text('Cancel Donation',
                style: TextStyle(color: AppTheme.white)),
          ),
        ],
      ),
    );
  }
}

class _DonationCard extends StatelessWidget {
  final DonationHistoryModel donation;
  final VoidCallback onCancel;
  final VoidCallback onShowQr;

  const _DonationCard({
    required this.donation,
    required this.onCancel,
    required this.onShowQr,
  });

  @override
  Widget build(BuildContext context) {
    final statusStyle = _statusStyle(donation.status);
    final isPending = donation.status == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppTheme.grey.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.bloodtype,
                    color: AppTheme.red, size: 22),
              ),
              const SizedBox(width: 10),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (donation.location.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 12, color: AppTheme.grey),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              donation.location,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF444444)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              if (isPending)
                IconButton(
                  onPressed: onCancel,
                  icon: const Icon(Icons.cancel_outlined,
                      color: AppTheme.red, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Cancel donation',
                ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusStyle.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusStyle.icon,
                        size: 11, color: statusStyle.color),
                    const SizedBox(width: 4),
                    Text(
                      statusStyle.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusStyle.color,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Icon(Icons.calendar_today_outlined,
                  size: 12, color: AppTheme.grey),
              const SizedBox(width: 4),
              Text(
                DateFormatter.formatDate(donation.date),
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF444444)),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.water_drop_outlined,
                  size: 12, color: AppTheme.red),
              const SizedBox(width: 3),
              Text(
                '${donation.unitsQuantity} unit${donation.unitsQuantity > 1 ? 's' : ''}',
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF444444)),
              ),
            ],
          ),
          if (isPending) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onShowQr,
                icon: const Icon(Icons.qr_code,
                    color: AppTheme.red, size: 18),
                label: const Text(
                  'Show QR Code',
                  style: TextStyle(
                    color: AppTheme.red,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  side: const BorderSide(
                      color: AppTheme.red, width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  _StatusStyle _statusStyle(String status) {
    switch (status) {
      case 'confirmed':
        return _StatusStyle(
            AppTheme.green, Icons.check_circle_outline, 'Confirmed');
      case 'cancelled':
        return _StatusStyle(
            AppTheme.grey, Icons.cancel_outlined, 'Cancelled');
      case 'rejected':
        return _StatusStyle(
            AppTheme.red, Icons.block_outlined, 'Rejected');
      case 'withdrawn':
        return _StatusStyle(const Color(0xFF9370DB),
            Icons.undo_outlined, 'Withdrawn');
      default:
        return _StatusStyle(
            Colors.orange, Icons.hourglass_top_outlined, 'Pending');
    }
  }
}

class _StatusStyle {
  final Color color;
  final IconData icon;
  final String label;
  const _StatusStyle(this.color, this.icon, this.label);
}