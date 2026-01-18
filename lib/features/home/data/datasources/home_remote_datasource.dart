import 'package:blood_donation/core/network/api_client.dart';
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
    await Future.delayed(const Duration(milliseconds: 600));
    
    // TODO: Replace with actual API call
    /*
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/users/$userId/dashboard-stats'),
      headers: await apiClient.getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return DashboardStatsModel.fromJson(jsonDecode(response.body));
    }
    
    throw Exception('Failed to load dashboard stats');
    */
    
    return DashboardStatsModel.getSampleStats();
  }

  @override
  Future<List<UrgentRequestModel>> getUrgentRequests(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // TODO: Replace with actual API call
    /*
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/blood-requests/urgent?userId=$userId'),
      headers: await apiClient.getHeaders(),
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => UrgentRequestModel.fromJson(json)).toList();
    }
    
    throw Exception('Failed to load urgent requests');
    */
    
    return UrgentRequestModel.getSampleRequests();
  }
}