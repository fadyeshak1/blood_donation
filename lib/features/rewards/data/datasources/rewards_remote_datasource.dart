import 'package:blood_donation/core/network/api_client.dart';
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
    await Future.delayed(const Duration(milliseconds: 800));

    // TODO: Replace with actual API call
    /*
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/rewards'),
      headers: await apiClient.getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => RewardModel.fromJson(json)).toList();
    }

    throw Exception('Failed to load rewards');
    */

    return RewardModel.getSampleRewards();
  }

  @override
  Future<UserPointsModel> getUserPoints(String userId) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // TODO: Replace with actual API call
    /*
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/users/$userId/points'),
      headers: await apiClient.getHeaders(),
    );

    if (response.statusCode == 200) {
      return UserPointsModel.fromJson(jsonDecode(response.body));
    }

    throw Exception('Failed to load user points');
    */

    return UserPointsModel.getSamplePoints();
  }

  @override
  Future<List<RedemptionHistoryModel>> getRedemptionHistory(
    String userId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // TODO: Replace with actual API call
    /*
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/users/$userId/redemptions'),
      headers: await apiClient.getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => RedemptionHistoryModel.fromJson(json)).toList();
    }

    throw Exception('Failed to load redemption history');
    */

    return RedemptionHistoryModel.getSampleHistory();
  }

  @override
  Future<void> redeemReward(String rewardId) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    // TODO: Replace with actual API call
    /*
    final response = await http.post(
      Uri.parse('${ApiClient.baseUrl}/rewards/$rewardId/redeem'),
      headers: await apiClient.getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to redeem reward');
    }
    */
  }
}