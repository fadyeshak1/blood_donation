import 'package:blood_donation/core/network/api_result.dart';
import 'package:blood_donation/features/profile/data/models/donation_history_model.dart';
import 'package:blood_donation/features/profile/data/models/request_history_model.dart';
import 'package:blood_donation/features/profile/data/models/user_model.dart';
import 'package:blood_donation/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:blood_donation/features/profile/presentation/providers/profile_state.dart';
import 'package:flutter/foundation.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository repository;
  ProfileState _state = const ProfileState();

  ProfileProvider(this.repository);

  ProfileState get state => _state;

  void _setState(ProfileState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> loadUserProfile(String userId) async {
    _setState(_state.copyWith(status: ProfileStatus.loading));

    final userResult = await repository.getUserProfile(userId);
    final historyResult = await repository.getDonationHistory(userId);

    switch (userResult) {
      case ApiSuccess<UserModel>(data: final userData):
        switch (historyResult) {
          case ApiSuccess(data: final historyData):
            _setState(_state.copyWith(
              status: ProfileStatus.success,
              user: userData,
              donationHistory: historyData,
            ));
          case ApiFailure(message: final errorMsg):
            _setState(_state.copyWith(
              status: ProfileStatus.error,
              errorMessage: errorMsg,
            ));
        }
      case ApiFailure(message: final errorMsg):
        _setState(_state.copyWith(
          status: ProfileStatus.error,
          errorMessage: errorMsg,
        ));
    }
  }

  Future<bool> updateProfile(UserModel updatedUser) async {
    final result = await repository.updateUserProfile(updatedUser);

    switch (result) {
      case ApiSuccess(data: final userData):
        _setState(_state.copyWith(
          user: userData,
          status: ProfileStatus.success,
        ));
        return true;
      case ApiFailure(message: final errorMsg):
        _setState(_state.copyWith(
          status: ProfileStatus.error,
          errorMessage: errorMsg,
        ));
        return false;
    }
  }

  Future<bool> logout() async {
    final result = await repository.logout();
    return result is ApiSuccess;
  }

  // ── Donation History ─────────────────────────────────────────────────────────

  /// Called by RequestsProvider.acceptRequest() and donation_cta_card
  /// after the user donates. Prepends a pending entry to donationHistory.
  void addPendingDonation({
    required String hospitalName,
    String location = '',
  }) {
    final entry = DonationHistoryModel(
      id: 'don_${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      hospitalName: hospitalName,
      location: location,
      unitsQuantity: 1,
      pointsEarned: 0,
      certificateUrl: '',
      status: 'pending',
    );
    _setState(_state.copyWith(
      donationHistory: [entry, ..._state.donationHistory],
    ));
  }

  /// Called when the user taps Delete on a donation card.
  void deleteDonation(String donationId) {
    final updated =
        _state.donationHistory.where((d) => d.id != donationId).toList();
    _setState(_state.copyWith(donationHistory: updated));
  }

  // ── Request History ──────────────────────────────────────────────────────────

  /// Called by RequestsProvider.createRequest() after a request is created.
  /// Prepends it to requestHistory immediately.
  void addRequest(RequestHistoryModel request) {
    _setState(_state.copyWith(
      requestHistory: [request, ..._state.requestHistory],
    ));
  }

  /// Called when the user taps Delete on a request card.
  void deleteRequest(String requestId) {
    final updated =
        _state.requestHistory.where((r) => r.id != requestId).toList();
    _setState(_state.copyWith(requestHistory: updated));
  }
}