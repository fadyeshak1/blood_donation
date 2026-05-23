import 'package:blood_donation/core/network/api_client.dart';
import 'package:blood_donation/core/network/api_endpoints.dart';
import 'package:blood_donation/core/services/token_storage.dart';
import 'package:blood_donation/features/auth/data/models/auth_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(LoginRequestModel request);
  Future<AuthResponseModel> register(RegisterRequestModel request);
  Future<void> logout();
  Future<AuthResponseModel> refreshToken(String refreshToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  const AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<AuthResponseModel> login(LoginRequestModel request) async {
    final response = await apiClient.post(
      ApiEndpoints.login,
      body: request.toJson(),
      requiresAuth: false,
    );

    if (response.statusCode == 200) {
      final data = ApiClient.decode(response) as Map<String, dynamic>;
      final authResponse = AuthResponseModel.fromJson(data);

      // Persist tokens immediately after successful login
      await TokenStorage.instance.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );

      return authResponse;
    }

    throw Exception(ApiClient.errorMessage(response));
  }

  @override
  Future<AuthResponseModel> register(RegisterRequestModel request) async {
    final response = await apiClient.post(
      ApiEndpoints.register,
      body: request.toJson(),
      requiresAuth: false,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = ApiClient.decode(response) as Map<String, dynamic>;
      final authResponse = AuthResponseModel.fromJson(data);

      // Persist tokens immediately after successful registration
      await TokenStorage.instance.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );

      return authResponse;
    }

    throw Exception(ApiClient.errorMessage(response));
  }

  @override
  Future<void> logout() async {
    final refreshToken = await TokenStorage.instance.getRefreshToken();

    if (refreshToken != null) {
      await apiClient.post(
        ApiEndpoints.logout,
        body: {'refreshToken': refreshToken},
      );
    }

    // Always clear local tokens regardless of API response
    await TokenStorage.instance.clearTokens();
  }

  @override
  Future<AuthResponseModel> refreshToken(String refreshToken) async {
    final response = await apiClient.post(
      ApiEndpoints.refreshToken,
      body: {'refreshToken': refreshToken},
      requiresAuth: false,
    );

    if (response.statusCode == 200) {
      final data = ApiClient.decode(response) as Map<String, dynamic>;
      final authResponse = AuthResponseModel.fromJson(data);

      await TokenStorage.instance.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );

      return authResponse;
    }

    throw Exception(ApiClient.errorMessage(response));
  }
}