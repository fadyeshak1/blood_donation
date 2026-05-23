import 'package:blood_donation/core/network/api_client.dart';
import 'package:blood_donation/core/network/api_endpoints.dart';
import 'package:blood_donation/features/profile/data/models/donation_history_model.dart';
import 'package:blood_donation/features/profile/data/models/user_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel> getUserProfile(String userId);
  Future<UserModel> updateUserProfile(UserModel user);
  Future<List<DonationHistoryModel>> getDonationHistory(String userId);
  Future<void> logout();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient apiClient;

  const ProfileRemoteDataSourceImpl(this.apiClient);

  @override
  Future<UserModel> getUserProfile(String userId) async {
    // Fetch profile and dashboard in parallel
    final profileFuture = apiClient.get(ApiEndpoints.profile);
    final dashboardFuture = apiClient.get(ApiEndpoints.dashboard);

    final results =
        await Future.wait([profileFuture, dashboardFuture]);
    final profileResponse = results[0];
    final dashboardResponse = results[1];

    if (profileResponse.statusCode == 200) {
      final profileData =
          ApiClient.decode(profileResponse) as Map<String, dynamic>;
      UserModel user = UserModel.fromProfileJson(profileData);

      if (dashboardResponse.statusCode == 200) {
        final dash =
            ApiClient.decode(dashboardResponse) as Map<String, dynamic>;
        user = user.copyWithDashboard(
          totalDonations:
              (dash['totalDonations'] as num?)?.toInt() ?? 0,
          totalPoints: (dash['totalPoints'] as num?)?.toInt() ?? 0,
        );
      }

      return user;
    }

    throw Exception(ApiClient.errorMessage(profileResponse));
  }

  @override
  Future<UserModel> updateUserProfile(UserModel user) async {
    // user.toJson() always returns the 4 required fields:
    // { fullName, phoneNumber, address, age }
    final response = await apiClient.put(
      ApiEndpoints.profile,
      body: user.toJson(),
    );

    if (response.statusCode == 200) {
      // Re-fetch to get the authoritative updated profile
      return getUserProfile(user.id);
    }

    throw Exception(ApiClient.errorMessage(response));
  }

  @override
  Future<List<DonationHistoryModel>> getDonationHistory(
      String userId) async {
    final response = await apiClient.get(ApiEndpoints.myDonations);

    if (response.statusCode == 200) {
      final decoded = ApiClient.decode(response);
      if (decoded is List) {
        return decoded
            .map((json) => DonationHistoryModel.fromJson(
                json as Map<String, dynamic>))
            .toList();
      }
    }

    if (response.statusCode == 404) return [];

    throw Exception(ApiClient.errorMessage(response));
  }

  @override
  Future<void> logout() async {}
}