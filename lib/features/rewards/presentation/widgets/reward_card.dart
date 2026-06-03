import 'package:blood_donation/core/network/api_client.dart';
import 'package:blood_donation/core/network/api_endpoints.dart';
import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:blood_donation/features/rewards/data/models/reward_model.dart';
import 'package:blood_donation/features/rewards/presentation/providers/rewards_provider.dart';
import 'package:blood_donation/features/rewards/presentation/screens/reward_qr_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const _kImages = [
  'assets/images/rewards/medical_checkup.png',
  'assets/images/rewards/pharmacy_discount.png',
  'assets/images/rewards/blood_test.png',
  'assets/images/rewards/hospital_priority.png',
  'assets/images/rewards/health_package.png',
];

const _kThemes = [
  _RewardTheme(icon: Icons.medical_services_outlined, color: Color(0xFF22C55E)),
  _RewardTheme(icon: Icons.local_pharmacy_outlined,   color: Color(0xFF8B5CF6)),
  _RewardTheme(icon: Icons.bloodtype_outlined,         color: Color(0xFFE53935)),
  _RewardTheme(icon: Icons.local_hospital_outlined,    color: Color(0xFF3B82F6)),
  _RewardTheme(icon: Icons.health_and_safety_outlined, color: Color(0xFFF59E0B)),
];

class RewardCard extends StatelessWidget {
  final RewardModel reward;
  final bool canAfford;

  const RewardCard({
    super.key,
    required this.reward,
    required this.canAfford,
  });

  String _resolveAsset() {
    final t = reward.title.toLowerCase();
    if (t.contains('medical checkup') || t.contains('checkup')) return _kImages[0];
    if (t.contains('pharmacy'))  return _kImages[1];
    if (t.contains('blood test')) return _kImages[2];
    if (t.contains('hospital priority')) return _kImages[3];
    if (t.contains('health package') || t.contains('full health')) return _kImages[4];
    final id = int.tryParse(reward.id) ?? 0;
    return _kImages[id % _kImages.length];
  }

  _RewardTheme _resolveTheme() {
    final t = reward.title.toLowerCase();
    if (t.contains('medical checkup') || t.contains('checkup')) return _kThemes[0];
    if (t.contains('pharmacy'))  return _kThemes[1];
    if (t.contains('blood test')) return _kThemes[2];
    if (t.contains('hospital priority')) return _kThemes[3];
    if (t.contains('health package') || t.contains('full health')) return _kThemes[4];
    final id = int.tryParse(reward.id) ?? 0;
    return _kThemes[id % _kThemes.length];
  }

  @override
  Widget build(BuildContext context) {
    final assetPath = _resolveAsset();
    final theme = _resolveTheme();

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
            blurRadius: 8, offset: const Offset(0, 2)),
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
              _buildImage(assetPath, theme),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(reward.title,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.black),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(
                        reward.description.isEmpty
                            ? 'Tap to view details'
                            : reward.description,
                        style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.grey.withValues(alpha: 0.8)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
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

  Widget _buildImage(String assetPath, _RewardTheme theme) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: SizedBox(
        height: 120,
        width: double.infinity,
        child: Image.asset(
          assetPath, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                theme.color.withValues(alpha: 0.18),
                theme.color.withValues(alpha: 0.06),
              ]),
            ),
            child: Center(
              child: Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.9),
                  boxShadow: [BoxShadow(
                      color: theme.color.withValues(alpha: 0.2),
                      blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Icon(theme.icon, size: 32, color: theme.color),
              ),
            ),
          ),
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
          Icon(Icons.star, size: 14,
              color: canAfford ? AppTheme.green : AppTheme.grey),
          const SizedBox(width: 4),
          Text('${reward.pointsRequired}',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: canAfford ? AppTheme.green : AppTheme.grey)),
        ],
      ),
    );
  }

  Future<String> _fetchDescription() async {
    try {
      final id = int.tryParse(reward.id);
      if (id == null) return reward.description;
      final response = await const ApiClient().get(ApiEndpoints.rewardById(id));
      if (response.statusCode == 200) {
        final data = ApiClient.decode(response) as Map<String, dynamic>;
        return data['description'] as String? ?? reward.description;
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
            Text(reward.title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            FutureBuilder<String>(
              future: _fetchDescription(),
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: SizedBox(width: 14, height: 14,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppTheme.red)),
                  );
                }
                final desc = snapshot.data ?? '';
                return Text(
                    desc.isEmpty ? 'No additional details.' : desc,
                    style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF444444),
                        height: 1.5));
              },
            ),
            const SizedBox(height: 16),
            Row(children: [
              const Icon(Icons.star, color: AppTheme.purple, size: 20),
              const SizedBox(width: 8),
              Text('${reward.pointsRequired} points',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.purple)),
            ]),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              final provider = context.read<RewardsProvider>();
              final redemptionId =
                  await provider.redeemRewardAndGetId(reward.id);

              if (context.mounted) {
                if (redemptionId != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reward redeemed! Here is your QR code.'),
                      backgroundColor: AppTheme.green,
                    ),
                  );
                  // Navigate to QR screen with the redemption id
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RewardQrScreen(
                        redemptionId: redemptionId,
                        rewardTitle: reward.title,
                        status: 'Unused',
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to redeem reward'),
                      backgroundColor: AppTheme.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Redeem')),
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