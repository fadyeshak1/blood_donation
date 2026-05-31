import 'package:blood_donation/core/network/api_client.dart';
import 'package:blood_donation/core/network/api_endpoints.dart';
import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:blood_donation/features/rewards/data/models/reward_model.dart';
import 'package:blood_donation/features/rewards/presentation/providers/rewards_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Reward Image Mapping (assets/images/rewards/)
//  Free Medical Checkup       →  medical_checkup.png
//  Pharmacy Discount          →  pharmacy_discount.png
//  Blood Test Package         →  blood_test.png
//  Hospital Priority Service  →  hospital_priority.png
//  Full Health Package        →  health_package.png
//
//  Description note: GET /api/rewards (list) does NOT return `description`.
//  GET /api/rewards/{id} (single) DOES. The redeem dialog fetches the single
//  endpoint to pull the description on demand.
// ─────────────────────────────────────────────────────────────────────────────

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
    final theme = _rewardTheme(reward.title);
    final assetPath = _resolveAsset(reward.title);

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
              _buildImage(theme, assetPath),
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
                        reward.description.isEmpty
                            ? 'Tap to view details'
                            : reward.description,
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

  String? _resolveAsset(String title) {
    final t = title.toLowerCase();
    if (t.contains('medical checkup') || t.contains('checkup')) {
      return 'assets/images/rewards/medical_checkup.png';
    }
    if (t.contains('pharmacy')) {
      return 'assets/images/rewards/pharmacy_discount.png';
    }
    if (t.contains('blood test')) {
      return 'assets/images/rewards/blood_test.png';
    }
    if (t.contains('hospital priority') || t.contains('hospital')) {
      return 'assets/images/rewards/hospital_priority.png';
    }
    if (t.contains('health package') || t.contains('full health')) {
      return 'assets/images/rewards/health_package.png';
    }
    return null;
  }

  Widget _buildImage(_RewardTheme theme, String? assetPath) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.color.withValues(alpha: 0.18),
              theme.color.withValues(alpha: 0.06),
            ],
          ),
        ),
        child: assetPath != null
            ? Image.asset(
                assetPath,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 120,
                errorBuilder: (_, __, ___) => _iconFallback(theme),
              )
            : _iconFallback(theme),
      ),
    );
  }

  Widget _iconFallback(_RewardTheme theme) {
    return Center(
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.9),
          boxShadow: [
            BoxShadow(
              color: theme.color.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(theme.icon, size: 32, color: theme.color),
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
          Icon(Icons.star, size: 14,
              color: canAfford ? AppTheme.green : AppTheme.grey),
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

  _RewardTheme _rewardTheme(String title) {
    final t = title.toLowerCase();
    if (t.contains('medical checkup') || t.contains('checkup')) {
      return const _RewardTheme(
          icon: Icons.medical_services_outlined, color: Color(0xFF22C55E));
    }
    if (t.contains('pharmacy')) {
      return const _RewardTheme(
          icon: Icons.local_pharmacy_outlined, color: Color(0xFF8B5CF6));
    }
    if (t.contains('blood test')) {
      return _RewardTheme(
          icon: Icons.bloodtype_outlined, color: AppTheme.red);
    }
    if (t.contains('hospital priority') || t.contains('hospital')) {
      return _RewardTheme(
          icon: Icons.local_hospital_outlined, color: AppTheme.blue);
    }
    if (t.contains('health package') || t.contains('full health')) {
      return const _RewardTheme(
          icon: Icons.health_and_safety_outlined, color: Color(0xFFF59E0B));
    }
    return _RewardTheme(icon: Icons.card_giftcard, color: AppTheme.red);
  }

  /// Fetches the full reward details (including description) from
  /// GET /api/rewards/{id}, since the list endpoint omits `description`.
  Future<String> _fetchDescription() async {
    try {
      final id = int.tryParse(reward.id);
      if (id == null) return reward.description;

      final response =
          await const ApiClient().get(ApiEndpoints.rewardById(id));
      if (response.statusCode == 200) {
        final data =
            ApiClient.decode(response) as Map<String, dynamic>;
        return data['description'] as String? ??
            reward.description;
      }
    } catch (_) {}
    return reward.description;
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
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Description — fetched from GET /api/rewards/{id}
            FutureBuilder<String>(
              future: _fetchDescription(),
              builder: (_, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: SizedBox(
                      height: 14,
                      width: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppTheme.red),
                    ),
                  );
                }
                final desc = snapshot.data ?? '';
                if (desc.isEmpty) {
                  return const Text(
                    'No additional details available.',
                    style: TextStyle(
                        fontSize: 13, color: Color(0xFF666666)),
                  );
                }
                return Text(
                  desc,
                  style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF444444),
                      height: 1.5),
                );
              },
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                const Icon(Icons.star,
                    color: AppTheme.purple, size: 20),
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
                    content: Text(success
                        ? 'Reward redeemed successfully!'
                        : 'Failed to redeem reward'),
                    backgroundColor:
                        success ? AppTheme.green : AppTheme.red,
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

class _RewardTheme {
  final IconData icon;
  final Color color;
  const _RewardTheme({required this.icon, required this.color});
}