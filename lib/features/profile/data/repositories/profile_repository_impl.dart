import 'package:blood_donation/core/network/api_result.dart';
import 'package:blood_donation/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:blood_donation/features/profile/data/models/donation_history_model.dart';
import 'package:blood_donation/features/profile/data/models/request_history_model.dart';
import 'package:blood_donation/features/profile/data/models/user_model.dart';

abstract class ProfileRepository {
  Future<ApiResult<UserModel>> getUserProfile(String userId);
  Future<ApiResult<UserModel>> updateUserProfile(UserModel user);
  Future<ApiResult<List<DonationHistoryModel>>> getDonationHistory(
      String userId);
  Future<ApiResult<List<RequestHistoryModel>>> getRequestHistory();
  Future<ApiResult<void>> logout();
}

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  const ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<UserModel>> getUserProfile(String userId) async {
    try {
      final user = await remoteDataSource.getUserProfile(userId);
      return ApiSuccess(user);
    } catch (e) {
      return ApiFailure(
          'Failed to load profile: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  @override
  Future<ApiResult<UserModel>> updateUserProfile(UserModel user) async {
    try {
      final updated = await remoteDataSource.updateUserProfile(user);
      return ApiSuccess(updated);
    } catch (e) {
      return ApiFailure(
          'Failed to update profile: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  @override
  Future<ApiResult<List<DonationHistoryModel>>> getDonationHistory(
      String userId) async {
    try {
      final history =
          await remoteDataSource.getDonationHistory(userId);
      return ApiSuccess(history);
    } catch (e) {
      return ApiFailure(
          'Failed to load donation history: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  @override
  Future<ApiResult<List<RequestHistoryModel>>> getRequestHistory() async {
    try {
      final requests = await remoteDataSource.getRequestHistory();
      return ApiSuccess(requests);
    } catch (e) {
      return ApiFailure(
          'Failed to load request history: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  @override
  Future<ApiResult<void>> logout() async {
    return const ApiSuccess(null);
  }
}