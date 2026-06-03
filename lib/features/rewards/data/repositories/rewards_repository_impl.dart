import 'package:blood_donation/core/network/api_result.dart';
import 'package:blood_donation/features/rewards/data/datasources/rewards_remote_datasource.dart';
import 'package:blood_donation/features/rewards/data/models/redemption_model.dart';
import 'package:blood_donation/features/rewards/data/models/reward_model.dart';
import 'package:blood_donation/features/rewards/data/models/user_points_model.dart';

abstract class RewardsRepository {
  Future<ApiResult<List<RewardModel>>> getRewards();
  Future<ApiResult<UserPointsModel>> getUserPoints(String userId);
  Future<ApiResult<List<RedemptionModel>>> getRedemptionHistory(String userId);
  /// Returns the redemption ID on success so the caller can fetch the QR.
  Future<ApiResult<String>> redeemRewardForId(String rewardId);
}

class RewardsRepositoryImpl implements RewardsRepository {
  final RewardsRemoteDataSource remoteDataSource;

  const RewardsRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<List<RewardModel>>> getRewards() async {
    try {
      return ApiSuccess(await remoteDataSource.getRewards());
    } catch (e) {
      return ApiFailure('Failed to fetch rewards: $e');
    }
  }

  @override
  Future<ApiResult<UserPointsModel>> getUserPoints(String userId) async {
    try {
      return ApiSuccess(await remoteDataSource.getUserPoints(userId));
    } catch (e) {
      return ApiFailure('Failed to fetch points: $e');
    }
  }

  @override
  Future<ApiResult<List<RedemptionModel>>> getRedemptionHistory(
      String userId) async {
    try {
      return ApiSuccess(
          await remoteDataSource.getRedemptionHistory(userId));
    } catch (e) {
      return ApiFailure('Failed to fetch redemption history: $e');
    }
  }

  @override
  Future<ApiResult<String>> redeemRewardForId(String rewardId) async {
    try {
      final redemptionId = await remoteDataSource.redeemReward(rewardId);
      return ApiSuccess(redemptionId);
    } catch (e) {
      return ApiFailure('Failed to redeem reward: $e');
    }
  }
}