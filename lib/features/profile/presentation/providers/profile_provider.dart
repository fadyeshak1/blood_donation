import 'package:blood_donation/core/network/api_client.dart';
import 'package:blood_donation/core/network/api_result.dart';
import 'package:blood_donation/features/donations/data/datasources/donation_remote_datasource.dart';
import 'package:blood_donation/features/profile/data/models/donation_history_model.dart';
import 'package:blood_donation/features/profile/data/models/request_history_model.dart';
import 'package:blood_donation/features/profile/data/models/user_model.dart';
import 'package:blood_donation/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:blood_donation/features/profile/presentation/providers/profile_state.dart';
import 'package:blood_donation/features/requests/data/repositories/requests_repository_impl.dart';
import 'package:flutter/foundation.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository repository;
  RequestsRepository? _requestsRepository;
  ProfileState _state = const ProfileState();

  ProfileProvider(this.repository);

  ProfileState get state => _state;

  void setRequestsRepository(RequestsRepository r) =>
      _requestsRepository = r;

  void _setState(ProfileState s) {
    _state = s;
    notifyListeners();
  }

  /// Loads profile, donation history AND request history from the API.
  /// Request history is always fetched live so statuses stay current.
  Future<void> loadUserProfile(String userId) async {
    _setState(_state.copyWith(status: ProfileStatus.loading));

    // Run all three fetches in parallel for speed
    final results = await Future.wait([
      repository.getUserProfile(userId),
      repository.getDonationHistory(userId),
      repository.getRequestHistory(),   // ← live from GET /api/requests/my
    ]);

    final userResult = results[0] as ApiResult<UserModel>;
    final donationResult =
        results[1] as ApiResult<List<DonationHistoryModel>>;
    final requestResult =
        results[2] as ApiResult<List<RequestHistoryModel>>;

    if (userResult is ApiFailure) {
      _setState(_state.copyWith(
        status: ProfileStatus.error,
        errorMessage: (userResult as ApiFailure).message,
      ));
      return;
    }

    final user = (userResult as ApiSuccess<UserModel>).data;
    final donations = donationResult is ApiSuccess
        ? (donationResult as ApiSuccess<List<DonationHistoryModel>>).data
        : _state.donationHistory;
    final requests = requestResult is ApiSuccess
        ? (requestResult as ApiSuccess<List<RequestHistoryModel>>).data
        : _state.requestHistory;

    _setState(_state.copyWith(
      status: ProfileStatus.success,
      user: user,
      donationHistory: donations,
      requestHistory: requests,   // always the live list from API
    ));
  }

  Future<bool> updateProfile(UserModel updatedUser) async {
    final result = await repository.updateUserProfile(updatedUser);
    switch (result) {
      case ApiSuccess(data: final u):
        _setState(_state.copyWith(user: u, status: ProfileStatus.success));
        return true;
      case ApiFailure(message: final m):
        _setState(_state.copyWith(
            status: ProfileStatus.error, errorMessage: m));
        return false;
    }
  }

  Future<bool> logout() async =>
      (await repository.logout()) is ApiSuccess;

  // ── Donation History ───────────────────────────────────────────────────────

  void addDonationFromApi(DonationHistoryModel donation) {
    _setState(_state.copyWith(
      donationHistory: [donation, ..._state.donationHistory],
    ));
  }

  Future<bool> cancelDonation(String donationId) async {
    try {
      final ds = DonationRemoteDataSourceImpl(const ApiClient());
      await ds.cancelDonation(donationId);

      final updated = _state.donationHistory.map((d) {
        return d.id == donationId ? d.copyWith(status: 'cancelled') : d;
      }).toList();

      _setState(_state.copyWith(donationHistory: updated));
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Request History ────────────────────────────────────────────────────────

  /// Adds a newly created request optimistically so it appears instantly.
  /// The real status will be refreshed from the API on next profile load.
  void addRequest(RequestHistoryModel request) {
    // Only add if not already present (avoid duplicates on refresh)
    final exists = _state.requestHistory.any((r) => r.id == request.id);
    if (!exists) {
      _setState(_state.copyWith(
        requestHistory: [request, ..._state.requestHistory],
      ));
    }
  }

  /// Calls DELETE /api/requests/{id} then removes from list on success.
  Future<bool> deleteRequest(String requestId) async {
    if (_requestsRepository != null) {
      final result =
          await _requestsRepository!.deleteRequest(requestId);
      if (result is ApiFailure) return false;
    }
    _setState(_state.copyWith(
      requestHistory: _state.requestHistory
          .where((r) => r.id != requestId)
          .toList(),
    ));
    return true;
  }

  /// Re-fetches request history from API and updates the list in place.
  /// Call this after any action that might change request status.
  Future<void> refreshRequestHistory() async {
    final result = await repository.getRequestHistory();
    if (result is ApiSuccess) {
      _setState(_state.copyWith(
        requestHistory:
            (result as ApiSuccess<List<RequestHistoryModel>>).data,
      ));
    }
  }
}