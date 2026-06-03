import 'package:blood_donation/core/network/api_result.dart';
import 'package:blood_donation/features/rewards/data/repositories/rewards_repository_impl.dart';
import 'package:blood_donation/features/rewards/presentation/providers/rewards_state.dart';
import 'package:flutter/foundation.dart';

class RewardsProvider extends ChangeNotifier {
  final RewardsRepository repository;
  RewardsState _state = const RewardsState();

  RewardsProvider(this.repository);

  RewardsState get state => _state;

  void _setState(RewardsState s) {
    _state = s;
    notifyListeners();
  }

  Future<void> loadRewards(String userId) async {
    _setState(_state.copyWith(status: RewardsStatus.loading));

    final rewardsResult = await repository.getRewards();
    final pointsResult = await repository.getUserPoints(userId);
    final historyResult = await repository.getRedemptionHistory(userId);

    switch (rewardsResult) {
      case ApiSuccess(data: final rewards):
        switch (pointsResult) {
          case ApiSuccess(data: final points):
            switch (historyResult) {
              case ApiSuccess(data: final history):
                _setState(_state.copyWith(
                  status: RewardsStatus.success,
                  rewards: rewards,
                  userPoints: points,
                  redemptionHistory: history,
                ));
              case ApiFailure(message: final m):
                _setState(_state.copyWith(
                    status: RewardsStatus.error, errorMessage: m));
            }
          case ApiFailure(message: final m):
            _setState(
                _state.copyWith(status: RewardsStatus.error, errorMessage: m));
        }
      case ApiFailure(message: final m):
        _setState(
            _state.copyWith(status: RewardsStatus.error, errorMessage: m));
    }
  }

  /// Redeems a reward and returns the redemption ID so the UI can
  /// navigate to the QR screen. Returns null on failure.
  Future<String?> redeemRewardAndGetId(String rewardId) async {
    final result = await repository.redeemRewardForId(rewardId);
    if (result is ApiSuccess<String>) {
      await loadRewards('');
      return result.data;
    }
    return null;
  }

  /// Legacy method kept for compatibility — use redeemRewardAndGetId instead.
  Future<bool> redeemReward(String rewardId, int pointsRequired) async {
    final id = await redeemRewardAndGetId(rewardId);
    return id != null;
  }
}