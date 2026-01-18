import 'package:blood_donation/features/profile/data/models/donation_history_model.dart';
import 'package:blood_donation/features/profile/data/models/user_model.dart';

enum ProfileStatus { initial, loading, success, error }

class ProfileState {
  final ProfileStatus status;
  final UserModel? user;
  final List<DonationHistoryModel> donationHistory;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.user,
    this.donationHistory = const [],
    this.errorMessage,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    UserModel? user,
    List<DonationHistoryModel>? donationHistory,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      donationHistory: donationHistory ?? this.donationHistory,
      errorMessage: errorMessage,
    );
  }

  bool get isLoading => status == ProfileStatus.loading;
  bool get isError => status == ProfileStatus.error;
  bool get isSuccess => status == ProfileStatus.success;
  bool get hasUser => user != null;
}