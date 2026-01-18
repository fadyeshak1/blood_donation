  import 'package:blood_donation/core/network/api_result.dart';
import 'package:blood_donation/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:blood_donation/features/profile/data/models/donation_history_model.dart';
import 'package:blood_donation/features/profile/data/models/user_model.dart';

abstract class ProfileRepository {
  Future<ApiResult<UserModel>> getUserProfile(String userId);
  Future<ApiResult<UserModel>> updateUserProfile(UserModel user);
  Future<ApiResult<List<DonationHistoryModel>>> getDonationHistory(String userId);
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
      return ApiFailure('Failed to fetch user profile: ${e.toString()}');
    }
  }

  @override
  Future<ApiResult<UserModel>> updateUserProfile(UserModel user) async {
    try {
      final updatedUser = await remoteDataSource.updateUserProfile(user);
      return ApiSuccess(updatedUser);
    } catch (e) {
      return ApiFailure('Failed to update profile: ${e.toString()}');
    }
  }

  @override
  Future<ApiResult<List<DonationHistoryModel>>> getDonationHistory(
    String userId,
  ) async {
    try {
      final history = await remoteDataSource.getDonationHistory(userId);
      return ApiSuccess(history);
    } catch (e) {
      return ApiFailure('Failed to fetch donation history: ${e.toString()}');
    }
  }

  @override
  Future<ApiResult<void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const ApiSuccess(null);
    } catch (e) {
      return ApiFailure('Failed to logout: ${e.toString()}');
    }
  }
}