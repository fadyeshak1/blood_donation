import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:blood_donation/features/rewards/data/models/reward_model.dart';
import 'package:blood_donation/features/rewards/presentation/providers/rewards_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RewardCard extends StatelessWidget {
  final RewardModel reward;
  final bool canAfford;

  const RewardCard({
    super.key,
    required this.reward,
    required this.canAfford,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: canAfford
              ? AppTheme.green.withValues(alpha: 0.3)
              : AppTheme.grey.withValues(alpha: 0.2),
          width: canAfford ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canAfford ? () => _showRedeemDialog(context) : null,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImage(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reward.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reward.description,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.grey.withValues(alpha: 0.8),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      _buildPointsBadge(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppTheme.grey.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      child: Center(
        child: Icon(
          _getCategoryIcon(),
          size: 48,
          color: AppTheme.grey.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildPointsBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: canAfford
            ? AppTheme.green.withValues(alpha: 0.1)
            : AppTheme.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: 14,
            color: canAfford ? AppTheme.green : AppTheme.grey,
          ),
          const SizedBox(width: 4),
          Text(
            '${reward.pointsRequired}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: canAfford ? AppTheme.green : AppTheme.grey,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon() {
    switch (reward.category.toLowerCase()) {
      case 'food & beverage':
        return Icons.restaurant;
      case 'entertainment':
        return Icons.movie;
      case 'health & fitness':
        return Icons.fitness_center;
      case 'merchandise':
        return Icons.checkroom;
      case 'shopping':
        return Icons.shopping_bag;
      default:
        return Icons.card_giftcard;
    }
  }

  void _showRedeemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Redeem Reward'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reward.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(reward.description),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.star, color: AppTheme.purple, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${reward.pointsRequired} points',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await context
                  .read<RewardsProvider>()
                  .redeemReward(reward.id, reward.pointsRequired);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Reward redeemed successfully!'
                          : 'Failed to redeem reward',
                    ),
                    backgroundColor: success ? AppTheme.green : AppTheme.red,
                  ),
                );
              }
            },
            child: const Text('Redeem'),
          ),
        ],
      ),
    );
  }
}