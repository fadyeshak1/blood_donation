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

  Future<void> loadUserProfile(String userId) async {
    _setState(_state.copyWith(status: ProfileStatus.loading));
    final userResult = await repository.getUserProfile(userId);
    final historyResult = await repository.getDonationHistory(userId);
    switch (userResult) {
      case ApiSuccess<UserModel>(data: final u):
        switch (historyResult) {
          case ApiSuccess(data: final h):
            _setState(_state.copyWith(
              status: ProfileStatus.success,
              user: u,
              donationHistory: h,
            ));
          case ApiFailure(message: final m):
            _setState(_state.copyWith(
              status: ProfileStatus.error,
              errorMessage: m,
            ));
        }
      case ApiFailure(message: final m):
        _setState(_state.copyWith(
          status: ProfileStatus.error,
          errorMessage: m,
        ));
    }
  }

  Future<bool> updateProfile(UserModel updatedUser) async {
    final result = await repository.updateUserProfile(updatedUser);
    switch (result) {
      case ApiSuccess(data: final u):
        _setState(_state.copyWith(
          user: u,
          status: ProfileStatus.success,
        ));
        return true;
      case ApiFailure(message: final m):
        _setState(_state.copyWith(
          status: ProfileStatus.error,
          errorMessage: m,
        ));
        return false;
    }
  }

  Future<bool> logout() async =>
      (await repository.logout()) is ApiSuccess;

  // ── Donation History ───────────────────────────────────────────────────────

  /// Called after a successful POST /api/donations — stores the entry with
  /// the real DB id so cancelDonation can reference it later.
  void addDonationFromApi(DonationHistoryModel donation) {
    _setState(_state.copyWith(
      donationHistory: [donation, ..._state.donationHistory],
    ));
  }

  /// Calls POST /api/donations/{id}/cancel.
  /// On success, updates the status to 'cancelled' in the UI — the entry
  /// stays visible in Donation History (not removed).
  /// Returns true on success, false on failure.
  Future<bool> cancelDonation(String donationId) async {
    try {
      final ds = DonationRemoteDataSourceImpl(const ApiClient());
      await ds.cancelDonation(donationId);

      // Update status in the local list — keep the entry visible
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

  void addRequest(RequestHistoryModel request) {
    _setState(_state.copyWith(
      requestHistory: [request, ..._state.requestHistory],
    ));
  }

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
}