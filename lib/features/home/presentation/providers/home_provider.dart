import 'package:blood_donation/core/network/api_result.dart';
import 'package:blood_donation/features/home/data/repositories/home_repository_impl.dart';
import 'package:blood_donation/features/home/presentation/providers/home_state.dart';
import 'package:flutter/foundation.dart';


class HomeProvider extends ChangeNotifier {
  final HomeRepository repository;
  HomeState _state = const HomeState();

  HomeProvider(this.repository);

  HomeState get state => _state;

  void _setState(HomeState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> loadDashboard(String userId) async {
    _setState(_state.copyWith(status: HomeStatus.loading));

    final statsResult = await repository.getDashboardStats(userId);
    final requestsResult = await repository.getUrgentRequests(userId);

    switch (statsResult) {
      case ApiSuccess(data: final statsData):
        switch (requestsResult) {
          case ApiSuccess(data: final requestsData):
            _setState(_state.copyWith(
              status: HomeStatus.success,
              stats: statsData,
              urgentRequests: requestsData,
            ));
          case ApiFailure(message: final errorMsg):
            _setState(_state.copyWith(
              status: HomeStatus.error,
              errorMessage: errorMsg,
            ));
        }
      case ApiFailure(message: final errorMsg):
        _setState(_state.copyWith(
          status: HomeStatus.error,
          errorMessage: errorMsg,
        ));
    }
  }
}