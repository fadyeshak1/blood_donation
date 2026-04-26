import 'package:blood_donation/core/network/api_result.dart';
import 'package:blood_donation/features/rewards/data/datasources/rewards_remote_datasource.dart';
import 'package:blood_donation/features/rewards/data/models/redemption_history_model.dart';
import 'package:blood_donation/features/rewards/data/models/reward_model.dart';
import 'package:blood_donation/features/rewards/data/models/user_points_model.dart';

abstract class RewardsRepository {
  Future<ApiResult<List<RewardModel>>> getRewards();
  Future<ApiResult<UserPointsModel>> getUserPoints(String userId);
  Future<ApiResult<List<RedemptionHistoryModel>>> getRedemptionHistory(
    String userId,
  );
  Future<ApiResult<void>> redeemReward(String rewardId);
}

class RewardsRepositoryImpl implements RewardsRepository {
  final RewardsRemoteDataSource remoteDataSource;

  const RewardsRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<List<RewardModel>>> getRewards() async {
    try {
      final rewards = await remoteDataSource.getRewards();
      return ApiSuccess(rewards);
    } catch (e) {
      return ApiFailure('Failed to fetch rewards: ${e.toString()}');
    }
  }

  @override
  Future<ApiResult<UserPointsModel>> getUserPoints(String userId) async {
    try {
      final points = await remoteDataSource.getUserPoints(userId);
      return ApiSuccess(points);
    } catch (e) {
      return ApiFailure('Failed to fetch user points: ${e.toString()}');
    }
  }

  @override
  Future<ApiResult<List<RedemptionHistoryModel>>> getRedemptionHistory(
    String userId,
  ) async {
    try {
      final history = await remoteDataSource.getRedemptionHistory(userId);
      return ApiSuccess(history);
    } catch (e) {
      return ApiFailure('Failed to fetch redemption history: ${e.toString()}');
    }
  }

  @override
  Future<ApiResult<void>> redeemReward(String rewardId) async {
    try {
      await remoteDataSource.redeemReward(rewardId);
      return const ApiSuccess(null);
    } catch (e) {
      return ApiFailure('Failed to redeem reward: ${e.toString()}');
    }
  }
}
