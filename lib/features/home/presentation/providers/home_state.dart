import 'package:blood_donation/features/home/data/models/dashboard_stats_model.dart';
import 'package:blood_donation/features/home/data/models/urgent_request_model.dart';

enum HomeStatus { initial, loading, success, error }

class HomeState {
  final HomeStatus status;
  final DashboardStatsModel? stats;
  final List<UrgentRequestModel> urgentRequests;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.stats,
    this.urgentRequests = const [],
    this.errorMessage,
  });

  HomeState copyWith({
    HomeStatus? status,
    DashboardStatsModel? stats,
    List<UrgentRequestModel>? urgentRequests,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
      urgentRequests: urgentRequests ?? this.urgentRequests,
      errorMessage: errorMessage,
    );
  }

  bool get isLoading => status == HomeStatus.loading;
  bool get isError => status == HomeStatus.error;
  bool get isSuccess => status == HomeStatus.success;
  bool get hasStats => stats != null;
}