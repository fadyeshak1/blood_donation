import 'package:blood_donation/core/network/api_result.dart';
import 'package:blood_donation/features/profile/data/models/donation_history_model.dart';
import 'package:blood_donation/features/profile/data/models/request_history_model.dart';
import 'package:blood_donation/features/profile/presentation/providers/profile_provider.dart';
import 'package:blood_donation/features/requests/data/models/blood_request_model.dart';
import 'package:blood_donation/features/requests/data/models/create_request_model.dart';
import 'package:blood_donation/features/requests/data/repositories/requests_repository_impl.dart';
import 'package:blood_donation/features/requests/presentation/providers/requests_state.dart';
import 'package:flutter/foundation.dart';

class RequestsProvider extends ChangeNotifier {
  final RequestsRepository repository;
  ProfileProvider? _profileProvider;

  RequestsState _state = const RequestsState();

  RequestsProvider(this.repository);

  RequestsState get state => _state;

  /// Called by ChangeNotifierProxyProvider in main.dart every time
  /// ProfileProvider updates. Keeps the reference current.
  void setProfileProvider(ProfileProvider profileProvider) {
    _profileProvider = profileProvider;
  }

  void _setState(RequestsState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> loadRequests() async {
    _setState(_state.copyWith(status: RequestsStatus.loading));

    final result = await repository.getRequests(
      bloodType: _state.selectedBloodType,
      urgency: _state.selectedUrgency,
      search: _state.searchQuery,
    );

    switch (result) {
      case ApiSuccess(data: final requestsData):
        _setState(_state.copyWith(
          status: RequestsStatus.success,
          requests: requestsData,
        ));
      case ApiFailure(message: final errorMsg):
        _setState(_state.copyWith(
          status: RequestsStatus.error,
          errorMessage: errorMsg,
        ));
    }
  }

  void updateBloodTypeFilter(String bloodType) {
    _setState(_state.copyWith(selectedBloodType: bloodType));
    loadRequests();
  }

  void updateUrgencyFilter(String urgency) {
    _setState(_state.copyWith(selectedUrgency: urgency));
    loadRequests();
  }

  void updateSearchQuery(String query) {
    _setState(_state.copyWith(searchQuery: query));
    loadRequests();
  }

  /// Accept a blood request. If successful, adds a pending donation
  /// to Profile → Donation History using the request's hospital info.
  Future<bool> acceptRequest(String requestId) async {
    // Find the request before accepting so we have its hospital info
    final request = _state.requests
        .where((r) => r.id == requestId)
        .firstOrNull;

    final result = await repository.acceptRequest(requestId);

    if (result is ApiSuccess) {
      // Add to Donation History in Profile
      if (request != null) {
        _profileProvider?.addPendingDonation(
          hospitalName: request.hospitalName,
          location: request.location,
        );
      }
      await loadRequests();
      return true;
    }
    return false;
  }

  /// Create a blood request. If successful, adds it to Profile → Request History.
  Future<bool> createRequest(CreateRequestModel request) async {
    final result = await repository.createRequest(request);

    if (result is ApiSuccess) {
      // Add to Request History in Profile
      final historyEntry = RequestHistoryModel(
        id: 'req_${DateTime.now().millisecondsSinceEpoch}',
        bloodType: request.bloodType,
        hospitalName: request.hospitalName,
        hospitalLocation: request.hospitalLocation,
        bloodQuantity: request.bloodQuantity,
        neededByDate: request.neededByDate,
        createdAt: DateTime.now(),
        status: 'pending',
      );
      _profileProvider?.addRequest(historyEntry);

      await loadRequests();
      return true;
    }
    return false;
  }
}