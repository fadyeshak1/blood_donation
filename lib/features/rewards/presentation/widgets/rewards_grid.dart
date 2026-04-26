import 'package:blood_donation/features/rewards/data/models/reward_model.dart';
import 'package:blood_donation/features/rewards/presentation/widgets/reward_card.dart';
import 'package:flutter/material.dart';

class RewardsGrid extends StatelessWidget {
  final List<RewardModel> rewards;
  final int availablePoints;

  const RewardsGrid({
    super.key,
    required this.rewards,
    required this.availablePoints,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: rewards.length,
      itemBuilder: (context, index) {
        return RewardCard(
          reward: rewards[index],
          canAfford: availablePoints >= rewards[index].pointsRequired,
        );
      },
    );
  }
}