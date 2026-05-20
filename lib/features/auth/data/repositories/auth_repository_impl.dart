import 'package:blood_donation/core/network/api_result.dart';
import 'package:blood_donation/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:blood_donation/features/auth/data/models/auth_model.dart';

// ─── Abstract ─────────────────────────────────────────────────────────────────

abstract class AuthRepository {
  Future<ApiResult<AuthResponseModel>> login(LoginRequestModel request);
  Future<ApiResult<AuthResponseModel>> register(RegisterRequestModel request);
}

// ─── Implementation ───────────────────────────────────────────────────────────

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
      return ApiFailure('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<ApiResult<AuthResponseModel>> register(
      RegisterRequestModel request) async {
    try {
      final response = await remoteDataSource.register(request);
      return ApiSuccess(response);
    } catch (e) {
      return ApiFailure('Registration failed: ${e.toString()}');
    }
  }
}