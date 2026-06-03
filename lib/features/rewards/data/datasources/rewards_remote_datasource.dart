import 'dart:convert';
import 'package:blood_donation/core/network/api_client.dart';
import 'package:blood_donation/core/network/api_endpoints.dart';
import 'package:blood_donation/features/rewards/data/models/redemption_model.dart';
import 'package:blood_donation/features/rewards/data/models/reward_model.dart';
import 'package:blood_donation/features/rewards/data/models/user_points_model.dart';

abstract class RewardsRemoteDataSource {
  Future<List<RewardModel>> getRewards();
  Future<UserPointsModel> getUserPoints(String userId);
  Future<List<RedemptionModel>> getRedemptionHistory(String userId);

  /// Redeems a reward and returns the new redemption ID so the
  /// caller can immediately navigate to the QR screen.
  Future<String> redeemReward(String rewardId);
}

class RewardsRemoteDataSourceImpl implements RewardsRemoteDataSource {
  final ApiClient apiClient;

  const RewardsRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<RewardModel>> getRewards() async {
    final response = await apiClient.get(ApiEndpoints.rewards);
    if (response.statusCode == 200) {
      final list = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      return list
          .map((j) => RewardModel.fromJson(j as Map<String, dynamic>))
          .toList();
    }
    throw Exception(ApiClient.errorMessage(response));
  }

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

  @override
  Future<List<RedemptionModel>> getRedemptionHistory(String userId) async {
    final response = await apiClient.get(ApiEndpoints.myRewards);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is List) {
        return decoded
            .map((j) =>
                RedemptionModel.fromJson(j as Map<String, dynamic>))
            .toList();
      }
      return [];
    }
    if (response.statusCode == 404) return [];
    throw Exception(ApiClient.errorMessage(response));
  }

  /// POST /api/rewards/redeem → returns the redemption ID from the response.
  /// The redemption ID is needed to call GET /api/rewards/redemptions/{id}/qr.
  @override
  Future<String> redeemReward(String rewardId) async {
    final id = int.tryParse(rewardId);
    if (id == null) throw Exception('Invalid reward ID');

    final response = await apiClient.post(
      ApiEndpoints.redeemReward,
      body: {'rewardId': id},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Try to extract the redemption ID from the response body
      try {
        final data = ApiClient.decode(response) as Map<String, dynamic>;
        // Try common field names the API might use for the redemption id
        final redemptionId = data['id']?.toString() ??
            data['redemptionId']?.toString() ??
            data['redemption']?['id']?.toString();
        if (redemptionId != null) return redemptionId;
      } catch (_) {}

      // If the API doesn't return the id in the body, fetch the history
      // and return the most recent redemption's id
      try {
        final hist = await getRedemptionHistory('');
        if (hist.isNotEmpty) return hist.first.id;
      } catch (_) {}

      return '';
    }

    throw Exception(ApiClient.errorMessage(response));
  }
}