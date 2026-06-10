import 'package:blood_donation/core/network/api_result.dart';
import 'package:blood_donation/features/notifications/data/models/notification_model.dart';
import 'package:blood_donation/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:flutter/foundation.dart';

enum NotificationsStatus { initial, loading, success, error }

class NotificationsState {
  final NotificationsStatus status;
  final List<NotificationModel> notifications;
  final String? errorMessage;

  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.notifications = const [],
    this.errorMessage,
  });

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<NotificationModel>? notifications,
    String? errorMessage,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      errorMessage: errorMessage,
    );
  }

  bool get isLoading => status == NotificationsStatus.loading;
  bool get isError => status == NotificationsStatus.error;
  bool get isEmpty => notifications.isEmpty;
  int get unreadCount => notifications.where((n) => !n.isRead).length;
  bool get hasUnread => unreadCount > 0;
}

class NotificationsProvider extends ChangeNotifier {
  final NotificationsRepository repository;
  NotificationsState _state = const NotificationsState();

  NotificationsProvider(this.repository);

  NotificationsState get state => _state;

  void _setState(NotificationsState s) {
    _state = s;
    notifyListeners();
  }

  Future<void> loadNotifications() async {
    _setState(_state.copyWith(status: NotificationsStatus.loading));

    final result = await repository.getNotifications();

    switch (result) {
      case ApiSuccess(data: final data):
        // Sort: unread first, then by date descending
        final sorted = [...data]
          ..sort((a, b) {
            if (a.isRead != b.isRead) return a.isRead ? 1 : -1;
            return b.createdAt.compareTo(a.createdAt);
          });
        _setState(_state.copyWith(
          status: NotificationsStatus.success,
          notifications: sorted,
        ));
      case ApiFailure(message: final m):
        _setState(_state.copyWith(
          status: NotificationsStatus.error,
          errorMessage: m,
        ));
    }
  }

  /// Marks one notification as read — optimistic UI update + API call.
  Future<void> markAsRead(String id) async {
    // Optimistic update first
    final updated = _state.notifications.map((n) {
      return n.id == id ? n.copyWith(isRead: true) : n;
    }).toList();
    _setState(_state.copyWith(notifications: updated));

    // Fire-and-forget API call (failure is silent — UI already updated)
    await repository.markAsRead(id);
  }

  /// Marks all notifications as read — optimistic UI update + API calls.
  Future<void> markAllAsRead() async {
    final unread =
        _state.notifications.where((n) => !n.isRead).toList();
    if (unread.isEmpty) return;

    // Optimistic update
    final updated =
        _state.notifications.map((n) => n.copyWith(isRead: true)).toList();
    _setState(_state.copyWith(notifications: updated));

    // Fire individual API calls (no bulk endpoint)
    for (final n in unread) {
      await repository.markAsRead(n.id);
    }
  }
}