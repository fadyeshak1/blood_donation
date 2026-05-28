import 'dart:convert';
import 'package:blood_donation/core/network/api_client.dart';
import 'package:blood_donation/core/network/api_endpoints.dart';
import 'package:blood_donation/core/network/api_result.dart';
import 'package:blood_donation/features/donations/data/datasources/donation_remote_datasource.dart';
import 'package:blood_donation/features/donations/data/models/create_donation_model.dart';
import 'package:blood_donation/features/home/data/models/eligibility_result.dart';
import 'package:blood_donation/features/profile/data/models/donation_history_model.dart';
import 'package:blood_donation/features/profile/data/models/request_history_model.dart';
import 'package:blood_donation/features/profile/presentation/providers/profile_provider.dart';
import 'package:blood_donation/features/requests/data/datasources/requests_remote_datasource.dart';
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

  void setProfileProvider(ProfileProvider p) => _profileProvider = p;

  void _setState(RequestsState s) {
    _state = s;
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
      case ApiSuccess(data: final d):
        _setState(_state.copyWith(
            status: RequestsStatus.success, requests: d));
      case ApiFailure(message: final m):
        _setState(_state.copyWith(
            status: RequestsStatus.error, errorMessage: m));
    }
  }

  void updateBloodTypeFilter(String bt) {
    _setState(_state.copyWith(selectedBloodType: bt));
    loadRequests();
  }

  void updateUrgencyFilter(String u) {
    _setState(_state.copyWith(selectedUrgency: u));
    loadRequests();
  }

  void updateSearchQuery(String q) {
    _setState(_state.copyWith(searchQuery: q));
    loadRequests();
  }

  Future<List<HospitalDropdownItem>> getHospitals() async {
    final result = await repository.getHospitals();
    switch (result) {
      case ApiSuccess(data: final h):
        return h;
      case ApiFailure():
        return [];
    }
  }

  Future<bool> createRequest(CreateRequestModel request) async {
    final result = await repository.createRequest(request);
    if (result is ApiSuccess) {
      await _addRequestWithRealId(request);
      await loadRequests();
      return true;
    }
    return false;
  }

  Future<void> _addRequestWithRealId(CreateRequestModel request) async {
    try {
      final response =
          await const ApiClient().get(ApiEndpoints.myRequests);
      if (response.statusCode == 200) {
        final list =
            jsonDecode(utf8.decode(response.bodyBytes)) as List;
        if (list.isNotEmpty) {
          final latest = list.first as Map<String, dynamic>;
          final rawBt = latest['bloodType'] as String? ?? '';
          _profileProvider?.addRequest(RequestHistoryModel(
            id: latest['id'].toString(),
            bloodType: _normaliseBloodType(rawBt),
            hospitalName: latest['hospitalName'] as String? ?? '',
            hospitalLocation:
                latest['hospitalLocation'] as String? ?? '',
            bloodQuantity:
                (latest['quantity'] as num?)?.toInt() ?? 1,
            neededByDate:
                DateTime.tryParse(
                        latest['neededBy'] as String? ?? '') ??
                    request.neededByDate,
            createdAt:
                DateTime.tryParse(
                        latest['createdAt'] as String? ?? '') ??
                    DateTime.now(),
            status: latest['status'] as String? ?? 'Open',
          ));
          return;
        }
      }
    } catch (_) {}

    _profileProvider?.addRequest(RequestHistoryModel(
      id: 'req_${DateTime.now().microsecondsSinceEpoch}',
      bloodType: request.bloodType,
      hospitalName: request.hospitalName,
      hospitalLocation: request.hospitalLocation,
      bloodQuantity: request.bloodQuantity,
      neededByDate: request.neededByDate,
      createdAt: DateTime.now(),
      status: 'Open',
    ));
  }

  /// Accepts a request by creating a donation via POST /api/donations.
  /// Returns the created [DonationHistoryModel] on success (with real DB id
  /// so the screen can navigate to the QR code), or null on failure.
  Future<DonationHistoryModel?> acceptRequest(
    BloodRequestModel bloodRequest,
    EligibilityResult eligibilityResult,
  ) async {
    try {
      final ds = DonationRemoteDataSourceImpl(const ApiClient());
      final created = await ds.createDonation(CreateDonationModel(
        bloodRequestId: int.tryParse(bloodRequest.id),
        hospitalId: eligibilityResult.hospitalId,
        age: eligibilityResult.age,
        weight: eligibilityResult.weight,
        hasTattoo: eligibilityResult.hasTattoo,
        lastDonationDate: eligibilityResult.lastDonationDate,
        medicalCondition: eligibilityResult.medicalCondition,
      ));

      _profileProvider?.addDonationFromApi(created);
      await loadRequests();
      return created;
    } catch (_) {
      return null;
    }
  }

  static String _normaliseBloodType(String raw) {
    const types = [
      'AB+', 'AB-', 'A+', 'A-', 'B+', 'B-', 'O+', 'O-'
    ];
    for (final t in types) {
      if (raw.startsWith(t)) return t;
    }
    return raw;
  }
}