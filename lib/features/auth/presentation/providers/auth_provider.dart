import 'package:blood_donation/core/network/api_result.dart';
import 'package:blood_donation/core/services/token_storage.dart';
import 'package:blood_donation/features/auth/data/models/auth_model.dart';
import 'package:blood_donation/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:blood_donation/features/auth/presentation/providers/auth_state.dart';
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository repository;
  AuthState _state = const AuthState();

  AuthProvider(this.repository);

  AuthState get state => _state;

  void _setState(AuthState s) {
    _state = s;
    notifyListeners();
  }

  void clearError() {
    _setState(_state.copyWith(
      status: AuthStatus.idle,
      errorMessage: null,
    ));
  }

  /// Checks SharedPreferences on app start. If a token exists, the user
  /// stays logged in without re-entering credentials.
  Future<bool> checkLoginStatus() async {
    return TokenStorage.instance.hasToken();
  }

  Future<bool> login(LoginRequestModel request) async {
    _setState(_state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
    ));

    final result = await repository.login(request);

    switch (result) {
      case ApiSuccess(data: final data):
        _setState(_state.copyWith(
          status: AuthStatus.success,
          authResponse: data,
        ));
        return true;
      case ApiFailure(message: final msg):
        _setState(_state.copyWith(
          status: AuthStatus.error,
          errorMessage: msg,
        ));
        return false;
    }
  }

  Future<bool> register(RegisterRequestModel request) async {
    _setState(_state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
    ));

    final result = await repository.register(request);

    switch (result) {
      case ApiSuccess(data: final data):
        _setState(_state.copyWith(
          status: AuthStatus.success,
          authResponse: data,
        ));
        return true;
      case ApiFailure(message: final msg):
        _setState(_state.copyWith(
          status: AuthStatus.error,
          errorMessage: msg,
        ));
        return false;
    }
  }

  Future<void> logout() async {
    await repository.logout();
    _setState(const AuthState());
  }
}