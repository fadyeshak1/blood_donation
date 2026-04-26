import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:blood_donation/core/widgets/custom_app_bar.dart';
import 'package:blood_donation/core/widgets/error_view.dart';
import 'package:blood_donation/core/widgets/loading_indicator.dart';
import 'package:blood_donation/features/rewards/presentation/providers/rewards_provider.dart';
import 'package:blood_donation/features/rewards/presentation/widgets/points_header.dart';
import 'package:blood_donation/features/rewards/presentation/widgets/redemption_history_section.dart';
import 'package:blood_donation/features/rewards/presentation/widgets/rewards_grid.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RewardsProvider>().loadRewards('user_123');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Rewards',
        subtitle: 'Redeem your points',
      ),
      body: Consumer<RewardsProvider>(
        builder: (context, provider, _) {
          final state = provider.state;

          if (state.isLoading) {
            return const LoadingIndicator();
          }

          if (state.isError) {
            return ErrorView(
              message: state.errorMessage ?? 'Failed to load rewards',
              onRetry: () => provider.loadRewards('user_123'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadRewards('user_123'),
            color: AppTheme.red,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.hasPoints) PointsHeader(points: state.userPoints!),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Available Rewards',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (state.hasRewards)
                    RewardsGrid(
                      rewards: state.rewards,
                      availablePoints: state.userPoints?.availablePoints ?? 0,
                    ),
                  const SizedBox(height: 24),
                  if (state.redemptionHistory.isNotEmpty)
                    RedemptionHistorySection(
                      history: state.redemptionHistory,
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}