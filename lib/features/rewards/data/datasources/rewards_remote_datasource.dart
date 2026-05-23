import 'package:blood_donation/core/network/api_client.dart';
import 'package:blood_donation/core/network/api_endpoints.dart';
import 'package:blood_donation/features/rewards/data/models/redemption_history_model.dart';
import 'package:blood_donation/features/rewards/data/models/reward_model.dart';
import 'package:blood_donation/features/rewards/data/models/user_points_model.dart';

abstract class RewardsRemoteDataSource {
  Future<List<RewardModel>> getRewards();
  Future<UserPointsModel> getUserPoints(String userId);
  Future<List<RedemptionHistoryModel>> getRedemptionHistory(String userId);
  Future<void> redeemReward(String rewardId);
}

class RewardsRemoteDataSourceImpl implements RewardsRemoteDataSource {
  final ApiClient apiClient;

  const RewardsRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<RewardModel>> getRewards() async {
    final response = await apiClient.get(ApiEndpoints.rewards);

    if (response.statusCode == 200) {
      final List<dynamic> data = ApiClient.decode(response) as List;
      return data
          .map((json) =>
              RewardModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    throw Exception(ApiClient.errorMessage(response));
  }

  @override
  Future<UserPointsModel> getUserPoints(String userId) async {
    // Dashboard returns totalPoints
    final response = await apiClient.get(ApiEndpoints.dashboard);

    if (response.statusCode == 200) {
      final data = ApiClient.decode(response) as Map<String, dynamic>;
      final totalPoints = (data['totalPoints'] as num?)?.toInt() ?? 0;
      return UserPointsModel(
        totalPoints: totalPoints,
        availablePoints: totalPoints,
        redeemedPoints: 0,
        lifetimePoints: totalPoints,
      );
    }

    return const UserPointsModel(
      totalPoints: 0,
      availablePoints: 0,
      redeemedPoints: 0,
      lifetimePoints: 0,
    );
  }

  @override
  Future<List<RedemptionHistoryModel>> getRedemptionHistory(
      String userId) async {
    final response = await apiClient.get(ApiEndpoints.myRewards);

    if (response.statusCode == 200) {
      final decoded = ApiClient.decode(response);
      if (decoded is List) {
        return decoded
            .map((json) => RedemptionHistoryModel.fromJson(
                json as Map<String, dynamic>))
            .toList();
      }
    }

    return [];
  }

  @override
  Future<void> redeemReward(String rewardId) async {
    final response = await apiClient.post(
      ApiEndpoints.redeemReward,
      body: {'rewardId': int.tryParse(rewardId) ?? 0},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    }

    throw Exception(ApiClient.errorMessage(response));
  }
}