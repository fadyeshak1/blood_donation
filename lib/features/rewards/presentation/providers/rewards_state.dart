import 'package:blood_donation/features/rewards/data/models/redemption_history_model.dart';
import 'package:blood_donation/features/rewards/data/models/reward_model.dart';
import 'package:blood_donation/features/rewards/data/models/user_points_model.dart';

enum RewardsStatus { initial, loading, success, error }

class RewardsState {
  final RewardsStatus status;
  final List<RewardModel> rewards;
  final UserPointsModel? userPoints;
  final List<RedemptionHistoryModel> redemptionHistory;
  final String? errorMessage;

  const RewardsState({
    this.status = RewardsStatus.initial,
    this.rewards = const [],
    this.userPoints,
    this.redemptionHistory = const [],
    this.errorMessage,
  });

  RewardsState copyWith({
    RewardsStatus? status,
    List<RewardModel>? rewards,
    UserPointsModel? userPoints,
    List<RedemptionHistoryModel>? redemptionHistory,
    String? errorMessage,
  }) {
    return RewardsState(
      status: status ?? this.status,
      rewards: rewards ?? this.rewards,
      userPoints: userPoints ?? this.userPoints,
      redemptionHistory: redemptionHistory ?? this.redemptionHistory,
      errorMessage: errorMessage,
    );
  }

  bool get isLoading => status == RewardsStatus.loading;
  bool get isError => status == RewardsStatus.error;
  bool get isSuccess => status == RewardsStatus.success;
  bool get hasRewards => rewards.isNotEmpty;
  bool get hasPoints => userPoints != null;
}