import 'package:blood_donation/core/network/api_result.dart';
import 'package:blood_donation/features/auth/data/models/auth_model.dart';
import 'package:blood_donation/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:blood_donation/features/auth/presentation/providers/auth_state.dart';
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository repository;
  AuthState _state = const AuthState();

  AuthProvider(this.repository);

  AuthState get state => _state;

  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  void clearError() {
    _setState(_state.copyWith(
      status: AuthStatus.idle,
      errorMessage: null,
    ));
  }

  /// Called from LoginScreen. Returns true on success.
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
          user: data,
        ));
        // TODO: Save token to SharedPreferences here:
        // await prefs.setString('token', data.token);
        return true;

      case ApiFailure(message: final msg):
        _setState(_state.copyWith(
          status: AuthStatus.error,
          errorMessage: msg,
        ));
        return false;
    }
  }

  /// Called from RegisterScreen. Returns true on success.
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
          user: data,
        ));
        // TODO: Save token to SharedPreferences here:
        // await prefs.setString('token', data.token);
        return true;

      case ApiFailure(message: final msg):
        _setState(_state.copyWith(
          status: AuthStatus.error,
          errorMessage: msg,
        ));
        return false;
    }
  }

  void logout() {
    // TODO: Clear token from SharedPreferences here:
    // await prefs.remove('token');
    _setState(const AuthState());
  }
}