import 'package:blood_donation/features/auth/data/models/auth_model.dart';

enum AuthStatus { idle, loading, success, error }

class AuthState {
  final AuthStatus status;
  final AuthResponseModel? authResponse;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.idle,
    this.authResponse,
    this.errorMessage,
  });

  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated =>
      authResponse != null &&
      authResponse!.accessToken.isNotEmpty;

  String? get userId => authResponse?.user?.id;
  String? get userFullName => authResponse?.user?.fullName;

  AuthState copyWith({
    AuthStatus? status,
    AuthResponseModel? authResponse,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      authResponse: authResponse ?? this.authResponse,
      errorMessage: errorMessage,
    );
  }
}