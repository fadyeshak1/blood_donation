import 'package:blood_donation/core/network/api_client.dart';
import 'package:blood_donation/core/network/api_endpoints.dart';
import 'package:blood_donation/core/network/api_result.dart';
import 'package:blood_donation/features/home/data/repositories/home_repository_impl.dart';
import 'package:blood_donation/features/home/presentation/providers/home_state.dart';
import 'package:flutter/foundation.dart';

class HomeProvider extends ChangeNotifier {
  final HomeRepository repository;
  HomeState _state = const HomeState();

  HomeProvider(this.repository);

  HomeState get state => _state;

  void _setState(HomeState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> loadDashboard(String userId) async {
    _setState(_state.copyWith(status: HomeStatus.loading));

    final statsResult    = await repository.getDashboardStats(userId);
    final requestsResult = await repository.getUrgentRequests(userId);

    switch (statsResult) {
      case ApiSuccess(data: final statsData):
        switch (requestsResult) {
          case ApiSuccess(data: final requestsData):
            _setState(_state.copyWith(
              status: HomeStatus.success,
              stats: statsData,
              urgentRequests: requestsData,
            ));
          case ApiFailure(message: final errorMsg):
            _setState(_state.copyWith(
              status: HomeStatus.error,
              errorMessage: errorMsg,
            ));
        }
      case ApiFailure(message: final errorMsg):
        _setState(_state.copyWith(
          status: HomeStatus.error,
          errorMessage: errorMsg,
        ));
    }
  }

  /// Saves the user's chosen location to the backend profile (single source
  /// of truth), then refreshes the urgent requests list.
  ///
  /// Returns true on success, false on failure.
  Future<bool> updateUserLocation({
    required double latitude,
    required double longitude,
    required String address,
    required String currentFullName,
    required String currentPhone,
    required int currentAge,
    required int currentGender,
  }) async {
    try {
      // Save coordinates + address directly to the backend profile.
      // This is the ONLY place we persist location — no local storage.
      final response = await const ApiClient().put(
        ApiEndpoints.profile,
        body: {
          'fullName':    currentFullName,
          'phoneNumber': currentPhone,
          'address':     address,
          'age':         currentAge,
          'gender':      currentGender,
          'latitude':    latitude,
          'longitude':   longitude,
        },
      );

      if (response.statusCode != 200) return false;
    } catch (_) {
      return false;
    }

    // Refresh urgent requests — backend now has the coordinates and will
    // return matched requests for the new location.
    final requestsResult = await repository.getUrgentRequests('');
    if (requestsResult is ApiSuccess) {
      _setState(_state.copyWith(
        urgentRequests: (requestsResult as ApiSuccess).data,
      ));
    }

    return true;
  }
}