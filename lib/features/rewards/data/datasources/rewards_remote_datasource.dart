import 'dart:convert';
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

  /// GET /api/rewards — returns [{id(int), title, pointsRequired, isAvailable}]
  @override
  Future<List<RewardModel>> getRewards() async {
    final response = await apiClient.get(ApiEndpoints.rewards);

    if (response.statusCode == 200) {
      final list =
          jsonDecode(utf8.decode(response.bodyBytes)) as List;
      return list
          .map((j) => RewardModel.fromJson(j as Map<String, dynamic>))
          .toList();
    }

    throw Exception(ApiClient.errorMessage(response));
  }

  /// Points come from GET /api/users/dashboard → totalPoints
  @override
  Future<UserPointsModel> getUserPoints(String userId) async {
    final response = await apiClient.get(ApiEndpoints.dashboard);

    if (response.statusCode == 200) {
      final data = ApiClient.decode(response) as Map<String, dynamic>;
      final points = (data['totalPoints'] as num?)?.toInt() ?? 0;
      return UserPointsModel(
        totalPoints: points,
        availablePoints: points,
        redeemedPoints: 0,
        lifetimePoints: points,
      );
    }

    throw Exception(ApiClient.errorMessage(response));
  }

  /// GET /api/users/rewards — returns redemption history
  @override
  Future<List<RedemptionHistoryModel>> getRedemptionHistory(
      String userId) async {
    final response = await apiClient.get(ApiEndpoints.myRewards);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is List) {
        return decoded
            .map((j) => RedemptionHistoryModel.fromJson(
                j as Map<String, dynamic>))
            .toList();
      }
      return [];
    }

    if (response.statusCode == 404) return [];

    throw Exception(ApiClient.errorMessage(response));
  }

  /// POST /api/rewards/redeem — body: {rewardId: int}
  @override
  Future<void> redeemReward(String rewardId) async {
    final id = int.tryParse(rewardId);
    if (id == null) throw Exception('Invalid reward ID');

    final response = await apiClient.post(
      ApiEndpoints.redeemReward,
      body: {'rewardId': id},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    }

    throw Exception(ApiClient.errorMessage(response));
  }
}