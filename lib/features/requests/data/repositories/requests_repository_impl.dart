import 'package:blood_donation/core/network/api_result.dart';
import 'package:blood_donation/features/requests/data/datasources/requests_remote_datasource.dart';
import 'package:blood_donation/features/requests/data/models/blood_request_model.dart';
import 'package:blood_donation/features/requests/data/models/create_request_model.dart';

abstract class RequestsRepository {
  Future<ApiResult<List<BloodRequestModel>>> getRequests({
    String? bloodType,
    String? urgency,
    String? search,
  });
  Future<ApiResult<BloodRequestModel>> getRequestById(String requestId);
  Future<ApiResult<void>> acceptRequest(String requestId);
  Future<ApiResult<void>> createRequest(CreateRequestModel request);
}

class RequestsRepositoryImpl implements RequestsRepository {
  final RequestsRemoteDataSource remoteDataSource;

  const RequestsRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<List<BloodRequestModel>>> getRequests({
    String? bloodType,
    String? urgency,
    String? search,
  }) async {
    try {
      final requests = await remoteDataSource.getRequests(
        bloodType: bloodType,
        urgency: urgency,
        search: search,
      );
      return ApiSuccess(requests);
    } catch (e) {
      return ApiFailure('Failed to fetch requests: ${e.toString()}');
    }
  }

  @override
  Future<ApiResult<BloodRequestModel>> getRequestById(String requestId) async {
    try {
      final request = await remoteDataSource.getRequestById(requestId);
      return ApiSuccess(request);
    } catch (e) {
      return ApiFailure('Failed to fetch request details: ${e.toString()}');
    }
  }

  @override
  Future<ApiResult<void>> acceptRequest(String requestId) async {
    try {
      await remoteDataSource.acceptRequest(requestId);
      return const ApiSuccess(null);
    } catch (e) {
      return ApiFailure('Failed to accept request: ${e.toString()}');
    }
  }
  @override
Future<ApiResult<void>> createRequest(CreateRequestModel request) async {
  try {
    await remoteDataSource.createRequest(request);
    return const ApiSuccess(null);
  } catch (e) {
    return ApiFailure('Failed to create request: ${e.toString()}');
  }
}
}