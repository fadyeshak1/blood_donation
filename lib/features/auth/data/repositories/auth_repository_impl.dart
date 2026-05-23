import 'package:blood_donation/core/network/api_result.dart';
import 'package:blood_donation/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:blood_donation/features/auth/data/models/auth_model.dart';

abstract class AuthRepository {
  Future<ApiResult<AuthResponseModel>> login(LoginRequestModel request);
  Future<ApiResult<AuthResponseModel>> register(RegisterRequestModel request);
  Future<ApiResult<void>> logout();
  Future<ApiResult<AuthResponseModel>> refreshToken(String refreshToken);
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  const AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<AuthResponseModel>> login(
      LoginRequestModel request) async {
    try {
      final response = await remoteDataSource.login(request);
      return ApiSuccess(response);
    } catch (e) {
      return ApiFailure(_clean(e));
    }
  }

  @override
  Future<ApiResult<AuthResponseModel>> register(
      RegisterRequestModel request) async {
    try {
      final response = await remoteDataSource.register(request);
      return ApiSuccess(response);
    } catch (e) {
      return ApiFailure(_clean(e));
    }
  }

  @override
  Future<ApiResult<void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const ApiSuccess(null);
    } catch (e) {
      return ApiFailure(_clean(e));
    }
  }

  @override
  Future<ApiResult<AuthResponseModel>> refreshToken(
      String refreshToken) async {
    try {
      final response = await remoteDataSource.refreshToken(refreshToken);
      return ApiSuccess(response);
    } catch (e) {
      return ApiFailure(_clean(e));
    }
  }

  String _clean(Object e) =>
      e.toString().replaceFirst('Exception: ', '');
}