import 'dart:io';
import 'package:blood_donation/core/network/api_client.dart';
import 'package:blood_donation/core/network/api_endpoints.dart';
import 'package:blood_donation/features/home/data/models/dashboard_stats_model.dart';
import 'package:blood_donation/features/home/data/models/urgent_request_model.dart';

abstract class HomeRemoteDataSource {
  Future<DashboardStatsModel> getDashboardStats(String userId);
  Future<List<UrgentRequestModel>> getUrgentRequests(String userId);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final ApiClient apiClient;

  const HomeRemoteDataSourceImpl(this.apiClient);

  @override
  Future<DashboardStatsModel> getDashboardStats(String userId) async {
    try {
      final response = await apiClient.get(ApiEndpoints.dashboard);

      if (response.statusCode == 200) {
        final data =
            ApiClient.decode(response) as Map<String, dynamic>;
        return DashboardStatsModel.fromJson(data);
      }

      throw Exception(ApiClient.errorMessage(response));
    } on SocketException {
      throw Exception(
          'No internet connection. Please check your network and try again.');
    } on HandshakeException {
      throw Exception('Connection error. Please try again.');
    }
  }

  @override
  Future<List<UrgentRequestModel>> getUrgentRequests(String userId) async {
    try {
      final response = await apiClient
          .get('${ApiEndpoints.matchRequests}?Priority=2');

      if (response.statusCode == 200) {
        final decoded = ApiClient.decode(response);

        // Handle all three shapes the API can return:
        // 1. {"message": "..."} — no location set
        // 2. {"results": [...]} — success
        // 3. [...] — bare list
        if (decoded is Map) {
          if (decoded.containsKey('results')) {
            final list = decoded['results'] as List? ?? [];
            return list
                .map((json) => UrgentRequestModel.fromApiJson(
                    json as Map<String, dynamic>))
                .toList();
          }
          // No location set — fall back to sample
          return UrgentRequestModel.getSampleRequests();
        }

        if (decoded is List) {
          return decoded
              .map((json) => UrgentRequestModel.fromApiJson(
                  json as Map<String, dynamic>))
              .toList();
        }

        return UrgentRequestModel.getSampleRequests();
      }

      return UrgentRequestModel.getSampleRequests();
    } on SocketException {
      // Urgent requests failing silently is acceptable —
      // return sample data so the rest of the home screen still loads.
      return UrgentRequestModel.getSampleRequests();
    } catch (_) {
      return UrgentRequestModel.getSampleRequests();
    }
  }
}