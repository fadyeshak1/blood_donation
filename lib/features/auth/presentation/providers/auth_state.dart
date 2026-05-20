import 'package:blood_donation/features/auth/data/models/auth_model.dart';

enum AuthStatus { idle, loading, success, error }

class AuthState {
  final AuthStatus status;
  final AuthResponseModel? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.idle,
    this.user,
    this.errorMessage,
  });

  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => user != null && user!.token.isNotEmpty;

  AuthState copyWith({
    AuthStatus? status,
    AuthResponseModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}