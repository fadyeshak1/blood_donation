import 'package:blood_donation/core/network/api_result.dart';
import 'package:blood_donation/features/home/data/datasources/home_remote_datasource.dart';
import 'package:blood_donation/features/home/data/models/dashboard_stats_model.dart';
import 'package:blood_donation/features/home/data/models/urgent_request_model.dart';

abstract class HomeRepository {
  Future<ApiResult<DashboardStatsModel>> getDashboardStats(String userId);
  Future<ApiResult<List<UrgentRequestModel>>> getUrgentRequests(String userId);
}

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  const HomeRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<DashboardStatsModel>> getDashboardStats(String userId) async {
    try {
      final stats = await remoteDataSource.getDashboardStats(userId);
      return ApiSuccess(stats);
    } catch (e) {
      return ApiFailure('Failed to fetch dashboard stats: ${e.toString()}');
    }
  }

  @override
  Future<ApiResult<List<UrgentRequestModel>>> getUrgentRequests(
    String userId,
  ) async {
    try {
      final requests = await remoteDataSource.getUrgentRequests(userId);
      return ApiSuccess(requests);
    } catch (e) {
      return ApiFailure('Failed to fetch urgent requests: ${e.toString()}');
    }
  }
}
