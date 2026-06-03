import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:blood_donation/features/rewards/data/models/redemption_model.dart';
import 'package:blood_donation/features/rewards/presentation/screens/reward_qr_screen.dart';
import 'package:flutter/material.dart';

class RedemptionHistorySection extends StatelessWidget {
  final List<RedemptionModel> history;

  const RedemptionHistorySection({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Redeemed Rewards',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.black)),
          const SizedBox(height: 12),
          ...history.map((r) => _RedemptionCard(redemption: r)),
        ],
      ),
    );
  }
}

class _RedemptionCard extends StatelessWidget {
  final RedemptionModel redemption;

  const _RedemptionCard({required this.redemption});

  @override
  Widget build(BuildContext context) {
    final isUsed = redemption.isUsed;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUsed
              ? AppTheme.grey.withValues(alpha: 0.3)
              : AppTheme.purple.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Status icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUsed
                  ? AppTheme.green.withValues(alpha: 0.1)
                  : AppTheme.purple.withValues(alpha: 0.1),
            ),
            child: Icon(
              isUsed ? Icons.check_circle_outline : Icons.card_giftcard_outlined,
              color: isUsed ? AppTheme.green : AppTheme.purple,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          // Title + status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  redemption.rewardTitle.isEmpty
                      ? 'Reward #${redemption.id}'
                      : redemption.rewardTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isUsed
                            ? AppTheme.green.withValues(alpha: 0.1)
                            : AppTheme.purple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isUsed ? 'Used' : 'Unused',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isUsed ? AppTheme.green : AppTheme.purple,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${redemption.pointsSpent} pts',
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Show QR button — always visible, shows used state if already used
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RewardQrScreen(
                  redemptionId: redemption.id,
                  rewardTitle: redemption.rewardTitle,
                  status: redemption.status,
                ),
              ),
            ),
            icon: Icon(
              Icons.qr_code,
              color: isUsed ? AppTheme.grey : AppTheme.purple,
            ),
            tooltip: isUsed ? 'Already used' : 'Show QR Code',
          ),
        ],
      ),
    );
  }
}