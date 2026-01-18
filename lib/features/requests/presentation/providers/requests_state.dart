import 'package:blood_donation/features/requests/data/models/blood_request_model.dart';

enum RequestsStatus { initial, loading, success, error }

class RequestsState {
  final RequestsStatus status;
  final List<BloodRequestModel> requests;
  final String? errorMessage;
  final String selectedBloodType;
  final String selectedUrgency;
  final String searchQuery;

  const RequestsState({
    this.status = RequestsStatus.initial,
    this.requests = const [],
    this.errorMessage,
    this.selectedBloodType = 'All',
    this.selectedUrgency = 'All',
    this.searchQuery = '',
  });

  RequestsState copyWith({
    RequestsStatus? status,
    List<BloodRequestModel>? requests,
    String? errorMessage,
    String? selectedBloodType,
    String? selectedUrgency,
    String? searchQuery,
  }) {
    return RequestsState(
      status: status ?? this.status,
      requests: requests ?? this.requests,
      errorMessage: errorMessage,
      selectedBloodType: selectedBloodType ?? this.selectedBloodType,
      selectedUrgency: selectedUrgency ?? this.selectedUrgency,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  bool get isLoading => status == RequestsStatus.loading;
  bool get isError => status == RequestsStatus.error;
  bool get isSuccess => status == RequestsStatus.success;
  bool get hasRequests => requests.isNotEmpty;
}