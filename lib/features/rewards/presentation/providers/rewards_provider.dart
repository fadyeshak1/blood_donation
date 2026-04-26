import 'package:blood_donation/core/network/api_result.dart';
import 'package:blood_donation/features/rewards/data/repositories/rewards_repository_impl.dart';
import 'package:blood_donation/features/rewards/presentation/providers/rewards_state.dart';
import 'package:flutter/foundation.dart';

class RewardsProvider extends ChangeNotifier {
  final RewardsRepository repository;
  RewardsState _state = const RewardsState();

  RewardsProvider(this.repository);

  RewardsState get state => _state;

  void _setState(RewardsState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> loadRewards(String userId) async {
    _setState(_state.copyWith(status: RewardsStatus.loading));

    final rewardsResult = await repository.getRewards();
    final pointsResult = await repository.getUserPoints(userId);
    final historyResult = await repository.getRedemptionHistory(userId);

    switch (rewardsResult) {
      case ApiSuccess(data: final rewardsData):
        switch (pointsResult) {
          case ApiSuccess(data: final pointsData):
            switch (historyResult) {
              case ApiSuccess(data: final historyData):
                _setState(_state.copyWith(
                  status: RewardsStatus.success,
                  rewards: rewardsData,
                  userPoints: pointsData,
                  redemptionHistory: historyData,
                ));
              case ApiFailure(message: final errorMsg):
                _setState(_state.copyWith(
                  status: RewardsStatus.error,
                  errorMessage: errorMsg,
                ));
            }
          case ApiFailure(message: final errorMsg):
            _setState(_state.copyWith(
              status: RewardsStatus.error,
              errorMessage: errorMsg,
            ));
        }
      case ApiFailure(message: final errorMsg):
        _setState(_state.copyWith(
          status: RewardsStatus.error,
          errorMessage: errorMsg,
        ));
    }
  }

  Future<bool> redeemReward(String rewardId, int pointsRequired) async {
    // Check if user has enough points
    if (_state.userPoints == null ||
        _state.userPoints!.availablePoints < pointsRequired) {
      return false;
    }

    final result = await repository.redeemReward(rewardId);

    if (result is ApiSuccess) {
      // Refresh data after successful redemption
      await loadRewards('user_123');
      return true;
    }
    return false;
  }
}