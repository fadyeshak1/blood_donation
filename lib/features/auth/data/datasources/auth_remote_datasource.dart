import 'package:blood_donation/core/network/api_client.dart';
import 'package:blood_donation/features/auth/data/models/auth_model.dart';

// ─── Abstract ─────────────────────────────────────────────────────────────────

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(LoginRequestModel request);
  Future<AuthResponseModel> register(RegisterRequestModel request);
}

// ─── Mock Implementation ──────────────────────────────────────────────────────
// Replace the method bodies with real http calls when the API is ready.
// The abstract interface and all callers remain unchanged.

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  const AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<AuthResponseModel> login(LoginRequestModel request) async {
    // TODO: Replace with real API call:
    // final response = await apiClient.post(
    //   ApiEndpoints.login,
    //   body: request.toJson(),
    // );
    // return AuthResponseModel.fromJson(response.data);

    await Future.delayed(const Duration(milliseconds: 800));
    return AuthResponseModel(
      token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'user_001',
      fullName: 'Ahmed Hassan',
      email: request.email,
      bloodType: 'A+',
      role: 'donor',
    );
  }

  @override
  Future<AuthResponseModel> register(RegisterRequestModel request) async {
    // TODO: Replace with real API call:
    // final response = await apiClient.post(
    //   ApiEndpoints.register,
    //   body: request.toJson(),
    // );
    // return AuthResponseModel.fromJson(response.data);

    await Future.delayed(const Duration(milliseconds: 1000));
    return AuthResponseModel(
      token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
      fullName: request.fullName,
      email: request.email,
      bloodType: request.bloodType,
      role: 'donor',
    );
  }
}