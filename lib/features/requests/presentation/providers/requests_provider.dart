import 'package:blood_donation/core/network/api_result.dart';
import 'package:blood_donation/features/requests/data/models/create_request_model.dart';
import 'package:blood_donation/features/requests/data/repositories/requests_repository_impl.dart';
import 'package:blood_donation/features/requests/presentation/providers/requests_state.dart';
import 'package:flutter/foundation.dart';

class RequestsProvider extends ChangeNotifier {
  final RequestsRepository repository;
  RequestsState _state = const RequestsState();

  RequestsProvider(this.repository);

  RequestsState get state => _state;

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

  Future<bool> acceptRequest(String requestId) async {
    final result = await repository.acceptRequest(requestId);
    
    if (result is ApiSuccess) {
      // Refresh the list after accepting
      await loadRequests();
      return true;
    }
    return false;
  }
  Future<bool> createRequest(CreateRequestModel request) async {
  final result = await repository.createRequest(request);
  
  if (result is ApiSuccess) {
    // Refresh the list after creating
    await loadRequests();
    return true;
  }
  return false;
}
}